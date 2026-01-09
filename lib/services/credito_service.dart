import '../models/credito.dart';
import 'optimized_api_service.dart';

class CreditoService {
  static final ApiService _apiService = ApiService();
  
  static Future<void> _ensureInitialized() async {
    if (!_apiService.isInitialized) {
      await _apiService.initialize();
    }
  }

  /// Listar todos los créditos con paginación
  static Future<List<Credito>> getCreditos({int? skip, int? limit}) async {
    try {
      await _ensureInitialized();
      final creditos = await _apiService.getCreditos();
      // Aplicar paginación manualmente si es necesario
      if (skip != null || limit != null) {
        final start = skip ?? 0;
        final end = limit != null ? start + limit : creditos.length;
        return creditos.sublist(start < creditos.length ? start : creditos.length, 
                                end < creditos.length ? end : creditos.length);
      }
      return creditos;
    } catch (e) {
      throw Exception('Error al obtener créditos: $e');
    }
  }

  /// Obtener crédito específico por ID
  static Future<Credito> getCredito(int id) async {
    try {
      await _ensureInitialized();
      return await _apiService.getCredito(id);
    } catch (e) {
      throw Exception('Error al obtener crédito: $e');
    }
  }

  /// Crear nuevo crédito
  static Future<Credito> createCredito(Credito credito) async {
    try {
      await _ensureInitialized();
      return await _apiService.createCredito(credito.toCreateJson());
    } catch (e) {
      throw Exception('Error al crear crédito: $e');
    }
  }

  /// Modificar crédito existente
  static Future<Credito> updateCredito(Credito credito) async {
    try {
      await _ensureInitialized();
      return await _apiService.updateCredito(credito.id, credito.toUpdateJson());
    } catch (e) {
      throw Exception('Error al actualizar crédito: $e');
    }
  }

  /// Eliminar crédito
  static Future<void> deleteCredito(int id) async {
    try {
      await _ensureInitialized();
      await _apiService.deleteCredito(id);
    } catch (e) {
      throw Exception('Error al eliminar crédito: $e');
    }
  }
}

class CuotaCreditoService {
  static final ApiService _apiService = ApiService();
  
  static Future<void> _ensureInitialized() async {
    if (!_apiService.isInitialized) {
      await _apiService.initialize();
    }
  }

  /// Listar todas las cuotas con paginación
  static Future<List<CuotaCredito>> getCuotas({int? skip, int? limit}) async {
    try {
      await _ensureInitialized();
      final cuotasData = await _apiService.getCuotasCredito();
      final cuotas = cuotasData.map((json) => CuotaCredito.fromJson(json)).toList();
      // Aplicar paginación manualmente si es necesario
      if (skip != null || limit != null) {
        final start = skip ?? 0;
        final end = limit != null ? start + limit : cuotas.length;
        return cuotas.sublist(start < cuotas.length ? start : cuotas.length, 
                             end < cuotas.length ? end : cuotas.length);
      }
      return cuotas;
    } catch (e) {
      throw Exception('Error al obtener cuotas: $e');
    }
  }

  /// Obtener cuota específica por ID
  static Future<CuotaCredito> getCuota(int id) async {
    try {
      await _ensureInitialized();
      final cuotaData = await _apiService.getCuotaCredito(id);
      return CuotaCredito.fromJson(cuotaData);
    } catch (e) {
      throw Exception('Error al obtener cuota: $e');
    }
  }

  /// Crear nueva cuota
  static Future<CuotaCredito> createCuota(CuotaCredito cuota) async {
    try {
      await _ensureInitialized();
      final response = await _apiService.createCuotaCredito(cuota.toCreateJson());
      return CuotaCredito.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear cuota: $e');
    }
  }

  /// Modificar cuota existente
  static Future<CuotaCredito> updateCuota(CuotaCredito cuota) async {
    try {
      await _ensureInitialized();
      final response = await _apiService.updateCuotaCredito(cuota.id, cuota.toUpdateJson());
      return CuotaCredito.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar cuota: $e');
    }
  }

  /// Eliminar cuota
  static Future<void> deleteCuota(int id) async {
    try {
      await _ensureInitialized();
      await _apiService.deleteCuotaCredito(id);
    } catch (e) {
      throw Exception('Error al eliminar cuota: $e');
    }
  }

  /// Obtener cuotas por crédito específico
  static Future<List<CuotaCredito>> getCuotasByCredito(int creditoId) async {
    try {
      await _ensureInitialized();
      final cuotasData = await _apiService.getCuotasCredito();
      final cuotas = cuotasData.map((json) => CuotaCredito.fromJson(json)).toList();
      return cuotas.where((cuota) => cuota.idCredito == creditoId).toList();
    } catch (e) {
      throw Exception('Error al obtener cuotas del crédito: $e');
    }
  }
}
