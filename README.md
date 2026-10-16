# StreetBite

Flutter food discovery and ordering app. Phase 1 includes a native logo splash,
animated in-app splash, login, sign-up, Firebase Authentication, and user profiles
in the `Users` Firestore collection. Phase 2 adds a live meal menu, featured meals,
Hot Offers, a cart preview, bottom navigation, and a saved light/dark theme.

## Run the app

1. Install Flutter and run `flutter pub get` in this `streetbite` directory.
2. In the Firebase project, enable **Authentication → Email/Password** and create
   a Cloud Firestore database.
3. The project already contains `lib/firebase_options.dart` and the Android
   Firebase configuration. If using another Firebase project, run
   `flutterfire configure` and replace the generated configuration.
4. Deploy the included `firestore.rules` before testing sign-up:
   `firebase deploy --only firestore:rules --project streetbite-324a0`.
   These rules permit each signed-in user to access only `Users/{their uid}`.
5. Run `flutter run` on Android or iOS. The current Firebase options support
   those two platforms.

The menu uses TheMealDB's development API key `1`. It shows saved meals first,
refreshes from the API, and keeps cached meals visible if a refresh fails. Browse
searches the loaded meals by name or category. The Orders and Favorites destinations
are placeholders until their later phases.

The sign-up form stores `id`, `fullName`, and `email` in `Users/{uid}`. A failed
profile write is shown as an error, and the newly created Auth account is rolled
back where Firebase permits. Passwords are managed only by Firebase Auth.

## Structure

- `lib/data`: Firebase and TheMealDB sources, JSON models, and local meal cache.
- `lib/domain`: user and meal entities, repository contracts, and auth use cases.
- `lib/presentation`: auth, menu, cart, and theme state; screens and shared widgets.
- `lib/core`: colors, copy, and validators.
- `lib/injection.dart`: GetIt registrations.

The original `assets/images/logo.svg` is the source for
`assets/images/splash_logo.png`, which `flutter_native_splash.yaml` uses for the
native Android and iOS splash. Regenerate native resources after changing the PNG
with `dart run flutter_native_splash:create`.

## Checks

Run `flutter analyze` and `flutter test` from this directory. Firebase requests
also require an enabled Auth provider, a Firestore database, deployed rules, and
network access; these are not exercised by the local widget tests. Menu tests use
an in-memory API response and preferences store, so they also run offline.
