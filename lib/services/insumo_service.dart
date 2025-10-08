import '../models/insumo.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class InsumoService {
  static Future<List<Insumo>> getInsumos({int? skip, int? limit, String? categoria}) async {
    try {
      String endpoint = '${AppConstants.insumosEndpoint}';
      final params = <String>[];
      if (skip != null) params.add('skip=$skip');
      if (limit != null) params.add('limit=$limit');
      if (categoria != null) params.add('categoria=$categoria');
      
      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }
      
      final response = await ApiService.get(endpoint);
      final List<dynamic> insumosData = response is List ? response : (response['data'] ?? []);
      return insumosData.map((json) => Insumo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener insumos: $e');
    }
  }

  static Future<Insumo> getInsumo(int id) async {
    try {
      final response = await ApiService.get('${AppConstants.insumosEndpoint}/$id');
      return Insumo.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener insumo: $e');
    }
  }

  static Future<Insumo> createInsumo(Insumo insumo) async {
    try {
      final response = await ApiService.post(AppConstants.insumosEndpoint, insumo.toJson());
      if (response is Map<String, dynamic>) {
        return Insumo.fromJson(response);
      }
      throw Exception('Respuesta inesperada al crear insumo');
    } catch (e) {
      throw Exception('Error al crear insumo: $e');
    }
  }

  static Future<Insumo> updateInsumo(Insumo insumo) async {
    try {
      final response = await ApiService.put('${AppConstants.insumosEndpoint}/${insumo.id}', insumo.toJson());
      return Insumo.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar insumo: $e');
    }
  }

  static Future<void> deleteInsumo(int id) async {
    try {
      await ApiService.delete('${AppConstants.insumosEndpoint}/$id');
    } catch (e) {
      throw Exception('Error al eliminar insumo: $e');
    }
  }

  static Future<List<Insumo>> getInsumosBajoStock() async {
    try {
      final response = await ApiService.get('${AppConstants.insumosEndpoint}/bajo-stock');
      final List<dynamic> insumosData = response['data'] ?? response;
      return insumosData.map((json) => Insumo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener insumos bajo stock: $e');
    }
  }

  static Future<List<Insumo>> getInsumosProximosVencimiento() async {
    try {
      final response = await ApiService.get('${AppConstants.insumosEndpoint}/proximos-vencimiento');
      final List<dynamic> insumosData = response['data'] ?? response;
      return insumosData.map((json) => Insumo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener insumos próximos a vencer: $e');
    }
  }

  static Future<List<Insumo>> getInsumosVencidos() async {
    try {
      final response = await ApiService.get('${AppConstants.insumosEndpoint}/vencidos');
      final List<dynamic> insumosData = response['data'] ?? response;
      return insumosData.map((json) => Insumo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener insumos vencidos: $e');
    }
  }

  static Future<List<String>> getCategoriasInsumos() async {
    try {
      final response = await ApiService.get('${AppConstants.insumosEndpoint}/categorias');
      return List<String>.from(response);
    } catch (e) {
      throw Exception('Error al obtener categorías de insumos: $e');
    }
  }

  static Future<Map<String, dynamic>> getResumenInventario() async {
    try {
      final response = await ApiService.get('${AppConstants.insumosEndpoint}/resumen');
      return response;
    } catch (e) {
      throw Exception('Error al obtener resumen de inventario: $e');
    }
  }
}
