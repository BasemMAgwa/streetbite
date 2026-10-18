# StreetBite

Flutter food discovery and ordering app. Phase 1 includes a native logo splash,
animated in-app splash, login, sign-up, Firebase Authentication, and user profiles
in the `Users` Firestore collection. Phase 2 adds a live meal menu, featured meals,
Hot Offers, a cart preview, bottom navigation, and a saved light/dark theme.
Phase 3 adds meal details and favourites saved to each user's Firestore document.
Phase 4 adds the cart, cash or simulated card payment, and orders saved to Firestore.

## Run the app

1. Install Flutter and run `flutter pub get` in this `streetbite` directory.
2. In the Firebase project, enable **Authentication → Email/Password** and create
   a Cloud Firestore database.
3. The project already contains `lib/firebase_options.dart` and the Android
   Firebase configuration. If using another Firebase project, run
   `flutterfire configure` and replace the generated configuration.
4. Deploy the included `firestore.rules` before testing sign-up:
   `firebase deploy --only firestore:rules --project streetbite-324a0`.
   These rules permit each signed-in user to access only `Users/{their uid}`
   and to create and read orders under `Users/{their uid}/Orders`.
5. Run `flutter run` on Android or iOS. The current Firebase options support
   those two platforms.

The menu uses TheMealDB's development API key `1`. It shows saved meals first,
refreshes from the API, and keeps cached meals visible if a refresh fails. Browse
searches the loaded meals by name or category. Meal cards, featured banners, and
Hot Offers open details. Favourites are stored under `Users/{uid}.favorites` and
can be opened from the heart icon.

The cart groups repeated meals by quantity and updates the total as items are
added, decreased, or removed. TheMealDB has no prices, so each meal gets a stable
demo price and rating derived from its id. When TheMealDB leaves `strArea` empty
for a known meal, the app uses a country identified by that meal's recipe source.
Other unknown origins remain unfilled. Placing an order saves it to
`Users/{uid}/Orders/{orderId}` with its items, total, payment method, and payment
status, then clears the cart. Cash orders are marked `dueOnDelivery`. Card payment
is simulated: no card details are collected and nothing is charged. The Orders tab
stays a placeholder until order history is loaded in Phase 6.

The sign-up form stores `id`, `fullName`, and `email` in `Users/{uid}`. A failed
profile write is shown as an error, and the newly created Auth account is rolled
back where Firebase permits. Passwords are managed only by Firebase Auth.

## Structure

- `lib/data`: Firebase and TheMealDB sources, JSON models, and local meal cache.
- `lib/domain`: user and meal entities, repository contracts, and auth use cases.
- `lib/presentation`: auth, menu, cart, favourites, and theme state; screens and shared widgets.
- `lib/core`: colors, copy, and validators.
- `lib/injection.dart`: GetIt registrations.

The original `assets/images/logo.svg` is the source for
`assets/images/splash_logo.png`, which `flutter_native_splash.yaml` uses for the
native Android and iOS splash. Regenerate native resources after changing the PNG
with `dart run flutter_native_splash:create`.

The launcher icon is the white logo on the primary green (`#00C874`).
`assets/icon/app_icon.png` is the full icon, and `assets/icon/app_icon_foreground.png`
is the Android adaptive icon foreground. After changing either file, regenerate the
Android and iOS icons with `dart run flutter_launcher_icons`.

## Checks

Run `flutter analyze` and `flutter test` from this directory. Firebase requests
also require an enabled Auth provider, a Firestore database, deployed rules, and
network access; these are not exercised by the local widget tests. Menu tests use
an in-memory API response and preferences store, so they also run offline.
