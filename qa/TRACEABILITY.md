# Requirement Traceability Matrix

`Manual` IDs refer to `TEST_CASES.md`; `Auto` names refer to Java methods under `appium/src/test`. This matrix maps planned verification, not passed results.

| SRS area | Manual | Auto |
| --- | --- | --- |
| Phase 1: splash, validation, Firebase login, persisted auth | TC_LOGIN_001–TC_LOGIN_010, TC_SIGNUP_001–002 | `LoginTest.validLoginOpensHome`, `invalidCredentialsStayOnLogin`, `emptyFieldsShowValidationErrors` |
| Phase 2: live menu, cache, grid, offers, theme | TC_HOME_001–TC_HOME_010, TC_PREF_002 | `HomeTest.scrollsThroughMealGrid`, `addingMealShowsSnackBar` |
| Phase 3: meal details, cart, favourites | TC_HOME_005, TC_DISCOVERY_001–002 | `HomeTest.addingMealShowsSnackBar` |
| Phase 4: cart, checkout, orders | TC_ORDER_001–003 | — |
| Phase 5: vendor map | TC_DEVICE_001 | — |
| Phase 6: profile, biometrics, photo, device info | TC_DEVICE_002 | — |
| Phase 7: English/Arabic localization | TC_HOME_009, TC_PREF_001 | — |
| Phase 8: beta distribution | Test plan entry check; distribution screenshots in `../screenshots/` | — |
| Responsive UI and error handling | TC_LOGIN_001, 007–008, TC_HOME_001, 006–008 | `LoginTest.invalidCredentialsStayOnLogin` |
| QA bonus: plan, cases, execution, defects, closure | `TEST_PLAN.md`, `TEST_CASES.md`, `EXECUTION_LOG.csv`, `TEST_CLOSURE.md` | — |
| Appium bonus: Login and Home flows, physical rerun | TC_LOGIN_002–003, 005, TC_HOME_003–004 | `LoginTest`, `HomeTest` |

Design-pattern and architecture requirements are code review items; they are not asserted by device UI cases. Record their review outcome separately in closure if included in a QA release decision.
