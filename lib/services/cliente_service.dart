import '../models/cliente.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class ClienteService {
  static Future<List<Cliente>> getClientes({int? skip, int? limit}) async {
    try {
      String endpoint = '${AppConstants.clientesEndpoint}';
      if (skip != null || limit != null) {
        final params = <String>[];
        if (skip != null) params.add('skip=$skip');
        if (limit != null) params.add('limit=$limit');
        endpoint += '?${params.join('&')}';
      }
      
      final response = await ApiService.get(endpoint);
      final List<dynamic> clientesData = response is List ? response : (response['data'] ?? []);
      return clientesData.map((json) => Cliente.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener clientes: $e');
    }
  }

  static Future<Cliente> getCliente(int id) async {
    try {
      final response = await ApiService.get('${AppConstants.clientesEndpoint}/$id');
      return Cliente.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener cliente: $e');
    }
  }

  static Future<Cliente> createCliente(Cliente cliente) async {
    try {
      final response = await ApiService.post(AppConstants.clientesEndpoint, cliente.toJson());
      if (response is Map<String, dynamic>) {
        return Cliente.fromJson(response);
      }
      throw Exception('Respuesta inesperada al crear cliente');
    } catch (e) {
      throw Exception('Error al crear cliente: $e');
    }
  }

  static Future<Cliente> updateCliente(Cliente cliente) async {
    try {
      final response = await ApiService.put('${AppConstants.clientesEndpoint}/${cliente.id}', cliente.toJson());
      return Cliente.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar cliente: $e');
    }
  }

  static Future<void> deleteCliente(int id) async {
    try {
      await ApiService.delete('${AppConstants.clientesEndpoint}/$id');
    } catch (e) {
      throw Exception('Error al eliminar cliente: $e');
    }
  }

  static Future<List<Cliente>> searchClientes(String query) async {
    try {
      final response = await ApiService.get('${AppConstants.clientesEndpoint}/search?q=$query');
      final List<dynamic> clientesData = response['data'] ?? response;
      return clientesData.map((json) => Cliente.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al buscar clientes: $e');
    }
  }

  static Future<List<Cliente>> getClientesActivos() async {
    try {
      final response = await ApiService.get('${AppConstants.clientesEndpoint}/activos');
      final List<dynamic> clientesData = response['data'] ?? response;
      return clientesData.map((json) => Cliente.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener clientes activos: $e');
    }
  }
}
