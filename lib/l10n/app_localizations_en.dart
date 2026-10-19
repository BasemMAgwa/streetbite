// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tapToContinue => 'Tap to continue';

  @override
  String get loginTitle => 'Food and groceries\ndelivered to you';

  @override
  String get loginSubtitle => 'Log in to get started';

  @override
  String get signUpTitle => 'Create your account';

  @override
  String get signUpSubtitle => 'Join StreetBite and find your next meal';

  @override
  String get fullName => 'Full name';

  @override
  String get email => 'Email address';

  @override
  String get password => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get logIn => 'Log in';

  @override
  String get signUp => 'Sign up';

  @override
  String get createAccount => 'Create an account';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get haveAccount => 'Already have an account? ';

  @override
  String get signOut => 'Sign out';

  @override
  String get requiredName => 'Enter your full name';

  @override
  String get capitalName => 'Start your name with a capital letter';

  @override
  String get requiredEmail => 'Enter your email address';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get requiredPassword => 'Enter your password';

  @override
  String get shortPassword => 'Use at least 6 characters';

  @override
  String get requiredConfirmation => 'Confirm your password';

  @override
  String get passwordsMismatch => 'Passwords do not match';

  @override
  String get loginSuccess => 'You are logged in.';

  @override
  String get signUpSuccess => 'Your account is ready.';

  @override
  String get signOutSuccess => 'You are signed out.';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get networkError => 'Check your internet connection and try again.';

  @override
  String get invalidCredentials => 'Email or password is incorrect.';

  @override
  String get emailInUse => 'This email already has an account.';

  @override
  String get weakPassword => 'Use a stronger password.';

  @override
  String get blocked => 'Too many attempts. Please try again later.';

  @override
  String get accountSaveError =>
      'Could not save your account. Please try again.';

  @override
  String get serviceUnavailable => 'Service is unavailable. Please try again.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get home => 'Home';

  @override
  String get vendors => 'Vendors';

  @override
  String get nearbyVendors => 'Nearby Vendors';

  @override
  String get orders => 'Orders';

  @override
  String get order => 'Order';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '$count item',
    );
    return '$_temp0';
  }

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get ordersLoadError => 'Could not load your orders. Please try again.';

  @override
  String get paidStatus => 'Paid';

  @override
  String get cashOnDeliveryStatus => 'Cash on delivery';

  @override
  String get pendingStatus => 'Payment pending';

  @override
  String get profile => 'Profile';

  @override
  String get recommended => 'Recommended';

  @override
  String get hotOffers => 'Hot Offers';

  @override
  String get liveMenu => 'Live Menu';

  @override
  String get addToCart => 'Add to cart';

  @override
  String get removeFromCart => 'Remove from cart';

  @override
  String get cart => 'Cart';

  @override
  String get favorites => 'Favorites';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get favoritesSaveError =>
      'Could not update favorites. Please try again.';

  @override
  String get category => 'Category';

  @override
  String get origin => 'Origin';

  @override
  String get instructions => 'Instructions';

  @override
  String get unknownDetail => 'Not available';

  @override
  String get lightMode => 'Light mode';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get menuUnavailable =>
      'Meals are unavailable right now. Please try again.';

  @override
  String get showingSavedMeals => 'Showing saved meals while offline.';

  @override
  String get loadingMeals => 'Loading meals…';

  @override
  String get mealAdded => 'Added to cart';

  @override
  String get emptyCart => 'Your cart is empty.';

  @override
  String get clearCart => 'Empty cart';

  @override
  String get continueToCheckout => 'Continue';

  @override
  String get checkout => 'Checkout';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get orderSummary => 'Price summary';

  @override
  String get orderAmount => 'Order';

  @override
  String get deliveryFee => 'Delivery fee';

  @override
  String get taxesFee => 'Fees & taxes';

  @override
  String get currentLocation => 'Your current location';

  @override
  String get findingLocation => 'Finding your location…';

  @override
  String get locationUnavailable =>
      'Location is unavailable. Enable location access to see your position.';

  @override
  String get cartEmptied => 'Your cart is now empty.';

  @override
  String get increaseQuantity => 'Increase quantity';

  @override
  String get decreaseQuantity => 'Decrease quantity';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get cashPayment => 'Cash';

  @override
  String get cardPayment => 'Card';

  @override
  String get cashPaymentSubtitle => 'Pay on delivery';

  @override
  String get cardPaymentSubtitle => 'Payment pending';

  @override
  String get cardPaymentNote =>
      'Card payment will remain pending until payment is available.';

  @override
  String get total => 'Total';

  @override
  String get placeOrder => 'Place order';

  @override
  String get orderPlacedCash => 'Order placed. Pay in cash on delivery.';

  @override
  String get orderPlacedPaid => 'Order placed and paid by card.';

  @override
  String get orderPlacedCardPending => 'Order placed. Card payment is pending.';

  @override
  String get orderSaveError => 'Could not place your order. Please try again.';

  @override
  String get paymentError => 'Payment failed. Please try another method.';

  @override
  String get noOrders => 'Your orders will appear here.';

  @override
  String get noFavorites => 'Your favorites will appear here.';

  @override
  String get hotFlag => 'HOT';

  @override
  String get biometricReason => 'Unlock your profile';

  @override
  String get biometricFailed => 'Could not verify you. Please try again.';

  @override
  String get biometricUnavailable => 'No biometrics are set up on this device.';

  @override
  String get biometricCancelled => 'Profile unlock was cancelled.';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get photoUploaded => 'Your photo has been updated.';

  @override
  String get photoPickError =>
      'Could not open your photo library. Please try again.';

  @override
  String get photoUploadError => 'Could not save your photo. Please try again.';

  @override
  String get deviceCardTitle => 'Device';

  @override
  String get deviceModelLabel => 'Model';

  @override
  String get deviceOsLabel => 'OS version';

  @override
  String get profileLockOnTooltip => 'Profile lock is on';

  @override
  String get profileLockOffTooltip => 'Profile lock is off';

  @override
  String get profileLockEnabled => 'Biometric profile lock enabled.';

  @override
  String get profileLockDisabled => 'Biometric profile lock disabled.';

  @override
  String get language => 'Language';

  @override
  String get settings => 'Settings';

  @override
  String get switchLanguage => 'Switch language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';
}
