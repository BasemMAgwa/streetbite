# StreetBite V1.0 Test Closure Summary

**Cycle date:** 2026-10-19  
**Status:** Executed with three failed cases and four documented coverage blocks; full release sign-off is withheld.

| Field | Result |
| --- | --- |
| APK version/build and source commit | 1.0.0 (1); `4f96e01` |
| Physical device | Realme RMX1851, Android 11, 1080×2340 |
| Manual cases planned | 32 |
| Manual Pass / Fail / Blocked / Not Run | **25 / 3 / 4 / 0** |
| Appium physical-device Login | **3 pass / 0 fail / 0 skipped** |
| Appium physical-device Home | **2 pass / 0 fail / 0 skipped** |
| Flutter unit/widget tests | **46 pass** |
| Jira Bugs opened in TC | **2**: [TC-1](https://basem-magdy.atlassian.net/browse/TC-1), [TC-2](https://basem-magdy.atlassian.net/browse/TC-2) |
| Confirmed critical or high defects | **1 high**: Profile lock toggle after sign-out/sign-in |

## What was verified

The installed release APK passed valid, invalid, and empty-field Login automation on the physical phone. Home automation scrolled the Live Menu and asserted the Add to cart SnackBar. Manual testing covered Login validation, network error, persisted authentication, live and offline menu, cart quantity and removal, cash checkout, persisted order history, favorites persistence, vendor markers, English/Arabic screens, dark mode persistence, biometric Profile entry, and location permission recovery. Evidence is linked per case in [`EXECUTION_LOG.csv`](EXECUTION_LOG.csv) and stored in [`screenshots/`](screenshots/). Maven Surefire XML for this run reports 3 Login and 2 Home tests with no failures or skips.

The user chose to test with the existing account. A cash order for one Flan was placed on that account during QA and remains in its order history. Temporary cart and favorite changes were cleared; the original two favorites and Profile lock setting were restored after restarting the app. Wi-Fi and mobile data were restored. The phone's master location switch was already off and remains off; StreetBite location permission was restored. Profile photo was not changed. The app remains signed in.

## Blocks and residual risk

| Cases | Block / remaining coverage |
| --- | --- |
| TC_LOGIN_001, TC_HOME_001 | Standard physical layout passed inspection. A second narrow physical viewport could not be set because the Realme build denies ADB display-size changes. |
| TC_HOME_007 | Empty-cache offline Home is unreachable after data reset because Firebase authentication requires connectivity. Cached offline Home passed TC_HOME_006. |
| TC_SIGNUP_001 | A positive registration would create another account; the user chose the existing account for this cycle. Negative registration validation passed. |

Gallery photo replacement within failed case TC_DEVICE_002 was left unexecuted on the live account. Cash checkout returned to Home, cleared the cart, and produced an order visible after relaunch. The transient confirmation message was not captured in the screenshot, so its exact wording is not evidenced.

## Defects and release recommendation

Three failed cases map to two confirmed Jira Bugs; both have screenshot evidence attached. [TC-1](https://basem-magdy.atlassian.net/browse/TC-1) is High severity and priority: after sign-out/sign-in the Profile lock button says enabled but stays off, Profile opens without a prompt, and logcat records `Cannot emit new states after calling close` in `ProfileLockCubit.toggle`. It affects TC_DEVICE_002. [TC-2](https://basem-magdy.atlassian.net/browse/TC-2) is Medium severity and priority: Arabic Home/Details keep English meal category values; it affects TC_HOME_009 and TC_PREF_001. The four blocked cases are coverage gaps rather than demonstrated product defects.

**Recommendation:** Withhold full V1.0 release sign-off while the High severity Profile lock defect is open. Core Login, menu, cart, and cash-order flows worked on this device, so a limited beta can be considered only with the Profile security issue explicitly accepted. Fix and retest TC-1 and TC-2, then complete the four blocked checks using a second viewport and an account that can be created for QA. The test plan's execution-record and Jira reporting criteria are met; its full-coverage and release-quality goals are not.
