# English / Arabic localization

## How it works

- **ARB files** at `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb` are the
  single source of truth for all UI strings. Flutter's gen-l10n (enabled via
  `generate: true` + `l10n.yaml`) generates `lib/l10n/gen/app_localizations*`
  on every `flutter pub get` / build.
- **`AppStrings`** kept its old static API (`AppStrings.welcomeBack`) but now
  delegates to the generated bundle — no widget call sites had to change.
  `AppStrings.load(locale)` swaps the active language.
- **`LocaleCubit`** (`lib/core/locale/locale_cubit.dart`) holds + persists the
  choice (`SharedPreferences`, key `app_locale`), rebinds
  `AppStrings`/`AppTextStyles`, and rebuilds `MaterialApp` with the new
  `locale` — text, fonts and layout direction all flip instantly.
- **Fonts**: Manrope for English, **Cairo** for Arabic (Manrope has no Arabic
  glyphs); the brand wordmark stays Montserrat. Both the `AppTextStyles`
  getters and the theme's `textTheme` switch per locale.
- **RTL**: Arabic renders right-to-left automatically. The **phone input** and
  **OTP boxes** are wrapped in forced `Directionality.ltr` — numbers and codes
  always read left-to-right, even in an RTL layout.

## Where the user changes language

- Onboarding: the existing locale page now actually applies + persists the
  selection (index 1 = العربية).
- Profile → **Language** tile reopens the same page (pops back after saving).

## Adding a new string

1. Add the key to BOTH `app_en.arb` and `app_ar.arb`.
2. Run `flutter gen-l10n` (or any build).
3. Use it via `AppLocalizations.of(context)` (preferred for new code) or add a
   delegating getter in `AppStrings` if the screen already uses that pattern.

## What is NOT yet translated

- ~60 hardcoded strings remain in secondary screens (home sections, product
  detail, cart rows, orders, checkout labels…). Find them with:
  `grep -rn "Text('" lib/features --include=*.dart | grep -v AppStrings`
  Migrate them to ARB keys screen by screen — the infrastructure is done.
- RTL directional audit was applied to the core auth/checkout path; sweep the
  remaining screens for `EdgeInsets.only(left:/right:)` → `EdgeInsetsDirectional`,
  `Alignment.centerLeft/Right` → `AlignmentDirectional`, trailing
  `Icons.chevron_right` → flip under RTL.
- **Arabic copy is my draft** — have a native speaker review `app_ar.arb`.
- Catalog content (category/product names) stays English by scope decision;
  see "Backend error codes" below for the API-text strategy.

## Backend error codes — planned design (not yet built)

Today API errors arrive as English `message` strings and are shown verbatim.
The plan, so alerts localize AND the owner/admin can reword them without an
app release:

1. **Backend returns stable codes.** Every thrown exception carries a
   machine-readable `code` (e.g. `OTP_INVALID`, `OTP_RATE_LIMITED`,
   `PHONE_TAKEN`, `PHONE_VERIFICATION_REQUIRED` — the last one already
   exists). Codes never change; wording is presentation.
2. **Admin-editable message catalog.** A small `error_messages` table
   (`code`, `locale`, `message`) + admin CRUD endpoints, so the owner can
   reword any error per language from the admin panel.
3. **API resolves wording server-side**: the exception filter looks up
   (code, `Accept-Language`) in the catalog (cached in Redis), falling back to
   the built-in message. Response keeps BOTH: `code` + localized `message`.
4. **App behavior**: show `message` as received; branch logic ONLY on `code`
   (never string-match wording). ARB fallbacks used when offline/unknown.

This keeps wording editable by non-developers, localized centrally, and the
app forward-compatible. Rough effort: backend table+filter+admin CRUD ~1 day,
app-side just uses what it already shows.

## Verify

`flutter pub get` then `flutter analyze`; run, switch to العربية on the locale
page: whole UI flips RTL with Arabic text/font; phone + OTP fields stay LTR;
choice survives restart; Profile → Language switches back.
