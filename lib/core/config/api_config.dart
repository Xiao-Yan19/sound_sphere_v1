
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sound-sphere-v1-backend.onrender.com',
  );
}
