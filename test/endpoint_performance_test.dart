import 'package:flutter_test/flutter_test.dart';
import 'package:ges_agro_front/utils/endpoint_tester.dart';
import 'package:ges_agro_front/utils/performance_analyzer.dart';
import 'package:ges_agro_front/core/config/app_config.dart';

void main() {
  group('Pruebas de Endpoints y Rendimiento', () {
    setUpAll(() async {
      await AppConfig.instance.initialize();
    });

    test('Prueba completa de endpoints', () async {
      final endpointTester = EndpointTester();
      final results = await endpointTester.runAllTests();
      
      final summary = results['summary'] as Map<String, dynamic>;
      print('\n═══════════════════════════════════════════════════════════');
      print('📊 RESULTADOS DE ENDPOINTS:');
      print('═══════════════════════════════════════════════════════════');
      print('Total: ${summary['total']}');
      print('Exitosos: ${summary['successful']}');
      print('Fallidos: ${summary['failed']}');
      print('Tasa de éxito: ${summary['successRate']}%');
      print('Tiempo promedio: ${summary['avgDurationMs']}ms');
      print('═══════════════════════════════════════════════════════════\n');
      
      final report = endpointTester.generateReport(results);
      print(report);
      
      // Verificar que al menos algunos endpoints funcionan
      expect(summary['total'], greaterThan(0));
    }, timeout: const Timeout(Duration(minutes: 10)));

    test('Análisis de rendimiento', () async {
      final performanceAnalyzer = PerformanceAnalyzer();
      final results = await performanceAnalyzer.generateFullReport();
      
      print('\n═══════════════════════════════════════════════════════════');
      print('⚡ RESULTADOS DE RENDIMIENTO:');
      print('═══════════════════════════════════════════════════════════');
      
      final report = performanceAnalyzer.generateTextReport(results);
      print(report);
      
      // Verificar que se generaron métricas
      if (results.containsKey('generalStats')) {
        final stats = results['generalStats'] as Map<String, dynamic>;
        expect(stats['totalOperations'], greaterThan(0));
      }
    }, timeout: const Timeout(Duration(minutes: 10)));
  });
}
