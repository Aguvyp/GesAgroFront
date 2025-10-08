import '../models/credito.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class CreditoService {
  static Future<List<Credito>> getCreditos({int? skip, int? limit, String? estado}) async {
    try {
      String endpoint = '${AppConstants.creditosEndpoint}';
      final params = <String>[];
      if (skip != null) params.add('skip=$skip');
      if (limit != null) params.add('limit=$limit');
      if (estado != null) params.add('estado=$estado');
      
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

  static Future<Credito> getCredito(int id) async {
    try {
      final response = await ApiService.get('${AppConstants.creditosEndpoint}/$id');
      return Credito.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener crédito: $e');
    }
  }

  static Future<Credito> createCredito(Credito credito) async {
    try {
      final response = await ApiService.post(AppConstants.creditosEndpoint, credito.toJson());
      if (response is Map<String, dynamic>) {
        return Credito.fromJson(response);
      }
      throw Exception('Respuesta inesperada al crear crédito');
    } catch (e) {
      throw Exception('Error al crear crédito: $e');
    }
  }

  static Future<Credito> updateCredito(Credito credito) async {
    try {
      final response = await ApiService.put('${AppConstants.creditosEndpoint}/${credito.id}', credito.toJson());
      return Credito.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar crédito: $e');
    }
  }

  static Future<void> deleteCredito(int id) async {
    try {
      await ApiService.delete('${AppConstants.creditosEndpoint}/$id');
    } catch (e) {
      throw Exception('Error al eliminar crédito: $e');
    }
  }

  static Future<List<Credito>> getCreditosByCliente(int clienteId) async {
    try {
      final response = await ApiService.get('${AppConstants.creditosEndpoint}/cliente/$clienteId');
      final List<dynamic> creditosData = response['data'] ?? response;
      return creditosData.map((json) => Credito.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener créditos del cliente: $e');
    }
  }

  static Future<List<Credito>> getCreditosActivos() async {
    try {
      final response = await ApiService.get('${AppConstants.creditosEndpoint}/activos');
      final List<dynamic> creditosData = response['data'] ?? response;
      return creditosData.map((json) => Credito.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener créditos activos: $e');
    }
  }

  static Future<List<Credito>> getCreditosVencidos() async {
    try {
      final response = await ApiService.get('${AppConstants.creditosEndpoint}/vencidos');
      final List<dynamic> creditosData = response['data'] ?? response;
      return creditosData.map((json) => Credito.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener créditos vencidos: $e');
    }
  }
}

class CuotaCreditoService {
  static Future<List<CuotaCredito>> getCuotasByCredito(int creditoId) async {
    try {
      final response = await ApiService.get('${AppConstants.cuotasCreditoEndpoint}/credito/$creditoId');
      final List<dynamic> cuotasData = response['data'] ?? response;
      return cuotasData.map((json) => CuotaCredito.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener cuotas del crédito: $e');
    }
  }

  static Future<CuotaCredito> pagarCuota(int cuotaId, double montoPagado) async {
    try {
      final response = await ApiService.put('${AppConstants.cuotasCreditoEndpoint}/$cuotaId/pagar', {
        'monto_pagado': montoPagado,
        'fecha_pago': DateTime.now().toIso8601String(),
      });
      return CuotaCredito.fromJson(response);
    } catch (e) {
      throw Exception('Error al pagar cuota: $e');
    }
  }

  static Future<List<CuotaCredito>> getCuotasVencidas() async {
    try {
      final response = await ApiService.get('${AppConstants.cuotasCreditoEndpoint}/vencidas');
      final List<dynamic> cuotasData = response['data'] ?? response;
      return cuotasData.map((json) => CuotaCredito.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener cuotas vencidas: $e');
    }
  }
}
