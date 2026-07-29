# Auth flows — OTP + Google sign-in (setup & verification)

What changed in this pass, across both repos, and what you must do to run it.

## Fixes applied

**App**
- OTP is now **6 digits** (was 4 — every verify failed against the backend's
  6-digit Twilio codes). Auto-submits when the last digit is entered.
- **Auto OTP detection**:
  - Android — SMS User Consent API (`smart_auth`): a system sheet appears when
    the OTP SMS arrives; one tap fills the boxes and submits. Chosen over SMS
    Retriever because Retriever requires an app-hash inside the SMS, which
    Twilio Verify templates don't carry.
  - iOS — keyboard autofill (`AutofillHints.oneTimeCode`): the code from
    Messages appears above the keyboard; tapping it fills all boxes.
  - Pasting a full code into any box also distributes it.
- Resend timer now syncs to the backend: 30s default, and on a 429 it adopts
  the API's `retryAfterSeconds`.
- **Google sign-in wired end-to-end**: native Google sheet → Supabase
  `signInWithIdToken` → backend `/auth/customer/social/google` → Zook tokens
  stored. Button on the login page; cancellation returns quietly.
- **Checkout phone gate**: Google-signup users (no phone) are routed to a new
  Verify Phone page (`/verify-phone`) before placing an order. It calls the new
  authenticated attach endpoints, so the phone lands on the SAME account.

**Backend**
- 429 responses now include `retryAfterSeconds` (was dropped by the exception
  filter).
- New authenticated endpoints: `POST /auth/customer/phone/send` and
  `POST /auth/customer/phone/verify` — attach + verify a phone on the current
  user. Critical fix: the plain `otp/verify` would have logged the Google user
  into a different phone-keyed account instead of attaching the phone.

## Setup you must do

1. **Backend**: `npm install && npm run build && npm test`, deploy.
2. **App**: `flutter pub get`, then `flutter analyze` (no Flutter SDK in the
   sandbox — neither has been run).
3. **Credentials** live in `.env` at the repo root (gitignored; template in
   `.env.example`). Supabase URL/anon key + Google Web client ID are already
   filled in; `GOOGLE_IOS_CLIENT_ID` is still empty (create the iOS OAuth
   client in Google Cloud, then fill it). Run and build with:

   ```
   flutter run --dart-define-from-file=.env
   flutter build apk --dart-define-from-file=.env
   flutter build ipa --dart-define-from-file=.env
   ```

   Without the flag, Google login is disabled (phone OTP still works). The
   Android client ID isn't referenced in code — Android is authorized by
   package name + SHA-1 registered on that client in Google Cloud.

4. **iOS**: in `ios/Runner/Info.plist`, replace `REVERSED_IOS_CLIENT_ID` with
   the reversed iOS client ID (e.g. `com.googleusercontent.apps.1234-abc`).
5. **Android**: no manifest changes needed (User Consent API and serverClientId
   flow need none), but the **SHA-1** of your signing keys must be registered on
   the Android OAuth client in Google Cloud.
6. **Supabase**: Google provider enabled with the Web client ID/secret; all
   three client IDs (web first) in "Authorized Client IDs"; UAE geo untouched.

## Manual test checklist

- Phone login: send → SMS arrives → Android consent sheet / iOS keyboard chip
  fills the 6 boxes → auto-submits → home.
- Wrong code → error alert; 4-digit entry impossible to submit.
- Resend: disabled 30s; hammering send until 429 → timer adopts the server's
  `retryAfterSeconds`.
- Google (new user): picker → home; profile shows Google name/email; cart →
  checkout → Verify Phone page appears → OTP → order confirmed.
- Google (existing phone user, same email): logs into the SAME account
  (identity linked server-side by verified email).
- Google (returning): straight to home, no phone prompt (phone already
  attached).
- Attach a phone that belongs to another account → 409 "already linked" alert.

## Known limits

- `smart_auth` API surface (v3.x: `SmartAuth.instance.getSmsWithUserConsentApi()`)
  should be confirmed by `flutter analyze` after `pub get` — if the resolved
  version differs, the two call sites are `otp_page.dart` and
  `verify_phone_page.dart`.
- Checkout is still UI-only in the app (no `POST /customers/orders/checkout`
  call yet). The phone gate runs client-side before the confirmed screen; when
  checkout is wired to the API, also handle its 403
  `PHONE_VERIFICATION_REQUIRED` by pushing `/verify-phone` (comment already at
  the call site).
- Apple sign-in button remains inactive (Apple requires it if you ship social
  login on iOS — plan before App Store submission).
