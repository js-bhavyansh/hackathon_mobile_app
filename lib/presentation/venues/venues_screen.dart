import 'package:booking_slot_app/bloc/venue/venue_cubit.dart';
import 'package:booking_slot_app/bloc/venue/venue_state.dart';
import 'package:booking_slot_app/common/error_view.dart';
import 'package:booking_slot_app/data/models/venue_model.dart';
import 'package:booking_slot_app/utils/app_routes.dart';
import 'package:booking_slot_app/utils/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class VenuesScreen extends StatefulWidget {
  const VenuesScreen({super.key});

  @override
  State<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends State<VenuesScreen> {
  String _activeFilter = 'all';

  final _filters = [
    ('all', 'All'),
    ('badminton', 'Badminton'),
    ('turf', 'Turf'),
  ];

  @override
  void initState() {
    super.initState();
    context.read<VenueCubit>().loadVenues();
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
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back 👋', style: TextStyle(color: color.secondary, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(
                          "Let's find a slot",
                          style: TextStyle(color: color.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  // Theme toggle button
                  _ThemeToggleButton(),
                  const SizedBox(width: 8),
                  _SignOutButton(),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Filter chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (context2, i2) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final (key, label) = _filters[i];
                  final isActive = _activeFilter == key;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _activeFilter = key);
                      context.read<VenueCubit>().filterVenues(key);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? color.tertiary : color.primaryFixedDim,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isActive ? Colors.white : color.secondary,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Venue grid
            Expanded(
              child: BlocBuilder<VenueCubit, VenueState>(
                builder: (context, state) {
                  if (state is VenueLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is VenueError) {
                    return ErrorView(
                      message: state.message,
                      onRetry: () => context.read<VenueCubit>().loadVenues(),
                    );
                  }
                  if (state is VenueListLoaded) {
                    if (state.venues.isEmpty) {
                      return Center(
                        child: Text('No venues found', style: TextStyle(color: color.secondary)),
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: state.venues.length,
                      // Pass screen-level context to navigation — stable after route pops
                      itemBuilder: (_, i) => _VenueCard(
                        venue: state.venues[i],
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.venueDetailScreen,
                          arguments: state.venues[i],
                        ),
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

// Card for each venue matching the design reference
class _VenueCard extends StatelessWidget {
  final VenueModel venue;
  final VoidCallback onTap;
  const _VenueCard({required this.venue, required this.onTap});

  // Different gradient per sport type
  List<Color> get _gradientColors {
    if (venue.sportType.toLowerCase() == 'turf') {
      return [const Color(0xFF14B8A6), const Color(0xFF06B6D4)];
    }
    return [const Color(0xFF8B5CF6), const Color(0xFF6366F1)];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_gradientColors[0].withValues(alpha: 0.85), _gradientColors[1]],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative circle
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arrow button top-right
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_outward_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  const Spacer(),
                  // Sport type chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      venue.sportType,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    venue.name,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.white70, size: 12),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          venue.location,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
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
    );
  }
}

// Sign out icon button — shows confirmation dialog then signs out
class _SignOutButton extends StatelessWidget {
  Future<void> _confirmSignOut(BuildContext context) async {
    final color = Theme.of(context).colorScheme;
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
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _confirmSignOut(context),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.primaryFixedDim,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.logout_rounded, size: 20, color: color.onSurface),
      ),
    );
  }
}

// Theme toggle icon button — toggles between light/dark using the existing ThemeProvider
class _ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final color = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: themeProvider.toggleTheme,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.primaryFixedDim,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          themeProvider.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          size: 20,
          color: color.onSurface,
        ),
      ),
    );
  }
}
