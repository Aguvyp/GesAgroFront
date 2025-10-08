import '../models/costo.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class CostoService {
  static Future<List<Costo>> getCostos() async {
    try {
      final response = await ApiService.get('${AppConstants.costosListEndpoint}');
      final List<dynamic> costosData = response is List ? response : (response['data'] ?? []);
      return costosData.map((json) => Costo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener costos: $e');
    }
  }

  static Future<Costo> getCosto(int id) async {
    try {
      final response = await ApiService.get('${AppConstants.costosEndpoint}/$id');
      return Costo.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener costo: $e');
    }
  }

  static Future<Costo> createCosto(Costo costo) async {
    try {
      final response = await ApiService.post('${AppConstants.costosEndpoint}', costo.toJson());
      if (response is Map<String, dynamic>) {
        return Costo.fromJson(response);
      }
      throw Exception('Respuesta inesperada al crear costo');
    } catch (e) {
      throw Exception('Error al crear costo: $e');
    }
  }

  static Future<Costo> updateCosto(Costo costo) async {
    try {
      final response = await ApiService.put('${AppConstants.costosEndpoint}/${costo.id}', costo.toJson());
      return Costo.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar costo: $e');
    }
  }

  static Future<void> deleteCosto(int id) async {
    try {
      await ApiService.delete('${AppConstants.costosEndpoint}/$id');
    } catch (e) {
      throw Exception('Error al eliminar costo: $e');
    }
  }

  static Future<List<Costo>> getCostosByMes(int year, int month) async {
    try {
      final response = await ApiService.get('${AppConstants.costosEndpoint}/mes/$year/$month');
      final List<dynamic> costosData = response['data'] ?? response;
      return costosData.map((json) => Costo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener costos del mes: $e');
    }
  }

  static Future<List<Costo>> getCostosByCategoria(String categoria) async {
    try {
      final response = await ApiService.get('${AppConstants.costosEndpoint}/categoria/$categoria');
      final List<dynamic> costosData = response['data'] ?? response;
      return costosData.map((json) => Costo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener costos por categoría: $e');
    }
  }

  static Future<List<Costo>> getCostosPendientes() async {
    try {
      final response = await ApiService.get('${AppConstants.costosEndpoint}/pendientes');
      final List<dynamic> costosData = response['data'] ?? response;
      return costosData.map((json) => Costo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener costos pendientes: $e');
    }
  }

  static Future<List<Costo>> getCostosPagados() async {
    try {
      final response = await ApiService.get('${AppConstants.costosEndpoint}/pagados');
      final List<dynamic> costosData = response['data'] ?? response;
      return costosData.map((json) => Costo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener costos pagados: $e');
    }
  }

  static Future<Map<String, double>> getResumenCostos(int year, int month) async {
    try {
      final response = await ApiService.get('${AppConstants.costosEndpoint}/resumen/$year/$month');
      return Map<String, double>.from(response);
    } catch (e) {
      throw Exception('Error al obtener resumen de costos: $e');
    }
  }

  static Future<List<Costo>> searchCostos(String query) async {
    try {
      final response = await ApiService.get('${AppConstants.costosEndpoint}/search?q=$query');
      final List<dynamic> costosData = response['data'] ?? response;
      return costosData.map((json) => Costo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al buscar costos: $e');
    }
  }
}
