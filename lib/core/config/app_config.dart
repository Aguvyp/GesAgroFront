import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

/// Configuración centralizada de la aplicación
class AppConfig {
  static AppConfig? _instance;
  static AppConfig get instance => _instance ??= AppConfig._();
  
  AppConfig._();

  // Storage instances
  late final FlutterSecureStorage _secureStorage;
  late final SharedPreferences _prefs;
  late final Box _hiveBox;
  late final Logger _logger;

  // Configuration
  static const String _apiBaseUrl = 'http://168.181.185.234:8080';
  static const Duration _apiTimeout = Duration(seconds: 30);
  static const Duration _cacheTimeout = Duration(hours: 1);
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  // Getters
  String get apiBaseUrl => _apiBaseUrl;
  Duration get apiTimeout => _apiTimeout;
  Duration get cacheTimeout => _cacheTimeout;
  int get maxRetries => _maxRetries;
  Duration get retryDelay => _retryDelay;
  Logger get logger => _logger;
  FlutterSecureStorage get secureStorage => _secureStorage;
  SharedPreferences get prefs => _prefs;
  Box get hiveBox => _hiveBox;

  /// Inicializar todas las dependencias de configuración
  Future<void> initialize() async {
    try {
      // Initialize Hive
      await Hive.initFlutter();
      _hiveBox = await Hive.openBox('gesagro_cache');

      // Initialize secure storage
      _secureStorage = const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );

      // Initialize shared preferences
      _prefs = await SharedPreferences.getInstance();

      // Initialize logger
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

      _logger.i('AppConfig initialized successfully');
    } catch (e) {
      throw Exception('Failed to initialize AppConfig: $e');
    }
  }

  /// Obtener configuración de caché
  Map<String, dynamic> getCacheConfig() {
    return {
      'maxAge': _cacheTimeout.inMilliseconds,
      'maxStale': const Duration(days: 7).inMilliseconds,
    };
  }

  /// Obtener configuración de red
  Map<String, dynamic> getNetworkConfig() {
    return {
      'timeout': _apiTimeout,
      'maxRetries': _maxRetries,
      'retryDelay': _retryDelay,
      'followRedirects': true,
      'maxRedirects': 5,
    };
  }

  /// Limpiar todos los datos de caché
  Future<void> clearCache() async {
    await _hiveBox.clear();
    await _prefs.clear();
    _logger.i('Cache cleared successfully');
  }

  /// Obtener información del dispositivo
  Map<String, dynamic> getDeviceInfo() {
    return {
      'isDebug': kDebugMode,
      'platform': defaultTargetPlatform.name,
      'version': '1.0.0+1',
    };
  }
}
