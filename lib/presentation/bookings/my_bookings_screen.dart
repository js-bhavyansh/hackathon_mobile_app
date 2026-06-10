import 'package:booking_slot_app/bloc/booking/booking_cubit.dart';
import 'package:booking_slot_app/bloc/booking/booking_state.dart';
import 'package:booking_slot_app/common/error_view.dart';
import 'package:booking_slot_app/data/models/booking_model.dart';
import 'package:booking_slot_app/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookingCubit>().loadMyBookings();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Bookings',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color.onSurface),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, AppRoutes.signInScreen);
                      }
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color.primaryFixedDim,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.logout_rounded, size: 20, color: color.onSurface),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<BookingCubit, BookingState>(
                builder: (context, state) {
                  if (state is BookingLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is BookingError) {
                    return ErrorView(
                      message: state.message,
                      onRetry: () => context.read<BookingCubit>().loadMyBookings(),
                    );
                  }
                  if (state is BookingListLoaded) {
                    final active = state.bookings.where((b) => b.isConfirmed).toList();
                    final past = state.bookings.where((b) => !b.isConfirmed).toList();

                    if (state.bookings.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 56, color: color.secondary),
                            const SizedBox(height: 12),
                            Text('No bookings yet', style: TextStyle(color: color.secondary, fontSize: 15)),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => context.read<BookingCubit>().loadMyBookings(),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          if (active.isNotEmpty) ...[
                            _sectionLabel('Upcoming', color),
                            ...active.map((b) => _BookingCard(booking: b)),
                          ],
                          if (past.isNotEmpty) ...[
                            _sectionLabel('Cancelled', color),
                            ...past.map((b) => _BookingCard(booking: b)),
                          ],
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _sectionLabel(String text, ColorScheme color) => Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color.secondary)),
    );

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final venue = booking.venue;
    final slot = booking.slot;

    // Parse booked date for display
    final bookedAt = DateTime.tryParse(booking.bookedAt);
    final dateStr = bookedAt != null ? DateFormat('MMM d, yyyy').format(bookedAt) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.primaryFixedDim,
        borderRadius: BorderRadius.circular(16),
        border: booking.isConfirmed
            ? Border.all(color: color.tertiary.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Row(
        children: [
          // Sport icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: booking.isConfirmed
                  ? color.tertiary.withValues(alpha: 0.15)
                  : color.primary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              venue?.sportType.toLowerCase() == 'turf'
                  ? Icons.sports_soccer_rounded
                  : Icons.sports_tennis_rounded,
              color: booking.isConfirmed ? color.tertiary : color.secondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue?.name ?? 'Venue',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color.onSurface),
                ),
                const SizedBox(height: 3),
                Text(
                  slot != null ? '${slot.formattedTime} · ${slot.date}' : dateStr,
                  style: TextStyle(color: color.secondary, fontSize: 12),
                ),
                if (venue?.location != null) ...[
                  const SizedBox(height: 2),
                  Text(venue!.location, style: TextStyle(color: color.secondary, fontSize: 11)),
                ],
              ],
            ),
          ),
          // Status badge or cancel button
          if (booking.isConfirmed)
            _CancelButton(bookingId: booking.id)
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.primary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Cancelled', style: TextStyle(color: color.secondary, fontSize: 11)),
            ),
        ],
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final String bookingId;
  const _CancelButton({required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _confirmCancel(context),
      style: TextButton.styleFrom(
        foregroundColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  void _confirmCancel(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: color.primaryFixed,
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: color.primary, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('Cancel booking?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: color.onSurface)),
            const SizedBox(height: 8),
            Text('This action cannot be undone.', style: TextStyle(color: color.secondary, fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(sheetCtx),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: color.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Keep it', style: TextStyle(color: color.onSurface)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      context.read<BookingCubit>().cancelBooking(bookingId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Yes, cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
