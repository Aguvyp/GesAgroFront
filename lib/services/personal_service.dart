import '../models/personal.dart';
import 'optimized_api_service.dart';

class PersonalService {
  static final ApiService _apiService = ApiService();
  
  static Future<void> _ensureInitialized() async {
    if (!_apiService.isInitialized) {
      await _apiService.initialize();
    }
  }

  static Future<List<Personal>> getPersonal() async {
    try {
      await _ensureInitialized();
      return await _apiService.getPersonal();
    } catch (e) {
      throw Exception('Error al obtener personal: $e');
    }
  }

  static Future<Personal> getPersonalById(int id) async {
    try {
      await _ensureInitialized();
      return await _apiService.getPersonalById(id);
    } catch (e) {
      throw Exception('Error al obtener personal: $e');
    }
  }

  static Future<Personal> createPersonal(Personal personal) async {
    try {
      await _ensureInitialized();
      final body = {
        'nombre': personal.nombre,
        'dni': personal.dni,
        'telefono': personal.telefono,
      };
      return await _apiService.createPersonal(body);
    } catch (e) {
      throw Exception('Error al crear personal: $e');
    }
  }

  static Future<Personal> updatePersonal(Personal personal) async {
    try {
      await _ensureInitialized();
      final body = <String, dynamic>{
        if (personal.nombre.isNotEmpty) 'nombre': personal.nombre,
        if (personal.dni.isNotEmpty) 'dni': personal.dni,
        if (personal.telefono != null) 'telefono': personal.telefono,
      };
      return await _apiService.updatePersonal(personal.id!, body);
    } catch (e) {
      throw Exception('Error al actualizar personal: $e');
    }
  }

  static Future<void> deletePersonal(int id) async {
    try {
      await _ensureInitialized();
      await _apiService.deletePersonal(id);
    } catch (e) {
      throw Exception('Error al eliminar personal: $e');
    }
  }

  static Future<List<Personal>> searchPersonal(String query) async {
    try {
      await _ensureInitialized();
      final personal = await _apiService.getPersonal();
      final queryLower = query.toLowerCase();
      return personal.where((p) => 
        p.nombre.toLowerCase().contains(queryLower) ||
        p.dni.toLowerCase().contains(queryLower) ||
        (p.telefono?.toLowerCase().contains(queryLower) ?? false)
      ).toList();
    } catch (e) {
      throw Exception('Error al buscar personal: $e');
    }
  }
}
