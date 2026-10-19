import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streetbite/l10n/app_localizations.dart';

import 'base_automation.dart';

/// Auth screen actions stay here so tests assert behavior instead of field order.
class AuthAutomation extends BaseTest {
  AuthAutomation(super.tester);

  Future<void> openSignUp(AppLocalizations l10n) async {
    await tester.ensureVisible(find.text(l10n.createAccount));
    await tapText(l10n.createAccount);
  }

  Future<void> enterSignUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), name);
    await tester.enterText(fields.at(1), email);
    await tester.enterText(fields.at(2), password);
    await tester.enterText(fields.at(3), password);
  }
}
