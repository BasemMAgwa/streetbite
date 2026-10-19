import 'package:streetbite/l10n/app_localizations.dart';

import 'base_automation.dart';

/// Cart gestures used across drawer and checkout widget tests.
class CartAutomation extends BaseTest {
  CartAutomation(super.tester);

  Future<void> increaseQuantity(AppLocalizations l10n) =>
      tapTooltip(l10n.increaseQuantity);

  Future<void> decreaseQuantity(AppLocalizations l10n) =>
      tapTooltip(l10n.decreaseQuantity);

  Future<void> continueToCheckout(AppLocalizations l10n) =>
      tapText(l10n.continueToCheckout);
}
