import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// Sistema de logging ultra optimizado
class AppLogger {
  static AppLogger? _instance;
  static AppLogger get instance => _instance ??= AppLogger._();
  
  AppLogger._();

  late final Logger _logger;

  /// Inicializar el logger
  void initialize() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      level: kDebugMode ? Level.debug : Level.warning,
    );
  }

  /// Log de debug
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log de información
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log de advertencia
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log de error
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log de error fatal
  void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// Log de API calls
  void apiCall(String method, String endpoint, {Map<String, dynamic>? data}) {
    final message = '🌐 $method $endpoint';
    if (data != null) {
      debug('$message\nData: $data');
    } else {
      debug(message);
    }
  }

  /// Log de API response
  void apiResponse(String endpoint, int statusCode, {dynamic data}) {
    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    info('$emoji $endpoint -> $statusCode');
    if (data != null && kDebugMode) {
      debug('Response: $data');
    }
  }

  /// Log de performance
  void performance(String operation, Duration duration) {
    final emoji = duration.inMilliseconds > 1000 ? '🐌' : '⚡';
    info('$emoji $operation took ${duration.inMilliseconds}ms');
  }

  /// Log de cache
  void cache(String operation, String key, {dynamic data}) {
    debug('💾 Cache $operation: $key');
    if (data != null && kDebugMode) {
      debug('Cache data: $data');
    }
  }

  /// Log de error de red
  void networkError(String operation, dynamic error) {
    this.error('🌐 Network error in $operation', error);
  }

  /// Log de autenticación
  void auth(String operation, {String? userId, String? role}) {
    final message = '🔐 Auth $operation';
    if (userId != null) {
      info('$message - User: $userId${role != null ? ' ($role)' : ''}');
    } else {
      info(message);
    }
  }

  /// Log de base de datos
  void database(String operation, {String? table, int? count}) {
    final message = '🗄️ DB $operation';
    if (table != null) {
      info('$message - Table: $table${count != null ? ' ($count records)' : ''}');
    } else {
      info(message);
    }
  }

  /// Log de UI
  void ui(String operation, {String? screen, String? widget}) {
    debug('🎨 UI $operation${screen != null ? ' - Screen: $screen' : ''}${widget != null ? ' - Widget: $widget' : ''}');
  }

  /// Log de estado
  void state(String provider, String operation, {dynamic data}) {
    debug('🔄 State $provider.$operation');
    if (data != null && kDebugMode) {
      debug('State data: $data');
    }
  }
}


/// Extensiones para logging más fácil
extension LoggerExtensions on Object {
  void logDebug(String message) => AppLogger.instance.debug('$runtimeType: $message');
  void logInfo(String message) => AppLogger.instance.info('$runtimeType: $message');
  void logWarning(String message) => AppLogger.instance.warning('$runtimeType: $message');
  void logError(String message, [dynamic error]) => AppLogger.instance.error('$runtimeType: $message', error);
}
