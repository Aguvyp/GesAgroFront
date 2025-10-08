import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import 'storage_service.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/login/');
    final response = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode({'email': email, 'password': password}),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final String? token = body['access_token'] as String?;
      final String? role = body['role'] as String?;
      if (token != null) {
        await StorageService.saveToken(token);
      }
      if (role != null) {
        await StorageService.saveRole(role);
      }
      return body;
    }
    throw Exception('Login fallido (${response.statusCode})');
  }

  Future<void> logout() async {
    await StorageService.clearSecureData();
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/auth/register/');
    final response = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    ).timeout(ApiConfig.timeout);

    if (response.statusCode == 201) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return body;
    }
    throw Exception('Registro fallido (${response.statusCode}): ${response.body}');
  }
}


