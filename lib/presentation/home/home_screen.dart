import 'package:booking_slot_app/bloc/booking/booking_cubit.dart';
import 'package:booking_slot_app/bloc/venue/venue_cubit.dart';
import 'package:booking_slot_app/data/services/api/booking_service.dart';
import 'package:booking_slot_app/data/services/api/venue_service.dart';
import 'package:booking_slot_app/presentation/bookings/my_bookings_screen.dart';
import 'package:booking_slot_app/presentation/venues/venues_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

// Bottom nav shell — holds venues and my-bookings tabs with their blocs
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final _pages = const [VenuesScreen(), MyBookingsScreen()];

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => VenueCubit(VenueService())),
        BlocProvider(create: (_) => BookingCubit(BookingService())),
      ],
      child: Scaffold(
        backgroundColor: color.surface,
        // extendBody lets content render behind the floating nav bar
        extendBody: true,
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Container(
            decoration: BoxDecoration(
              color: color.onSurface,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: GNav(
                backgroundColor: color.onSurface,
                color: color.surface,
                activeColor: color.onSurface,
                // solid dark/light pill — no alpha
                tabBackgroundColor: color.surface,
                gap: 8,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                tabBorderRadius: 24,
                duration: const Duration(milliseconds: 250),
                selectedIndex: _selectedIndex,
                onTabChange: (i) => setState(() => _selectedIndex = i),
                tabs: const [
                  GButton(icon: Icons.home_outlined, text: 'Venues'),
                  GButton(icon: Icons.calendar_month_outlined, text: 'My Bookings'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
