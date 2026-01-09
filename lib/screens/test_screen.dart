import 'package:flutter/material.dart';
import '../utils/endpoint_tester.dart';
import '../utils/performance_analyzer.dart';
import '../core/logger/app_logger.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final EndpointTester _endpointTester = EndpointTester();
  final PerformanceAnalyzer _performanceAnalyzer = PerformanceAnalyzer();
  final AppLogger _logger = AppLogger.instance;

  bool _isTestingEndpoints = false;
  bool _isAnalyzingPerformance = false;
  String _endpointReport = '';
  String _performanceReport = '';
  bool _autoRun = true;

  @override
  void initState() {
    super.initState();
    // Ejecutar pruebas automáticamente al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_autoRun) {
        _runAllTests();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pruebas y Análisis'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección de pruebas de endpoints
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '🔍 Prueba de Endpoints',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Prueba todos los endpoints de la API para verificar que funcionan correctamente y miden tiempos de respuesta.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isTestingEndpoints
                          ? null
                          : () => _testEndpoints(),
                      icon: _isTestingEndpoints
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow),
                      label: Text(_isTestingEndpoints
                          ? 'Probando...'
                          : 'Ejecutar Pruebas'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    if (_endpointReport.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _endpointReport,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Sección de análisis de rendimiento
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '⚡ Análisis de Rendimiento',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Analiza el rendimiento de la aplicación, identifica operaciones lentas y tiempos muertos.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isAnalyzingPerformance
                          ? null
                          : () => _analyzePerformance(),
                      icon: _isAnalyzingPerformance
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.speed),
                      label: Text(_isAnalyzingPerformance
                          ? 'Analizando...'
                          : 'Ejecutar Análisis'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    if (_performanceReport.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _performanceReport,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Botón para ejecutar ambas pruebas
            ElevatedButton.icon(
              onPressed: (_isTestingEndpoints || _isAnalyzingPerformance)
                  ? null
                  : () => _runAllTests(),
              icon: const Icon(Icons.check_circle),
              label: const Text('Ejecutar Todas las Pruebas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testEndpoints() async {
    setState(() {
      _isTestingEndpoints = true;
      _endpointReport = 'Iniciando pruebas de endpoints...\n';
    });

    try {
      _logger.info('🧪 Iniciando pruebas de endpoints...');
      final results = await _endpointTester.runAllTests();
      final report = _endpointTester.generateReport(results);

      setState(() {
        _endpointReport = report;
        _isTestingEndpoints = false;
      });

      _logger.info('✅ Pruebas de endpoints completadas');
      _logger.info('📊 Resumen: ${results['summary']}');
      
      // Mostrar resultados en consola también
      print('\n═══════════════════════════════════════════════════════════');
      print('📊 RESULTADOS DE PRUEBAS DE ENDPOINTS');
      print('═══════════════════════════════════════════════════════════');
      print(report);
      print('═══════════════════════════════════════════════════════════\n');
    } catch (e, stackTrace) {
      setState(() {
        _endpointReport = 'Error: $e\n\nStack trace: $stackTrace';
        _isTestingEndpoints = false;
      });
      _logger.error('❌ Error en pruebas de endpoints: $e');
      _logger.error('Stack trace: $stackTrace');
      print('❌ Error en pruebas de endpoints: $e');
    }
  }

  Future<void> _analyzePerformance() async {
    setState(() {
      _isAnalyzingPerformance = true;
      _performanceReport = 'Iniciando análisis de rendimiento...\n';
    });

    try {
      _logger.info('⚡ Iniciando análisis de rendimiento...');
      final results = await _performanceAnalyzer.generateFullReport();
      final report = _performanceAnalyzer.generateTextReport(results);

      setState(() {
        _performanceReport = report;
        _isAnalyzingPerformance = false;
      });

      _logger.info('✅ Análisis de rendimiento completado');
      
      // Mostrar resultados en consola también
      print('\n═══════════════════════════════════════════════════════════');
      print('⚡ RESULTADOS DE ANÁLISIS DE RENDIMIENTO');
      print('═══════════════════════════════════════════════════════════');
      print(report);
      print('═══════════════════════════════════════════════════════════\n');
    } catch (e, stackTrace) {
      setState(() {
        _performanceReport = 'Error: $e\n\nStack trace: $stackTrace';
        _isAnalyzingPerformance = false;
      });
      _logger.error('❌ Error en análisis de rendimiento: $e');
      _logger.error('Stack trace: $stackTrace');
      print('❌ Error en análisis de rendimiento: $e');
    }
  }

  Future<void> _runAllTests() async {
    await _testEndpoints();
    await Future.delayed(const Duration(seconds: 2));
    await _analyzePerformance();
  }
}
