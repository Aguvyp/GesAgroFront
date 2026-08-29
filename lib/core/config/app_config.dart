import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../../utils/constants.dart';

/// Configuración centralizada de la aplicación
class AppConfig {
  static AppConfig? _instance;
  static AppConfig get instance => _instance ??= AppConfig._();

  AppConfig._();

  // Storage instances
  FlutterSecureStorage? _secureStorage;
  SharedPreferences? _prefs;
  Box? _hiveBox;
  Logger? _logger;
  bool _isInitialized = false;
  late String _apiBaseUrl;

  // Configuration
  // Usar la URL de constants.dart para mantener una sola fuente de verdad
  String get apiBaseUrl => _apiBaseUrl;
  static const Duration _apiTimeout = Duration(seconds: 15);
  static const Duration _cacheTimeout = Duration(hours: 1);
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  // Getters
  Duration get apiTimeout => _apiTimeout;
  Duration get cacheTimeout => _cacheTimeout;
  int get maxRetries => _maxRetries;
  Duration get retryDelay => _retryDelay;
  Logger get logger => _logger!;
  FlutterSecureStorage get secureStorage => _secureStorage!;
  SharedPreferences get prefs => _prefs!;
  Box get hiveBox => _hiveBox!;
  bool get isInitialized => _isInitialized;

  /// Inicializar todas las dependencias de configuración
  Future<void> initialize() async {
    // Si ya está inicializado, no hacer nada
    if (_isInitialized) {
      return;
    }

    try {
      // Initialize Hive (solo si no está inicializado)
      try {
        await Hive.initFlutter();
      } catch (e) {
        // Hive ya está inicializado, continuar
        if (!e.toString().contains('already initialized')) {
          rethrow;
        }
      }

      // Abrir box solo si no está ya abierto
      try {
        if (!Hive.isBoxOpen('gesagro_cache')) {
          _hiveBox = await Hive.openBox('gesagro_cache');
        } else {
          _hiveBox = Hive.box('gesagro_cache');
        }
      } catch (e) {
        // Si el box ya está abierto, obtenerlo directamente
        _hiveBox = Hive.box('gesagro_cache');
      }

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
      // La aplicación productiva siempre usa el backend oficial. Las versiones
      // anteriores podían persistir una URL local o de ngrok y dejar el login
      // esperando hasta agotar el timeout incluso después de actualizar el APK.
      _apiBaseUrl = _normalizeBaseUrl(AppConstants.apiBaseUrl);
      await _prefs!.remove('api_base_url');

      // Initialize logger
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
        level: kDebugMode ? Level.debug : Level.warning,
      );

      _logger!.i('AppConfig initialized successfully');
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize AppConfig: $e');
    }
  }

  /// Actualiza la API usada por toda la aplicación y la persiste.
  Future<void> setApiBaseUrl(String value) async {
    final normalized = _normalizeBaseUrl(value);
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        !uri.hasScheme ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw const FormatException('La URL de la API no es válida');
    }

    _apiBaseUrl = normalized;
    await _prefs!.setString('api_base_url', normalized);
  }

  String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
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
    if (_hiveBox != null) {
      await _hiveBox!.clear();
    }
    if (_prefs != null) {
      final savedApiBaseUrl = _prefs!.getString('api_base_url');
      await _prefs!.clear();
      if (savedApiBaseUrl != null) {
        await _prefs!.setString('api_base_url', savedApiBaseUrl);
      }
    }
    _logger?.i('Cache cleared successfully');
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
