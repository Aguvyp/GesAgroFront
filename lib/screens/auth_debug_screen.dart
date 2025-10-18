import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/optimized_api_service.dart';
import '../core/network/optimized_http_client.dart';
import '../core/logger/app_logger.dart';

class AuthDebugScreen extends ConsumerStatefulWidget {
  const AuthDebugScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthDebugScreen> createState() => _AuthDebugScreenState();
}

class _AuthDebugScreenState extends ConsumerState<AuthDebugScreen> {
  Map<String, dynamic>? _authInfo;
  Map<String, dynamic>? _httpClientInfo;
  bool _isLoading = false;
  final AppLogger _logger = AppLogger.instance;

  @override
  void initState() {
    super.initState();
    _loadAuthInfo();
  }

  Future<void> _loadAuthInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final httpClient = OptimizedHttpClient.instance;
      await httpClient.initialize();

      // Información simple sobre el token fijo
      final authInfo = {
        'isAuthenticated': true,
        'hasToken': true,
        'tokenType': 'Bearer',
        'userRole': 'Administrador',
        'tokenPreview':
            'aB3xK9mP2qR7sT1vW4yZ6cD8eF0gH5jL3nM9pQ2rS7tU1vX4yA6bC8dE0fG5hI',
        'method': 'Token fijo configurado',
      };

      final httpClientInfo = {
        'hasToken': true,
        'tokenLength': 200,
        'tokenType': 'Bearer',
        'userRole': 'Administrador',
        'tokenPreview':
            'aB3xK9mP2qR7sT1vW4yZ6cD8eF0gH5jL3nM9pQ2rS7tU1vX4yA6bC8dE0fG5hI',
        'method': 'Token fijo en interceptor',
      };

      setState(() {
        _authInfo = authInfo;
        _httpClientInfo = httpClientInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _logger.error('Error loading auth info', e);
    }
  }

  Future<void> _testApiCall() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      await apiService.initialize();

      // Intentar hacer una llamada a la API
      final campos = await apiService.getCampos();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('API call exitosa: ${campos.length} campos'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en API call: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug de Autenticación'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información de autenticación
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estado de Autenticación',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_authInfo != null) ...[
                            _buildInfoRow(
                                'Autenticado', _authInfo!['isAuthenticated']),
                            _buildInfoRow(
                                'Tiene Token', _authInfo!['hasToken']),
                            _buildInfoRow('Método', _authInfo!['method']),
                            _buildInfoRow(
                                'Rol de Usuario', _authInfo!['userRole']),
                            _buildInfoRow(
                                'Tipo de Token', _authInfo!['tokenType']),
                            _buildInfoRow('Vista Previa del Token',
                                _authInfo!['tokenPreview']),
                          ] else
                            const Text('No se pudo cargar la información'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Información del HTTP Client
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HTTP Client',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_httpClientInfo != null) ...[
                            _buildInfoRow(
                                'Tiene Token', _httpClientInfo!['hasToken']),
                            _buildInfoRow('Longitud del Token',
                                _httpClientInfo!['tokenLength']),
                            _buildInfoRow('Método', _httpClientInfo!['method']),
                            _buildInfoRow(
                                'Tipo de Token', _httpClientInfo!['tokenType']),
                            _buildInfoRow(
                                'Rol de Usuario', _httpClientInfo!['userRole']),
                            _buildInfoRow('Vista Previa del Token',
                                _httpClientInfo!['tokenPreview']),
                          ] else
                            const Text('No se pudo cargar la información'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _testApiCall,
                          icon: const Icon(Icons.api),
                          label: const Text('Probar API'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _loadAuthInfo,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Actualizar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'null',
              style: TextStyle(
                color: value == true
                    ? Colors.green
                    : value == false
                        ? Colors.red
                        : Colors.black,
                fontWeight: value == true || value == false
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
