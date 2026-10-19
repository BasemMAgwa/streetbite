# StreetBite Manual Test Cases

Use the test plan's environment and data setup. Record actual results separately in `EXECUTION_LOG.csv`. Unless stated otherwise, start from a clean install in English with network access.

| ID | Type | Preconditions and steps | Expected result |
| --- | --- | --- | --- |
| TC_LOGIN_001 | GUI | Launch signed-out app; observe splash and Login on a narrow and a standard phone. | Splash fades in; Login image, title, two inputs, password visibility control, and actions fit without clipping. |
| TC_LOGIN_002 | Positive | Enter valid authorized account email/password; tap Log in. | Home opens and shows menu; success feedback appears. |
| TC_LOGIN_003 | Negative | Tap Log in with both fields empty. | Email and password required messages appear; no backend login occurs. |
| TC_LOGIN_004 | Negative | Enter malformed email and any password; tap Log in. | Email format message appears and Home does not open. |
| TC_LOGIN_005 | Negative | Enter valid-format unregistered email and incorrect password; tap Log in. | Friendly invalid-credentials feedback appears and Login remains visible. |
| TC_LOGIN_006 | GUI | Enter password; toggle visibility twice. | Password is revealed and hidden; typed value remains unchanged. |
| TC_LOGIN_007 | General mobile | Focus email, open keyboard, rotate device if supported, then dismiss keyboard. | Form remains usable; submit action is reachable without overflow. |
| TC_LOGIN_008 | General mobile | Turn network off; submit valid-format credentials. | Friendly connection error appears; app remains responsive. |
| TC_LOGIN_009 | Positive | Open Create an account from Login; return using Log in. | Correct Sign Up and Login screens appear; back navigation works. |
| TC_LOGIN_010 | General mobile | Log in, force close app, relaunch. | Authentication persists and Home opens without another login. |
| TC_HOME_001 | GUI | Log in; inspect Home on narrow and standard phones. | Featured banner, Hot Offers, Live Menu, two-column cards, header, and bottom navigation render without clipping. |
| TC_HOME_002 | Positive | With network on, open Home and wait for fetch. | Loading state resolves to meal cards with image, name, category, and add action. |
| TC_HOME_003 | Positive | Scroll Home through Live Menu. | List scrolls; meal cards remain visible and tappable. |
| TC_HOME_004 | Positive | Tap Add to cart on a meal card. | Cart count increases, button changes to Remove from cart, and Added to cart SnackBar appears. |
| TC_HOME_005 | Positive | Tap a meal card outside its cart button. | Meal Details opens for the selected meal with image, name, category, origin, and instructions. |
| TC_HOME_006 | Negative | After a successful fetch, disable network and reopen app. | Saved meals appear with offline notice; app does not crash. |
| TC_HOME_007 | Negative | Clear app data, disable network, open Home after login setup if possible. | Friendly menu error and Try again action appear when neither network nor cache is available. Mark Blocked if login itself cannot be completed offline. |
| TC_HOME_008 | General mobile | Pull to refresh Home after restoring network. | Menu refresh completes; no duplicate cards or stuck loading state. |
| TC_HOME_009 | General mobile | Toggle dark mode and English/Arabic on Home. | Theme and direction update immediately; visible app strings are localized. |
| TC_HOME_010 | GUI | Inspect Hot Offers and featured meals. | Five offers are shown; banner/page transitions and cards remain usable. |
| TC_SIGNUP_001 | Positive | Enter capitalized name, new email, matching password of 6+ characters; submit. | Account is created and Home opens. |
| TC_SIGNUP_002 | Negative | Try lowercase Latin name, malformed email, short password, and mismatch separately. | Each input shows the corresponding validation message; no account is created. |
| TC_DISCOVERY_001 | Positive | Open meal details from Home; add it to cart. | Correct meal details appear; cart count and feedback update. |
| TC_DISCOVERY_002 | Positive | Favourite a meal, open Favourites, relaunch. | Meal persists for the current user and can be removed. |
| TC_ORDER_001 | Positive | Add two meals; open Cart; change quantity and remove one. | Items and total update; empty-cart message appears when last item is removed. |
| TC_ORDER_002 | Positive | Add a meal; proceed to Checkout; select cash; place order. | Order is saved, cart clears, and confirmation appears. |
| TC_ORDER_003 | Positive | Open Orders after placing an order; relaunch. | Order history displays the saved order and remains available. |
| TC_DEVICE_001 | GUI | Open Vendors; inspect at least five markers in different cities; tap one. | Full-screen map appears; marker window shows vendor name, cuisine, and rating. |
| TC_DEVICE_002 | General mobile | Open Profile; enable biometric lock, leave and reopen; test successful and cancelled prompts; select a gallery photo. | Profile shows user/device details; lock controls access; selected photo updates; favourites/orders load. |
| TC_PREF_001 | General mobile | Toggle Arabic on Login and Home; inspect details, cart, orders, map, and profile. | All visible app strings use Arabic and layout follows RTL where applicable. |
| TC_PREF_002 | General mobile | Toggle dark mode, force close, and relaunch. | Dark theme remains selected and controls remain legible. |
| TC_PREF_003 | General mobile | Deny location permission at checkout, then grant it in settings. | Checkout remains usable while denied; map location updates after permission is granted. |
