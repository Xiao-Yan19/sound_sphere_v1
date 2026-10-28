class ApiConfig {
  /// 10.0.2.2 is how the Android EMULATOR reaches your PC's localhost.
  ///
  /// On a REAL phone, run with your PC's LAN IP (same Wi-Fi):
  ///   flutter run --dart-define=API_BASE_URL=http://192.168.1.5:5000
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );
}
