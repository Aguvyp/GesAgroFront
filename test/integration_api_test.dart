import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  // URL Base del Servidor, tomada de ENDPOINTS_COMPLETOS.md
  const String baseUrl = 'http://200.58.96.143';

  group('API Integration Tests', () {
    final Map<String, String> headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };

    String? authToken; // Variable para almacenar el token de autenticación
    int? testUserId; // Variable para almacenar el ID del usuario de prueba

    Map<String, String> getAuthHeaders() {
      return {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      };
    }

    test('POST /api/auth/login/ - User Login', () async {
      final loginBody = jsonEncode({
        'email': 'epablosacco@yahoo.com.ar', // Usar credenciales válidas
        'password': 'pablo1973',
      });

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login/'),
        headers: headers,
        body: loginBody,
      );

      expect(response.statusCode, 200, reason: 'El login debe devolver 200 OK');
      expect(response.headers['content-type'], contains('application/json'), reason: 'La respuesta debe ser JSON');

      final responseBody = jsonDecode(response.body);
      expect(responseBody, contains('access_token'), reason: 'La respuesta de login debe contener un access_token');
      expect(responseBody['access_token'], isNotEmpty, reason: 'El access_token no debe estar vacío');

      authToken = responseBody['access_token'];
      print('Auth Token: $authToken');
    });

    test('GET /api/usuarios/ - List Users', () async {
      final authHeaders = getAuthHeaders();
      final response = await http.get(Uri.parse('$baseUrl/api/usuarios/'), headers: authHeaders);
      expect(response.statusCode, 200, reason: 'Listar usuarios debe devolver 200 OK');
      expect(response.headers['content-type'], contains('application/json'), reason: 'La respuesta debe ser JSON');
      final List<dynamic> users = jsonDecode(response.body);
      expect(users, isA<List>(), reason: 'La respuesta debe ser una lista de usuarios');
      // Assuming there's at least one user for this test to pass meaningfully
      if (users.isNotEmpty) {
        expect(users[0], containsPair('id', isA<int>()));
        expect(users[0], containsPair('nombre', isA<String>()));
        expect(users[0], containsPair('email', isA<String>()));
      }
    });

    test('GET /api/usuarios/{id} - Get User by ID', () async {
      final authHeaders = getAuthHeaders();
      // First, get a list of users to find an ID
      final listResponse = await http.get(Uri.parse('$baseUrl/api/usuarios/'), headers: authHeaders);
      expect(listResponse.statusCode, 200);
      final List<dynamic> users = jsonDecode(listResponse.body);
      
      // If there are no users, this test cannot proceed meaningfully.
      // For now, we'll assume there is at least one user.
      expect(users, isNotEmpty, reason: 'Debe haber al menos un usuario para obtener por ID');

      final int userId = users[0]['id'];
      final response = await http.get(Uri.parse('$baseUrl/api/usuarios/$userId'), headers: authHeaders);
      expect(response.statusCode, 200, reason: 'Obtener usuario por ID debe devolver 200 OK');
      expect(response.headers['content-type'], contains('application/json'), reason: 'La respuesta debe ser JSON');
      final Map<String, dynamic> user = jsonDecode(response.body);
      expect(user, containsPair('id', userId));
      expect(user, containsPair('nombre', isA<String>()));
      expect(user, containsPair('email', isA<String>()));
    });

    test('POST /api/usuarios/create - Create User', () async {
      final authHeaders = getAuthHeaders();
      final userBody = jsonEncode({
        'nombre': 'Test User',
        'email': 'testuser_${DateTime.now().millisecondsSinceEpoch}@example.com',
        'rol': 'Operario',
        'password': 'testpassword',
      });

      final response = await http.post(
        Uri.parse('$baseUrl/api/usuarios/create'),
        headers: authHeaders,
        body: userBody,
      );

      expect(response.statusCode, 201, reason: 'Crear usuario debe devolver 201 Created');
      expect(response.headers['content-type'], contains('application/json'), reason: 'La respuesta debe ser JSON');

      final responseBody = jsonDecode(response.body);
      expect(responseBody, containsPair('id', isA<int>()));
      expect(responseBody, containsPair('nombre', 'Test User'));
      expect(responseBody, containsPair('email', 'testuser@example.com'));
      testUserId = responseBody['id'];
    });

    test('PUT /api/usuarios/{id}/update - Update User', () async {
      final authHeaders = getAuthHeaders();
      expect(testUserId, isNotNull, reason: 'El ID del usuario de prueba debe estar establecido para actualizar');

      final updateBody = jsonEncode({
        'nombre': 'Updated Test User',
        'email': 'updatedtestuser@example.com',
        'rol': 'Administrador',
        'activo': true,
      });

      final response = await http.put(
        Uri.parse('$baseUrl/api/usuarios/$testUserId/update'),
        headers: authHeaders,
        body: updateBody,
      );

      expect(response.statusCode, 200, reason: 'Actualizar usuario debe devolver 200 OK');
      expect(response.headers['content-type'], contains('application/json'), reason: 'La respuesta debe ser JSON');

      final responseBody = jsonDecode(response.body);
      expect(responseBody, containsPair('id', testUserId));
      expect(responseBody, containsPair('nombre', 'Updated Test User'));
      expect(responseBody, containsPair('email', 'updatedtestuser@example.com'));
      expect(responseBody, containsPair('rol', 'Administrador'));
    });

    test('GET /api/usuarios/{id} (after update) - Verify Updated User', () async {
      final authHeaders = getAuthHeaders();
      expect(testUserId, isNotNull, reason: 'El ID del usuario de prueba debe estar establecido para verificar la actualización');

      final response = await http.get(Uri.parse('$baseUrl/api/usuarios/$testUserId'), headers: authHeaders);
      expect(response.statusCode, 200, reason: 'Obtener usuario actualizado por ID debe devolver 200 OK');
      final Map<String, dynamic> user = jsonDecode(response.body);
      expect(user, containsPair('nombre', 'Updated Test User'));
      expect(user, containsPair('email', 'updatedtestuser@example.com'));
    });

    test('DELETE /api/usuarios/{id}/delete - Delete User', () async {
      final authHeaders = getAuthHeaders();
      expect(testUserId, isNotNull, reason: 'El ID del usuario de prueba debe estar establecido para eliminar');

      final response = await http.delete(
        Uri.parse('$baseUrl/api/usuarios/$testUserId/delete'),
        headers: authHeaders,
      );

      expect(response.statusCode, 200, reason: 'Eliminar usuario debe devolver 200 OK');
      expect(jsonDecode(response.body), containsPair('message', 'Usuario eliminado exitosamente'));
    });

    test('GET /api/usuarios/{id} (after delete) - Verify User Deletion', () async {
      final authHeaders = getAuthHeaders();
      expect(testUserId, isNotNull, reason: 'El ID del usuario de prueba debe estar establecido para verificar la eliminación');

      final response = await http.get(Uri.parse('$baseUrl/api/usuarios/$testUserId'), headers: authHeaders);
      expect(response.statusCode, 404, reason: 'Obtener usuario eliminado por ID debe devolver 404 Not Found');
    });

    test('GET / - Root URL Check', () async {
      final response = await http.get(Uri.parse(baseUrl), headers: headers);
      // We don't know what to expect here, but a 200 would be a good sign.
      // For now, let's just print the status and body to see what we get.
      print('Root URL status code: ${response.statusCode}');
      print('Root URL body: ${response.body}');
      // This test is for diagnosis, so we won't assert anything yet.
      expect(response.statusCode, lessThan(500), reason: 'El servidor no debe devolver un error 5xx en la raíz');
    });

    test('GET /api/health/ - Health Check', () async {
      final response = await http.get(Uri.parse('$baseUrl/api/health/'), headers: headers);
      expect(response.statusCode, 200, reason: 'El endpoint de health check debe devolver 200 OK');
      expect(response.headers['content-type'], contains('application/json'), reason: 'La respuesta debe ser JSON');
    });

    test('GET /api/auth/test/ - Auth Test Connection', () async {
      final response = await http.get(Uri.parse('$baseUrl/api/auth/test/'), headers: headers);
      expect(response.statusCode, 200, reason: 'El endpoint de test de autenticación debe devolver 200 OK');
      expect(response.headers['content-type'], contains('application/json'), reason: 'La respuesta debe ser JSON');
    });
  });
}
