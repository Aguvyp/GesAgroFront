import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../logger/app_logger.dart';
import '../../services/optimized_auth_service.dart';

/// Cliente HTTP optimizado con cache y conexión persistente
class OptimizedHttpClient {
  static OptimizedHttpClient? _instance;
  static OptimizedHttpClient get instance =>
      _instance ??= OptimizedHttpClient._();

  OptimizedHttpClient._();

  final Dio _dio = Dio();
  final Connectivity _connectivity = Connectivity();
  final AppLogger _logger = AppLogger.instance;
  bool _isInitialized = false;

  /// Inicializar el cliente HTTP
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.debug('OptimizedHttpClient already initialized, skipping...');
      return;
    }

    // Normalizar la URL base (eliminar barra final si existe)
    String baseUrl = AppConfig.instance.apiBaseUrl.trim();
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    // Configurar opciones base con timeouts amplios para ngrok
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 60), // Aumentado para ngrok
      receiveTimeout: const Duration(seconds: 60), // Aumentado para ngrok
      sendTimeout: const Duration(seconds: 60), // Aumentado para ngrok
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    _logger.info('🌐 OptimizedHttpClient configured');
    _logger.info('   Base URL: $baseUrl');
    _logger.info('   Connect Timeout: 60s');
    _logger.info('   Receive Timeout: 60s');
    _logger.info('   Send Timeout: 60s');

    // Configurar interceptores
    _setupInterceptors();

    _isInitialized = true;
    _logger.info('OptimizedHttpClient initialized');
  }

  /// Aplica una nueva URL base sin reiniciar la aplicación.
  Future<void> reconfigure() async {
    var baseUrl = AppConfig.instance.apiBaseUrl.trim();
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    _dio.options.baseUrl = baseUrl;
    _logger.info('🌐 API reconfigurada: $baseUrl');
  }

  /// Configurar todos los interceptores
  void _setupInterceptors() {
    // Retry interceptor removido - sin reintentos automáticos

    // Logging interceptor
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          requestHeader: false,
          responseHeader: false,
          logPrint: (object) => _logger.debug(object.toString()),
        ),
      );
    }

    // Authentication interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Normalizar el path (asegurar que empiece con / y termine con /)
          final originalPath = options.path;
          if (!options.path.startsWith('/')) {
            options.path = '/${options.path}';
          }
          // Agregar barra final si no existe (todos los endpoints terminan con slash)
          // Excepción: el endpoint de clima no debe llevar barra final según requerimiento del backend
          if (!options.path.endsWith('/') &&
              options.path != '/' &&
              !options.path.contains('/api/clima/pronostico')) {
            options.path = '${options.path}/';
          }

          // Log de normalización para debugging
          if (originalPath != options.path) {
            _logger.info(
                '🔧 Path normalizado en interceptor: "$originalPath" → "${options.path}"');
          }

          // Construir URL completa para logging
          final fullUrl = '${options.baseUrl}${options.path}';

          // Asegurar que el header de ngrok siempre esté presente
          options.headers['ngrok-skip-browser-warning'] = 'true';

          // LOG DETALLADO ANTES DE CADA PETICIÓN
          _logger.info(
              '═══════════════════════════════════════════════════════════');
          _logger.info('📤 REQUEST PREPARATION');
          _logger.info(
              '═══════════════════════════════════════════════════════════');
          _logger.info('🌐 URL Completa: $fullUrl');
          _logger.info('📡 Método: ${options.method}');
          _logger.info('📋 Headers:');
          options.headers.forEach((key, value) {
            if (key == 'Authorization') {
              _logger.info('   $key: [REDACTED]');
            } else {
              _logger.info('   $key: $value');
            }
          });
          if (options.data != null &&
              !options.path.toLowerCase().contains('/auth/')) {
            _logger.info('📦 Body: ${options.data}');
          }
          if (options.queryParameters.isNotEmpty) {
            _logger.info('🔍 Query Params: ${options.queryParameters}');
          }
          _logger.info(
              '═══════════════════════════════════════════════════════════');

          // No agregar token a endpoints de autenticación y health check
          final path = options.path.toLowerCase();
          final isAuthEndpoint =
              path.contains('/api/auth/') || path.contains('/auth/');
          final isHealthEndpoint =
              path.contains('/api/health/') || path.contains('/health/');

          if (!isAuthEndpoint && !isHealthEndpoint) {
            // Agregar token de autenticación si está disponible
            // Primero intentar obtener el token del AuthService (token del login)
            try {
              final authService = AuthService();
              await authService.initialize();
              String? token = await authService.getToken();

              if (token != null && token.isNotEmpty) {
                _logger.info('🔐 Usando token del login para: ${options.path}');
                final authHeader = 'Bearer $token';
                options.headers['Authorization'] = authHeader;
                _logger.info(
                    '═══════════════════════════════════════════════════════════');
                _logger.info('🔐 AUTENTICACIÓN - HEADER CONFIGURADO');
                _logger.info(
                    '═══════════════════════════════════════════════════════════');
                _logger.info('📡 Endpoint: ${options.path}');
                _logger
                    .info('🌐 URL completa: ${options.baseUrl}${options.path}');
                _logger.info('🔑 Token completo: $token');
                _logger.info('📏 Token length: ${token.length} caracteres');
                _logger.info('🔐 Header Authorization completo: $authHeader');
                _logger.info('📋 Todos los headers de la petición:');
                options.headers.forEach((key, value) {
                  if (key == 'Authorization') {
                    _logger.info(
                        '   $key: Bearer ${value.toString().substring(7).length > 20 ? value.toString().substring(7, 27) + "..." : value}');
                  } else {
                    _logger.info('   $key: $value');
                  }
                });
                _logger.info(
                    '═══════════════════════════════════════════════════════════');
              } else {
                _logger.warning(
                    '⚠️ ❌ No hay token de login para la petición: ${options.path}');
              }
            } catch (e) {
              _logger.error('❌ Error obteniendo token: $e');
            }
          } else {
            _logger.debug('🔓 Endpoint sin autenticación: ${options.path}');
          }
          handler.next(options);
        },
      ),
    );

    // Error handling interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          _handleError(error);
          handler.next(error);
        },
      ),
    );
  }

  /// Manejar errores de manera inteligente
  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        _logger.warning('Timeout error: ${error.message}');
        break;
      case DioExceptionType.badResponse:
        _logger.error(
            'Bad response: ${error.response?.statusCode} - ${error.message}');
        break;
      case DioExceptionType.cancel:
        _logger.info('Request cancelled');
        break;
      case DioExceptionType.connectionError:
        _logger.error('Connection error: ${error.message}');
        break;
      case DioExceptionType.badCertificate:
        _logger.error('Bad certificate: ${error.message}');
        break;
      case DioExceptionType.unknown:
        _logger.error('Unknown error: ${error.message}');
        break;
    }
  }

  /// Verificar conectividad
  Future<bool> hasConnection() async {
    if (!_isInitialized) {
      _logger
          .warning('OptimizedHttpClient not initialized, initializing now...');
      await initialize();
    }

    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// GET request optimizado
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool forceRefresh = false,
  }) async {
    if (!_isInitialized) {
      _logger
          .warning('OptimizedHttpClient not initialized, initializing now...');
      await initialize();
    }

    // Normalizar path (asegurar que empiece con / y termine con /)
    final originalPath = path;
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    // Agregar barra final si no existe (todos los endpoints terminan con slash)
    // Excepción: el endpoint de clima no debe llevar barra final
    if (!path.endsWith('/') &&
        path != '/' &&
        !path.contains('/api/clima/pronostico')) {
      path = '${path}/';
    }

    // Log de normalización para debugging
    if (originalPath != path) {
      _logger.info('🔧 Path normalizado: "$originalPath" → "$path"');
    }

    final fullUrl = '${AppConfig.instance.apiBaseUrl}$path';
    _logger.info('🚀 GET Request: $fullUrl');

    final requestOptions = options ?? Options();

    if (forceRefresh) {
      requestOptions.extra = {'cache': false};
    }

    try {
      // El interceptor ya agregó el header Authorization antes de llegar aquí
      // IMPORTANTE: El path ya está normalizado (sin slash final)
      // El interceptor también normalizará el path nuevamente como medida de seguridad
      _logger.info('📤 Enviando GET a Dio con path: "$path"');
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
      );

      _logger.info('✅ GET Response: ${response.statusCode} - $fullUrl');
      return response;
    } catch (e) {
      _logger.error('❌ GET Error: $e - $fullUrl');
      if (e is DioException) {
        _logger.error('   Error Type: ${e.type}');
        _logger.error('   Status Code: ${e.response?.statusCode}');
        _logger.error('   Message: ${e.message}');
        if (e.response?.data != null) {
          _logger.error('   Response Data: ${e.response?.data}');
        }
        // Si es timeout, dar sugerencias específicas
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          _logger.error('   ⏱️ TIMEOUT - Verificar:');
          _logger.error('      - ¿La URL de ngrok es correcta?');
          _logger.error('      - ¿El túnel ngrok está activo?');
          _logger.error('      - ¿El backend Django está corriendo?');
        }
      }
      // Si es un error 500, agregar información adicional sobre autenticación
      if (e is DioException && e.response?.statusCode == 500) {
        _logger.error('❌ Error 500 - Verificar en el servidor:');
        _logger.error('   - ¿El token es válido?');
        _logger.error('   - ¿El endpoint existe?');
        _logger.error('   - ¿Hay un error en el servidor?');
      }
      rethrow;
    }
  }

  /// POST request optimizado
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (!_isInitialized) {
      _logger
          .warning('OptimizedHttpClient not initialized, initializing now...');
      await initialize();
    }

    // Normalizar path (asegurar que empiece con / y termine con /)
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    // Agregar barra final si no existe (todos los endpoints terminan con slash)
    if (!path.endsWith('/') && path != '/') {
      path = '${path}/';
    }

    final fullUrl = '${AppConfig.instance.apiBaseUrl}$path';
    _logger.info('🚀 POST Request: $fullUrl');

    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      _logger.info('✅ POST Response: ${response.statusCode} - $fullUrl');
      return response;
    } catch (e) {
      _logger.error('❌ POST Error: $e - $fullUrl');
      if (e is DioException) {
        _logger.error('   Error Type: ${e.type}');
        _logger.error('   Status Code: ${e.response?.statusCode}');
        _logger.error('   Message: ${e.message}');
        if (e.response?.data != null) {
          _logger.error('   Response Data: ${e.response?.data}');
        }
      }
      rethrow;
    }
  }

  /// PUT request optimizado
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (!_isInitialized) {
      _logger
          .warning('OptimizedHttpClient not initialized, initializing now...');
      await initialize();
    }

    // Normalizar path (asegurar que empiece con / y termine con /)
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    // Agregar barra final si no existe (todos los endpoints terminan con slash)
    if (!path.endsWith('/') && path != '/') {
      path = '${path}/';
    }

    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// DELETE request optimizado
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    if (!_isInitialized) {
      _logger
          .warning('OptimizedHttpClient not initialized, initializing now...');
      await initialize();
    }

    // Normalizar path (asegurar que empiece con / y termine con /)
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    // Agregar barra final si no existe (todos los endpoints terminan con slash)
    if (!path.endsWith('/') && path != '/') {
      path = '${path}/';
    }

    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Limpiar caché del cliente HTTP
  Future<void> clearCache() async {
    // Implementar limpieza de caché si es necesario
  }

  /// Obtener estadísticas de caché
  Map<String, dynamic> getCacheStats() {
    return {
      'totalRequests': 0,
      'cachedRequests': 0,
    };
  }
}
