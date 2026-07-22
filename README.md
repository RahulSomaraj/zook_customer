# Zook — Customer App

UAE's trusted secondhand marketplace (electronics). Flutter app built with a
**feature-first Clean Architecture** and **BLoC** for state management.

## Getting started

```bash
flutter pub get
flutter run
```

## Architecture

Each feature is a self-contained module split into three layers:

```
presentation  → UI (pages, widgets) + BLoC/Cubit
domain        → entities, repository contracts, use cases (pure Dart)
data          → models, data sources (Dio), repository implementations
```

The `core/` directory holds cross-cutting concerns shared by all features:
theme/design tokens, constants, DI (get_it), networking (Dio), error types,
the use-case base class, and reusable widgets.

Navigation uses `go_router`. Dependencies are registered in
`core/di/injection.dart` and resolved via the `sl` service locator.

## Folder structure

```
lib/
├── main.dart                      # bootstrap: DI init + runApp
├── app/
│   ├── app.dart                   # MaterialApp.router, global BlocProviders, theme
│   └── app_router.dart            # go_router config + AppRoute enum
├── core/
│   ├── constants/                 # strings, asset paths, API endpoints
│   ├── di/                        # get_it service locator
│   ├── error/                     # Failures + Exceptions
│   ├── network/                   # Dio client
│   ├── theme/                     # colors, text styles, ThemeData
│   ├── usecases/                  # UseCase<T, Params> base
│   └── widgets/                   # PrimaryButton, SocialButton, inputs
└── features/
    ├── splash/
    │   └── presentation/pages/    # SplashPage (auto-redirect)
    ├── onboarding/
    │   ├── domain/entities/       # OnboardingItem + slide content
    │   └── presentation/          # OnboardingCubit, page, slide, indicator
    └── auth/
        ├── data/                  # AuthUserModel, remote data source, repo impl
        ├── domain/                # AuthUser, AuthRepository, SendOtp / VerifyOtp
        └── presentation/          # AuthBloc, LoginPage, OtpPage, OtpInput
```

## Screens (this milestone)

Splash → Onboarding (3 slides) → Login (phone + social) → OTP verification.
UI matches the provided design mockup (brand color `#FF4500`, Montserrat +
Manrope fonts).

## What's stubbed for later

API calls in `AuthRemoteDataSourceImpl` are mocked with delays — swap in real
Dio requests (endpoints already declared in `core/constants/api_constants.dart`).
The repository → use case → BLoC wiring is complete, so only the data source
needs real HTTP. A `home` feature/route and persisted auth/session are the
natural next steps.
