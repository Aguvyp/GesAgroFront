import 'dart:convert';
import '../core/config/app_config.dart';
import '../core/network/optimized_http_client.dart';
import '../services/optimized_api_service.dart';
import '../core/logger/app_logger.dart';

/// Métrica de rendimiento
class PerformanceMetric {
  final String operation;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  PerformanceMetric({
    required this.operation,
    required this.duration,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'operation': operation,
      'durationMs': duration.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

/// Analizador de rendimiento de la aplicación
class PerformanceAnalyzer {
  final List<PerformanceMetric> _metrics = [];
  final AppLogger _logger = AppLogger.instance;
  final Map<String, Stopwatch> _activeTimers = {};

  // #region agent log
  void _logToFile(Map<String, dynamic> data) {
    // Solo loggear a consola ya que el sistema de archivos es de solo lectura
    // Los logs detallados se pueden ver en la consola de Flutter
    try {
      final logEntry = {
        'id': 'perf_${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'location': 'performance_analyzer.dart',
        'message': data['message'] ?? 'Performance metric',
        'data': data,
        'sessionId': 'performance-test-session',
        'runId': 'run1',
        'hypothesisId': 'A',
      };
      
      // Log a consola en formato JSON para fácil parsing
      print('🟢 [PERF_TEST] ${jsonEncode(logEntry)}');
      _logger.debug('📝 Log: ${data['message']}');
    } catch (e) {
      // Si falla el JSON encoding, solo imprimir el mensaje
      print('🟢 [PERF_TEST] ${data['message'] ?? 'Performance metric'}: $e');
      _logger.warning('⚠️ Error procesando log: $e');
    }
  }
  // #endregion

  /// Iniciar medición de una operación
  void startMeasurement(String operation, {Map<String, dynamic>? metadata}) {
    final stopwatch = Stopwatch()..start();
    _activeTimers[operation] = stopwatch;
    
    // #region agent log
    _logToFile({
      'message': 'Performance measurement started',
      'operation': operation,
      'metadata': metadata,
    });
    // #endregion
  }

  /// Detener medición de una operación
  void stopMeasurement(String operation, {Map<String, dynamic>? metadata}) {
    final stopwatch = _activeTimers.remove(operation);
    if (stopwatch != null) {
      stopwatch.stop();
      final metric = PerformanceMetric(
        operation: operation,
        duration: stopwatch.elapsed,
        timestamp: DateTime.now(),
        metadata: metadata,
      );
      _metrics.add(metric);
      
      // #region agent log
      _logToFile({
        'message': 'Performance measurement completed',
        'operation': operation,
        'durationMs': metric.duration.inMilliseconds,
        'metadata': metadata,
      });
      // #endregion
    }
  }

  /// Medir una operación async
  Future<T> measureAsync<T>(
    String operation,
    Future<T> Function() fn, {
    Map<String, dynamic>? metadata,
  }) async {
    startMeasurement(operation, metadata: metadata);
    try {
      final result = await fn();
      stopMeasurement(operation, metadata: metadata);
      return result;
    } catch (e) {
      stopMeasurement(operation, metadata: {...?metadata, 'error': e.toString()});
      rethrow;
    }
  }

  /// Analizar rendimiento de inicialización
  Future<Map<String, dynamic>> analyzeInitialization() async {
    // #region agent log
    _logToFile({
      'message': 'Starting initialization performance analysis',
    });
    // #endregion

    final results = <String, dynamic>{};

    // Inicialización de AppConfig
    await measureAsync(
      'app_config_init',
      () => AppConfig.instance.initialize(),
    );

    // Inicialización de OptimizedHttpClient
    await measureAsync(
      'http_client_init',
      () => OptimizedHttpClient.instance.initialize(),
    );

    // Inicialización de ApiService
    final apiService = ApiService();
    await measureAsync(
      'api_service_init',
      () => apiService.initialize(),
    );

    // Análisis de resultados
    final initMetrics = _metrics.where((m) => m.operation.contains('init')).toList();
    final totalInitTime = initMetrics
        .map((m) => m.duration.inMilliseconds)
        .fold(0, (a, b) => a + b);

    results['initialization'] = {
      'totalTimeMs': totalInitTime,
      'metrics': initMetrics.map((m) => m.toJson()).toList(),
    };

    // #region agent log
    _logToFile({
      'message': 'Initialization analysis completed',
      'totalTimeMs': totalInitTime,
    });
    // #endregion

    return results;
  }

  /// Analizar rendimiento de operaciones API
  Future<Map<String, dynamic>> analyzeApiOperations() async {
    // #region agent log
    _logToFile({
      'message': 'Starting API operations performance analysis',
    });
    // #endregion

    final apiService = ApiService();
    await apiService.initialize();

    final results = <String, dynamic>{};
    final apiMetrics = <String, List<int>>{};

    // Probar operaciones comunes
    final operations = [
      ('get_campos', () => apiService.getCampos()),
      ('get_maquinas', () => apiService.getMaquinas()),
      ('get_personal', () => apiService.getPersonal()),
      ('get_clientes', () => apiService.getClientes()),
      ('get_trabajos', () => apiService.getTrabajos()),
      ('get_insumos', () => apiService.getInsumos()),
      ('get_mantenimientos', () => apiService.getMantenimientos()),
      ('get_costos', () => apiService.getCostos()),
      ('get_facturas', () => apiService.getFacturas()),
      ('get_creditos', () => apiService.getCreditos()),
      ('get_movimientos', () => apiService.getMovimientos()),
      ('get_tipos_trabajo', () => apiService.getTiposTrabajo()),
      ('get_dashboard_resumen', () => apiService.getDashboardResumen()),
    ];

    for (final (operation, fn) in operations) {
      try {
        final durations = <int>[];
        
        // Ejecutar 3 veces para obtener promedio
        for (int i = 0; i < 3; i++) {
          await measureAsync(
            operation,
            fn,
            metadata: {'iteration': i},
          );
          durations.add(_metrics.last.duration.inMilliseconds);
          
          // Pequeña pausa entre iteraciones
          await Future.delayed(const Duration(milliseconds: 200));
        }
        
        apiMetrics[operation] = durations;
      } catch (e) {
        _logger.warning('Error en operación $operation: $e');
        apiMetrics[operation] = [];
      }
    }

    // Calcular estadísticas
    final stats = <String, Map<String, dynamic>>{};
    apiMetrics.forEach((operation, durations) {
      if (durations.isNotEmpty) {
        durations.sort();
        final avg = durations.reduce((a, b) => a + b) / durations.length;
        stats[operation] = {
          'avgMs': avg.toStringAsFixed(2),
          'minMs': durations.first,
          'maxMs': durations.last,
          'medianMs': durations[durations.length ~/ 2],
          'count': durations.length,
        };
      }
    });

    results['apiOperations'] = {
      'stats': stats,
      'metrics': _metrics
          .where((m) => apiMetrics.containsKey(m.operation))
          .map((m) => m.toJson())
          .toList(),
    };

    // #region agent log
    _logToFile({
      'message': 'API operations analysis completed',
      'operationsTested': apiMetrics.length,
    });
    // #endregion

    return results;
  }

  /// Analizar operaciones lentas
  List<Map<String, dynamic>> getSlowOperations({int thresholdMs = 1000}) {
    final slowOps = _metrics
        .where((m) => m.duration.inMilliseconds > thresholdMs)
        .toList();
    
    slowOps.sort((a, b) => b.duration.compareTo(a.duration));
    
    return slowOps.map((m) => {
      'operation': m.operation,
      'durationMs': m.duration.inMilliseconds,
      'timestamp': m.timestamp.toIso8601String(),
      'metadata': m.metadata,
    }).toList();
  }

  /// Analizar tiempos muertos (gaps entre operaciones)
  List<Map<String, dynamic>> analyzeIdleTimes({int thresholdMs = 500}) {
    if (_metrics.length < 2) return [];

    final idleTimes = <Map<String, dynamic>>[];
    _metrics.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (int i = 0; i < _metrics.length - 1; i++) {
      final current = _metrics[i];
      final next = _metrics[i + 1];
      
      final gap = next.timestamp.difference(current.timestamp);
      final gapMs = gap.inMilliseconds - current.duration.inMilliseconds;
      
      if (gapMs > thresholdMs) {
        idleTimes.add({
          'afterOperation': current.operation,
          'beforeOperation': next.operation,
          'idleTimeMs': gapMs,
          'timestamp': current.timestamp.toIso8601String(),
        });
      }
    }

    idleTimes.sort((a, b) => (b['idleTimeMs'] as int).compareTo(a['idleTimeMs'] as int));
    
    return idleTimes;
  }

  /// Generar reporte completo
  Future<Map<String, dynamic>> generateFullReport() async {
    // #region agent log
    _logToFile({
      'message': 'Generating full performance report',
    });
    // #endregion

    final report = <String, dynamic>{};

    // Análisis de inicialización
    report['initialization'] = await analyzeInitialization();

    // Análisis de operaciones API
    report['apiOperations'] = await analyzeApiOperations();

    // Operaciones lentas
    report['slowOperations'] = getSlowOperations(thresholdMs: 1000);

    // Tiempos muertos
    report['idleTimes'] = analyzeIdleTimes(thresholdMs: 500);

    // Estadísticas generales
    if (_metrics.isNotEmpty) {
      final durations = _metrics.map((m) => m.duration.inMilliseconds).toList();
      durations.sort();
      
      report['generalStats'] = {
        'totalOperations': _metrics.length,
        'avgDurationMs': (durations.reduce((a, b) => a + b) / durations.length).toStringAsFixed(2),
        'minDurationMs': durations.first,
        'maxDurationMs': durations.last,
        'medianDurationMs': durations[durations.length ~/ 2],
        'totalTimeMs': durations.reduce((a, b) => a + b),
      };
    }

    // #region agent log
    _logToFile({
      'message': 'Full performance report generated',
      'totalMetrics': _metrics.length,
    });
    // #endregion

    return report;
  }

  /// Generar reporte en texto
  String generateTextReport(Map<String, dynamic> report) {
    final buffer = StringBuffer();
    
    buffer.writeln('═══════════════════════════════════════════════════════════');
    buffer.writeln('⚡ REPORTE DE RENDIMIENTO DE LA APLICACIÓN');
    buffer.writeln('═══════════════════════════════════════════════════════════');
    buffer.writeln('');

    // Estadísticas generales
    if (report.containsKey('generalStats')) {
      final stats = report['generalStats'] as Map<String, dynamic>;
      buffer.writeln('📊 ESTADÍSTICAS GENERALES:');
      buffer.writeln('   Total de operaciones: ${stats['totalOperations']}');
      buffer.writeln('   Tiempo promedio: ${stats['avgDurationMs']}ms');
      buffer.writeln('   Tiempo mínimo: ${stats['minDurationMs']}ms');
      buffer.writeln('   Tiempo máximo: ${stats['maxDurationMs']}ms');
      buffer.writeln('   Tiempo mediano: ${stats['medianDurationMs']}ms');
      buffer.writeln('   Tiempo total: ${stats['totalTimeMs']}ms');
      buffer.writeln('');
    }

    // Inicialización
    if (report.containsKey('initialization')) {
      final init = report['initialization'] as Map<String, dynamic>;
      buffer.writeln('🚀 INICIALIZACIÓN:');
      buffer.writeln('   Tiempo total: ${init['totalTimeMs']}ms');
      if (init.containsKey('metrics')) {
        final metrics = init['metrics'] as List;
        for (final metric in metrics) {
          buffer.writeln(
            '   ${metric['operation']}: ${metric['durationMs']}ms',
          );
        }
      }
      buffer.writeln('');
    }

    // Operaciones API
    if (report.containsKey('apiOperations')) {
      final apiOps = report['apiOperations'] as Map<String, dynamic>;
      if (apiOps.containsKey('stats')) {
        final stats = apiOps['stats'] as Map<String, dynamic>;
        buffer.writeln('🌐 OPERACIONES API:');
        stats.forEach((operation, stat) {
          final s = stat as Map<String, dynamic>;
          buffer.writeln(
            '   $operation: avg=${s['avgMs']}ms, '
            'min=${s['minMs']}ms, max=${s['maxMs']}ms',
          );
        });
        buffer.writeln('');
      }
    }

    // Operaciones lentas
    if (report.containsKey('slowOperations')) {
      final slowOps = report['slowOperations'] as List;
      if (slowOps.isNotEmpty) {
        buffer.writeln('🐌 OPERACIONES LENTAS (> 1s):');
        for (final op in slowOps.take(10)) {
          buffer.writeln(
            '   ${op['operation']}: ${op['durationMs']}ms',
          );
        }
        buffer.writeln('');
      }
    }

    // Tiempos muertos
    if (report.containsKey('idleTimes')) {
      final idleTimes = report['idleTimes'] as List;
      if (idleTimes.isNotEmpty) {
        buffer.writeln('⏸️  TIEMPOS MUERTOS (> 500ms):');
        for (final idle in idleTimes.take(10)) {
          buffer.writeln(
            '   ${idle['afterOperation']} → ${idle['beforeOperation']}: '
            '${idle['idleTimeMs']}ms',
          );
        }
        buffer.writeln('');
      }
    }

    buffer.writeln('═══════════════════════════════════════════════════════════');
    
    return buffer.toString();
  }

  /// Limpiar métricas
  void clearMetrics() {
    _metrics.clear();
    _activeTimers.clear();
  }
}
