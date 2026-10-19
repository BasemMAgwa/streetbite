// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get tapToContinue => 'اضغط للمتابعة';

  @override
  String get loginTitle => 'الطعام والبقالة\nتصلك إلى بابك';

  @override
  String get loginSubtitle => 'سجّل الدخول للبدء';

  @override
  String get signUpTitle => 'أنشئ حسابك';

  @override
  String get signUpSubtitle => 'انضم إلى StreetBite واكتشف وجبتك القادمة';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get logIn => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get createAccount => 'إنشاء حساب جديد';

  @override
  String get noAccount => 'ليس لديك حساب؟ ';

  @override
  String get haveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get requiredName => 'أدخل اسمك الكامل';

  @override
  String get capitalName => 'ابدأ اسمك بحرف كبير';

  @override
  String get requiredEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get invalidEmail => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get requiredPassword => 'أدخل كلمة المرور';

  @override
  String get shortPassword => 'استخدم 6 أحرف على الأقل';

  @override
  String get requiredConfirmation => 'أكّد كلمة المرور';

  @override
  String get passwordsMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get loginSuccess => 'تم تسجيل دخولك.';

  @override
  String get signUpSuccess => 'حسابك جاهز.';

  @override
  String get signOutSuccess => 'تم تسجيل خروجك.';

  @override
  String get genericError => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get networkError => 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى.';

  @override
  String get invalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get emailInUse => 'هذا البريد الإلكتروني مسجّل بالفعل.';

  @override
  String get weakPassword => 'استخدم كلمة مرور أقوى.';

  @override
  String get blocked => 'محاولات كثيرة جدًا. يرجى المحاولة لاحقًا.';

  @override
  String get accountSaveError => 'تعذّر حفظ حسابك. يرجى المحاولة مرة أخرى.';

  @override
  String get serviceUnavailable => 'الخدمة غير متاحة. يرجى المحاولة مرة أخرى.';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get home => 'الرئيسية';

  @override
  String get vendors => 'البائعون';

  @override
  String get nearbyVendors => 'البائعون القريبون';

  @override
  String get orders => 'الطلبات';

  @override
  String get order => 'طلب';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصر',
      many: '$count عنصرًا',
      few: '$count عناصر',
      two: 'عنصران',
      one: 'عنصر واحد',
      zero: 'لا عناصر',
    );
    return '$_temp0';
  }

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String daysAgo(int count) {
    return 'منذ $count أيام';
  }

  @override
  String get ordersLoadError => 'تعذّر تحميل طلباتك. يرجى المحاولة مرة أخرى.';

  @override
  String get paidStatus => 'مدفوع';

  @override
  String get cashOnDeliveryStatus => 'الدفع عند الاستلام';

  @override
  String get pendingStatus => 'الدفع قيد الانتظار';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get recommended => 'موصى به';

  @override
  String get hotOffers => 'عروض ساخنة';

  @override
  String get liveMenu => 'القائمة المباشرة';

  @override
  String get addToCart => 'أضف إلى السلة';

  @override
  String get removeFromCart => 'أزل من السلة';

  @override
  String get cart => 'السلة';

  @override
  String get favorites => 'المفضلة';

  @override
  String get addToFavorites => 'أضف إلى المفضلة';

  @override
  String get removeFromFavorites => 'أزل من المفضلة';

  @override
  String get addedToFavorites => 'تمت الإضافة إلى المفضلة';

  @override
  String get removedFromFavorites => 'تمت الإزالة من المفضلة';

  @override
  String get favoritesSaveError =>
      'تعذّر تحديث المفضلة. يرجى المحاولة مرة أخرى.';

  @override
  String get category => 'الفئة';

  @override
  String get origin => 'المنشأ';

  @override
  String get instructions => 'طريقة التحضير';

  @override
  String get unknownDetail => 'غير متوفر';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get menuUnavailable =>
      'الوجبات غير متاحة حاليًا. يرجى المحاولة مرة أخرى.';

  @override
  String get showingSavedMeals => 'عرض الوجبات المحفوظة أثناء عدم الاتصال.';

  @override
  String get loadingMeals => 'جارٍ تحميل الوجبات…';

  @override
  String get mealAdded => 'تمت الإضافة إلى السلة';

  @override
  String get emptyCart => 'سلتك فارغة.';

  @override
  String get clearCart => 'إفراغ السلة';

  @override
  String get continueToCheckout => 'متابعة';

  @override
  String get checkout => 'إتمام الطلب';

  @override
  String get back => 'رجوع';

  @override
  String get close => 'إغلاق';

  @override
  String get orderSummary => 'ملخص السعر';

  @override
  String get orderAmount => 'الطلب';

  @override
  String get deliveryFee => 'رسوم التوصيل';

  @override
  String get taxesFee => 'الرسوم والضرائب';

  @override
  String get currentLocation => 'موقعك الحالي';

  @override
  String get findingLocation => 'جارٍ تحديد موقعك…';

  @override
  String get locationUnavailable =>
      'الموقع غير متاح. فعّل الوصول إلى الموقع لعرض موقعك.';

  @override
  String get cartEmptied => 'سلتك فارغة الآن.';

  @override
  String get increaseQuantity => 'زيادة الكمية';

  @override
  String get decreaseQuantity => 'تقليل الكمية';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get cashPayment => 'نقدًا';

  @override
  String get cardPayment => 'بطاقة';

  @override
  String get cashPaymentSubtitle => 'الدفع عند الاستلام';

  @override
  String get cardPaymentSubtitle => 'الدفع قيد الانتظار';

  @override
  String get cardPaymentNote =>
      'سيبقى الدفع بالبطاقة قيد الانتظار إلى حين توفره.';

  @override
  String get total => 'الإجمالي';

  @override
  String get placeOrder => 'تأكيد الطلب';

  @override
  String get orderPlacedCash => 'تم إرسال الطلب. ادفع نقدًا عند الاستلام.';

  @override
  String get orderPlacedPaid => 'تم إرسال الطلب ودفعه بالبطاقة.';

  @override
  String get orderPlacedCardPending =>
      'تم إرسال الطلب. الدفع بالبطاقة قيد الانتظار.';

  @override
  String get orderSaveError => 'تعذّر إرسال طلبك. يرجى المحاولة مرة أخرى.';

  @override
  String get paymentError => 'فشلت عملية الدفع. يرجى تجربة طريقة أخرى.';

  @override
  String get noOrders => 'ستظهر طلباتك هنا.';

  @override
  String get noFavorites => 'ستظهر مفضلتك هنا.';

  @override
  String get hotFlag => 'ساخن';

  @override
  String get biometricReason => 'افتح ملفك الشخصي';

  @override
  String get biometricFailed =>
      'تعذّر التحقق من هويتك. يرجى المحاولة مرة أخرى.';

  @override
  String get biometricUnavailable =>
      'لم يتم إعداد أي بصمة أو وسيلة بيومترية على هذا الجهاز.';

  @override
  String get biometricCancelled => 'تم إلغاء فتح الملف الشخصي.';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get photoUploaded => 'تم تحديث صورتك.';

  @override
  String get photoPickError => 'تعذّر فتح مكتبة الصور. يرجى المحاولة مرة أخرى.';

  @override
  String get photoUploadError => 'تعذّر حفظ صورتك. يرجى المحاولة مرة أخرى.';

  @override
  String get deviceCardTitle => 'الجهاز';

  @override
  String get deviceModelLabel => 'الطراز';

  @override
  String get deviceOsLabel => 'إصدار النظام';

  @override
  String get profileLockOnTooltip => 'قفل الملف الشخصي مفعّل';

  @override
  String get profileLockOffTooltip => 'قفل الملف الشخصي معطّل';

  @override
  String get profileLockEnabled => 'تم تفعيل قفل الملف الشخصي البيومتري.';

  @override
  String get profileLockDisabled => 'تم تعطيل قفل الملف الشخصي البيومتري.';

  @override
  String get language => 'اللغة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get switchLanguage => 'تغيير اللغة';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';
}
