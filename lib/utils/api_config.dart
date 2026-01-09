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
    _baseUrl = _normalizeBaseUrl(AppConstants.apiBaseUrl);
    await prefs.setString('api_base_url', _baseUrl);
  }

  static Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', url);
  }

  /// Normaliza un endpoint: asegura que empiece con / y termine con /
  static String _normalizeEndpoint(String endpoint) {
    // Asegurar que empiece con /
    if (!endpoint.startsWith('/')) {
      endpoint = '/$endpoint';
    }
    // Agregar barra final si no existe (todos los endpoints terminan con slash)
    if (!endpoint.endsWith('/') && endpoint != '/') {
      endpoint = '${endpoint}/';
    }
    return endpoint;
  }

  /// Normaliza la URL base: elimina la barra final si existe
  static String _normalizeBaseUrl(String url) {
    url = url.trim();
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

  static Future<http.Response> get(String endpoint) async {
    try {
      final headers = await _buildHeaders();
      final normalizedEndpoint = _normalizeEndpoint(endpoint);
      final normalizedBaseUrl = _normalizeBaseUrl(_baseUrl);
      final response = await http
          .get(
            Uri.parse('$normalizedBaseUrl$normalizedEndpoint'),
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
      final normalizedEndpoint = _normalizeEndpoint(endpoint);
      final normalizedBaseUrl = _normalizeBaseUrl(_baseUrl);
      final response = await http
          .post(
            Uri.parse('$normalizedBaseUrl$normalizedEndpoint'),
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
      final normalizedEndpoint = _normalizeEndpoint(endpoint);
      final normalizedBaseUrl = _normalizeBaseUrl(_baseUrl);
      final response = await http
          .put(
            Uri.parse('$normalizedBaseUrl$normalizedEndpoint'),
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
      final normalizedEndpoint = _normalizeEndpoint(endpoint);
      final normalizedBaseUrl = _normalizeBaseUrl(_baseUrl);
      final response = await http
          .patch(
            Uri.parse('$normalizedBaseUrl$normalizedEndpoint'),
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
      final normalizedEndpoint = _normalizeEndpoint(endpoint);
      final normalizedBaseUrl = _normalizeBaseUrl(_baseUrl);
      final response = await http
          .delete(
            Uri.parse('$normalizedBaseUrl$normalizedEndpoint'),
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
      final response = await get('/api/health/');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, String>> _buildHeaders() async {
    final Map<String, String> headers = {};
    headers['Content-Type'] = 'application/json; charset=utf-8';
    
    // Este es el header CLAVE para saltar la pantalla de ngrok
    headers['ngrok-skip-browser-warning'] = 'true';
    
    // Token fijo para todas las peticiones
    const String fixedToken =
        'aB3xK9mP2qR7sT1vW4yZ6cD8eF0gH5jL3nM9pQ2rS7tU1vX4yA6bC8dE0fG5hI';
    headers['Authorization'] = 'Bearer $fixedToken';
    
    return headers;
  }
}
