import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @tapToContinue.
  ///
  /// In en, this message translates to:
  /// **'Tap to continue'**
  String get tapToContinue;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Food and groceries\ndelivered to you'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to get started'**
  String get loginSubtitle;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join StreetBite and find your next meal'**
  String get signUpSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccount;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get haveAccount;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @requiredName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get requiredName;

  /// No description provided for @capitalName.
  ///
  /// In en, this message translates to:
  /// **'Start your name with a capital letter'**
  String get capitalName;

  /// No description provided for @requiredEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get requiredEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @requiredPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get requiredPassword;

  /// No description provided for @shortPassword.
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters'**
  String get shortPassword;

  /// No description provided for @requiredConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get requiredConfirmation;

  /// No description provided for @passwordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsMismatch;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'You are logged in.'**
  String get loginSuccess;

  /// No description provided for @signUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account is ready.'**
  String get signUpSuccess;

  /// No description provided for @signOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'You are signed out.'**
  String get signOutSuccess;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get networkError;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get invalidCredentials;

  /// No description provided for @emailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email already has an account.'**
  String get emailInUse;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Use a stronger password.'**
  String get weakPassword;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later.'**
  String get blocked;

  /// No description provided for @accountSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save your account. Please try again.'**
  String get accountSaveError;

  /// No description provided for @serviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Service is unavailable. Please try again.'**
  String get serviceUnavailable;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @vendors.
  ///
  /// In en, this message translates to:
  /// **'Vendors'**
  String get vendors;

  /// No description provided for @nearbyVendors.
  ///
  /// In en, this message translates to:
  /// **'Nearby Vendors'**
  String get nearbyVendors;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} item} other {{count} items}}'**
  String itemCount(int count);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @ordersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your orders. Please try again.'**
  String get ordersLoadError;

  /// No description provided for @paidStatus.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidStatus;

  /// No description provided for @cashOnDeliveryStatus.
  ///
  /// In en, this message translates to:
  /// **'Cash on delivery'**
  String get cashOnDeliveryStatus;

  /// No description provided for @pendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment pending'**
  String get pendingStatus;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @hotOffers.
  ///
  /// In en, this message translates to:
  /// **'Hot Offers'**
  String get hotOffers;

  /// No description provided for @liveMenu.
  ///
  /// In en, this message translates to:
  /// **'Live Menu'**
  String get liveMenu;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @removeFromCart.
  ///
  /// In en, this message translates to:
  /// **'Remove from cart'**
  String get removeFromCart;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @favoritesSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not update favorites. Please try again.'**
  String get favoritesSaveError;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @origin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get origin;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @unknownDetail.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get unknownDetail;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @menuUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Meals are unavailable right now. Please try again.'**
  String get menuUnavailable;

  /// No description provided for @showingSavedMeals.
  ///
  /// In en, this message translates to:
  /// **'Showing saved meals while offline.'**
  String get showingSavedMeals;

  /// No description provided for @loadingMeals.
  ///
  /// In en, this message translates to:
  /// **'Loading meals…'**
  String get loadingMeals;

  /// No description provided for @mealAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get mealAdded;

  /// No description provided for @emptyCart.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty.'**
  String get emptyCart;

  /// No description provided for @clearCart.
  ///
  /// In en, this message translates to:
  /// **'Empty cart'**
  String get clearCart;

  /// No description provided for @continueToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueToCheckout;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Price summary'**
  String get orderSummary;

  /// No description provided for @orderAmount.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orderAmount;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get deliveryFee;

  /// No description provided for @taxesFee.
  ///
  /// In en, this message translates to:
  /// **'Fees & taxes'**
  String get taxesFee;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Your current location'**
  String get currentLocation;

  /// No description provided for @findingLocation.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get findingLocation;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location is unavailable. Enable location access to see your position.'**
  String get locationUnavailable;

  /// No description provided for @cartEmptied.
  ///
  /// In en, this message translates to:
  /// **'Your cart is now empty.'**
  String get cartEmptied;

  /// No description provided for @increaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get increaseQuantity;

  /// No description provided for @decreaseQuantity.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get decreaseQuantity;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @cashPayment.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cashPayment;

  /// No description provided for @cardPayment.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get cardPayment;

  /// No description provided for @cashPaymentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay on delivery'**
  String get cashPaymentSubtitle;

  /// No description provided for @cardPaymentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Payment pending'**
  String get cardPaymentSubtitle;

  /// No description provided for @cardPaymentNote.
  ///
  /// In en, this message translates to:
  /// **'Card payment will remain pending until payment is available.'**
  String get cardPaymentNote;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get placeOrder;

  /// No description provided for @orderPlacedCash.
  ///
  /// In en, this message translates to:
  /// **'Order placed. Pay in cash on delivery.'**
  String get orderPlacedCash;

  /// No description provided for @orderPlacedPaid.
  ///
  /// In en, this message translates to:
  /// **'Order placed and paid by card.'**
  String get orderPlacedPaid;

  /// No description provided for @orderPlacedCardPending.
  ///
  /// In en, this message translates to:
  /// **'Order placed. Card payment is pending.'**
  String get orderPlacedCardPending;

  /// No description provided for @orderSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not place your order. Please try again.'**
  String get orderSaveError;

  /// No description provided for @paymentError.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Please try another method.'**
  String get paymentError;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'Your orders will appear here.'**
  String get noOrders;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'Your favorites will appear here.'**
  String get noFavorites;

  /// No description provided for @hotFlag.
  ///
  /// In en, this message translates to:
  /// **'HOT'**
  String get hotFlag;

  /// No description provided for @biometricReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock your profile'**
  String get biometricReason;

  /// No description provided for @biometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not verify you. Please try again.'**
  String get biometricFailed;

  /// No description provided for @biometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No biometrics are set up on this device.'**
  String get biometricUnavailable;

  /// No description provided for @biometricCancelled.
  ///
  /// In en, this message translates to:
  /// **'Profile unlock was cancelled.'**
  String get biometricCancelled;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get changePhoto;

  /// No description provided for @photoUploaded.
  ///
  /// In en, this message translates to:
  /// **'Your photo has been updated.'**
  String get photoUploaded;

  /// No description provided for @photoPickError.
  ///
  /// In en, this message translates to:
  /// **'Could not open your photo library. Please try again.'**
  String get photoPickError;

  /// No description provided for @photoUploadError.
  ///
  /// In en, this message translates to:
  /// **'Could not save your photo. Please try again.'**
  String get photoUploadError;

  /// No description provided for @deviceCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get deviceCardTitle;

  /// No description provided for @deviceModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get deviceModelLabel;

  /// No description provided for @deviceOsLabel.
  ///
  /// In en, this message translates to:
  /// **'OS version'**
  String get deviceOsLabel;

  /// No description provided for @profileLockOnTooltip.
  ///
  /// In en, this message translates to:
  /// **'Profile lock is on'**
  String get profileLockOnTooltip;

  /// No description provided for @profileLockOffTooltip.
  ///
  /// In en, this message translates to:
  /// **'Profile lock is off'**
  String get profileLockOffTooltip;

  /// No description provided for @profileLockEnabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric profile lock enabled.'**
  String get profileLockEnabled;

  /// No description provided for @profileLockDisabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric profile lock disabled.'**
  String get profileLockDisabled;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @switchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Switch language'**
  String get switchLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
