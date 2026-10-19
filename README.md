# StreetBite

Flutter food discovery and ordering app. Phase 1 includes a native logo splash,
animated in-app splash, login, sign-up, Firebase Authentication, and user profiles
in the `Users` Firestore collection. Phase 2 adds a live meal menu, featured meals,
Hot Offers, a cart preview, bottom navigation, and a saved light/dark theme.
Phase 3 adds meal details and favourites saved to each user's Firestore document.
Phase 4 adds cart and favourites bottom drawers, checkout, orders saved to each
user's Firestore document, and order history shown live in the Orders tab.

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

Checkout uses Google Maps with a marker at the device's location. The app
requests foreground location permission at startup and uses the last known
position if a fresh fix times out. If location is unavailable, checkout shows a
retry message and remains usable. Set `MAPS_API_KEY=your-key` in ignored
`android/local.properties` and `ios/Flutter/Maps.xcconfig`, enable the Maps SDKs
and billing for that key's Google Cloud project, and restrict production keys
to the app IDs and signing certificates. The iOS map uses SDK 9 for the
project's iOS 15 target.

The menu uses TheMealDB's development API key `1`. It shows saved meals first,
refreshes from the API, and keeps cached meals visible if a refresh fails. Meal
cards, featured banners, and Hot Offers open details. The Vendors tab shows a
Google Map with six sample vendors across Egyptian cities; tapping a marker
shows its name, cuisine, and rating. Favourites are stored under
`Users/{uid}.favorites` and can be opened from the heart icon.

The cart groups repeated meals by quantity, saves them locally per signed-in
user, and restores them at startup. Checkout adds fixed $3.99 delivery and $2.45
taxes/fees to the meal subtotal; saved order totals use the same calculation.
TheMealDB has no prices, so each meal gets a stable
demo price and rating derived from its id. When TheMealDB leaves `strArea` empty
for a known meal, the app uses a country identified by that meal's recipe source.
Other unknown origins remain unfilled. Placing an order saves it to the `orders` map on the user's `Users/{uid}`
document with its items, total, payment method, and payment status, then clears
the cart. Cash orders are marked `dueOnDelivery`. Card is a selection only: no
card details are collected and no charge is attempted; card orders are marked
`pending` until a real payment gateway is integrated. The Orders tab loads this
history live from Firestore and shows each order's items, date, total, and
payment status. Orders written to the older `Users/{uid}/Orders` subcollection by
earlier builds still appear.

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

## Phase 6: profile

The Profile tab is protected by device biometrics. Tapping it calls
`local_auth`; the tab only opens after a successful scan, and failure or
cancellation shows a snackbar while the user stays on the current tab. When the
device has no biometrics enrolled, a snackbar explains and the profile stays
closed. A lock icon in the home top bar toggles the requirement on or off; the
choice is saved in SharedPreferences and remembered across launches, and the
profile then opens without a scan while the lock is off. On Android, biometrics
must be enrolled first (Settings > Security >
Fingerprint); on a connected emulator, simulate a touch with
`adb emu finger touch 1`.

The profile screen shows the account photo, name, email, and the device model
and OS version from `device_info_plus`, detected through
`defaultTargetPlatform`: Android reports manufacturer and model, iOS the
machine name, and Windows the computer name and display version; no runtime
permission is needed on any of them. A gallery photo is picked with
`image_picker` on Android, iOS and macOS (resized to 512 px, compressed to
quality 70). On Android, a failed picker launch retries with the system
document picker; Windows and Linux use `file_selector` directly. The photo is
shown immediately, then stored as base64 in `Users/{uid}.photoBase64` through the
`FirestoreService` singleton, which keeps it inside the Firestore document
limit and under the existing security rules. Android's system photo and document
pickers grant access to the selected file, so no broad media-storage permission
is needed.

The photo is read back on sign-in, and accounts without a photo keep working.

Below the device card, a segmented control switches between the favorites and
orders lists, reusing the favourites and order tiles.

## Checks

Run `flutter analyze` and `flutter test` from this directory. Firebase requests
also require an enabled Auth provider, a Firestore database, deployed rules, and
network access; these are not exercised by the local widget tests. Menu tests use
an in-memory API response and preferences store, so they also run offline.
