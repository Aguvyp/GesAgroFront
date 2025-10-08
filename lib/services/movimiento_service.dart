import '../models/movimiento.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class MovimientoService {
  static Future<List<Movimiento>> getMovimientos({int? skip, int? limit, int? insumoId, String? tipo}) async {
    try {
      String endpoint = '${AppConstants.movimientosEndpoint}';
      final params = <String>[];
      if (skip != null) params.add('skip=$skip');
      if (limit != null) params.add('limit=$limit');
      if (insumoId != null) params.add('insumo_id=$insumoId');
      if (tipo != null) params.add('tipo=$tipo');
      
      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }
      
      final response = await ApiService.get(endpoint);
      final List<dynamic> movimientosData = response is List ? response : (response['data'] ?? []);
      return movimientosData.map((json) => Movimiento.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener movimientos: $e');
    }
  }

  static Future<Movimiento> getMovimiento(int id) async {
    try {
      final response = await ApiService.get('${AppConstants.movimientosEndpoint}/$id');
      return Movimiento.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener movimiento: $e');
    }
  }

  static Future<Movimiento> createMovimiento(Movimiento movimiento) async {
    try {
      final response = await ApiService.post(AppConstants.movimientosEndpoint, movimiento.toJson());
      if (response is Map<String, dynamic>) {
        return Movimiento.fromJson(response);
      }
      throw Exception('Respuesta inesperada al crear movimiento');
    } catch (e) {
      throw Exception('Error al crear movimiento: $e');
    }
  }

  static Future<Movimiento> updateMovimiento(Movimiento movimiento) async {
    try {
      final response = await ApiService.put('${AppConstants.movimientosEndpoint}/${movimiento.id}', movimiento.toJson());
      return Movimiento.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar movimiento: $e');
    }
  }

  static Future<void> deleteMovimiento(int id) async {
    try {
      await ApiService.delete('${AppConstants.movimientosEndpoint}/$id');
    } catch (e) {
      throw Exception('Error al eliminar movimiento: $e');
    }
  }

  static Future<List<Movimiento>> getMovimientosByInsumo(int insumoId) async {
    try {
      final response = await ApiService.get('${AppConstants.movimientosEndpoint}/insumo/$insumoId');
      final List<dynamic> movimientosData = response['data'] ?? response;
      return movimientosData.map((json) => Movimiento.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener movimientos del insumo: $e');
    }
  }

  static Future<List<Movimiento>> getMovimientosEntrada() async {
    try {
      final response = await ApiService.get('${AppConstants.movimientosEndpoint}/entrada');
      final List<dynamic> movimientosData = response['data'] ?? response;
      return movimientosData.map((json) => Movimiento.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener movimientos de entrada: $e');
    }
  }

  static Future<List<Movimiento>> getMovimientosSalida() async {
    try {
      final response = await ApiService.get('${AppConstants.movimientosEndpoint}/salida');
      final List<dynamic> movimientosData = response['data'] ?? response;
      return movimientosData.map((json) => Movimiento.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener movimientos de salida: $e');
    }
  }

  static Future<Map<String, dynamic>> getResumenMovimientos() async {
    try {
      final response = await ApiService.get('${AppConstants.movimientosEndpoint}/resumen');
      return response;
    } catch (e) {
      throw Exception('Error al obtener resumen de movimientos: $e');
    }
  }
}
