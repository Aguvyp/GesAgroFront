import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import '../config/app_config.dart';
import '../logger/app_logger.dart';

/// Estado base para todos los repositorios
abstract class BaseState extends Equatable {
  const BaseState();
  
  @override
  List<Object?> get props => [];
}

/// Estado de carga
class LoadingState extends BaseState {
  const LoadingState();
}

/// Estado de datos cargados
class LoadedState<T> extends BaseState {
  final T data;
  final DateTime lastUpdated;
  
  LoadedState(this.data, {DateTime? lastUpdated}) 
      : lastUpdated = lastUpdated ?? DateTime.now();
  
  @override
  List<Object?> get props => [data, lastUpdated];
}

/// Estado de error
class ErrorState extends BaseState {
  final String message;
  final dynamic error;
  
  const ErrorState(this.message, [this.error]);
  
  @override
  List<Object?> get props => [message, error];
}

/// Estado inicial
class InitialState extends BaseState {
  const InitialState();
}

/// Repositorio base ultra optimizado
abstract class BaseRepository<T> {
  final AppLogger _logger = AppLogger.instance;
  final Box _cacheBox = AppConfig.instance.hiveBox;
  
  /// Clave base para el caché
  String get cacheKey;
  
  /// Duración del caché
  Duration get cacheDuration => Duration(hours: 1);
  
  /// Obtener datos del caché
  T? getCachedData(String key) {
    try {
      final cached = _cacheBox.get(key);
      if (cached != null) {
        _logger.cache('HIT', key);
        return _deserializeData(cached);
      }
      _logger.cache('MISS', key);
      return null;
    } catch (e) {
      _logger.error('Error getting cached data for $key', e);
      return null;
    }
  }
  
  /// Guardar datos en caché
  void setCachedData(String key, T data) {
    try {
      final serialized = _serializeData(data);
      _cacheBox.put(key, serialized);
      _logger.cache('SET', key);
    } catch (e) {
      _logger.error('Error setting cached data for $key', e);
    }
  }
  
  /// Verificar si el caché es válido
  bool isCacheValid(String key) {
    try {
      final metadata = _cacheBox.get('${key}_metadata');
      if (metadata == null) return false;
      
      final timestamp = DateTime.fromMillisecondsSinceEpoch(metadata['timestamp']);
      final isValid = DateTime.now().difference(timestamp) < cacheDuration;
      
      if (!isValid) {
        _logger.cache('EXPIRED', key);
        _cacheBox.delete(key);
        _cacheBox.delete('${key}_metadata');
      }
      
      return isValid;
    } catch (e) {
      _logger.error('Error checking cache validity for $key', e);
      return false;
    }
  }
  
  /// Guardar metadatos del caché
  void setCacheMetadata(String key) {
    try {
      _cacheBox.put('${key}_metadata', {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'duration': cacheDuration.inMilliseconds,
      });
    } catch (e) {
      _logger.error('Error setting cache metadata for $key', e);
    }
  }
  
  /// Limpiar caché específico
  void clearCache(String key) {
    try {
      _cacheBox.delete(key);
      _cacheBox.delete('${key}_metadata');
      _logger.cache('CLEARED', key);
    } catch (e) {
      _logger.error('Error clearing cache for $key', e);
    }
  }
  
  /// Limpiar todo el caché del repositorio
  void clearAllCache() {
    try {
      final keys = _cacheBox.keys.where((key) => key.toString().startsWith(cacheKey));
      for (final key in keys) {
        _cacheBox.delete(key);
      }
      _logger.cache('CLEARED_ALL', cacheKey);
    } catch (e) {
      _logger.error('Error clearing all cache for $cacheKey', e);
    }
  }
  
  /// Serializar datos para caché
  dynamic _serializeData(T data) {
    if (data is Map<String, dynamic>) return data;
    if (data is List) return data.map((e) => e is Map<String, dynamic> ? e : e.toString()).toList();
    return data.toString();
  }
  
  /// Deserializar datos del caché
  T _deserializeData(dynamic data) {
    return data as T;
  }
  
  /// Construir clave de caché
  String buildCacheKey(String suffix) {
    return '${cacheKey}_$suffix';
  }
  
  /// Obtener estadísticas del caché
  Map<String, dynamic> getCacheStats() {
    try {
      final keys = _cacheBox.keys.where((key) => key.toString().startsWith(cacheKey));
      return {
        'totalKeys': keys.length,
        'keys': keys.toList(),
        'cacheKey': cacheKey,
        'duration': cacheDuration.inMilliseconds,
      };
    } catch (e) {
      _logger.error('Error getting cache stats', e);
      return {};
    }
  }
}

/// Provider base para repositorios
abstract class BaseRepositoryProvider<T> extends BaseRepository<T> {
  /// Obtener datos con caché inteligente
  Future<T> getData({
    String? cacheSuffix,
    bool forceRefresh = false,
    Future<T> Function()? fetchFunction,
  }) async {
    final key = buildCacheKey(cacheSuffix ?? 'default');
    
    // Si no es refresh forzado, intentar obtener del caché
    if (!forceRefresh && isCacheValid(key)) {
      final cached = getCachedData(key);
      if (cached != null) {
        return cached;
      }
    }
    
    // Si hay función de fetch, obtener datos frescos
    if (fetchFunction != null) {
      try {
        final data = await fetchFunction();
        setCachedData(key, data);
        setCacheMetadata(key);
        return data;
      } catch (e) {
        _logger.error('Error fetching data for $key', e);
        rethrow;
      }
    }
    
    throw Exception('No fetch function provided and no cached data available');
  }
  
  /// Actualizar datos en caché
  Future<void> updateData(String cacheSuffix, T data) async {
    final key = buildCacheKey(cacheSuffix);
    setCachedData(key, data);
    setCacheMetadata(key);
  }
  
  /// Invalidar caché específico
  void invalidateCache(String cacheSuffix) {
    final key = buildCacheKey(cacheSuffix);
    clearCache(key);
  }
}

/// Mixin para operaciones CRUD optimizadas
mixin CrudOperations<T> on BaseRepository<T> {
  /// Crear elemento
  Future<T> create(T item) async {
    _logger.database('CREATE', table: T.toString());
    // Implementar en clases concretas
    throw UnimplementedError();
  }
  
  /// Leer elemento por ID
  Future<T?> read(String id) async {
    _logger.database('READ', table: T.toString());
    // Implementar en clases concretas
    throw UnimplementedError();
  }
  
  /// Actualizar elemento
  Future<T> update(String id, T item) async {
    _logger.database('UPDATE', table: T.toString());
    // Implementar en clases concretas
    throw UnimplementedError();
  }
  
  /// Eliminar elemento
  Future<void> delete(String id) async {
    _logger.database('DELETE', table: T.toString());
    // Implementar en clases concretas
    throw UnimplementedError();
  }
  
  /// Listar todos los elementos
  Future<List<T>> list({int? limit, int? offset}) async {
    _logger.database('LIST', table: T.toString());
    // Implementar en clases concretas
    throw UnimplementedError();
  }
}