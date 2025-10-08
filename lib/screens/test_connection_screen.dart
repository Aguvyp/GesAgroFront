import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/optimized_api_service.dart';
import '../core/config/app_config.dart';

/// Pantalla de prueba de conexión con el backend
class TestConnectionScreen extends ConsumerStatefulWidget {
  const TestConnectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TestConnectionScreen> createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends ConsumerState<TestConnectionScreen> {
  bool _isLoading = false;
  String _status = 'No probado';
  Map<String, dynamic>? _testResults;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Conexión'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prueba de Conexión con Backend',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'URL Base: ${AppConfig.instance.apiBaseUrl}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Estado de Conexión:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_testResults != null) ...[
                      const Text(
                        'Resultados de la Prueba:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _testResults.toString(),
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testConnection,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_find),
                label: Text(_isLoading ? 'Probando...' : 'Probar Conexión'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testEndpoints,
                icon: const Icon(Icons.api),
                label: const Text('Probar Endpoints'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testAuth,
                icon: const Icon(Icons.security),
                label: const Text('Probar Autenticación'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_status.toLowerCase()) {
      case 'conectado':
        return Colors.green;
      case 'error':
        return Colors.red;
      case 'probando...':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Probando...';
      _testResults = null;
    });

    try {
      final apiService = ApiService();
      await apiService.initialize();
      
      final result = await apiService.testConnection();
      
      setState(() {
        _status = 'Conectado';
        _testResults = result;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Conexión exitosa con el backend'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _status = 'Error';
        _testResults = {'error': e.toString()};
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testEndpoints() async {
    setState(() {
      _isLoading = true;
      _status = 'Probando endpoints...';
    });

    try {
      final apiService = ApiService();
      await apiService.initialize();
      
      final results = <String, dynamic>{};
      
      // Probar diferentes endpoints
      try {
        final campos = await apiService.getCampos();
        results['campos'] = '✅ ${campos.length} campos encontrados';
      } catch (e) {
        results['campos'] = '❌ Error: $e';
      }
      
      try {
        final costos = await apiService.getCostos();
        results['costos'] = '✅ ${costos.length} costos encontrados';
      } catch (e) {
        results['costos'] = '❌ Error: $e';
      }
      
      try {
        final trabajos = await apiService.getTrabajos();
        results['trabajos'] = '✅ ${trabajos.length} trabajos encontrados';
      } catch (e) {
        results['trabajos'] = '❌ Error: $e';
      }
      
      setState(() {
        _status = 'Endpoints probados';
        _testResults = results;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Prueba de endpoints completada'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      setState(() {
        _status = 'Error en endpoints';
        _testResults = {'error': e.toString()};
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error probando endpoints: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testAuth() async {
    setState(() {
      _isLoading = true;
      _status = 'Probando autenticación...';
    });

    try {
      final apiService = ApiService();
      await apiService.initialize();
      
      // Probar login con credenciales de prueba
      final result = await apiService.login('test@ejemplo.com', 'password123');
      
      setState(() {
        _status = 'Autenticación exitosa';
        _testResults = {
          'login': '✅ Login exitoso',
          'token_type': result['token_type'],
          'role': result['role'],
        };
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Autenticación exitosa'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _status = 'Error de autenticación';
        _testResults = {'auth_error': e.toString()};
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error de autenticación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
