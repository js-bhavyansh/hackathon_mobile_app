# QuickSlot — Sports Slot Booking App
# Note: Sorry guys, I was short on time. It's 12:57 AM, and I'm just now pasting the video link here:

https://drive.google.com/file/d/1iJ9PoDh3Oa-Bhm2xdUO4CU9oGtA-TXGk/view?usp=sharing

You can also check when this project was last updated from the repository history.

A Flutter mobile app for booking sports venue slots (badminton courts, turf fields). Built for a hackathon.

## Features

- **Email/Password Auth** — sign up, sign in, sign out with confirmation dialog
- **Venue Listing** — browse venues filtered by sport type (Badminton / Turf / All)
- **Slot Booking** — pick a date, select an open time slot, confirm booking
- **My Bookings** — view upcoming and cancelled bookings, cancel with one tap
- **Past slot greying** — slots before the current hour are automatically disabled
- **Internet detection** — shows a wifi-off screen when offline with retry button
- **Light / Dark mode** — toggle from the header
- **Pull-to-refresh + refresh button** on bookings screen

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x / Dart |
| Auth | Supabase Flutter (email + JWT) |
| State management | flutter_bloc (Cubit pattern) |
| HTTP client | Dio |
| Navigation | Named routes |
| Bottom nav | google_nav_bar (floating pill) |
| Theme | Provider + custom ColorScheme |
| Date/time | intl |
| Animations | Lottie |

## Backend

REST API built with Node.js + Express, backed by Supabase (PostgreSQL).
Live at: `https://hackathon-backend-i8nf.onrender.com`
Repo: [hackathon_backend](https://github.com/js-bhavyansh/hackathon_backend)

## Getting Started

### Prerequisites

- Flutter SDK `^3.10.4`
- Android device / emulator (API 21+)

### Run

```bash
flutter pub get
flutter run
```

### Build release APK

```bash
flutter build apk --release --split-per-abi
# Submit: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

## Environment

The app connects to the live backend and Supabase project — no local setup needed. Supabase credentials are baked into the Flutter client via `supabase_flutter` initialization.

## Project Structure

```
lib/
├── bloc/          # Cubits + states (venue, booking)
├── common/        # Shared widgets (ErrorView)
├── data/
│   ├── models/    # VenueModel, SlotModel, BookingModel
│   └── services/  # VenueService, BookingService (Dio)
├── presentation/
│   ├── auth/      # Sign in / Sign up screens
│   ├── home/      # HomeScreen (bottom nav shell)
│   ├── venues/    # VenuesScreen, VenueDetailScreen
│   └── bookings/  # MyBookingsScreen
└── utils/         # Theme, routes, ApiErrorHandler
```
