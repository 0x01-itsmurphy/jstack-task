# jWallet Lite

A small digital wallet app built for the jStack Flutter assignment. You can log in, check your balance, send money, and browse your transaction history. The app talks to a mock REST API that I wrote in Node.js, which lives in this same repo.

```
jstack/
├── app/        Flutter app
└── backend/    Mock REST API (Node.js + Express)
```

## Demo

- **Video:** [jwallet-lite-demo.mov](https://github.com/0x01-itsmurphy/jstack-task/releases/download/v1.0.0/jwallet-lite-demo.mov) (about 15 MB)
- **APK:** [app-release.apk](https://github.com/0x01-itsmurphy/jstack-task/releases/download/v1.0.0/app-release.apk) (about 53 MB)

Both are also on the [v1.0.0 release page](https://github.com/0x01-itsmurphy/jstack-task/releases/tag/v1.0.0). The APK is built for the Android emulator, so it expects the backend at `10.0.2.2:3000`. To run it on a physical phone, see [Building the APK](#building-the-apk).

## What's in it

- Login with form validation, a show/hide password toggle, and a session that survives app restarts
- Dashboard with the user's name, balance, masked account number, quick actions and the last 5 transactions
- Send Money: form → confirmation → success/failure screen
- Transaction history with search (by reference or name), a Credit/Debit filter, pull-to-refresh and pagination
- Transaction details screen
- Mock API with token auth, validation, an insufficient balance check and idempotent transfers

## Prerequisites

| Tool | Version I used |
|---|---|
| Flutter | 3.47.0 (pinned with [FVM](https://fvm.app) in `app/.fvmrc`) |
| Dart | 3.13.0 |
| Node.js | 22 or newer (I used 25) |
| Android Studio / Xcode | for an emulator or simulator |

If you don't use FVM, any Flutter 3.47.x should work. Just drop the `fvm` prefix from the commands below.

## Running the backend

```bash
cd backend
npm install
cp .env.example .env   # optional, the defaults work fine
npm run dev
```

It starts on port 3000 and prints the URLs to use:

```
Local:            http://localhost:3000/api/v1
Android emulator: http://10.0.2.2:3000/api/v1
Physical device:  http://192.168.x.x:3000/api/v1
```

The data lives in memory, so restarting the server resets the balance and transactions. You can also reset it without restarting:

```bash
curl -X POST http://localhost:3000/api/v1/dev/reset
```

Demo login: **demo@jstack.co / Demo@123**

More details on the endpoints and error codes are in [backend/README.md](backend/README.md). The Postman collection is at `backend/postman/jWallet-Lite.postman_collection.json`.

## Running the app

Start the backend first, then:

```bash
cd app
fvm flutter pub get
fvm flutter run
```

### Pointing the app at the API

The base URL is read at build time from `API_BASE_URL`. The default is `http://10.0.2.2:3000/api/v1`, which is how the Android emulator reaches your computer's localhost, so on an emulator you don't need to pass anything.

For other targets, pass it in:

```bash
# iOS simulator
fvm flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1

# Physical phone (same Wi-Fi as your computer; use the IP the backend prints)
fvm flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/api/v1
```

A few things to check if a physical phone can't connect:

- The phone and the computer need to be on the same Wi-Fi network
- The backend listens on `0.0.0.0` by default, so it accepts connections from the LAN. Don't change `HOST` to `localhost`
- Your firewall may need to allow incoming connections on port 3000

### Building the APK

```bash
cd app
fvm flutter build apk --release --dart-define=API_BASE_URL=http://<your-ip>:3000/api/v1
```

The APK ends up in `app/build/app/outputs/flutter-apk/app-release.apk`. Since the URL is baked in at build time, build it with whatever address the device will actually be able to reach. The release build is signed with the debug key (Flutter's default), which is fine for installing directly on a device.

## Running the tests

```bash
# Flutter (unit, bloc and widget tests)
cd app
fvm flutter test

# Backend
cd backend
npm test
```

The Flutter suite covers the four areas the assignment asks for: login form validation, transfer amount validation, insufficient balance handling, and the state update after a successful transfer. It also tests the blocs, the API client's error mapping, and most screens. There's also a widget test that runs the whole transfer flow through the real router, from the dashboard to the success screen and back. The backend tests cover every endpoint, including idempotent and concurrent duplicate transfers.

## Architecture

The app follows a feature-first clean architecture. Each feature has three layers:

```
lib/
├── core/            shared stuff: network, DI, router, theme, widgets, utils
└── features/
    ├── auth/
    ├── dashboard/
    ├── transfer/
    └── transactions/
        ├── data/          API data sources, JSON models, repository implementations
        ├── domain/        entities and repository interfaces
        └── presentation/  blocs, screens, widgets
```

A request goes like this:

```
Screen → Bloc → Repository (interface) → RepositoryImpl → RemoteDataSource → ApiClient → Dio
```

Some decisions and why I made them:

- **Bloc for state management.** Each screen has one state class with a status enum (loading/loaded/failure and so on), which keeps the loading, error and empty states explicit. Events are sealed classes.
- **No use-case layer.** The assignment suggests use cases, but in this app every one of them would just pass the call through to a repository method. So the blocs depend on the repository interfaces directly. If the business logic grew, adding use cases would be easy.
- **get_it for dependency injection.** Everything is registered in `core/di/injection.dart`. Screen blocs are factories created per screen. `AuthBloc` is a singleton because the router's redirect and the session-expiry handling both need the same instance.
- **Errors never reach the UI as exceptions.** Below the repository, code throws typed `AppException`s. `ApiClient` turns Dio errors and any response with `"success": false` into those exceptions. The repositories catch them and return `Either<Failure, T>` (fpdart), so the blocs only ever deal with `Failure` objects.
- **go_router with an auth redirect.** The router watches `AuthBloc`. The splash screen restores the session from secure storage, then the redirect sends you to the dashboard or the login screen. If any request comes back with a 401, the auth interceptor fires an event, `AuthBloc` logs out, and you land on the login screen with a "session expired" message.
- **The token is stored in flutter_secure_storage**, which is backed by the Keychain on iOS and the Keystore on Android.
- **The transfer screens share one bloc** through a `ShellRoute`, so the form, confirmation and result screens all see the same state.

### Avoiding duplicate transfers

This was the part I cared most about, so it's protected at three levels:

1. The Confirm button is disabled and shows a spinner while the request is in flight, and you can't navigate back mid-request.
2. `TransferBloc` ignores any submit that comes in while one is already running or after it has succeeded.
3. Each transfer gets a UUID `Idempotency-Key`. If the request fails because of the network, Retry sends the **same** key. If the server had actually processed the first request, it returns the original result instead of deducting again. A new key is only generated when the transfer details change or after a successful transfer.

The app never changes the balance itself. After a transfer it shows the balance the backend returned, and the dashboard re-fetches when you come back to it.

### Backend

The backend is plain Express with an in-memory store. Money is stored as integer paise internally to avoid floating point issues, and it's converted to rupees only in the JSON. Every response uses the same shape: `{ success, data }` on success, `{ success: false, error: { code, message } }` on failure. Status codes follow the assignment (400, 401, 404, 409 for insufficient balance, 500).

## Known limitations

- The backend keeps everything in memory, so a restart resets all data. There's one demo user and one wallet.
- The access token is a static mock token. It doesn't expire and there's no refresh flow. Logout only clears the token on the device.
- "Add Money" is UI only, as the assignment says. It just shows a message.
- To reach a local HTTP server, cleartext traffic is allowed on Android (`usesCleartextTraffic`) and App Transport Security is relaxed on iOS. You wouldn't ship that against a real API.
- The base URL is fixed at build time through `--dart-define`. There's no in-app setting to change it.
- There's no offline caching. Without a connection you get an error screen with a retry button.
- The backend supports date-range filtering on transactions (`from` / `to`), but I didn't add it to the app's UI.
- The release APK is signed with the debug key.

## Use of AI tools

I used Claude Code (an AI coding assistant) while building this project. A large part of the code was written with it, including the mock backend, the Flutter features, and some of the tests. I directed the work step by step, and the app's structure follows my own existing Flutter architecture: feature folders, Bloc, get_it, go_router, the `ApiClient` wrapper and the exception-to-failure mapping. I reviewed the code that went in and can explain how all of it works.
