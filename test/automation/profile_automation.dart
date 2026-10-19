import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streetbite/l10n/app_localizations.dart';
import 'package:streetbite/presentation/screens/profile_screen.dart';

import 'base_automation.dart';

/// Profile navigation and segmented-list actions shared by profile tests.
class ProfileAutomation extends BaseTest {
  ProfileAutomation(super.tester);

  Future<void> open(AppLocalizations l10n) => tapText(l10n.profile, last: true);

  Future<void> selectSection(
    ProfileSection section,
    AppLocalizations l10n,
  ) async {
    final label = switch (section) {
      ProfileSection.favorites => l10n.favorites,
      ProfileSection.orders => l10n.orders,
    };
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<ProfileSection>),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }
}
