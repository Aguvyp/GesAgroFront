import 'dart:io';
import 'lib/utils/endpoint_tester.dart';
import 'lib/utils/performance_analyzer.dart';
import 'lib/core/config/app_config.dart';

Future<void> main() async {
  print('═══════════════════════════════════════════════════════════');
  print('🧪 INICIANDO PRUEBAS COMPLETAS');
  print('═══════════════════════════════════════════════════════════');
  print('');

  try {
    // Inicializar configuración
    print('📋 Inicializando configuración...');
    await AppConfig.instance.initialize();
    print('✅ Configuración inicializada\n');

    // PRUEBA 1: Endpoints
    print('═══════════════════════════════════════════════════════════');
    print('🔍 PRUEBA 1: TESTING DE ENDPOINTS');
    print('═══════════════════════════════════════════════════════════');
    print('');

    final endpointTester = EndpointTester();
    final endpointResults = await endpointTester.runAllTests();
    final endpointReport = endpointTester.generateReport(endpointResults);

    print(endpointReport);
    print('');

    // PRUEBA 2: Análisis de rendimiento
    print('═══════════════════════════════════════════════════════════');
    print('⚡ PRUEBA 2: ANÁLISIS DE RENDIMIENTO');
    print('═══════════════════════════════════════════════════════════');
    print('');

    final performanceAnalyzer = PerformanceAnalyzer();
    final performanceResults = await performanceAnalyzer.generateFullReport();
    final performanceReport = performanceAnalyzer.generateTextReport(performanceResults);

    print(performanceReport);
    print('');

    // RESUMEN FINAL
    print('═══════════════════════════════════════════════════════════');
    print('📊 RESUMEN FINAL');
    print('═══════════════════════════════════════════════════════════');
    print('');

    final endpointSummary = endpointResults['summary'] as Map<String, dynamic>;
    print('🔍 ENDPOINTS:');
    print('   Total: ${endpointSummary['total']}');
    print('   Exitosos: ${endpointSummary['successful']}');
    print('   Fallidos: ${endpointSummary['failed']}');
    print('   Tasa de éxito: ${endpointSummary['successRate']}%');
    print('   Tiempo promedio: ${endpointSummary['avgDurationMs']}ms');
    print('');

    if (performanceResults.containsKey('generalStats')) {
      final perfStats = performanceResults['generalStats'] as Map<String, dynamic>;
      print('⚡ RENDIMIENTO:');
      print('   Operaciones: ${perfStats['totalOperations']}');
      print('   Tiempo promedio: ${perfStats['avgDurationMs']}ms');
      print('   Tiempo total: ${perfStats['totalTimeMs']}ms');
      print('');
    }

    final slowEndpoints = endpointResults['slowEndpoints'] as List;
    if (slowEndpoints.isNotEmpty) {
      print('🐌 ENDPOINTS LENTOS: ${slowEndpoints.length}');
    }

    final failedEndpoints = endpointResults['failedEndpoints'] as List;
    if (failedEndpoints.isNotEmpty) {
      print('❌ ENDPOINTS FALLIDOS: ${failedEndpoints.length}');
      print('');
      print('Detalles de endpoints fallidos:');
      for (final failed in failedEndpoints) {
        print('   ${failed['method']} ${failed['endpoint']}');
        print('      Status: ${failed['statusCode'] ?? 'N/A'}');
        if (failed['error'] != null) {
          final error = failed['error'].toString();
          if (error.length > 100) {
            print('      Error: ${error.substring(0, 100)}...');
          } else {
            print('      Error: $error');
          }
        }
      }
    }

    print('');
    print('═══════════════════════════════════════════════════════════');
    print('✅ PRUEBAS COMPLETADAS');
    print('═══════════════════════════════════════════════════════════');
    print('');
    print('📝 Los logs detallados se han guardado en: .cursor/debug.log');
    print('');

  } catch (e, stackTrace) {
    print('');
    print('═══════════════════════════════════════════════════════════');
    print('❌ ERROR EN LAS PRUEBAS');
    print('═══════════════════════════════════════════════════════════');
    print('Error: $e');
    print('');
    print('Stack trace:');
    print(stackTrace);
    print('');
  }
  
  exit(0);
}
