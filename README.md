# sportsy-front

Flutter client for Sportsy. The backend lives in [sportsy-back](https://github.com/PrimalTeam/sportsy-back).

## Running against dev or prod

The backend URL is chosen at build time with `--dart-define`:

| Environment | Command | Backend |
|---|---|---|
| dev | `flutter run --dart-define=API_ENV=dev` | `http://localhost:3000` |
| prod | `flutter run --dart-define=API_ENV=prod` | `https://civisafe.online` |

Without `API_ENV`, release builds use prod and debug/profile builds use dev.
To point at any other server, pass `--dart-define=API_BASE_URL=https://example.com`.

VS Code (`.vscode/launch.json`) and Android Studio (`.idea/runConfigurations`) ship with matching **dev** and **prod** launch configurations.

Release build for production:

```sh
flutter build apk --release --dart-define=API_ENV=prod
```

### Dev on an Android emulator or device

`localhost` inside the emulator is the emulator itself, so forward the port to your machine first:

```sh
adb reverse tcp:3000 tcp:3000
```

Plain HTTP is allowed only in debug builds (`android/app/src/debug/AndroidManifest.xml`).
