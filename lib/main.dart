import 'package:booking_slot_app/presentation/auth/sign_in_screen.dart';
import 'package:booking_slot_app/presentation/auth/sign_up_screen.dart';
import 'package:booking_slot_app/presentation/home/home_screen.dart';
import 'package:booking_slot_app/presentation/onboard/onboarding_screen.dart';
import 'package:booking_slot_app/presentation/splash_screen.dart';
import 'package:booking_slot_app/presentation/venues/venue_detail_screen.dart';
import 'package:booking_slot_app/utils/app_routes.dart';
import 'package:booking_slot_app/utils/theme/theme.dart';
import 'package:booking_slot_app/utils/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Supabase — used for auth across the app
  await Supabase.initialize(
    url: 'https://awpsolscrfwxxihtkeee.supabase.co',
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF3cHNvbHNjcmZ3eHhpaHRrZWVlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExMDM1MDYsImV4cCI6MjA5NjY3OTUwNn0.2TszJJv72RGFPHA0U8-XoTt8fIdnfPQSZdTlG8wqLYo',
  );

  const storage = FlutterSecureStorage();
  final isDark = await storage.read(key: 'isDarkMode');
  final initialTheme = (isDark == 'true') ? darkMode : lightMode;

  runApp(
    MultiBlocProvider(
      providers: const [],
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(initialTheme),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const SplashScreen(),
      routes: {
        AppRoutes.splashScreen: (_) => const SplashScreen(),
        AppRoutes.onboardingScreen: (_) => const OnboardingScreen(),
        AppRoutes.signInScreen: (_) => const SignInScreen(),
        AppRoutes.signUpScreen: (_) => const SignUpScreen(),
        AppRoutes.homeScreen: (_) => const HomeScreen(),
        AppRoutes.venueDetailScreen: (_) => const VenueDetailScreen(),
      },
    );
  }
}
