# EventMate

A Flutter app for discovering events, creating your own gatherings, and keeping track of everything that matters. EventMate combines community-created events with Ticketmaster listings, syncs favourites across devices, and works offline with local caching.

## Features
- Email/password auth with Firebase; user profiles are cached locally for quick startup.
- Home dashboard with calendar highlights, daily schedule, and quick actions to browse, manage events, and open favourites.
- Event management: create, edit, and delete your own events (Firestore-backed) with local sqflite cache for offline viewing.
- Browse tab: community events plus Ticketmaster integration with search, rich cards, and deep links to buy tickets.
- Favourites: save community or Ticketmaster events; items are synced to Firestore and stored locally for offline access.
- Profile: view/edit profile details, access settings/info screens, and logout anywhere.

## Tech Stack
- Flutter (Material 3), GetX for state/navigation
- Firebase Core, Auth, Cloud Firestore
- Local persistence: sqflite + path
- Networking & utilities: http, url_launcher, intl, calendar_date_picker2

## Project Structure (high level)
- `lib/main.dart` – app entry, routing, theme, controller bootstrapping
- `lib/features/auth` – login/registration, splash, auth controller
- `lib/features/home` – dashboard with calendar and quick actions
- `lib/features/events` – community event CRUD, Firestore + local cache
- `lib/features/browse` – Ticketmaster search + community feed
- `lib/features/favourites` – favourites controller/UI + local DB
- `lib/features/profile` – profile view/edit and menu screens
- `lib/core` – colors, reusable widgets, and local database helpers

## Setup
1) Prerequisites: Flutter 3.10+; Android/iOS tooling; Firebase CLI (recommended for `flutterfire configure`).
2) Install dependencies:  
   `flutter pub get`
3) Firebase configuration:  
   - Create a Firebase project and enable Email/Password Auth and Cloud Firestore.  
   - Run `flutterfire configure` (or manually supply platform configs) to generate/update `lib/firebase_options.dart`.  
   - Place `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist`, and ensure `google-services` plugins are applied per FlutterFire docs.
4) Ticketmaster API key:  
   Replace `apiKey` in `lib/features/browse/services/ticketmaster_service.dart` with your key.
5) Run the app:  
   `flutter run -d <device>`

## Notes
- Local caches live in a SQLite database (`eventmate.db`) for events and favourites, allowing offline reads; Firestore sync restores connectivity.
- Favourites and user data are mirrored to Firestore for cross-device continuity. If you clear local storage, sync will repopulate after login.
