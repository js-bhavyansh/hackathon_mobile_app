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

  List<Color> get _gradientColors {
    if (widget.venue.sportType.toLowerCase() == 'turf') {
      return [const Color(0xFF14B8A6), const Color(0xFF06B6D4)];
    }
    return [const Color(0xFF8B5CF6), const Color(0xFF6366F1)];
  }

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

  bool _isSlotPast(SlotModel slot) {
    final now = DateTime.now();
    final isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
    if (!isToday) return false;
    final hour = int.parse(slot.startTime.split(':')[0]);
    return now.hour >= hour;
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isTurf = widget.venue.sportType.toLowerCase() == 'turf';

    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (state is BookingSuccess) {
          setState(() => _selectedSlot = null);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Slot booked successfully! 🎉'),
              backgroundColor: color.tertiary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            ),
          );
          context.read<VenueCubit>().loadSlots(widget.venue.id, _formattedDate);
        } else if (state is BookingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: color.surface,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // ── Hero header with gradient ──────────────────────────────
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_gradientColors[0].withValues(alpha: 0.9), _gradientColors[1]],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  // Content
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isTurf ? Icons.sports_soccer_rounded : Icons.sports_tennis_rounded,
                                color: Colors.white,
                                size: 13,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                widget.venue.sportType,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.venue.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.venue.location,
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Date selector ──────────────────────────────────────────
            _DateSelector(
              selectedDate: _selectedDate,
              onPrev: () => _onDateChanged(-1),
              onNext: () => _onDateChanged(1),
              gradientColors: _gradientColors,
            ),

            const SizedBox(height: 16),

            // ── Section label ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'AVAILABLE SLOTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color.secondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Slot grid ──────────────────────────────────────────────
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
                    if (state.slots.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: color.primaryFixedDim,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.event_busy_rounded, size: 30, color: color.secondary),
                            ),
                            const SizedBox(height: 12),
                            Text('No slots available', style: TextStyle(color: color.onSurface, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('Try a different date', style: TextStyle(color: color.secondary, fontSize: 13)),
                          ],
                        ),
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.55,
                      ),
                      itemCount: state.slots.length,
                      itemBuilder: (context, i) {
                        final slot = state.slots[i];
                        final isSelected = _selectedSlot?.id == slot.id;
                        final isPast = _isSlotPast(slot);
                        return _SlotTile(
                          slot: slot,
                          isSelected: isSelected,
                          isPast: isPast,
                          gradientColors: _gradientColors,
                          onTap: slot.isAvailable && !isPast
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
            ? _BookingSheet(slot: _selectedSlot!, venueName: widget.venue.name, gradientColors: _gradientColors)
            : null,
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final List<Color> gradientColors;

  const _DateSelector({
    required this.selectedDate,
    required this.onPrev,
    required this.onNext,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final selectedMidnight = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final canGoPrev = selectedMidnight.isAfter(todayMidnight);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.primaryFixed,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.primary.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            _NavButton(
              icon: Icons.chevron_left_rounded,
              enabled: canGoPrev,
              onTap: canGoPrev ? onPrev : null,
              color: color,
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    DateFormat('EEEE').format(selectedDate),
                    style: TextStyle(color: color.secondary, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM d, yyyy').format(selectedDate),
                    style: TextStyle(color: color.onSurface, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
            _NavButton(
              icon: Icons.chevron_right_rounded,
              enabled: true,
              onTap: onNext,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;
  final ColorScheme color;

  const _NavButton({required this.icon, required this.enabled, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: enabled ? color.primaryFixedDim : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: enabled ? color.onSurface : color.primary, size: 22),
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  final SlotModel slot;
  final bool isSelected;
  final bool isPast;
  final VoidCallback? onTap;
  final List<Color> gradientColors;

  const _SlotTile({
    required this.slot,
    required this.isSelected,
    required this.isPast,
    required this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final unavailable = !slot.isAvailable || isPast;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                )
              : null,
          color: isSelected ? null : color.primaryFixed,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : unavailable
                    ? color.primary.withValues(alpha: 0.1)
                    : color.primary.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: gradientColors[0].withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              slot.startTime.substring(0, 5),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : unavailable
                        ? color.secondary.withValues(alpha: 0.4)
                        : color.onSurface,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : unavailable
                        ? color.primaryFixedDim
                        : gradientColors[0].withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                unavailable ? (isPast ? 'Past' : 'Booked') : 'Open',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : unavailable
                          ? color.secondary.withValues(alpha: 0.4)
                          : gradientColors[0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom sheet shown when a slot is selected
class _BookingSheet extends StatelessWidget {
  final SlotModel slot;
  final String venueName;
  final List<Color> gradientColors;

  const _BookingSheet({required this.slot, required this.venueName, required this.gradientColors});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return BlocBuilder<BookingCubit, BookingState>(
      builder: (context, state) {
        final isLoading = state is BookingLoading;
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          decoration: BoxDecoration(
            color: color.primaryFixed,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, -4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: color.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  // Slot icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.schedule_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slot.formattedTime,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: color.onSurface),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          venueName,
                          style: TextStyle(color: color.secondary, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => context.read<BookingCubit>().bookSlot(slot.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gradientColors[0],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Book Now', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
