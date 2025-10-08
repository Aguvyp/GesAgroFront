import '../models/trabajo.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class TrabajoService {
  static Future<List<Trabajo>> getTrabajos() async {
    try {
      print('TrabajoService: Haciendo request a ${AppConstants.trabajosListEndpoint}');
      final response = await ApiService.get('${AppConstants.trabajosListEndpoint}');
      print('TrabajoService: Respuesta recibida: $response');
      final List<dynamic> trabajosData = response is List ? response : (response['data'] ?? []);
      print('TrabajoService: Datos procesados: ${trabajosData.length} elementos');
      return trabajosData.map((json) => Trabajo.fromJson(json)).toList();
    } catch (e) {
      print('TrabajoService: Error: $e');
      throw Exception('Error al obtener trabajos: $e');
    }
  }

  static Future<Trabajo> getTrabajo(int id) async {
    try {
      final response = await ApiService.get('${AppConstants.trabajosEndpoint}/$id');
      return Trabajo.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener trabajo: $e');
    }
  }

  static Future<Trabajo> createTrabajo(Trabajo trabajo) async {
    try {
      final response = await ApiService.post('${AppConstants.trabajosEndpoint}', trabajo.toJson());
      if (response is Map<String, dynamic>) {
        return Trabajo.fromJson(response);
      }
      throw Exception('Respuesta inesperada al crear trabajo');
    } catch (e) {
      throw Exception('Error al crear trabajo: $e');
    }
  }

  static Future<Trabajo> updateTrabajo(Trabajo trabajo) async {
    try {
      final response = await ApiService.put('${AppConstants.trabajosEndpoint}/${trabajo.id}', trabajo.toJson());
      return Trabajo.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar trabajo: $e');
    }
  }

  static Future<Trabajo> updateTrabajoEstado(int trabajoId, String estado) async {
    try {
      final response = await ApiService.put('${AppConstants.trabajosEndpoint}/$trabajoId/estado', {'estado': estado});
      return Trabajo.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar estado del trabajo: $e');
    }
  }

  static Future<List<Trabajo>> getTrabajosByPersonal(int personalId) async {
    try {
      final response = await ApiService.get('${AppConstants.trabajosEndpoint}/personal/$personalId');
      final List<dynamic> trabajosData = response is List ? response : (response['data'] ?? []);
      return trabajosData.map((json) => Trabajo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener trabajos del personal: $e');
    }
  }

  static Future<void> deleteTrabajo(int id) async {
    try {
      await ApiService.delete('${AppConstants.trabajosEndpoint}/$id');
    } catch (e) {
      throw Exception('Error al eliminar trabajo: $e');
    }
  }

  static Future<List<Trabajo>> getTrabajosByCampo(int campoId) async {
    try {
      final response = await ApiService.get('${AppConstants.trabajosEndpoint}/campo/$campoId');
      final List<dynamic> trabajosData = response['data'] ?? response;
      return trabajosData.map((json) => Trabajo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener trabajos del campo: $e');
    }
  }

  static Future<List<Trabajo>> getTrabajosByMaquina(int maquinaId) async {
    try {
      final response = await ApiService.get('${AppConstants.trabajosEndpoint}/maquina/$maquinaId');
      final List<dynamic> trabajosData = response['data'] ?? response;
      return trabajosData.map((json) => Trabajo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener trabajos de la máquina: $e');
    }
  }

  static Future<List<Trabajo>> getTrabajosByEstado(String estado) async {
    try {
      final response = await ApiService.get('${AppConstants.trabajosEndpoint}/estado/$estado');
      final List<dynamic> trabajosData = response['data'] ?? response;
      return trabajosData.map((json) => Trabajo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener trabajos por estado: $e');
    }
  }

  static Future<List<Trabajo>> getTrabajosRecientes({int limit = 5}) async {
    try {
      final response = await ApiService.get('${AppConstants.trabajosRecientesEndpoint}?limit=$limit');
      final List<dynamic> trabajosData = response['data'] ?? response;
      return trabajosData.map((json) => Trabajo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener trabajos recientes: $e');
    }
  }

  static Future<List<Trabajo>> searchTrabajos(String query) async {
    try {
      final response = await ApiService.get('${AppConstants.trabajosEndpoint}/search?q=$query');
      final List<dynamic> trabajosData = response['data'] ?? response;
      return trabajosData.map((json) => Trabajo.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al buscar trabajos: $e');
    }
  }
}
