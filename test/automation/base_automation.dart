import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:streetbite/app.dart';

/// Shared widget-test setup and gestures used by feature automation helpers.
abstract class BaseTest {
  BaseTest(this.tester);

  final WidgetTester tester;

  static void resetPreferences() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  }

  Future<void> launchSignedInApp() async {
    await tester.pumpWidget(const StreetBiteApp());
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();
  }

  Future<void> tapText(String label, {bool last = false}) async {
    final target = find.text(label);
    await tester.tap(last ? target.last : target);
    await tester.pumpAndSettle();
  }

  Future<void> tapTooltip(String label) async {
    await tester.tap(find.byTooltip(label));
    await tester.pumpAndSettle();
  }
}
