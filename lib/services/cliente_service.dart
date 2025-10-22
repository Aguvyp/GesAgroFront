import '../models/campo.dart';
import '../models/cliente.dart';
import 'optimized_api_service.dart';

class ClienteService {
  static final ApiService _apiService = ApiService();
  
  static Future<void> _ensureInitialized() async {
    if (!_apiService.isInitialized) {
      await _apiService.initialize();
    }
  }

  static Future<List<Cliente>> getClientes() async {
    try {
      await _ensureInitialized();
      return await _apiService.getClientes();
    } catch (e) {
      throw Exception('Error al obtener clientes: $e');
    }
  }

  static Future<Cliente> getCliente(int id) async {
    try {
      await _ensureInitialized();
      return await _apiService.getCliente(id);
    } catch (e) {
      throw Exception('Error al obtener cliente: $e');
    }
  }

  static Future<Cliente> createCliente(Map<String, dynamic> data) async {
    try {
      await _ensureInitialized();
      return await _apiService.createCliente(data);
    } catch (e) {
      throw Exception('Error al crear cliente: $e');
    }
  }

  static Future<Cliente> updateCliente(int id, Map<String, dynamic> data) async {
    try {
      await _ensureInitialized();
      return await _apiService.updateCliente(id, data);
    } catch (e) {
      throw Exception('Error al actualizar cliente: $e');
    }
  }

  static Future<void> deleteCliente(int id) async {
    try {
      await _ensureInitialized();
      await _apiService.deleteCliente(id);
    } catch (e) {
      throw Exception('Error al eliminar cliente: $e');
    }
  }

  // Obtener campos asignados a un cliente específico
  static Future<List<Campo>> getCamposByCliente(int clienteId) async {
    try {
      await _ensureInitialized();
      final response = await _apiService.get('/campos-cliente/?cliente_id=$clienteId');
      final List<dynamic> camposData = response is List ? response : (response['data'] ?? []);
      return camposData.map((json) => Campo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener campos del cliente: $e');
    }
  }

  // Obtener todas las asignaciones
  static Future<List<Map<String, dynamic>>> getAsignaciones() async {
    try {
      await _ensureInitialized();
      final response = await _apiService.get('/campos-cliente/');
      final List<dynamic> asignacionesData = response is List ? response : (response['data'] ?? []);
      return asignacionesData.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error al obtener asignaciones: $e');
    }
  }

  // Obtener asignación por ID
  static Future<Map<String, dynamic>> getAsignacion(int asignacionId) async {
    try {
      await _ensureInitialized();
      final response = await _apiService.get('/campos-cliente/$asignacionId');
      return response;
    } catch (e) {
      throw Exception('Error al obtener asignación: $e');
    }
  }

  // Asignar un campo a un cliente
  static Future<Map<String, dynamic>> asignarCampoACliente(int clienteId, int campoId, {String? observaciones}) async {
    try {
      await _ensureInitialized();
      final data = {
        'cliente_id': clienteId,
        'campo_id': campoId,
        'observaciones': observaciones,
        'activo': true,
      };
      final response = await _apiService.post('/campos-cliente/', data: data);
      return response;
    } catch (e) {
      throw Exception('Error al asignar campo al cliente: $e');
    }
  }

  // Actualizar asignación
  static Future<Map<String, dynamic>> actualizarAsignacion(int asignacionId, Map<String, dynamic> data) async {
    try {
      await _ensureInitialized();
      final response = await _apiService.put('/campos-cliente/$asignacionId', data: data);
      return response;
    } catch (e) {
      throw Exception('Error al actualizar asignación: $e');
    }
  }

  // Eliminar asignación (hard delete)
  static Future<void> eliminarAsignacion(int asignacionId) async {
    try {
      await _ensureInitialized();
      await _apiService.delete('/campos-cliente/$asignacionId');
    } catch (e) {
      throw Exception('Error al eliminar asignación: $e');
    }
  }

  // Desactivar asignación (soft delete)
  static Future<void> desactivarAsignacion(int asignacionId) async {
    try {
      await _ensureInitialized();
      await _apiService.patch('/campos-cliente/$asignacionId/desactivar');
    } catch (e) {
      throw Exception('Error al desactivar asignación: $e');
    }
  }

  // Desasignar un campo de un cliente (busca la asignación y la desactiva)
  static Future<void> desasignarCampoDeCliente(int clienteId, int campoId) async {
    try {
      // Primero obtener todas las asignaciones para encontrar la correcta
      final asignaciones = await getAsignaciones();
      final asignacion = asignaciones.firstWhere(
        (asig) => asig['cliente_id'] == clienteId && asig['campo_id'] == campoId && asig['activo'] == true,
        orElse: () => throw Exception('Asignación no encontrada'),
      );
      
      // Desactivar la asignación encontrada
      await desactivarAsignacion(asignacion['id']);
    } catch (e) {
      throw Exception('Error al desasignar campo del cliente: $e');
    }
  }
}