import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/app_config.dart';
import '../core/logger/app_logger.dart';
import '../services/optimized_api_service.dart';

/// Servicio de autenticación ultra optimizado
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  static const String _legacyFixedToken =
      'aB3xK9mP2qR7sT1vW4yZ6cD8eF0gH5jL3nM9pQ2rS7tU1vX4yA6bC8dE0fG5hI';
  static String? _memoryToken;

  late final FlutterSecureStorage _secureStorage;
  late final SharedPreferences _prefs;
  final AppLogger _logger = AppLogger.instance;

  Future<void> initialize() async {
    _secureStorage = AppConfig.instance.secureStorage;
    _prefs = AppConfig.instance.prefs;
    _logger.info('AuthService initialized');
  }

  /// ==================== AUTENTICACIÓN ====================

  /// Login con email y password
  Future<Map<String, dynamic>> login(String email, String password) async {
    _logger.auth('LOGIN_ATTEMPT', userId: email);

    try {
      final apiService = ApiService();
      await apiService.initialize();
      final response = await apiService.login(email, password);

      // Guardar token y datos del usuario
      await _saveAuthData(response);

      _logger.auth('LOGIN_SUCCESS', userId: email, role: response['role']);
      return response;
    } catch (e) {
      _logger.auth('LOGIN_FAILED', userId: email);
      _logger.error('Login error', e);
      rethrow;
    }
  }

  /// Registro de usuario
  Future<Map<String, dynamic>> register({
    required String nombre,
    required String dni,
    required String telefono,
    required String email,
    required String password,
  }) async {
    _logger.auth('REGISTER_ATTEMPT', userId: email);

    try {
      final apiService = ApiService();
      await apiService.initialize();
      final response = await apiService.register(
        nombre: nombre,
        dni: dni,
        telefono: telefono,
        email: email,
        password: password,
      );

      _logger.auth('REGISTER_SUCCESS', userId: email);
      return response;
    } catch (e) {
      _logger.auth('REGISTER_FAILED', userId: email);
      _logger.error('Register error', e);
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    _logger.auth('LOGOUT');

    try {
      try {
        final apiService = ApiService();
        await apiService.initialize();
        await apiService.logout();
      } catch (error) {
        // El cierre local debe funcionar aun sin conexión.
        _logger.warning('No se pudo invalidar la sesión remota: $error');
      }

      // Limpiar datos de autenticación
      await _clearAuthData();

      // Limpiar caché de la aplicación
      await AppConfig.instance.clearCache();

      _logger.auth('LOGOUT_SUCCESS');
    } catch (e) {
      _logger.error('Logout error', e);
      rethrow;
    }
  }

  /// Verificar estado de autenticación
  Future<bool> checkAuthStatus() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        _logger.warning('No token found in storage');
        return false;
      }

      _logger.info('🔐 Sesión almacenada encontrada');

      // Verificar si el token es válido haciendo una llamada al servidor
      // Usamos un endpoint que requiere autenticación para validar el token
      final apiService = ApiService();
      await apiService.initialize();

      try {
        // Validar contra un endpoint protegido que no oculta errores HTTP.
        await apiService.validateSession();
        _logger.info('✅ Token válido - Autenticación exitosa');
        return true;
      } catch (e) {
        // Si falla con 401/403, el token es inválido
        if (e.toString().contains('401') || e.toString().contains('403')) {
          _logger.warning(
              '⚠️ Token inválido o expirado (401/403), haciendo logout');
          await logout();
          return false;
        }
        // Si es otro error (conexión, timeout, etc.), NO hacer logout
        // Solo loguear el error pero mantener la sesión
        _logger.warning(
            '⚠️ Error de conexión al validar token, pero manteniendo sesión: $e');
        return true; // Mantener sesión si hay problemas de conexión
      }
    } catch (e) {
      _logger.error('❌ Error checking auth status: $e');
      // NO hacer logout automático por errores de conexión
      // Solo retornar false si realmente no hay token
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return false;
      }
      // Si hay token pero hay error de conexión, mantener la sesión
      return true;
    }
  }

  /// ==================== GESTIÓN DE TOKENS ====================

  /// Obtener token de acceso
  Future<String?> getToken() async {
    try {
      if (_memoryToken != null && _memoryToken!.isNotEmpty) {
        return _memoryToken;
      }

      final token = await _secureStorage.read(key: 'access_token');
      if (token == _legacyFixedToken) {
        await _secureStorage.delete(key: 'access_token');
        _logger.warning('Token legacy eliminado del almacenamiento seguro');
        return null;
      }

      _memoryToken = token;
      return token;
    } catch (e) {
      _logger.error('Error getting token', e);
      return null;
    }
  }

  /// Guardar token de acceso
  Future<void> setToken(String token) async {
    if (token.isEmpty) {
      throw StateError('El token de acceso recibido está vacío');
    }

    await _secureStorage.write(key: 'access_token', value: token);
    _memoryToken = token;
    _logger.auth('TOKEN_SAVED');
  }

  /// Obtener tipo de token
  Future<String?> getTokenType() async {
    try {
      return await _secureStorage.read(key: 'token_type');
    } catch (e) {
      _logger.error('Error getting token type', e);
      return null;
    }
  }

  /// Guardar tipo de token
  Future<void> setTokenType(String tokenType) async {
    try {
      await _secureStorage.write(key: 'token_type', value: tokenType);
    } catch (e) {
      _logger.error('Error saving token type', e);
    }
  }

  /// ==================== GESTIÓN DE USUARIO ====================

  /// Obtener datos del usuario actual
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final userJson = await _secureStorage.read(key: 'current_user');
      if (userJson != null) {
        final decoded = jsonDecode(userJson);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
      return null;
    } catch (e) {
      _logger.error('Error getting current user', e);
      return null;
    }
  }

  /// Guardar datos del usuario actual
  Future<void> setCurrentUser(Map<String, dynamic> user) async {
    try {
      await _secureStorage.write(
        key: 'current_user',
        value: jsonEncode(user),
      );
      _logger.auth('USER_DATA_SAVED');
    } catch (e) {
      _logger.error('Error saving current user', e);
    }
  }

  /// Obtener rol del usuario
  Future<String?> getUserRole() async {
    try {
      return await _secureStorage.read(key: 'user_role');
    } catch (e) {
      _logger.error('Error getting user role', e);
      return null;
    }
  }

  /// Guardar rol del usuario
  Future<void> setUserRole(String role) async {
    try {
      await _secureStorage.write(key: 'user_role', value: role);
    } catch (e) {
      _logger.error('Error saving user role', e);
    }
  }

  /// Verificar si el usuario tiene un rol específico
  Future<bool> hasRole(String role) async {
    final userRole = await getUserRole();
    return userRole == role;
  }

  /// Verificar si el usuario tiene alguno de los roles permitidos
  Future<bool> hasAnyRole(List<String> allowedRoles) async {
    final userRole = await getUserRole();
    return userRole != null && allowedRoles.contains(userRole);
  }

  /// ==================== GESTIÓN DE SESIÓN ====================

  /// Verificar si la sesión está activa
  Future<bool> isSessionActive() async {
    try {
      final lastActivity = _prefs.getInt('last_activity');
      if (lastActivity == null) {
        return false;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final sessionTimeout = const Duration(hours: 24).inMilliseconds;

      return (now - lastActivity) < sessionTimeout;
    } catch (e) {
      _logger.error('Error checking session activity', e);
      return false;
    }
  }

  /// Actualizar última actividad
  Future<void> updateLastActivity() async {
    try {
      await _prefs.setInt(
          'last_activity', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      _logger.error('Error updating last activity', e);
    }
  }

  /// Obtener tiempo de última actividad
  Future<DateTime?> getLastActivity() async {
    try {
      final lastActivity = _prefs.getInt('last_activity');
      if (lastActivity != null) {
        return DateTime.fromMillisecondsSinceEpoch(lastActivity);
      }
      return null;
    } catch (e) {
      _logger.error('Error getting last activity', e);
      return null;
    }
  }

  /// ==================== MÉTODOS PRIVADOS ====================

  /// Guardar datos de autenticación
  Future<void> _saveAuthData(Map<String, dynamic> response) async {
    try {
      final accessToken = (response['access_token'] ?? '').toString();

      if (accessToken.isEmpty) {
        throw StateError('El login no devolvió access_token');
      }

      _logger
          .info('═══════════════════════════════════════════════════════════');
      _logger.info('🔐 LOGIN EXITOSO - TOKEN RECIBIDO');
      _logger
          .info('═══════════════════════════════════════════════════════════');
      _logger.info('💾 Token recibido del servidor:');
      if (accessToken.isNotEmpty) {
        _logger.info('   Token recibido correctamente');
        _logger.info('   📏 Longitud: ${accessToken.length} caracteres');
      } else {
        _logger.warning('   ⚠️ ATENCIÓN: Token recibido está VACÍO');
      }
      _logger.info('💾 Token Type: ${response['token_type'] ?? 'bearer'}');
      _logger.info('💾 Role: ${response['role'] ?? 'N/A'}');
      _logger.info(
          '💾 User ID: ${response['user_id'] ?? response['usuario_id'] ?? 'N/A'}');
      _logger
          .info('═══════════════════════════════════════════════════════════');

      await setToken(accessToken);
      final savedToken = await getToken();
      if (savedToken != accessToken) {
        throw StateError('No se pudo persistir el token de sesión');
      }
      await setTokenType(response['token_type'] ?? 'bearer');

      if (response['role'] != null) {
        await setUserRole(response['role']);
      }

      // Guardar datos del usuario si están disponibles
      if (response['personal_id'] != null || response['usuario_id'] != null) {
        await setCurrentUser({
          'personal_id': response['personal_id'],
          'usuario_id': response['usuario_id'],
          'role': response['role'],
        });
      }

      // Actualizar última actividad
      await updateLastActivity();

      _logger.auth('AUTH_DATA_SAVED');
    } catch (e) {
      _logger.error('Error saving auth data', e);
      rethrow;
    }
  }

  /// Limpiar datos de autenticación
  Future<void> _clearAuthData() async {
    try {
      await _secureStorage.delete(key: 'access_token');
      _memoryToken = null;
      await _secureStorage.delete(key: 'token_type');
      await _secureStorage.delete(key: 'user_role');
      await _secureStorage.delete(key: 'current_user');

      await _prefs.remove('last_activity');

      _logger.auth('AUTH_DATA_CLEARED');
    } catch (e) {
      _logger.error('Error clearing auth data', e);
    }
  }

  /// ==================== UTILIDADES ====================

  /// Obtener información de autenticación
  Future<Map<String, dynamic>> getAuthInfo() async {
    try {
      final token = await getToken();
      final tokenType = await getTokenType();
      final userRole = await getUserRole();
      final currentUser = await getCurrentUser();
      final lastActivity = await getLastActivity();
      final isActive = await isSessionActive();

      return {
        'hasToken': token != null && token.isNotEmpty,
        'tokenType': tokenType,
        'userRole': userRole,
        'currentUser': currentUser,
        'lastActivity': lastActivity?.toIso8601String(),
        'isSessionActive': isActive,
        'isAuthenticated': token != null && token.isNotEmpty && isActive,
      };
    } catch (e) {
      _logger.error('Error getting auth info', e);
      return {
        'hasToken': false,
        'isAuthenticated': false,
        'isSessionActive': false,
      };
    }
  }

  /// Validar formato de email
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validar fortaleza de password
  bool isValidPassword(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }
}
