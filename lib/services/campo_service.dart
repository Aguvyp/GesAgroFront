import '../models/campo.dart';
import 'optimized_api_service.dart';

class CampoService {
  static final ApiService _apiService = ApiService();

  static Future<List<Campo>> getCampos() async {
    try {
      await _apiService.initialize();
      return await _apiService.getCampos();
    } catch (e) {
      print('Error en CampoService.getCampos: $e');
      throw Exception('Error al obtener campos: $e');
    }
  }

  static Future<Campo> getCampo(int id) async {
    try {
      await _apiService.initialize();
      return await _apiService.getCampo(id);
    } catch (e) {
      throw Exception('Error al obtener campo: $e');
    }
  }

  static Future<Campo> createCampo(Campo campo) async {
    try {
      await _apiService.initialize();
      return await _apiService.createCampo(campo.toJson());
    } catch (e) {
      throw Exception('Error al crear campo: $e');
    }
  }

  static Future<Campo> updateCampo(Campo campo) async {
    try {
      await _apiService.initialize();
      return await _apiService.updateCampo(campo.id!, campo.toJson());
    } catch (e) {
      throw Exception('Error al actualizar campo: $e');
    }
  }

  static Future<void> deleteCampo(int id) async {
    try {
      await _apiService.initialize();
      await _apiService.deleteCampo(id);
    } catch (e) {
      throw Exception('Error al eliminar campo: $e');
    }
  }

  static Future<List<Campo>> searchCampos(String query) async {
    try {
      await _apiService.initialize();
      // Usar el método getCampos con filtros si está disponible, o implementar búsqueda
      final campos = await _apiService.getCampos();
      return campos
          .where((campo) =>
              campo.nombre.toLowerCase().contains(query.toLowerCase()) ||
              (campo.detalles?.toLowerCase().contains(query.toLowerCase()) ??
                  false))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar campos: $e');
    }
  }
}
