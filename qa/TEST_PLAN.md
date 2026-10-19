# StreetBite V1.0 QA Test Plan

## Scope

Test the Android release APK against the functional and non-functional requirements in the root `SRS.md`. The manual cycle covers Splash, Login, Sign Up, Home, Meal Details, Favourites, Cart, Checkout, Vendor Map, Orders, and Profile, plus language, theme, offline menu, persistence, and device behavior. Login and Home have detailed GUI, positive, negative, and general mobile cases in `TEST_CASES.md`. The Appium suite automates the five flows requested by the SRS.

## Test environment and data

- Record APK version/build, commit, Android device model, OS/API level, screen size, locale, network state, and test date in `EXECUTION_LOG.csv` before execution.
- Use a physical Android phone for the required manual cycle and the final Login automation rerun. An emulator can be used for development checks only.
- Use an authorized Firebase account (`QA_TEST_EMAIL`, `QA_TEST_PASSWORD` for automation). This cycle used the existing account at the user's request. Keep its password out of Git and screenshots. Prepare a separate unregistered address for Sign Up tests.
- Enable Firebase Authentication, Firestore, TheMealDB access, Google Maps, and location permission as applicable. Install the same APK for all cases in a cycle.
- Reset app data when a case requires a fresh session; explicitly preserve data for restart/persistence cases. Restore Wi-Fi/mobile data after offline cases.
- Use English as the baseline for text-based Appium selectors; run manual localization checks in Arabic and English.

## Test types and suites

| Suite | Screens | Types | Case IDs |
| --- | --- | --- | --- |
| Login | Splash, Login | GUI, positive, negative, general mobile | TC_LOGIN_001–TC_LOGIN_010 |
| Home | Home, menu | GUI, positive, negative, general mobile | TC_HOME_001–TC_HOME_010 |
| Account | Sign Up | positive, negative | TC_SIGNUP_001–TC_SIGNUP_002 |
| Discovery | Meal Details, Favourites | functional | TC_DISCOVERY_001–TC_DISCOVERY_002 |
| Order | Cart, Checkout, Orders | functional | TC_ORDER_001–TC_ORDER_003 |
| Device | Vendor Map, Profile | functional, permission | TC_DEVICE_001–TC_DEVICE_002 |
| Preferences | Language, theme, authentication persistence | general mobile | TC_PREF_001–TC_PREF_003 |

## Entry criteria

Release APK installs and opens on the selected device; test account and backend are available; Firebase rules are deployed; the tester can access Jira project `TC`; and each case has a recorded expected result.

## Execution and defects

Follow the steps in `TEST_CASES.md`. Record **Pass**, **Fail**, or **Blocked** for every executed case in `EXECUTION_LOG.csv`, with actual result and evidence path. `Not Run` is a planning state only. For each Fail, create a Bug in Jira project `TC` after checking for duplicates. Include case ID, APK/build, device/OS, preconditions, reproduction steps, expected and actual results, severity, priority, and a screenshot. Put the Jira key in the execution log. A blocked case needs the blocking reason and may become a Jira bug only if the product itself caused the block. Severity describes impact; priority describes fixing order.

## Exit criteria

All planned cases have been attempted on a physical device and have Pass/Fail/Blocked status; every failure has a Jira Bug with evidence; no open critical or high-severity defect blocks Login, Home, cart, or ordering; traceability and `TEST_CLOSURE.md` show counts, residual risks, and an explicit release recommendation. Any exception to these criteria must be documented in closure.
