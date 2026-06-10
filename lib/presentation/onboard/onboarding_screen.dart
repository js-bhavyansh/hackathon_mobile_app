import 'package:booking_slot_app/utils/app_routes.dart';
import 'package:flutter/material.dart';

// Onboarding screen — dark background with gradient blobs and CTA arrow button
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: color.surface,
      body: Stack(
        children: [
          // Top-left blob — blue-purple
          Positioned(
            top: -60,
            left: -60,
            child: _GradientBlob(
              size: size.width * 0.75,
              colors: [const Color(0xFF8B5CF6), const Color(0xFF6366F1)],
            ),
          ),
          // Top-right smaller blob — pink
          Positioned(
            top: size.height * 0.1,
            right: -40,
            child: _GradientBlob(
              size: size.width * 0.4,
              colors: [const Color(0xFFEC4899), const Color(0xFFF97316)],
            ),
          ),
          // Bottom-center blob — orange-yellow
          Positioned(
            bottom: -80,
            left: size.width * 0.1,
            child: _GradientBlob(
              size: size.width * 0.7,
              colors: [const Color(0xFFF97316), const Color(0xFFFBBF24)],
            ),
          ),
          // Bottom-right teal blob
          Positioned(
            bottom: size.height * 0.15,
            right: -30,
            child: _GradientBlob(
              size: size.width * 0.35,
              colors: [const Color(0xFF14B8A6), const Color(0xFF06B6D4)],
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 3),
                  Text(
                    'Book your\nsports slot.',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: color.onSurface,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Find and reserve badminton courts\nand turfs near you — instantly.',
                    style: TextStyle(
                      fontSize: 16,
                      color: color.secondary,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Arrow button
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.signInScreen),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: color.onSurface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.onSurface.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: color.surface,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientBlob extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _GradientBlob({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [colors[0].withValues(alpha: 0.55), colors[1].withValues(alpha: 0.3), Colors.transparent],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
    );
  }
}
