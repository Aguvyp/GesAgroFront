import '../models/mantenimiento.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class MantenimientoService {
  static Future<List<Mantenimiento>> getMantenimientos({int? skip, int? limit, String? estado, String? tipo}) async {
    try {
      String endpoint = '${AppConstants.mantenimientosEndpoint}';
      final params = <String>[];
      if (skip != null) params.add('skip=$skip');
      if (limit != null) params.add('limit=$limit');
      if (estado != null) params.add('estado=$estado');
      if (tipo != null) params.add('tipo=$tipo');
      
      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }
      
      final response = await ApiService.get(endpoint);
      final List<dynamic> mantenimientosData = response is List ? response : (response['data'] ?? []);
      return mantenimientosData.map((json) => Mantenimiento.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener mantenimientos: $e');
    }
  }

  static Future<Mantenimiento> getMantenimiento(int id) async {
    try {
      final response = await ApiService.get('${AppConstants.mantenimientosEndpoint}/$id');
      return Mantenimiento.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener mantenimiento: $e');
    }
  }

  static Future<Mantenimiento> createMantenimiento(Mantenimiento mantenimiento) async {
    try {
      final response = await ApiService.post(AppConstants.mantenimientosEndpoint, mantenimiento.toJson());
      if (response is Map<String, dynamic>) {
        return Mantenimiento.fromJson(response);
      }
      throw Exception('Respuesta inesperada al crear mantenimiento');
    } catch (e) {
      throw Exception('Error al crear mantenimiento: $e');
    }
  }

  static Future<Mantenimiento> updateMantenimiento(Mantenimiento mantenimiento) async {
    try {
      final response = await ApiService.put('${AppConstants.mantenimientosEndpoint}/${mantenimiento.id}', mantenimiento.toJson());
      return Mantenimiento.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar mantenimiento: $e');
    }
  }

  static Future<void> deleteMantenimiento(int id) async {
    try {
      await ApiService.delete('${AppConstants.mantenimientosEndpoint}/$id');
    } catch (e) {
      throw Exception('Error al eliminar mantenimiento: $e');
    }
  }

  static Future<List<Mantenimiento>> getMantenimientosByMaquina(int maquinaId) async {
    try {
      final response = await ApiService.get('${AppConstants.mantenimientosEndpoint}/maquina/$maquinaId');
      final List<dynamic> mantenimientosData = response['data'] ?? response;
      return mantenimientosData.map((json) => Mantenimiento.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener mantenimientos de la máquina: $e');
    }
  }

  static Future<List<Mantenimiento>> getMantenimientosProximos() async {
    try {
      final response = await ApiService.get('${AppConstants.mantenimientosEndpoint}/proximos');
      final List<dynamic> mantenimientosData = response['data'] ?? response;
      return mantenimientosData.map((json) => Mantenimiento.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener mantenimientos próximos: $e');
    }
  }

  static Future<List<Mantenimiento>> getMantenimientosVencidos() async {
    try {
      final response = await ApiService.get('${AppConstants.mantenimientosEndpoint}/vencidos');
      final List<dynamic> mantenimientosData = response['data'] ?? response;
      return mantenimientosData.map((json) => Mantenimiento.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener mantenimientos vencidos: $e');
    }
  }

  static Future<List<Mantenimiento>> getMantenimientosPreventivos() async {
    try {
      final response = await ApiService.get('${AppConstants.mantenimientosEndpoint}/preventivos');
      final List<dynamic> mantenimientosData = response['data'] ?? response;
      return mantenimientosData.map((json) => Mantenimiento.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener mantenimientos preventivos: $e');
    }
  }

  static Future<List<Mantenimiento>> getMantenimientosCorrectivos() async {
    try {
      final response = await ApiService.get('${AppConstants.mantenimientosEndpoint}/correctivos');
      final List<dynamic> mantenimientosData = response['data'] ?? response;
      return mantenimientosData.map((json) => Mantenimiento.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener mantenimientos correctivos: $e');
    }
  }

  static Future<Map<String, dynamic>> getResumenMantenimientos() async {
    try {
      final response = await ApiService.get('${AppConstants.mantenimientosEndpoint}/resumen');
      return response;
    } catch (e) {
      throw Exception('Error al obtener resumen de mantenimientos: $e');
    }
  }
}
