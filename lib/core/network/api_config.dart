import 'package:flutter/foundation.dart';

/// Backend environment, chosen at build time:
///   flutter run --dart-define=API_ENV=dev   -> local backend
///   flutter run --dart-define=API_ENV=prod  -> production backend
/// Without the flag, release builds use prod and everything else uses dev.
/// `--dart-define=API_BASE_URL=...` overrides the URL for either environment.
enum ApiEnv { dev, prod }

const String _devApiUrl = 'http://localhost:3000';
const String _prodApiUrl = 'https://civisafe.online';

const String _envName = String.fromEnvironment('API_ENV');
const String _urlOverride = String.fromEnvironment('API_BASE_URL');

final ApiEnv apiEnv = switch (_envName) {
  'dev' => ApiEnv.dev,
  'prod' => ApiEnv.prod,
  _ => kReleaseMode ? ApiEnv.prod : ApiEnv.dev,
};

final String baseApiUrl = _urlOverride.isNotEmpty
    ? _urlOverride
    : switch (apiEnv) {
        ApiEnv.dev => _devApiUrl,
        ApiEnv.prod => _prodApiUrl,
      };
