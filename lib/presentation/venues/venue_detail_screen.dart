import 'package:booking_slot_app/bloc/booking/booking_cubit.dart';
import 'package:booking_slot_app/bloc/booking/booking_state.dart';
import 'package:booking_slot_app/bloc/venue/venue_cubit.dart';
import 'package:booking_slot_app/bloc/venue/venue_state.dart';
import 'package:booking_slot_app/common/error_view.dart';
import 'package:booking_slot_app/data/models/slot_model.dart';
import 'package:booking_slot_app/data/models/venue_model.dart';
import 'package:booking_slot_app/data/services/api/booking_service.dart';
import 'package:booking_slot_app/data/services/api/venue_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Outer shell — provides blocs before the body widget reads them
class VenueDetailScreen extends StatelessWidget {
  const VenueDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final venue = ModalRoute.of(context)!.settings.arguments as VenueModel;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => VenueCubit(VenueService())),
        BlocProvider(create: (_) => BookingCubit(BookingService())),
      ],
      child: _VenueDetailBody(venue: venue),
    );
  }
}

class _VenueDetailBody extends StatefulWidget {
  final VenueModel venue;
  const _VenueDetailBody({required this.venue});

  @override
  State<_VenueDetailBody> createState() => _VenueDetailBodyState();
}

class _VenueDetailBodyState extends State<_VenueDetailBody> {
  DateTime _selectedDate = DateTime.now();
  SlotModel? _selectedSlot;

  String get _formattedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);

  @override
  void initState() {
    super.initState();
    context.read<VenueCubit>().loadSlots(widget.venue.id, _formattedDate);
  }

  void _onDateChanged(int offset) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: offset));
      _selectedSlot = null;
    });
    context.read<VenueCubit>().loadSlots(widget.venue.id, _formattedDate);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingSuccess) {
          setState(() => _selectedSlot = null);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Slot booked successfully! 🎉'), backgroundColor: color.tertiary),
          );
          context.read<VenueCubit>().loadSlots(widget.venue.id, _formattedDate);
        } else if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
          );
        }
      },
      child: Scaffold(
        backgroundColor: color.surface,
        appBar: AppBar(
          backgroundColor: color.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: color.onSurface, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.venue.name,
            style: TextStyle(color: color.onSurface, fontWeight: FontWeight.bold, fontSize: 17),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.tertiary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.venue.sportType,
                style: TextStyle(color: color.tertiary, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.location_on_outlined, color: color.secondary, size: 16),
                  const SizedBox(width: 4),
                  Text(widget.venue.location, style: TextStyle(color: color.secondary, fontSize: 13)),
                ],
              ),
            ),
            _DateSelector(
              selectedDate: _selectedDate,
              onPrev: () => _onDateChanged(-1),
              onNext: () => _onDateChanged(1),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<VenueCubit, VenueState>(
                builder: (context, state) {
                  if (state is VenueLoading) return const Center(child: CircularProgressIndicator());
                  if (state is VenueError) {
                    return ErrorView(
                      message: state.message,
                      onRetry: () => context.read<VenueCubit>().loadSlots(widget.venue.id, _formattedDate),
                    );
                  }
                  if (state is SlotsLoaded) {
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.4,
                      ),
                      itemCount: state.slots.length,
                      itemBuilder: (context, i) {
                        final slot = state.slots[i];
                        final isSelected = _selectedSlot?.id == slot.id;
                        return _SlotTile(
                          slot: slot,
                          isSelected: isSelected,
                          onTap: slot.isAvailable
                              ? () => setState(() => _selectedSlot = isSelected ? null : slot)
                              : null,
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        bottomSheet: _selectedSlot != null
            ? _BookingSheet(slot: _selectedSlot!, venueName: widget.venue.name)
            : null,
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _DateSelector({required this.selectedDate, required this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final canGoPrev = selectedDate.isAfter(DateTime(today.year, today.month, today.day));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left_rounded, color: canGoPrev ? color.onSurface : color.primary),
            onPressed: canGoPrev ? onPrev : null,
          ),
          Expanded(
            child: Center(
              child: Text(
                DateFormat('EEEE, MMM d').format(selectedDate),
                style: TextStyle(color: color.onSurface, fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right_rounded, color: color.onSurface),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  final SlotModel slot;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SlotTile({required this.slot, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final Color bg;
    final Color textColor;

    if (!slot.isAvailable) {
      bg = color.primaryFixedDim;
      textColor = color.secondary.withValues(alpha: 0.5);
    } else if (isSelected) {
      bg = color.tertiary;
      textColor = Colors.white;
    } else {
      bg = color.primaryFixedDim;
      textColor = color.onSurface;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: color.tertiary, width: 2) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          slot.formattedTime,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Bottom sheet shown when a slot is selected
class _BookingSheet extends StatelessWidget {
  final SlotModel slot;
  final String venueName;

  const _BookingSheet({required this.slot, required this.venueName});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        final isLoading = state is BookingLoading;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: BoxDecoration(
            color: color.primaryFixed,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(slot.formattedTime,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color.onSurface)),
                    Text(venueName, style: TextStyle(color: color.secondary, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => context.read<BookingCubit>().bookSlot(slot.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.tertiary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Book Now', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
