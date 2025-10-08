import '../models/maquina.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class MaquinaService {
  static Future<List<Maquina>> getMaquinas() async {
    try {
      final response = await ApiService.get('${AppConstants.maquinasListEndpoint}');
      final List<dynamic> maquinasData = response is List ? response : (response['data'] ?? []);
      return maquinasData.map((json) => Maquina.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener máquinas: $e');
    }
  }

  static Future<Maquina> getMaquina(int id) async {
    try {
      final response = await ApiService.get('${AppConstants.maquinasEndpoint}/$id');
      return Maquina.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener máquina: $e');
    }
  }

  static Future<Maquina> createMaquina(Maquina maquina) async {
    try {
      final response = await ApiService.post('${AppConstants.maquinasEndpoint}', maquina.toJson());
      if (response is Map<String, dynamic>) {
        return Maquina.fromJson(response);
      }
      throw Exception('Respuesta inesperada al crear máquina');
    } catch (e) {
      throw Exception('Error al crear máquina: $e');
    }
  }

  static Future<Maquina> updateMaquina(Maquina maquina) async {
    try {
      final response = await ApiService.put('${AppConstants.maquinasEndpoint}/${maquina.id}', maquina.toJson());
      return Maquina.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar máquina: $e');
    }
  }

  static Future<void> deleteMaquina(int id) async {
    try {
      await ApiService.delete('${AppConstants.maquinasEndpoint}/$id');
    } catch (e) {
      throw Exception('Error al eliminar máquina: $e');
    }
  }

  static Future<List<Maquina>> searchMaquinas(String query) async {
    try {
      final response = await ApiService.get('${AppConstants.maquinasEndpoint}/search?q=$query');
      final List<dynamic> maquinasData = response['data'] ?? response;
      return maquinasData.map((json) => Maquina.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al buscar máquinas: $e');
    }
  }

  static Future<List<Maquina>> getMaquinasDisponibles() async {
    try {
      final response = await ApiService.get('${AppConstants.maquinasEndpoint}/disponibles');
      final List<dynamic> maquinasData = response['data'] ?? response;
      return maquinasData.map((json) => Maquina.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener máquinas disponibles: $e');
    }
  }
}
