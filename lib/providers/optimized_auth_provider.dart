import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import '../core/logger/app_logger.dart';
import '../services/optimized_auth_service.dart';

/// Estados de autenticación
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class InitialAuthState extends AuthState {
  const InitialAuthState();
}

class LoadingAuthState extends AuthState {
  const LoadingAuthState();
}

class AuthenticatedState extends AuthState {
  final String token;
  final String role;
  final Map<String, dynamic> user;

  const AuthenticatedState({
    required this.token,
    required this.role,
    required this.user,
  });

  @override
  List<Object?> get props => [token, role, user];
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class ErrorAuthState extends AuthState {
  final String message;

  const ErrorAuthState(this.message);

  @override
  List<Object?> get props => [message];
}

/// Provider de autenticación ultra optimizado
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AppLogger _logger = AppLogger.instance;

  AuthNotifier() : super(const InitialAuthState()) {
    _checkAuthStatus();
  }

  /// Verificar estado de autenticación
  Future<void> _checkAuthStatus() async {
    try {
      state = const LoadingAuthState();

      final authService = AuthService();
      await authService.initialize();
      final isAuthenticated = await authService.checkAuthStatus();

      if (isAuthenticated) {
        final token = await authService.getToken() ?? '';
        final role = await authService.getUserRole() ?? '';
        final user = await authService.getCurrentUser() ?? {};

        state = AuthenticatedState(
          token: token,
          role: role,
          user: user,
        );

        _logger.auth('STATUS_CHECK_SUCCESS', role: role);
      } else {
        state = const UnauthenticatedState();
        _logger.auth('STATUS_CHECK_UNAUTHENTICATED');
      }
    } catch (e) {
      state = ErrorAuthState('Error verificando autenticación: $e');
      _logger.error('Error checking auth status', e);
    }
  }

  /// Login
  Future<void> login(String email, String password) async {
    try {
      state = const LoadingAuthState();

      final authService = AuthService();
      await authService.initialize();
      final response = await authService.login(email, password);

      // Extraer datos de la respuesta según la estructura de la API
      final token = response['access_token'] ?? '';
      final role = response['role'] ?? '';
      final userId = response['user_id'];
      final username = response['username'] ?? email;

      final user = {
        'email': email,
        'username': username,
        'user_id': userId,
        'nombre': response['nombre'] ?? username,
      };

      state = AuthenticatedState(
        token: token,
        role: role,
        user: user,
      );

      _logger.auth('LOGIN_SUCCESS', userId: email, role: role);
    } catch (e) {
      // Manejar errores específicos de la API
      String errorMessage = 'Error al iniciar sesión';

      if (e.toString().contains('401')) {
        errorMessage =
            'Credenciales inválidas. Verifique su usuario y contraseña.';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Usuario inactivo. Contacte al administrador.';
      } else {
        errorMessage = e.toString();
      }

      state = ErrorAuthState(errorMessage);
      _logger.error('Login error', e);
      rethrow;
    }
  }

  /// Registro
  Future<void> register({
    required String nombre,
    required String dni,
    required String telefono,
    required String email,
    required String password,
  }) async {
    try {
      state = const LoadingAuthState();

      final authService = AuthService();
      await authService.initialize();
      await authService.register(
        nombre: nombre,
        dni: dni,
        telefono: telefono,
        email: email,
        password: password,
      );

      // Después del registro exitoso, hacer login automático
      await login(email, password);

      _logger.auth('REGISTER_SUCCESS', userId: email);
    } catch (e) {
      state = ErrorAuthState('Error al registrarse: $e');
      _logger.error('Register error', e);
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      state = const LoadingAuthState();

      final authService = AuthService();
      await authService.initialize();
      await authService.logout();

      state = const UnauthenticatedState();

      _logger.auth('LOGOUT_SUCCESS');
    } catch (e) {
      state = ErrorAuthState('Error al cerrar sesión: $e');
      _logger.error('Logout error', e);
    }
  }

  /// Actualizar última actividad
  Future<void> updateActivity() async {
    try {
      final authService = AuthService();
      await authService.initialize();
      await authService.updateLastActivity();
    } catch (e) {
      _logger.error('Error updating activity', e);
    }
  }

  /// Verificar si tiene rol específico
  bool hasRole(String role) {
    final authState = state;
    if (authState is AuthenticatedState) {
      return authState.role == role;
    }
    return false;
  }

  /// Verificar si tiene alguno de los roles permitidos
  bool hasAnyRole(List<String> allowedRoles) {
    final authState = state;
    if (authState is AuthenticatedState) {
      return allowedRoles.contains(authState.role);
    }
    return false;
  }

  /// Obtener token actual
  String? getCurrentToken() {
    final authState = state;
    if (authState is AuthenticatedState) {
      return authState.token;
    }
    return null;
  }

  /// Obtener rol actual
  String? getCurrentRole() {
    final authState = state;
    if (authState is AuthenticatedState) {
      return authState.role;
    }
    return null;
  }

  /// Obtener usuario actual
  Map<String, dynamic>? getCurrentUser() {
    final authState = state;
    if (authState is AuthenticatedState) {
      return authState.user;
    }
    return null;
  }

  /// Verificar si está autenticado
  bool get isAuthenticated {
    return state is AuthenticatedState;
  }

  /// Verificar si está cargando
  bool get isLoading {
    return state is LoadingAuthState;
  }

  /// Obtener mensaje de error
  String? get errorMessage {
    final authState = state;
    if (authState is ErrorAuthState) {
      return authState.message;
    }
    return null;
  }

  /// Limpiar error
  void clearError() {
    if (state is ErrorAuthState) {
      state = const UnauthenticatedState();
    }
  }

  /// Refrescar estado de autenticación
  Future<void> refresh() async {
    await _checkAuthStatus();
  }
}

/// Provider para verificar si el usuario está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState is AuthenticatedState;
});

/// Provider para obtener el rol del usuario
final userRoleProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthenticatedState) {
    return authState.role;
  }
  return null;
});

/// Provider para obtener el token del usuario
final userTokenProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthenticatedState) {
    return authState.token;
  }
  return null;
});

/// Provider para obtener los datos del usuario
final currentUserProvider = Provider<Map<String, dynamic>?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthenticatedState) {
    return authState.user;
  }
  return null;
});

/// Provider para verificar permisos de administrador
final isAdminProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == 'Superadmin' || role == 'Dueño';
});

/// Provider para verificar permisos de contable
final isContableProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == 'Dueño';
});

/// Provider para verificar permisos de usuario
final isUserProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == 'Empleado';
});

/// Provider para verificar si tiene permisos de administrador o contable
final hasAdminOrContableAccessProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == 'Superadmin' || role == 'Dueño';
});

final isSuperadminProvider = Provider<bool>((ref) {
  return ref.watch(userRoleProvider) == 'Superadmin';
});
