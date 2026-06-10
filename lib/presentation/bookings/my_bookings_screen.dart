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
            // Header row with title and sign-out
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Bookings',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color.onSurface),
                        ),
                        BlocBuilder<BookingCubit, BookingState>(
                          builder: (context, state) {
                            if (state is BookingListLoaded) {
                              final count = state.bookings.where((b) => b.isConfirmed).length;
                              return Text(
                                '$count upcoming',
                                style: TextStyle(color: color.secondary, fontSize: 13),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                  // Sign out button
                  GestureDetector(
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: color.primaryFixed,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Text('Sign out?', style: TextStyle(color: color.onSurface, fontWeight: FontWeight.bold)),
                          content: Text('You will need to sign in again to book slots.', style: TextStyle(color: color.secondary)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text('Cancel', style: TextStyle(color: color.secondary)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text('Sign out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) Navigator.pushReplacementNamed(context, AppRoutes.signInScreen);
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
            const SizedBox(height: 12),
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
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: color.primaryFixedDim,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.calendar_today_outlined, size: 36, color: color.secondary),
                            ),
                            const SizedBox(height: 16),
                            Text('No bookings yet', style: TextStyle(color: color.onSurface, fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text('Book a slot to see it here', style: TextStyle(color: color.secondary, fontSize: 13)),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => context.read<BookingCubit>().loadMyBookings(),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                        children: [
                          if (active.isNotEmpty) ...[
                            _sectionLabel('Upcoming', color),
                            ...active.map((b) => _BookingCard(booking: b)),
                          ],
                          if (past.isNotEmpty) ...[
                            _sectionLabel('Cancelled', color),
                            ...past.map((b) => _BookingCard(booking: b)),
                          ],
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
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color.secondary, letterSpacing: 1.2),
      ),
    );

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  const _BookingCard({required this.booking});

  // Match venue card gradient colors by sport type
  List<Color> get _sportGradient {
    if (booking.venue?.sportType.toLowerCase() == 'turf') {
      return [const Color(0xFF14B8A6), const Color(0xFF06B6D4)];
    }
    return [const Color(0xFF8B5CF6), const Color(0xFF6366F1)];
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final venue = booking.venue;
    final slot = booking.slot;
    final isTurf = venue?.sportType.toLowerCase() == 'turf';

    String dateDisplay = '';
    if (slot != null && slot.date.isNotEmpty) {
      final d = DateTime.tryParse(slot.date);
      if (d != null) dateDisplay = DateFormat('MMM d, yyyy').format(d);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: color.primaryFixed,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: booking.isConfirmed
              ? _sportGradient[0].withValues(alpha: 0.25)
              : color.primary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top header — gradient tint + sport icon + venue name + status badge
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: booking.isConfirmed
                    ? [_sportGradient[0].withValues(alpha: 0.12), _sportGradient[1].withValues(alpha: 0.04)]
                    : [color.primaryFixedDim, color.primaryFixed],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              children: [
                // Sport icon with gradient background
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: booking.isConfirmed
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _sportGradient,
                          )
                        : null,
                    color: booking.isConfirmed ? null : color.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isTurf ? Icons.sports_soccer_rounded : Icons.sports_tennis_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        venue?.name ?? 'Venue',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        venue?.sportType ?? '',
                        style: TextStyle(color: color.secondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Confirmed / Cancelled badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: booking.isConfirmed
                        ? const Color(0xFF22C55E).withValues(alpha: 0.13)
                        : color.primaryFixedDim,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        booking.isConfirmed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        size: 12,
                        color: booking.isConfirmed ? const Color(0xFF22C55E) : color.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        booking.isConfirmed ? 'Confirmed' : 'Cancelled',
                        style: TextStyle(
                          color: booking.isConfirmed ? const Color(0xFF22C55E) : color.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider line
          Divider(height: 1, color: color.primary.withValues(alpha: 0.12)),

          // Bottom info — time, date chips + location + cancel
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time + date chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (slot != null)
                            _InfoChip(icon: Icons.access_time_rounded, label: slot.formattedTime, color: color),
                          if (dateDisplay.isNotEmpty)
                            _InfoChip(icon: Icons.calendar_today_rounded, label: dateDisplay, color: color),
                        ],
                      ),
                      if (venue?.location != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 13, color: color.secondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                venue!.location,
                                style: TextStyle(color: color.secondary, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (booking.isConfirmed) ...[
                  const SizedBox(width: 12),
                  _CancelButton(bookingId: booking.id),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Small icon + text chip used for time and date info
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.primaryFixedDim,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.secondary),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color.secondary, fontSize: 11, fontWeight: FontWeight.w500)),
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
    return GestureDetector(
      onTap: () => _confirmCancel(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      backgroundColor: color.primaryFixed,
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: color.primary, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 28),
            ),
            const SizedBox(height: 16),
            Text('Cancel booking?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color.onSurface)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text('Keep it', style: TextStyle(color: color.onSurface, fontWeight: FontWeight.w600)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text('Yes, cancel', style: TextStyle(fontWeight: FontWeight.w600)),
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
