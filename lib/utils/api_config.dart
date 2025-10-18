import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ApiConfig {
  static String _baseUrl = AppConstants.apiBaseUrl;
  static const Duration timeout =
      Duration(seconds: AppConstants.apiTimeoutSeconds);

  static String get baseUrl => _baseUrl;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    // Forzar la URL base para todos los entornos y persistirla
    _baseUrl = AppConstants.apiBaseUrl;
    await prefs.setString('api_base_url', _baseUrl);
  }

  static Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', url);
  }

  static Future<http.Response> get(String endpoint) async {
    try {
      final headers = await _buildHeaders();
      final response = await http
          .get(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
          )
          .timeout(timeout);
      return response;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<http.Response> post(String endpoint,
      {required String body}) async {
    try {
      final headers = await _buildHeaders();
      final response = await http
          .post(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
            body: body,
          )
          .timeout(timeout);
      return response;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<http.Response> put(String endpoint,
      {required String body}) async {
    try {
      final headers = await _buildHeaders();
      final response = await http
          .put(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
            body: body,
          )
          .timeout(timeout);
      return response;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<http.Response> patch(String endpoint, {String? body}) async {
    try {
      final headers = await _buildHeaders();
      final response = await http
          .patch(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
            body: body,
          )
          .timeout(timeout);
      return response;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<http.Response> delete(String endpoint) async {
    try {
      final headers = await _buildHeaders();
      final response = await http
          .delete(
            Uri.parse('$_baseUrl$endpoint'),
            headers: headers,
          )
          .timeout(timeout);
      return response;
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<bool> testConnection() async {
    try {
      final response = await get('/health/');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, String>> _buildHeaders() async {
    final Map<String, String> headers = Map.of(AppConstants.headers);
    // Token fijo para todas las peticiones
    const String fixedToken =
        'aB3xK9mP2qR7sT1vW4yZ6cD8eF0gH5jL3nM9pQ2rS7tU1vX4yA6bC8dE0fG5hI';
    headers['Authorization'] = 'Bearer $fixedToken';
    return headers;
  }
}
