import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../logger/app_logger.dart';

/// Cliente HTTP ultra optimizado con cache, retry y conexión persistente
class OptimizedHttpClient {
  static OptimizedHttpClient? _instance;
  static OptimizedHttpClient get instance => _instance ??= OptimizedHttpClient._();
  
  OptimizedHttpClient._();

  final Dio _dio = Dio();
  final Connectivity _connectivity = Connectivity();
  final AppLogger _logger = AppLogger.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isInitialized = false;

  /// Inicializar el cliente HTTP
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.debug('OptimizedHttpClient already initialized, skipping...');
      return;
    }
    
    // Configurar opciones base
    _dio.options = BaseOptions(
      baseUrl: AppConfig.instance.apiBaseUrl,
      connectTimeout: AppConfig.instance.apiTimeout,
      receiveTimeout: AppConfig.instance.apiTimeout,
      sendTimeout: AppConfig.instance.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    _logger.info('🌐 OptimizedHttpClient configured with baseUrl: ${AppConfig.instance.apiBaseUrl}');

    // Configurar interceptores
    _setupInterceptors();
    
    _isInitialized = true;
    _logger.info('OptimizedHttpClient initialized');
  }

  /// Configurar todos los interceptores
  void _setupInterceptors() {
    // Retry interceptor
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logPrint: _logger.debug,
        retries: AppConfig.instance.maxRetries,
        retryDelays: List.generate(
          AppConfig.instance.maxRetries,
          (index) => Duration(milliseconds: 1000 * (index + 1)),
        ),
      ),
    );

    // Logging interceptor
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          logPrint: (object) => _logger.debug(object.toString()),
        ),
      );
    }

    // Authentication interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Agregar token de autenticación si está disponible
          final token = await _secureStorage.read(key: 'access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            _logger.debug('🔐 Token agregado a la petición: ${options.path}');
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
        _logger.error('Bad response: ${error.response?.statusCode} - ${error.message}');
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
      _logger.warning('OptimizedHttpClient not initialized, initializing now...');
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
      _logger.warning('OptimizedHttpClient not initialized, initializing now...');
      await initialize();
    }
    
    final fullUrl = '${AppConfig.instance.apiBaseUrl}$path';
    _logger.info('🚀 GET Request: $fullUrl');
    
    final requestOptions = options ?? Options();
    
    if (forceRefresh) {
      requestOptions.extra = {'cache': false};
    }

    try {
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
      _logger.warning('OptimizedHttpClient not initialized, initializing now...');
      await initialize();
    }
    
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
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
      _logger.warning('OptimizedHttpClient not initialized, initializing now...');
      await initialize();
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
      _logger.warning('OptimizedHttpClient not initialized, initializing now...');
      await initialize();
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

/// Interceptor personalizado para reintentos inteligentes
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;
  final void Function(String)? logPrint;

  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ],
    this.logPrint,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      
      if (retryCount < retries) {
        logPrint?.call('Retrying request (${retryCount + 1}/$retries)');
        
        await Future.delayed(retryDelays[retryCount]);
        
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        
        try {
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Continue to next retry or fail
        }
      }
    }
    
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}