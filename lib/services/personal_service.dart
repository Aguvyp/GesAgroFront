import '../models/personal.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class PersonalService {
  static Future<List<Personal>> getPersonal() async {
    try {
      final response = await ApiService.get('${AppConstants.personalListEndpoint}');
      final List<dynamic> personalData = response is List ? response : (response['data'] ?? []);
      return personalData.map((json) => Personal.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener personal: $e');
    }
  }

  static Future<Personal> getPersonalById(int id) async {
    try {
      final response = await ApiService.get('${AppConstants.personalEndpoint}/$id');
      return Personal.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener personal: $e');
    }
  }

  static Future<Personal> createPersonal(Personal personal) async {
    try {
      final body = {
        'nombre': personal.nombre,
        'dni': personal.dni,
        'telefono': personal.telefono,
      };
      final response = await ApiService.post('${AppConstants.personalEndpoint}', body);
      if (response is Map<String, dynamic>) {
        return Personal.fromJson(response);
      }
      throw Exception('Respuesta inesperada al crear personal');
    } catch (e) {
      throw Exception('Error al crear personal: $e');
    }
  }

  static Future<Personal> updatePersonal(Personal personal) async {
    try {
      final body = <String, dynamic>{
        if (personal.nombre.isNotEmpty) 'nombre': personal.nombre,
        if (personal.dni.isNotEmpty) 'dni': personal.dni,
        if (personal.telefono != null) 'telefono': personal.telefono,
      };
      final response = await ApiService.put('${AppConstants.personalEndpoint}/${personal.id}', body);
      if (response is Map<String, dynamic>) {
        return Personal.fromJson(response);
      }
      throw Exception('Respuesta inesperada al actualizar personal');
    } catch (e) {
      throw Exception('Error al actualizar personal: $e');
    }
  }

  static Future<void> deletePersonal(int id) async {
    try {
      await ApiService.delete('${AppConstants.personalEndpoint}/$id');
    } catch (e) {
      throw Exception('Error al eliminar personal: $e');
    }
  }

  static Future<List<Personal>> searchPersonal(String query) async {
    try {
      final response = await ApiService.get('${AppConstants.personalEndpoint}/search?q=$query');
      final List<dynamic> personalData = response['data'] ?? response;
      return personalData.map((json) => Personal.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al buscar personal: $e');
    }
  }

  // Endpoint no disponible en backend actual; se elimina la llamada.
}
