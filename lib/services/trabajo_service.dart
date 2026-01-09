import '../models/trabajo.dart';
import 'optimized_api_service.dart';

class TrabajoService {
  static final ApiService _apiService = ApiService();
  
  static Future<void> _ensureInitialized() async {
    if (!_apiService.isInitialized) {
      await _apiService.initialize();
    }
  }

  static Future<List<Trabajo>> getTrabajos() async {
    try {
      await _ensureInitialized();
      return await _apiService.getTrabajos();
    } catch (e) {
      throw Exception('Error al obtener trabajos: $e');
    }
  }

  static Future<Trabajo> getTrabajo(int id) async {
    try {
      await _ensureInitialized();
      return await _apiService.getTrabajo(id);
    } catch (e) {
      throw Exception('Error al obtener trabajo: $e');
    }
  }

  static Future<Trabajo> createTrabajo(Trabajo trabajo) async {
    try {
      await _ensureInitialized();
      return await _apiService.createTrabajo(trabajo.toJson());
    } catch (e) {
      throw Exception('Error al crear trabajo: $e');
    }
  }

  static Future<Trabajo> updateTrabajo(Trabajo trabajo) async {
    try {
      await _ensureInitialized();
      return await _apiService.updateTrabajo(trabajo.id!, trabajo.toJson());
    } catch (e) {
      throw Exception('Error al actualizar trabajo: $e');
    }
  }

  static Future<Trabajo> updateTrabajoEstado(int trabajoId, String estado) async {
    try {
      await _ensureInitialized();
      return await _apiService.updateTrabajo(trabajoId, {'estado': estado});
    } catch (e) {
      throw Exception('Error al actualizar estado del trabajo: $e');
    }
  }

  static Future<List<Trabajo>> getTrabajosByPersonal(int personalId) async {
    try {
      await _ensureInitialized();
      final trabajos = await _apiService.getTrabajos();
      return trabajos.where((t) => t.idPersonal.contains(personalId)).toList();
    } catch (e) {
      throw Exception('Error al obtener trabajos del personal: $e');
    }
  }

  static Future<void> deleteTrabajo(int id) async {
    try {
      await _ensureInitialized();
      await _apiService.deleteTrabajo(id);
    } catch (e) {
      throw Exception('Error al eliminar trabajo: $e');
    }
  }

  static Future<List<Trabajo>> getTrabajosByCampo(int campoId) async {
    try {
      await _ensureInitialized();
      final trabajos = await _apiService.getTrabajos();
      return trabajos.where((t) => t.idCampo == campoId).toList();
    } catch (e) {
      throw Exception('Error al obtener trabajos del campo: $e');
    }
  }

  static Future<List<Trabajo>> getTrabajosByMaquina(int maquinaId) async {
    try {
      await _ensureInitialized();
      final trabajos = await _apiService.getTrabajos();
      return trabajos.where((t) => t.idMaquinas.contains(maquinaId)).toList();
    } catch (e) {
      throw Exception('Error al obtener trabajos de la máquina: $e');
    }
  }

  static Future<List<Trabajo>> getTrabajosByEstado(String estado) async {
    try {
      await _ensureInitialized();
      final trabajos = await _apiService.getTrabajos();
      return trabajos.where((t) => t.estado == estado).toList();
    } catch (e) {
      throw Exception('Error al obtener trabajos por estado: $e');
    }
  }

  static Future<List<Trabajo>> getTrabajosRecientes({int limit = 5}) async {
    try {
      await _ensureInitialized();
      final trabajos = await _apiService.getTrabajos();
      trabajos.sort((a, b) => b.fechaInicio.compareTo(a.fechaInicio));
      return trabajos.take(limit).toList();
    } catch (e) {
      throw Exception('Error al obtener trabajos recientes: $e');
    }
  }

  static Future<List<Trabajo>> searchTrabajos(String query) async {
    try {
      await _ensureInitialized();
      final trabajos = await _apiService.getTrabajos();
      final queryLower = query.toLowerCase();
      return trabajos.where((t) => 
        (t.tipoTrabajoNombre?.toLowerCase().contains(queryLower) ?? false) ||
        (t.cliente?.toLowerCase().contains(queryLower) ?? false) ||
        t.cultivo.toLowerCase().contains(queryLower)
      ).toList();
    } catch (e) {
      throw Exception('Error al buscar trabajos: $e');
    }
  }
}
