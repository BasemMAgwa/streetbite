# QA workspace

- `TEST_PLAN.md`: scope, environment, execution, defects, exit criteria.
- `TEST_CASES.md`: manual cases with unique IDs, steps, expected results.
- `EXECUTION_LOG.csv`: actual result, status, evidence, Jira key for each case.
- `TRACEABILITY.md`: SRS requirement mapping.
- `TEST_CLOSURE.md`: physical-device cycle summary and remaining coverage gaps.
- `BUG_TEMPLATE.md`: fields for a confirmed Jira Bug.
- `appium/`: Java/JUnit 5 Appium suite.

## Run Appium tests

1. Build `streetbite/build/app/outputs/flutter-apk/app-release.apk` with `flutter build apk --release`.
2. Connect an Android device with USB debugging and check `adb devices`.
3. Install Appium and UiAutomator2 (`appium driver install uiautomator2`), then start `appium` in a separate terminal.
4. Use an authorized Firebase account. Set `QA_TEST_EMAIL` and `QA_TEST_PASSWORD` in the terminal environment; never commit them. Optionally set `ANDROID_UDID`, `APPIUM_SERVER`, and `STREETBITE_APK`.
5. From `qa/appium`, run `mvn test`. To run only Login tests on the physical device, use `mvn -Dtest=LoginTest test`.

The suite reinstalls the APK for each test and assumes the app starts in English. It grants declared runtime permissions during setup so the location prompt does not cover Login. Valid Login and Home tests are skipped until the account variables are set. Screenshots are written under `qa/appium/target/screenshots/`; copy selected, redacted evidence to the QA record. Maven `target/` and local evidence are ignored by Git. The 2026-10-19 physical-device run passed all five Appium scenarios.

Jira target is project `TC` (the clickable board URL supplied for this cycle). The Bug issue type (`10027`) and priorities Highest through Lowest were verified on 2026-10-19. Only confirmed failed cases should become issues; record the resulting Jira key in the execution log. The Jira API token is never stored here.
