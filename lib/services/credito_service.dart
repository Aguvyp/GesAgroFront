import '../models/credito.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class CreditoService {
  /// Listar todos los créditos con paginación
  static Future<List<Credito>> getCreditos({int? skip, int? limit}) async {
    try {
      String endpoint = '${AppConstants.creditosEndpoint}';
      final params = <String>[];
      if (skip != null) params.add('skip=$skip');
      if (limit != null) params.add('limit=$limit');
      
      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }
      
      final response = await ApiService.get(endpoint);
      final List<dynamic> creditosData = response is List ? response : (response['data'] ?? []);
      return creditosData.map((json) => Credito.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener créditos: $e');
    }
  }

  /// Obtener crédito específico por ID
  static Future<Credito> getCredito(int id) async {
    try {
      final response = await ApiService.get('${AppConstants.creditosEndpoint}/$id');
      return Credito.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener crédito: $e');
    }
  }

  /// Crear nuevo crédito
  static Future<Credito> createCredito(Credito credito) async {
    try {
      final response = await ApiService.post(AppConstants.creditosEndpoint, credito.toCreateJson());
      if (response is Map<String, dynamic>) {
        return Credito.fromJson(response);
      }
      throw Exception('Respuesta inesperada al crear crédito');
    } catch (e) {
      throw Exception('Error al crear crédito: $e');
    }
  }

  /// Modificar crédito existente
  static Future<Credito> updateCredito(Credito credito) async {
    try {
      final response = await ApiService.put('${AppConstants.creditosEndpoint}/${credito.id}', credito.toUpdateJson());
      return Credito.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar crédito: $e');
    }
  }

  /// Eliminar crédito
  static Future<void> deleteCredito(int id) async {
    try {
      await ApiService.delete('${AppConstants.creditosEndpoint}/$id');
    } catch (e) {
      throw Exception('Error al eliminar crédito: $e');
    }
  }
}

class CuotaCreditoService {
  /// Listar todas las cuotas con paginación
  static Future<List<CuotaCredito>> getCuotas({int? skip, int? limit}) async {
    try {
      String endpoint = '${AppConstants.cuotasCreditoEndpoint}';
      final params = <String>[];
      if (skip != null) params.add('skip=$skip');
      if (limit != null) params.add('limit=$limit');
      
      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }
      
      final response = await ApiService.get(endpoint);
      final List<dynamic> cuotasData = response is List ? response : (response['data'] ?? []);
      return cuotasData.map((json) => CuotaCredito.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener cuotas: $e');
    }
  }

  /// Obtener cuota específica por ID
  static Future<CuotaCredito> getCuota(int id) async {
    try {
      final response = await ApiService.get('${AppConstants.cuotasCreditoEndpoint}/$id');
      return CuotaCredito.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener cuota: $e');
    }
  }

  /// Crear nueva cuota
  static Future<CuotaCredito> createCuota(CuotaCredito cuota) async {
    try {
      final response = await ApiService.post(AppConstants.cuotasCreditoEndpoint, cuota.toCreateJson());
      if (response is Map<String, dynamic>) {
        return CuotaCredito.fromJson(response);
      }
      throw Exception('Respuesta inesperada al crear cuota');
    } catch (e) {
      throw Exception('Error al crear cuota: $e');
    }
  }

  /// Modificar cuota existente
  static Future<CuotaCredito> updateCuota(CuotaCredito cuota) async {
    try {
      final response = await ApiService.put('${AppConstants.cuotasCreditoEndpoint}/${cuota.id}', cuota.toUpdateJson());
      return CuotaCredito.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar cuota: $e');
    }
  }

  /// Eliminar cuota
  static Future<void> deleteCuota(int id) async {
    try {
      await ApiService.delete('${AppConstants.cuotasCreditoEndpoint}/$id');
    } catch (e) {
      throw Exception('Error al eliminar cuota: $e');
    }
  }

  /// Obtener cuotas por crédito específico
  static Future<List<CuotaCredito>> getCuotasByCredito(int creditoId) async {
    try {
      final response = await ApiService.get('${AppConstants.cuotasCreditoEndpoint}/?id_credito=$creditoId');
      final List<dynamic> cuotasData = response is List ? response : (response['data'] ?? []);
      return cuotasData.map((json) => CuotaCredito.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener cuotas del crédito: $e');
    }
  }
}
