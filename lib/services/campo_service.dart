import '../models/campo.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class CampoService {
  static Future<List<Campo>> getCampos() async {
    try {
      final response = await ApiService.get(AppConstants.camposListEndpoint);
      
      // Manejar diferentes formatos de respuesta
      List<dynamic> camposData;
      if (response is List) {
        camposData = response;
      } else if (response is Map<String, dynamic>) {
        camposData = response['data'] ?? response['campos'] ?? [];
      } else {
        camposData = [];
      }
      
      return camposData.map((json) => Campo.fromJson(json)).toList();
    } catch (e) {
      print('Error en CampoService.getCampos: $e');
      throw Exception('Error al obtener campos: $e');
    }
  }

  static Future<Campo> getCampo(int id) async {
    try {
      final response = await ApiService.get('/campos/$id');
      return Campo.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener campo: $e');
    }
  }

  static Future<Campo> createCampo(Campo campo) async {
    try {
      final response = await ApiService.post('/campos/', campo.toJson());
      if (response is Map<String, dynamic>) {
        return Campo.fromJson(response);
      }
      throw Exception('Respuesta inesperada al crear campo');
    } catch (e) {
      throw Exception('Error al crear campo: $e');
    }
  }

  static Future<Campo> updateCampo(Campo campo) async {
    try {
      final response = await ApiService.put('/campos/${campo.id}', campo.toJson());
      return Campo.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar campo: $e');
    }
  }

  static Future<void> deleteCampo(int id) async {
    try {
      await ApiService.delete('/campos/$id');
    } catch (e) {
      throw Exception('Error al eliminar campo: $e');
    }
  }

  static Future<List<Campo>> searchCampos(String query) async {
    try {
      final response = await ApiService.get('/campos/search?q=$query');
      final List<dynamic> camposData = response['data'] ?? response;
      return camposData.map((json) => Campo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al buscar campos: $e');
    }
  }
}
