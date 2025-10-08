import '../models/usuario.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class UsuarioService {
  static Future<List<Usuario>> getUsuarios({int? skip, int? limit, String? rol}) async {
    try {
      String endpoint = '${AppConstants.usuariosEndpoint}';
      final params = <String>[];
      if (skip != null) params.add('skip=$skip');
      if (limit != null) params.add('limit=$limit');
      if (rol != null) params.add('rol=$rol');
      
      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }
      
      final response = await ApiService.get(endpoint);
      final List<dynamic> usuariosData = response is List ? response : (response['data'] ?? []);
      return usuariosData.map((json) => Usuario.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener usuarios: $e');
    }
  }

  static Future<Usuario> getUsuario(int id) async {
    try {
      final response = await ApiService.get('${AppConstants.usuariosEndpoint}/$id');
      return Usuario.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  static Future<Usuario> createUsuario(Usuario usuario) async {
    try {
      final response = await ApiService.post(AppConstants.usuariosEndpoint, usuario.toJson());
      if (response is Map<String, dynamic>) {
        return Usuario.fromJson(response);
      }
      throw Exception('Respuesta inesperada al crear usuario');
    } catch (e) {
      throw Exception('Error al crear usuario: $e');
    }
  }

  static Future<Usuario> updateUsuario(Usuario usuario) async {
    try {
      final response = await ApiService.put('${AppConstants.usuariosEndpoint}/${usuario.id}', usuario.toJson());
      return Usuario.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  static Future<void> deleteUsuario(int id) async {
    try {
      await ApiService.delete('${AppConstants.usuariosEndpoint}/$id');
    } catch (e) {
      throw Exception('Error al eliminar usuario: $e');
    }
  }

  static Future<List<Usuario>> getUsuariosActivos() async {
    try {
      final response = await ApiService.get('${AppConstants.usuariosEndpoint}/activos');
      final List<dynamic> usuariosData = response['data'] ?? response;
      return usuariosData.map((json) => Usuario.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener usuarios activos: $e');
    }
  }

  static Future<List<Usuario>> getUsuariosByRol(String rol) async {
    try {
      final response = await ApiService.get('${AppConstants.usuariosEndpoint}/rol/$rol');
      final List<dynamic> usuariosData = response['data'] ?? response;
      return usuariosData.map((json) => Usuario.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener usuarios por rol: $e');
    }
  }

  static Future<bool> validateEmailUnique(String email, {int? excludeId}) async {
    try {
      final response = await ApiService.get('${AppConstants.usuariosEndpoint}/validate-email?email=$email&exclude_id=${excludeId ?? ''}');
      return response['is_unique'] ?? false;
    } catch (e) {
      throw Exception('Error al validar email único: $e');
    }
  }

  static Future<Usuario> cambiarEstadoUsuario(int id, bool activo) async {
    try {
      final response = await ApiService.put('${AppConstants.usuariosEndpoint}/$id/estado', {'activo': activo});
      return Usuario.fromJson(response);
    } catch (e) {
      throw Exception('Error al cambiar estado del usuario: $e');
    }
  }

  static Future<Usuario> cambiarRolUsuario(int id, String rol) async {
    try {
      final response = await ApiService.put('${AppConstants.usuariosEndpoint}/$id/rol', {'rol': rol});
      return Usuario.fromJson(response);
    } catch (e) {
      throw Exception('Error al cambiar rol del usuario: $e');
    }
  }
}
