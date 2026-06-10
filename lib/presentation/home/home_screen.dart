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
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: color.primaryFixed,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20)],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: GNav(
                backgroundColor: color.primaryFixed,
                color: color.secondary,
                activeColor: color.tertiary,
                tabBackgroundColor: color.tertiary.withValues(alpha: 0.12),
                gap: 8,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
