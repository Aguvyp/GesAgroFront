import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../core/config/app_config.dart';
import '../core/config/auth_config.dart';
import '../core/logger/app_logger.dart';
import '../services/optimized_auth_service.dart';

/// Resultado de una prueba de endpoint
class EndpointTestResult {
  final String endpoint;
  final String method;
  final int? statusCode;
  final Duration duration;
  final bool success;
  final String? error;
  final Map<String, dynamic>? requestData;
  final Map<String, dynamic>? responseData;
  final Map<String, String>? requestHeaders;
  final String? fullUrl;
  final Map<String, dynamic>? queryParams;

  EndpointTestResult({
    required this.endpoint,
    required this.method,
    this.statusCode,
    required this.duration,
    required this.success,
    this.error,
    this.requestData,
    this.responseData,
    this.requestHeaders,
    this.fullUrl,
    this.queryParams,
  });

  Map<String, dynamic> toJson() {
    return {
      'endpoint': endpoint,
      'method': method,
      'statusCode': statusCode,
      'durationMs': duration.inMilliseconds,
      'success': success,
      'error': error,
      'requestData': requestData,
      'responseData': responseData != null ? _truncateResponse(responseData!) : null,
      'requestHeaders': requestHeaders != null ? _sanitizeHeaders(requestHeaders!) : null,
      'fullUrl': fullUrl,
      'queryParams': queryParams,
    };
  }

  Map<String, dynamic> _truncateResponse(Map<String, dynamic> data) {
    // Limitar el tamaño de la respuesta para logs
    if (data.toString().length > 500) {
      return {'truncated': true, 'size': data.toString().length};
    }
    return data;
  }

  Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    final sanitized = <String, String>{};
    headers.forEach((key, value) {
      if (key.toLowerCase() == 'authorization') {
        sanitized[key] = value.length > 20 
            ? '${value.substring(0, 20)}...' 
            : value;
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }
}

/// Definición de un endpoint a probar
class EndpointDefinition {
  final String endpoint;
  final String method;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? queryParams;
  final bool requiresAuth;
  final int? expectedStatusCode;

  EndpointDefinition({
    required this.endpoint,
    required this.method,
    this.data,
    this.queryParams,
    this.requiresAuth = true,
    this.expectedStatusCode = 200,
  });
}

/// Tester completo de endpoints
class EndpointTester {
  final Dio _dio = Dio();
  final AppLogger _logger = AppLogger.instance;
  final List<EndpointTestResult> _results = [];
  
  // #region agent log
  void _logToFile(Map<String, dynamic> data) {
    // Solo loggear a consola ya que el sistema de archivos es de solo lectura
    // Los logs detallados se pueden ver en la consola de Flutter
    try {
      final logEntry = {
        'id': 'endpoint_test_${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'location': 'endpoint_tester.dart',
        'message': data['message'] ?? 'Endpoint test',
        'data': data,
        'sessionId': 'endpoint-test-session',
        'runId': 'run1',
        'hypothesisId': 'A',
      };
      
      // Log a consola en formato JSON para fácil parsing
      print('🔵 [ENDPOINT_TEST] ${jsonEncode(logEntry)}');
      _logger.debug('📝 Log: ${data['message']}');
    } catch (e) {
      // Si falla el JSON encoding, solo imprimir el mensaje
      print('🔵 [ENDPOINT_TEST] ${data['message'] ?? 'Endpoint test'}: $e');
      _logger.warning('⚠️ Error procesando log: $e');
    }
  }
  // #endregion

  Future<void> initialize() async {
    // #region agent log
    _logToFile({
      'message': 'EndpointTester initialization started',
      'timestamp': DateTime.now().toIso8601String(),
    });
    // #endregion
    
    // Solo inicializar AppConfig si no está inicializado
    if (!AppConfig.instance.isInitialized) {
      await AppConfig.instance.initialize();
    }
    await AuthConfig.initializeToken();
    
    final baseUrl = AppConfig.instance.apiBaseUrl.trim();
    final normalizedBaseUrl = baseUrl.endsWith('/') 
        ? baseUrl.substring(0, baseUrl.length - 1) 
        : baseUrl;
    
    _dio.options = BaseOptions(
      baseUrl: normalizedBaseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    // #region agent log
    _logToFile({
      'message': 'EndpointTester initialized',
      'baseUrl': normalizedBaseUrl,
    });
    // #endregion
    
    _logger.info('✅ EndpointTester inicializado con baseUrl: $normalizedBaseUrl');
  }

  /// Probar un endpoint individual
  Future<EndpointTestResult> testEndpoint(EndpointDefinition definition) async {
    final stopwatch = Stopwatch()..start();
    
    // #region agent log
    _logToFile({
      'message': 'Testing endpoint',
      'endpoint': definition.endpoint,
      'method': definition.method,
      'requiresAuth': definition.requiresAuth,
    });
    // #endregion

    // Preparar headers
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };

    try {
      if (definition.requiresAuth) {
        // Intentar obtener el access_token del login primero (como hace OptimizedHttpClient)
        String? token;
        String tokenSource = 'none';
        
        try {
          final authService = AuthService();
          await authService.initialize();
          token = await authService.getToken();
          if (token != null && token.isNotEmpty) {
            tokenSource = 'login';
            _logger.info('🔐 Usando access_token del login para: ${definition.endpoint}');
          }
        } catch (e) {
          _logger.debug('No se pudo obtener token del login: $e');
        }
        
        // Si no hay token del login, usar el token fijo de AuthConfig como fallback
        if (token == null || token.isEmpty) {
          token = await AuthConfig.getToken();
          if (token != null && token.isNotEmpty) {
            tokenSource = 'fixed';
            _logger.info('🔐 Usando token fijo de AuthConfig para: ${definition.endpoint}');
          }
        }
        
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
          
          // #region agent log
          _logToFile({
            'message': 'Authorization token added',
            'endpoint': definition.endpoint,
            'tokenLength': token.length,
            'tokenPrefix': token.substring(0, token.length > 20 ? 20 : token.length),
            'tokenSource': tokenSource,
            'hasToken': true,
          });
          // #endregion
          
          _logger.info('🔐 Token agregado para ${definition.endpoint} (longitud: ${token.length}, fuente: $tokenSource)');
        } else {
          // #region agent log
          _logToFile({
            'message': 'No token available',
            'endpoint': definition.endpoint,
            'requiresAuth': true,
            'hasToken': false,
          });
          // #endregion
          
          _logger.warning('⚠️ Endpoint requiere auth pero no hay token disponible: ${definition.endpoint}');
        }
      } else {
        // #region agent log
        _logToFile({
          'message': 'No auth required',
          'endpoint': definition.endpoint,
          'requiresAuth': false,
        });
        // #endregion
      }

      // Normalizar endpoint
      String normalizedEndpoint = definition.endpoint;
      if (!normalizedEndpoint.startsWith('/')) {
        normalizedEndpoint = '/$normalizedEndpoint';
      }
      if (!normalizedEndpoint.endsWith('/') && normalizedEndpoint != '/') {
        normalizedEndpoint = '${normalizedEndpoint}/';
      }

      // #region agent log
      _logToFile({
        'message': 'Request prepared',
        'endpoint': normalizedEndpoint,
        'headers': headers.keys.toList(),
        'hasData': definition.data != null,
        'hasQueryParams': definition.queryParams != null,
      });
      // #endregion

      // Realizar petición
      Response? response;

      switch (definition.method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(
            normalizedEndpoint,
            queryParameters: definition.queryParams,
            options: Options(headers: headers),
          );
          break;
        case 'POST':
          response = await _dio.post(
            normalizedEndpoint,
            data: definition.data,
            queryParameters: definition.queryParams,
            options: Options(headers: headers),
          );
          break;
        case 'PUT':
          response = await _dio.put(
            normalizedEndpoint,
            data: definition.data,
            queryParameters: definition.queryParams,
            options: Options(headers: headers),
          );
          break;
        case 'DELETE':
          response = await _dio.delete(
            normalizedEndpoint,
            data: definition.data,
            queryParameters: definition.queryParams,
            options: Options(headers: headers),
          );
          break;
        case 'PATCH':
          response = await _dio.patch(
            normalizedEndpoint,
            data: definition.data,
            queryParameters: definition.queryParams,
            options: Options(headers: headers),
          );
          break;
      }

      stopwatch.stop();
      final duration = stopwatch.elapsed;

      // #region agent log
      _logToFile({
        'message': 'Response received',
        'endpoint': normalizedEndpoint,
        'statusCode': response?.statusCode,
        'durationMs': duration.inMilliseconds,
        'hasResponseData': response?.data != null,
      });
      // #endregion

      // Construir URL completa
      final baseUrl = _dio.options.baseUrl;
      String fullUrl = '$baseUrl$normalizedEndpoint';
      if (definition.queryParams != null && definition.queryParams!.isNotEmpty) {
        final queryString = definition.queryParams!
            .entries
            .map((e) => '${Uri.encodeComponent(e.key.toString())}=${Uri.encodeComponent(e.value.toString())}')
            .join('&');
        fullUrl = '$fullUrl?$queryString';
      }

      final result = EndpointTestResult(
        endpoint: normalizedEndpoint,
        method: definition.method,
        statusCode: response?.statusCode,
        duration: duration,
        success: response?.statusCode == definition.expectedStatusCode,
        requestData: definition.data,
        responseData: response?.data is Map 
            ? response!.data as Map<String, dynamic>
            : response?.data is List
                ? {'list_length': (response!.data as List).length}
                : null,
        requestHeaders: headers,
        fullUrl: fullUrl,
        queryParams: definition.queryParams,
      );

      _results.add(result);
      return result;
    } catch (e) {
      stopwatch.stop();
      final duration = stopwatch.elapsed;

      // #region agent log
      _logToFile({
        'message': 'Request failed',
        'endpoint': definition.endpoint,
        'error': e.toString(),
        'durationMs': duration.inMilliseconds,
      });
      // #endregion

      int? statusCode;
      if (e is DioException) {
        statusCode = e.response?.statusCode;
      }

      // Construir URL completa para el error
      final baseUrl = _dio.options.baseUrl;
      String fullUrl = '$baseUrl${definition.endpoint}';
      if (definition.queryParams != null && definition.queryParams!.isNotEmpty) {
        final queryString = definition.queryParams!
            .entries
            .map((e) => '${Uri.encodeComponent(e.key.toString())}=${Uri.encodeComponent(e.value.toString())}')
            .join('&');
        fullUrl = '$fullUrl?$queryString';
      }

      final result = EndpointTestResult(
        endpoint: definition.endpoint,
        method: definition.method,
        statusCode: statusCode,
        duration: duration,
        success: false,
        error: e.toString(),
        requestData: definition.data,
        requestHeaders: headers,
        fullUrl: fullUrl,
        queryParams: definition.queryParams,
      );

      _results.add(result);
      return result;
    }
  }

  /// Obtener todos los endpoints a probar
  List<EndpointDefinition> getAllEndpoints() {
    return [
      // Autenticación (sin auth)
      EndpointDefinition(
        endpoint: '/api/auth/test/',
        method: 'GET',
        requiresAuth: false,
      ),
      EndpointDefinition(
        endpoint: '/api/health/',
        method: 'GET',
        requiresAuth: false,
      ),

      // Usuarios
      EndpointDefinition(endpoint: '/api/usuarios/', method: 'GET', queryParams: {'skip': 0, 'limit': 10}),
      
      // Campos
      EndpointDefinition(endpoint: '/api/campos/', method: 'GET', queryParams: {'skip': 0, 'limit': 10}),
      EndpointDefinition(endpoint: '/api/flutter/campos/lista', method: 'GET'),
      
      // Máquinas
      EndpointDefinition(endpoint: '/api/maquinas/', method: 'GET'),
      EndpointDefinition(endpoint: '/api/flutter/maquinas/lista', method: 'GET'),
      
      // Personal
      EndpointDefinition(endpoint: '/api/personal', method: 'GET'),
      EndpointDefinition(endpoint: '/api/flutter/personal/lista', method: 'GET'),
      
      // Clientes
      EndpointDefinition(endpoint: '/api/clientes/', method: 'GET'),
      EndpointDefinition(endpoint: '/api/flutter/clientes/lista', method: 'GET'),
      
      // Costos
      EndpointDefinition(endpoint: '/api/costos/pagados', method: 'GET'),
      EndpointDefinition(endpoint: '/api/costos/pendientes', method: 'GET'),
      EndpointDefinition(endpoint: '/api/flutter/costos/lista', method: 'GET'),
      
      // Facturas
      EndpointDefinition(endpoint: '/api/facturas/', method: 'GET'),
      EndpointDefinition(endpoint: '/api/flutter/facturas/lista', method: 'GET'),
      
      // Trabajos
      EndpointDefinition(endpoint: '/api/trabajos/', method: 'GET'),
      EndpointDefinition(
        endpoint: '/api/flutter/trabajos/lista',
        method: 'GET',
        queryParams: {'skip': 0, 'limit': 10},
      ),
      
      // Insumos
      EndpointDefinition(endpoint: '/api/insumos/', method: 'GET'),
      
      // Mantenimientos
      EndpointDefinition(endpoint: '/api/mantenimientos/', method: 'GET'),
      
      // Créditos
      EndpointDefinition(endpoint: '/api/creditos/', method: 'GET'),
      
      // Movimientos
      EndpointDefinition(endpoint: '/api/movimientos/', method: 'GET'),
      
      // Tipos de trabajo
      EndpointDefinition(endpoint: '/api/tipo-trabajo/', method: 'GET'),
      
      // Pagos
      EndpointDefinition(endpoint: '/api/pagos/', method: 'GET'),
      
      // Cuotas de crédito
      EndpointDefinition(endpoint: '/api/cuotas-credito/', method: 'GET'),
      
      // Dashboard
      EndpointDefinition(endpoint: '/api/dashboard/resumen', method: 'GET'),
      EndpointDefinition(endpoint: '/api/dashboard/estadisticas', method: 'GET'),
      EndpointDefinition(endpoint: '/api/flutter/dashboard/resumen', method: 'GET'),
      
      // Reportes
      EndpointDefinition(endpoint: '/api/reportes/trabajos', method: 'GET'),
      EndpointDefinition(endpoint: '/api/reportes/financiero', method: 'GET'),
      
      // Móvil
      EndpointDefinition(endpoint: '/api/mobile/sync', method: 'GET'),
    ];
  }

  /// Ejecutar todas las pruebas
  Future<Map<String, dynamic>> runAllTests() async {
    _logger.info('🚀 Iniciando pruebas de endpoints...');
    
    // #region agent log
    _logToFile({
      'message': 'Starting all endpoint tests',
      'totalEndpoints': getAllEndpoints().length,
      'timestamp': DateTime.now().toIso8601String(),
    });
    // #endregion
    
    try {
      await initialize();
    } catch (e) {
      _logger.error('❌ Error inicializando EndpointTester: $e');
      // #region agent log
      _logToFile({
        'message': 'Error initializing EndpointTester',
        'error': e.toString(),
      });
      // #endregion
      rethrow;
    }

    final endpoints = getAllEndpoints();
    final total = endpoints.length;
    var completed = 0;
    var successful = 0;
    var failed = 0;
    
    final startTime = DateTime.now();
    
    for (final endpoint in endpoints) {
      completed++;
      final result = await testEndpoint(endpoint);
      
      if (result.success) {
        successful++;
      } else {
        failed++;
      }
      
      _logger.info(
        '[$completed/$total] ${result.method} ${result.endpoint} - '
        '${result.success ? "✅" : "❌"} ${result.statusCode ?? "N/A"} '
        '(${result.duration.inMilliseconds}ms)',
      );
      
      // Pequeña pausa entre requests para no saturar
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    final endTime = DateTime.now();
    final totalDuration = endTime.difference(startTime);

    // #region agent log
    _logToFile({
      'message': 'All endpoint tests completed',
      'total': total,
      'successful': successful,
      'failed': failed,
      'totalDurationMs': totalDuration.inMilliseconds,
    });
    // #endregion

    // Calcular estadísticas
    final durations = _results.map((r) => r.duration.inMilliseconds).toList();
    durations.sort();
    
    final avgDuration = durations.isEmpty 
        ? 0 
        : durations.reduce((a, b) => a + b) / durations.length;
    final minDuration = durations.isEmpty ? 0 : durations.first;
    final maxDuration = durations.isEmpty ? 0 : durations.last;
    final medianDuration = durations.isEmpty 
        ? 0 
        : durations[durations.length ~/ 2];

    // Endpoints lentos (> 2 segundos)
    final slowEndpoints = _results
        .where((r) => r.duration.inMilliseconds > 2000)
        .map((r) => {
              'endpoint': r.endpoint,
              'method': r.method,
              'durationMs': r.duration.inMilliseconds,
            })
        .toList();

    // Endpoints fallidos
    final failedEndpoints = _results
        .where((r) => !r.success)
        .map((r) => {
              'endpoint': r.endpoint,
              'method': r.method,
              'statusCode': r.statusCode,
              'error': r.error,
            })
        .toList();

    // Preparar resultados para el reporte
    final resultsForReport = {
      'summary': {
        'total': total,
        'successful': successful,
        'failed': failed,
        'successRate': total > 0 ? (successful / total * 100).toStringAsFixed(2) : '0.00',
        'totalDurationMs': totalDuration.inMilliseconds,
        'avgDurationMs': avgDuration.toStringAsFixed(2),
        'minDurationMs': minDuration,
        'maxDurationMs': maxDuration,
        'medianDurationMs': medianDuration,
      },
      'slowEndpoints': slowEndpoints,
      'failedEndpoints': failedEndpoints,
      'allResults': _results.map((r) => r.toJson()).toList(),
    };

    // Guardar reporte de endpoints fallidos en .txt ANTES del return
    if (failed > 0) {
      try {
        final reportFileName = await saveFailedEndpointsReport(resultsForReport);
        _logger.info('📄 Reporte guardado: $reportFileName');
        print('📄 Reporte de endpoints fallidos guardado en: $reportFileName');
      } catch (e) {
        _logger.warning('⚠️ Error guardando reporte .txt: $e');
        print('⚠️ Error guardando reporte .txt: $e');
      }
    }

    return resultsForReport;
  }

  /// Generar reporte en texto
  String generateReport(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    final summary = results['summary'] as Map<String, dynamic>;
    
    buffer.writeln('═══════════════════════════════════════════════════════════');
    buffer.writeln('📊 REPORTE DE PRUEBAS DE ENDPOINTS');
    buffer.writeln('═══════════════════════════════════════════════════════════');
    buffer.writeln('');
    buffer.writeln('📈 RESUMEN:');
    buffer.writeln('   Total de endpoints probados: ${summary['total']}');
    buffer.writeln('   ✅ Exitosos: ${summary['successful']}');
    buffer.writeln('   ❌ Fallidos: ${summary['failed']}');
    buffer.writeln('   📊 Tasa de éxito: ${summary['successRate']}%');
    buffer.writeln('   ⏱️  Duración total: ${summary['totalDurationMs']}ms');
    buffer.writeln('');
    buffer.writeln('⏱️  TIEMPOS:');
    buffer.writeln('   Promedio: ${summary['avgDurationMs']}ms');
    buffer.writeln('   Mínimo: ${summary['minDurationMs']}ms');
    buffer.writeln('   Máximo: ${summary['maxDurationMs']}ms');
    buffer.writeln('   Mediana: ${summary['medianDurationMs']}ms');
    buffer.writeln('');

    final slowEndpoints = results['slowEndpoints'] as List;
    if (slowEndpoints.isNotEmpty) {
      buffer.writeln('🐌 ENDPOINTS LENTOS (> 2s):');
      for (final endpoint in slowEndpoints) {
        buffer.writeln(
          '   ${endpoint['method']} ${endpoint['endpoint']} - '
          '${endpoint['durationMs']}ms',
        );
      }
      buffer.writeln('');
    }

    final failedEndpoints = results['failedEndpoints'] as List;
    if (failedEndpoints.isNotEmpty) {
      buffer.writeln('❌ ENDPOINTS FALLIDOS:');
      for (final endpoint in failedEndpoints) {
        buffer.writeln(
          '   ${endpoint['method']} ${endpoint['endpoint']} - '
          'Status: ${endpoint['statusCode'] ?? "N/A"}',
        );
        if (endpoint['error'] != null) {
          buffer.writeln('      Error: ${endpoint['error']}');
        }
      }
      buffer.writeln('');
    }

    buffer.writeln('═══════════════════════════════════════════════════════════');
    
    return buffer.toString();
  }

  /// Generar reporte en formato Markdown para el backend
  String generateFailedEndpointsMarkdown(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    final summary = results['summary'] as Map<String, dynamic>;
    final failedResults = _results.where((r) => !r.success).toList();
    
    buffer.writeln('# ❌ Endpoints Fallidos - Reporte para Backend\n');
    buffer.writeln('**Fecha de Prueba:** ${DateTime.now().toIso8601String()}\n');
    buffer.writeln('**Resumen:**');
    buffer.writeln('- Total de endpoints probados: ${summary['total']}');
    buffer.writeln('- Endpoints exitosos: ${summary['successful']}');
    buffer.writeln('- **Endpoints fallidos: ${summary['failed']}**\n');
    buffer.writeln('---\n');
    
    if (failedResults.isEmpty) {
      buffer.writeln('✅ **¡Excelente! Todos los endpoints funcionaron correctamente.**\n');
      return buffer.toString();
    }
    
    buffer.writeln('## 📋 Detalle de Endpoints Fallidos\n');
    
    for (int i = 0; i < failedResults.length; i++) {
      final result = failedResults[i];
      buffer.writeln('### ${i + 1}. ${result.method} ${result.endpoint}\n');
      
      // URL completa
      if (result.fullUrl != null) {
        buffer.writeln('**URL Completa:**');
        buffer.writeln('```');
        buffer.writeln(result.fullUrl);
        buffer.writeln('```\n');
      }
      
      // Método HTTP
      buffer.writeln('**Método HTTP:** `${result.method}`\n');
      
      // Headers
      if (result.requestHeaders != null && result.requestHeaders!.isNotEmpty) {
        buffer.writeln('**Headers Enviados:**');
        buffer.writeln('```json');
        final headersJson = <String, String>{};
        bool hasAuthHeader = false;
        String? tokenValue;
        
        result.requestHeaders!.forEach((key, value) {
          if (key.toLowerCase() == 'authorization') {
            hasAuthHeader = true;
            // Extraer el token del Bearer token
            if (value.startsWith('Bearer ')) {
              final extractedToken = value.substring(7);
              tokenValue = extractedToken;
              if (extractedToken.isNotEmpty) {
                headersJson[key] = 'Bearer ${extractedToken.length > 20 ? extractedToken.substring(0, 20) + "..." : extractedToken}';
              } else {
                headersJson[key] = value;
              }
            } else {
              headersJson[key] = value.length > 30 
                  ? '${value.substring(0, 30)}...'
                  : value;
            }
          } else {
            headersJson[key] = value;
          }
        });
        buffer.writeln(const JsonEncoder.withIndent('  ').convert(headersJson));
        buffer.writeln('```\n');
        
        // Información adicional sobre el token
        final finalTokenValue = tokenValue;
        if (hasAuthHeader && finalTokenValue != null && finalTokenValue.isNotEmpty) {
          buffer.writeln('**Información del Token de Autorización:**');
          buffer.writeln('- ✅ Header Authorization: **ENVIADO**');
          buffer.writeln('- Formato: Bearer token');
          buffer.writeln('- Longitud del token: ${finalTokenValue.length} caracteres');
          buffer.writeln('- Token (primeros 20 caracteres): `${finalTokenValue.length > 20 ? finalTokenValue.substring(0, 20) : finalTokenValue}`');
          buffer.writeln('');
        } else if (!hasAuthHeader) {
          buffer.writeln('⚠️ **ADVERTENCIA:** No se envió el header Authorization en este request.\n');
        }
      } else {
        buffer.writeln('⚠️ **ADVERTENCIA:** No se enviaron headers en el request.\n');
      }
      
      // Query Parameters
      if (result.queryParams != null && result.queryParams!.isNotEmpty) {
        buffer.writeln('**Query Parameters:**');
        buffer.writeln('```json');
        buffer.writeln(const JsonEncoder.withIndent('  ').convert(result.queryParams));
        buffer.writeln('```\n');
      }
      
      // Body (si existe)
      if (result.requestData != null && result.requestData!.isNotEmpty) {
        buffer.writeln('**Body Enviado:**');
        buffer.writeln('```json');
        buffer.writeln(const JsonEncoder.withIndent('  ').convert(result.requestData));
        buffer.writeln('```\n');
      }
      
      // Status Code recibido
      if (result.statusCode != null) {
        buffer.writeln('**Status Code Recibido:** `${result.statusCode}`\n');
      }
      
      // Error
      if (result.error != null) {
        buffer.writeln('**Error:**');
        buffer.writeln('```');
        buffer.writeln(result.error);
        buffer.writeln('```\n');
      }
      
      // Response Data (si existe)
      if (result.responseData != null) {
        buffer.writeln('**Respuesta del Servidor:**');
        buffer.writeln('```json');
        try {
          buffer.writeln(const JsonEncoder.withIndent('  ').convert(result.responseData));
        } catch (e) {
          buffer.writeln(result.responseData.toString());
        }
        buffer.writeln('```\n');
      }
      
      // Tiempo de respuesta
      buffer.writeln('**Tiempo de Respuesta:** ${result.duration.inMilliseconds}ms\n');
      
      buffer.writeln('---\n');
    }
    
    buffer.writeln('## 📝 Notas\n');
    buffer.writeln('- Este reporte contiene todos los endpoints que fallaron durante las pruebas.');
    buffer.writeln('- Cada endpoint incluye el request completo que se envió.');
    buffer.writeln('- Los tokens de autenticación están parcialmente ocultos por seguridad.');
    buffer.writeln('- Por favor, revisar cada endpoint y verificar por qué falló.\n');
    
    return buffer.toString();
  }

  /// Guardar reporte de endpoints fallidos en archivo .txt
  Future<String> saveFailedEndpointsReport(Map<String, dynamic> results) async {
    try {
      final report = generateFailedEndpointsMarkdown(results);
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      
      // Intentar múltiples ubicaciones para guardar el archivo
      final possiblePaths = [
        'endpoints_fallidos_$timestamp.txt', // Directorio actual
        r'c:\Users\usuario\Repos\GesAgroFront\endpoints_fallidos_$timestamp.txt', // Ruta absoluta
      ];
      
      String? savedPath;
      Exception? lastError;
      
      for (final path in possiblePaths) {
        try {
          final fileName = path.replaceAll('\$timestamp', timestamp);
          final file = File(fileName);
          
          // #region agent log
          _logToFile({
            'message': 'Attempting to save report',
            'path': fileName,
            'reportLength': report.length,
          });
          // #endregion
          
          await file.writeAsString(report, encoding: utf8);
          
          // Verificar que el archivo se creó
          if (await file.exists()) {
            savedPath = fileName;
            _logger.info('📄 Reporte de endpoints fallidos guardado en: $fileName');
            print('📄 Reporte de endpoints fallidos guardado en: $fileName');
            print('📄 Ruta completa: ${file.absolute.path}');
            break;
          } else {
            _logger.warning('⚠️ Archivo no se creó en: $fileName');
            print('⚠️ Archivo no se creó en: $fileName');
          }
        } catch (e) {
          lastError = e is Exception ? e : Exception(e.toString());
          _logger.warning('⚠️ Error intentando guardar en $path: $e');
          print('⚠️ Error intentando guardar en $path: $e');
          continue;
        }
      }
      
      if (savedPath != null) {
        return savedPath;
      } else {
        throw lastError ?? Exception('No se pudo guardar el archivo en ninguna ubicación');
      }
    } catch (e, stackTrace) {
      _logger.error('❌ Error guardando reporte: $e');
      _logger.error('Stack trace: $stackTrace');
      print('❌ Error guardando reporte: $e');
      print('Stack trace: $stackTrace');
      
      // #region agent log
      _logToFile({
        'message': 'Failed to save report',
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      });
      // #endregion
      
      // Si falla, al menos devolver el contenido para mostrarlo
      return 'ERROR: No se pudo guardar. Contenido: ${generateFailedEndpointsMarkdown(results).substring(0, 100)}...';
    }
  }
}
