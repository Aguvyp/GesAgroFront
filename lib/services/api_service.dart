import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';

class ApiService {
  static Future<dynamic> get(String endpoint) async {
    try {
      print('ApiService: GET $endpoint');
      final response = await ApiConfig.get(endpoint);
      print('ApiService: Status code: ${response.statusCode}');
      print('ApiService: Response body: ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      print('ApiService: Error GET $endpoint: $e');
      throw Exception('Error GET $endpoint: $e');
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      print('ApiService: POST $endpoint');
      print('ApiService: Data: ${jsonEncode(data)}');
      final response = await ApiConfig.post(endpoint, body: jsonEncode(data));
      print('ApiService: Status code: ${response.statusCode}');
      print('ApiService: Response headers: ${response.headers}');
      print('ApiService: Response body: ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      print('ApiService: Error POST $endpoint: $e');
      throw Exception('Error POST $endpoint: $e');
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await ApiConfig.put(endpoint, body: jsonEncode(data));
      // print('PUT ' + ApiConfig.baseUrl + endpoint + ' headers=' + AppConstants.headers.toString() + ' body=' + jsonEncode(data));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error PUT $endpoint: $e');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      final response = await ApiConfig.delete(endpoint);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error DELETE $endpoint: $e');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    print('ApiService: Handling response with status ${response.statusCode}');
    
    // Manejar redirecciones
    if (response.statusCode == 307 || response.statusCode == 302) {
      final location = response.headers['location'];
      print('ApiService: Redirect to: $location');
      throw Exception('Redirección detectada a: $location. Verifique la configuración del servidor.');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return jsonDecode(response.body);
    } else {
      print('ApiService: Error response body: ${response.body}');
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  static Future<bool> testConnection() async {
    try {
      await get('/health/');
      return true;
    } catch (e) {
      return false;
    }
  }
}
