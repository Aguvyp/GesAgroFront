import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'security_config.dart';

/// Configuración de autenticación segura
class AuthConfig {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Token Bearer para autenticación API (obtenido de forma segura)
  static String get _bearerToken => SecurityConfig.bearerToken;
  
  /// Clave para almacenar el token en secure storage
  static const String _tokenKey = 'access_token';

  /// Inicializar el token de autenticación
  static Future<void> initializeToken() async {
    try {
      // Guardar el token de forma segura
      await _secureStorage.write(key: _tokenKey, value: _bearerToken);
    } catch (e) {
      // En caso de error, el token se puede usar directamente
      // pero no se almacenará de forma persistente
    }
  }

  /// Obtener el token desde secure storage
  static Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      // Si hay error leyendo desde secure storage, usar el token directo
      return _bearerToken;
    }
  }

  /// Limpiar el token almacenado
  static Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      // Ignorar errores de limpieza
    }
  }

  /// Verificar si el token está disponible
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
