import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/network/optimized_http_client.dart';
import '../core/logger/app_logger.dart';
import '../../models/campo.dart';
import '../../models/cliente.dart';
import '../../models/costo.dart';
import '../../models/credito.dart';
import '../../models/factura.dart';
import '../../models/insumo.dart';
import '../../models/mantenimiento.dart';
import '../../models/maquina.dart';
import '../../models/personal.dart';
import '../../models/trabajo.dart';
import '../../models/movimiento.dart';
import '../../models/usuario.dart';
import '../../models/tipo_trabajo.dart';
import '../../models/weather.dart';

/// Servicio API ultra optimizado con todos los endpoints
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

class ApiService {
  late final OptimizedHttpClient _httpClient;
  final AppLogger _logger = AppLogger.instance;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    _httpClient = OptimizedHttpClient.instance;
    await _httpClient.initialize();
    _isInitialized = true;
    _logger.info('ApiService initialized');
  }

  /// ==================== AUTENTICACIÓN ====================

  /// Login con token JWT
  Future<Map<String, dynamic>> login(String email, String password) async {
    _logger.info('═══════════════════════════════════════════════════════════');
    _logger.info('🔐 INICIANDO LOGIN');
    _logger.info('═══════════════════════════════════════════════════════════');
    _logger.info('📧 Email: $email');

    try {
      _logger.apiCall('POST', '/api/auth/login/', data: {'email': email});

      final response = await _httpClient.post('/api/auth/login/', data: {
        'email': email,
        'password': password,
      });

      _logger.info('✅ LOGIN EXITOSO');
      _logger.apiResponse('/api/auth/login/', response.statusCode!,
          data: response.data);
      return response.data;
    } catch (e) {
      _logger.error('❌ ERROR EN LOGIN');
      _logger.error('   Tipo de error: ${e.runtimeType}');
      _logger.error('   Mensaje: $e');

      if (e is DioException) {
        _logger.error('   DioException Type: ${e.type}');
        _logger.error('   Status Code: ${e.response?.statusCode}');
        _logger.error('   Request Path: ${e.requestOptions.path}');
        _logger.error('   Request Base URL: ${e.requestOptions.baseUrl}');
        _logger.error('   Request Headers: ${e.requestOptions.headers}');
        _logger.error('   Response Data: ${e.response?.data}');

        // Mensajes específicos según el tipo de error
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            _logger.error('   ⏱️ TIMEOUT DE CONEXIÓN');
            _logger.error('      - Verificar que ngrok esté corriendo');
            _logger
                .error('      - Verificar que el backend Django esté activo');
            _logger
                .error('      - Verificar la URL de ngrok en constants.dart');
            break;
          case DioExceptionType.receiveTimeout:
            _logger.error('   ⏱️ TIMEOUT DE RECEPCIÓN');
            _logger.error('      - El servidor tardó demasiado en responder');
            break;
          case DioExceptionType.connectionError:
            _logger.error('   🔌 ERROR DE CONEXIÓN');
            _logger.error('      - No se pudo conectar al servidor');
            _logger.error('      - Verificar conectividad de red');
            _logger.error('      - Verificar que ngrok esté activo');
            break;
          default:
            break;
        }
      }

      _logger
          .info('═══════════════════════════════════════════════════════════');
      rethrow;
    }
  }

  /// Registro de usuario
  Future<Map<String, dynamic>> register({
    required String nombre,
    required String dni,
    required String telefono,
    required String email,
    required String password,
  }) async {
    _logger.apiCall('POST', '/api/auth/register/', data: {
      'nombre': nombre,
      'dni': dni,
      'telefono': telefono,
      'email': email,
    });

    final response = await _httpClient.post('/api/auth/register/', data: {
      'nombre': nombre,
      'dni': dni,
      'telefono': telefono,
      'email': email,
      'password': password,
    });

    _logger.apiResponse('/api/auth/register/', response.statusCode!,
        data: response.data);
    return response.data;
  }

  /// Test de conexión
  Future<Map<String, dynamic>> testConnection() async {
    final response = await _httpClient.get('/api/auth/test/');
    return response.data;
  }

  /// ==================== USUARIOS ====================

  /// Listar usuarios
  Future<List<Usuario>> getUsuarios({int skip = 0, int limit = 100}) async {
    final response = await _httpClient.get('/api/usuarios/', queryParameters: {
      'skip': skip,
      'limit': limit,
    });

    return (response.data as List)
        .map((json) => Usuario.fromJson(json))
        .toList();
  }

  /// Obtener usuario por ID
  Future<Usuario> getUsuario(int id) async {
    final response = await _httpClient.get('/api/usuarios/$id');
    return Usuario.fromJson(response.data);
  }

  /// Crear usuario
  Future<Usuario> createUsuario(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/api/usuarios/create', data: data);
    return Usuario.fromJson(response.data);
  }

  /// Actualizar usuario
  Future<Usuario> updateUsuario(int id, Map<String, dynamic> data) async {
    final response =
        await _httpClient.put('/api/usuarios/$id/update', data: data);
    return Usuario.fromJson(response.data);
  }

  /// Eliminar usuario
  Future<void> deleteUsuario(int id) async {
    await _httpClient.delete('/api/usuarios/$id/delete');
  }

  /// ==================== CAMPOS ====================

  /// Listar campos
  Future<List<Campo>> getCampos({int skip = 0, int limit = 100}) async {
    final response = await _httpClient.get('/api/campos/', queryParameters: {
      'skip': skip,
      'limit': limit,
    });

    return (response.data as List).map((json) => Campo.fromJson(json)).toList();
  }

  /// Obtener campo por ID
  Future<Campo> getCampo(int id) async {
    final response = await _httpClient.get('/api/campos/$id');
    return Campo.fromJson(response.data);
  }

  /// Crear campo
  Future<Campo> createCampo(Map<String, dynamic> data) async {
    print('🔵 API SERVICE - createCampo - payload: $data');
    final response = await _httpClient.post('/api/campos/create', data: data);
    print('🔵 API SERVICE - createCampo - response: ${response.data}');
    return Campo.fromJson(response.data);
  }

  /// Actualizar campo
  Future<Campo> updateCampo(int id, Map<String, dynamic> data) async {
    final response =
        await _httpClient.put('/api/campos/$id/update', data: data);
    return Campo.fromJson(response.data);
  }

  /// Eliminar campo
  Future<void> deleteCampo(int id) async {
    await _httpClient.delete('/api/campos/$id/delete/');
  }

  /// ==================== MÁQUINAS ====================

  /// Listar máquinas
  Future<List<Maquina>> getMaquinas() async {
    final response = await _httpClient.get('/api/maquinas/');
    return (response.data as List)
        .map((json) => Maquina.fromJson(json))
        .toList();
  }

  /// Obtener máquina por ID
  Future<Maquina> getMaquina(int id) async {
    final response = await _httpClient.get('/api/maquinas/$id');
    return Maquina.fromJson(response.data);
  }

  /// Crear máquina
  Future<Maquina> createMaquina(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/api/maquinas/create', data: data);
    return Maquina.fromJson(response.data);
  }

  /// Actualizar máquina
  Future<Maquina> updateMaquina(int id, Map<String, dynamic> data) async {
    final response =
        await _httpClient.put('/api/maquinas/$id/update', data: data);
    return Maquina.fromJson(response.data);
  }

  /// Eliminar máquina
  Future<void> deleteMaquina(int id) async {
    await _httpClient.delete('/api/maquinas/$id/delete');
  }

  /// ==================== PERSONAL ====================

  /// Listar personal
  Future<List<Personal>> getPersonal() async {
    final response = await _httpClient.get('/api/personal');
    return (response.data as List)
        .map((json) => Personal.fromJson(json))
        .toList();
  }

  /// Obtener personal por ID
  Future<Personal> getPersonalById(int id) async {
    final response = await _httpClient.get('/api/personal/$id');
    return Personal.fromJson(response.data);
  }

  /// Crear personal
  Future<Personal> createPersonal(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/api/personal/create', data: data);
    return Personal.fromJson(response.data);
  }

  /// Actualizar personal
  Future<Personal> updatePersonal(int id, Map<String, dynamic> data) async {
    final response =
        await _httpClient.put('/api/personal/$id/update', data: data);
    return Personal.fromJson(response.data);
  }

  /// Eliminar personal
  Future<void> deletePersonal(int id) async {
    await _httpClient.delete('/api/personal/$id/delete');
  }

  /// Validar DNI
  Future<bool> validateDni(String dni, {int? excludeId}) async {
    final response =
        await _httpClient.get('/api/personal/validate-dni', queryParameters: {
      'dni': dni,
      if (excludeId != null) 'exclude_id': excludeId,
    });

    return response.data['available'] as bool;
  }

  /// ==================== CLIENTES ====================

  /// Listar clientes
  Future<List<Cliente>> getClientes() async {
    final response = await _httpClient.get('/api/clientes/');
    return (response.data as List)
        .map((json) => Cliente.fromJson(json))
        .toList();
  }

  /// Obtener cliente por ID
  Future<Cliente> getCliente(int id) async {
    final response = await _httpClient.get('/api/clientes/$id');
    return Cliente.fromJson(response.data);
  }

  /// Crear cliente
  Future<Cliente> createCliente(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/api/clientes/create', data: data);
    return Cliente.fromJson(response.data);
  }

  /// Actualizar cliente
  Future<Cliente> updateCliente(int id, Map<String, dynamic> data) async {
    final response =
        await _httpClient.put('/api/clientes/$id/update', data: data);
    return Cliente.fromJson(response.data);
  }

  /// Eliminar cliente
  Future<void> deleteCliente(int id) async {
    await _httpClient.delete('/api/clientes/$id/delete');
  }

  /// ==================== COSTOS ====================

  /// Listar costos
  Future<List<Costo>> getCostos() async {
    final responseData = await getCostosFlutter();

    // El endpoint Flutter devuelve {success: true, data: [...], pagination: {...}}
    final List<dynamic> costosData = responseData['data'] ?? [];
    return costosData.map((json) => Costo.fromJson(json)).toList();
  }

  /// Obtener costo por ID
  Future<Costo> getCosto(int id) async {
    final response = await _httpClient.get('/api/costos/$id');
    return Costo.fromJson(response.data);
  }

  /// Crear costo
  Future<Costo> createCosto(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/api/costos/create', data: data);
    return Costo.fromJson(response.data);
  }

  /// Actualizar costo
  Future<Costo> updateCosto(int id, Map<String, dynamic> data) async {
    final response =
        await _httpClient.put('/api/costos/$id/update', data: data);
    return Costo.fromJson(response.data);
  }

  /// Eliminar costo
  Future<void> deleteCosto(int id) async {
    await _httpClient.delete('/api/costos/$id/delete');
  }

  /// Obtener costos pagados
  Future<List<Costo>> getCostosPagados() async {
    final response = await _httpClient.get('/api/costos/pagados');
    return (response.data as List).map((json) => Costo.fromJson(json)).toList();
  }

  /// Obtener costos pendientes
  Future<List<Costo>> getCostosPendientes() async {
    final response = await _httpClient.get('/api/costos/pendientes');
    return (response.data as List).map((json) => Costo.fromJson(json)).toList();
  }

  /// ==================== FACTURAS ====================

  /// Listar facturas
  Future<List<Factura>> getFacturas() async {
    final response = await _httpClient.get('/api/facturas/');
    return (response.data as List)
        .map((json) => Factura.fromJson(json))
        .toList();
  }

  /// Obtener factura por ID
  Future<Factura> getFactura(int id) async {
    final response = await _httpClient.get('/api/facturas/$id');
    return Factura.fromJson(response.data);
  }

  /// Crear factura
  Future<Factura> createFactura(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/api/facturas/create', data: data);
    return Factura.fromJson(response.data);
  }

  /// Actualizar factura
  Future<Factura> updateFactura(int id, Map<String, dynamic> data) async {
    final response =
        await _httpClient.put('/api/facturas/$id/update', data: data);
    return Factura.fromJson(response.data);
  }

  /// Eliminar factura
  Future<void> deleteFactura(int id) async {
    await _httpClient.delete('/api/facturas/$id/delete');
  }

  /// ==================== TRABAJOS ====================

  /// Listar trabajos
  Future<List<Trabajo>> getTrabajos() async {
    final response = await _httpClient.get('/api/trabajos/');
    return (response.data as List)
        .map((json) => Trabajo.fromJson(json))
        .toList();
  }

  /// Obtener trabajo por ID
  Future<Trabajo> getTrabajo(int id) async {
    final response = await _httpClient.get('/api/trabajos/$id');
    return Trabajo.fromJson(response.data);
  }

  /// Obtener detalle completo de trabajo
  Future<Map<String, dynamic>> getTrabajoDetalle(int trabajoId) async {
    final response = await _httpClient.get('/api/trabajos/detalle/$trabajoId');
    return response.data as Map<String, dynamic>;
  }

  /// Crear trabajo
  Future<Trabajo> createTrabajo(Map<String, dynamic> data) async {
    // Log del request antes de enviarlo
    print(
        '🔵 ApiService.createTrabajo - Enviando request a /api/trabajos/create');
    print('🔵 Data a enviar:');
    try {
      print(JsonEncoder.withIndent('  ').convert(data));
    } catch (e) {
      print('Error al convertir data: $e');
      print('Data raw: $data');
    }

    final response = await _httpClient.post('/api/trabajos/create', data: data);
    return Trabajo.fromJson(response.data);
  }

  /// Actualizar trabajo
  Future<Trabajo> updateTrabajo(int id, Map<String, dynamic> data) async {
    final response =
        await _httpClient.put('/api/trabajos/$id/update', data: data);
    return Trabajo.fromJson(response.data);
  }

  /// Eliminar trabajo
  Future<void> deleteTrabajo(int id) async {
    await _httpClient.delete('/api/trabajos/$id/delete');
  }

  /// Registrar horas de trabajo
  Future<void> registrarHorasTrabajo(Map<String, dynamic> data) async {
    await _httpClient.post('/api/trabajos/registrar-horas/', data: data);
  }

  /// ==================== INSUMOS ====================

  /// Listar insumos
  Future<List<Insumo>> getInsumos() async {
    final response = await _httpClient.get('/api/insumos/');
    return (response.data as List)
        .map((json) => Insumo.fromJson(json))
        .toList();
  }

  /// Obtener insumo por ID
  Future<Insumo> getInsumo(int id) async {
    final response = await _httpClient.get('/api/insumos/$id');
    return Insumo.fromJson(response.data);
  }

  /// Crear insumo
  Future<Insumo> createInsumo(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/api/insumos/create', data: data);
    return Insumo.fromJson(response.data);
  }

  /// Actualizar insumo
  Future<Insumo> updateInsumo(int id, Map<String, dynamic> data) async {
    final response =
        await _httpClient.put('/api/insumos/$id/update', data: data);
    return Insumo.fromJson(response.data);
  }

  /// Eliminar insumo
  Future<void> deleteInsumo(int id) async {
    await _httpClient.delete('/api/insumos/$id/delete');
  }

  /// ==================== MANTENIMIENTOS ====================

  /// Listar mantenimientos
  Future<List<Mantenimiento>> getMantenimientos() async {
    try {
      _logger.apiCall('GET', '/api/mantenimientos/');
      final response = await _httpClient.get('/api/mantenimientos/');
      _logger.apiResponse('/api/mantenimientos/', response.statusCode!,
          data: response.data);

      if (response.data == null) {
        _logger.warning('⚠️ Respuesta vacía de /api/mantenimientos/');
        return [];
      }

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Mantenimiento.fromJson(json))
            .toList();
      } else if (response.data is Map &&
          (response.data as Map)['data'] != null) {
        final data = (response.data as Map)['data'];
        if (data is List) {
          return data.map((json) => Mantenimiento.fromJson(json)).toList();
        }
      }

      _logger.warning(
          '⚠️ Formato de respuesta inesperado de /api/mantenimientos/');
      return [];
    } catch (e) {
      // Log detallado del error
      _logger.error('❌ Error obteniendo mantenimientos: $e');

      // Capturar información adicional del error si es DioException
      if (e is DioException) {
        _logger.error('❌ DioException details:');
        _logger.error('   Type: ${e.type}');
        _logger.error('   Status Code: ${e.response?.statusCode}');
        _logger.error('   Status Message: ${e.response?.statusMessage}');
        _logger.error('   Response Data: ${e.response?.data}');
        _logger.error('   Request Path: ${e.requestOptions.path}');
        _logger.error('   Request Headers: ${e.requestOptions.headers}');

        // Si es un error 500, devolver lista vacía en lugar de fallar
        if (e.response?.statusCode == 500) {
          _logger.warning(
              '⚠️ Error 500 del servidor en /api/mantenimientos/. El servidor tiene un problema interno.');
          _logger.warning(
              '⚠️ Devolviendo lista vacía para permitir que la app continúe funcionando.');
          return [];
        }

        // Si es un error 404, puede ser que el endpoint no exista
        if (e.response?.statusCode == 404) {
          _logger.warning(
              '⚠️ Endpoint /api/mantenimientos/ devolvió 404. Verificar autenticación o existencia del endpoint.');
          return [];
        }
      }

      // Para otros errores, también devolver lista vacía para no bloquear la app
      _logger.warning(
          '⚠️ Error desconocido al obtener mantenimientos. Devolviendo lista vacía.');
      return [];
    }
  }

  /// Obtener mantenimiento por ID
  Future<Mantenimiento> getMantenimiento(int id) async {
    final response = await _httpClient.get('/api/mantenimientos/$id');
    return Mantenimiento.fromJson(response.data);
  }

  /// Crear mantenimiento
  Future<Mantenimiento> createMantenimiento(Map<String, dynamic> data) async {
    final response =
        await _httpClient.post('/api/mantenimientos/create', data: data);
    return Mantenimiento.fromJson(response.data);
  }

  /// Actualizar mantenimiento
  Future<Mantenimiento> updateMantenimiento(
      int id, Map<String, dynamic> data) async {
    final response =
        await _httpClient.put('/api/mantenimientos/$id/update', data: data);
    return Mantenimiento.fromJson(response.data);
  }

  /// Eliminar mantenimiento
  Future<void> deleteMantenimiento(int id) async {
    await _httpClient.delete('/api/mantenimientos/$id/delete');
  }

  /// ==================== CRÉDITOS ====================

  /// Listar créditos
  Future<List<Credito>> getCreditos() async {
    final response = await _httpClient.get('/api/creditos/');
    return (response.data as List)
        .map((json) => Credito.fromJson(json))
        .toList();
  }

  /// Obtener crédito por ID
  Future<Credito> getCredito(int id) async {
    final response = await _httpClient.get('/api/creditos/$id');
    return Credito.fromJson(response.data);
  }

  /// Crear crédito
  Future<Credito> createCredito(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/api/creditos/create', data: data);
    return Credito.fromJson(response.data);
  }

  /// Actualizar crédito
  Future<Credito> updateCredito(int id, Map<String, dynamic> data) async {
    final response =
        await _httpClient.put('/api/creditos/$id/update', data: data);
    return Credito.fromJson(response.data);
  }

  /// Eliminar crédito
  Future<void> deleteCredito(int id) async {
    await _httpClient.delete('/api/creditos/$id/delete');
  }

  /// ==================== MOVIMIENTOS ====================

  /// Listar movimientos
  Future<List<Movimiento>> getMovimientos() async {
    final response = await _httpClient.get('/api/movimientos/');
    return (response.data as List)
        .map((json) => Movimiento.fromJson(json))
        .toList();
  }

  /// Obtener movimiento por ID
  Future<Movimiento> getMovimiento(int id) async {
    final response = await _httpClient.get('/api/movimientos/$id');
    return Movimiento.fromJson(response.data);
  }

  /// Crear movimiento
  Future<Movimiento> createMovimiento(Map<String, dynamic> data) async {
    final response =
        await _httpClient.post('/api/movimientos/create', data: data);
    return Movimiento.fromJson(response.data);
  }

  /// Actualizar movimiento
  Future<Movimiento> updateMovimiento(int id, Map<String, dynamic> data) async {
    final response =
        await _httpClient.put('/api/movimientos/$id/update', data: data);
    return Movimiento.fromJson(response.data);
  }

  /// Eliminar movimiento
  Future<void> deleteMovimiento(int id) async {
    await _httpClient.delete('/api/movimientos/$id/delete');
  }

  /// ==================== TIPOS DE TRABAJO ====================

  /// Listar tipos de trabajo
  Future<List<TipoTrabajo>> getTiposTrabajo() async {
    final response = await _httpClient.get('/api/tipo-trabajo/');
    return (response.data as List)
        .map((json) => TipoTrabajo.fromJson(json))
        .toList();
  }

  /// Obtener tipo de trabajo por ID
  Future<TipoTrabajo> getTipoTrabajo(int id) async {
    final response = await _httpClient.get('/api/tipo-trabajo/$id');
    return TipoTrabajo.fromJson(response.data);
  }

  /// Crear tipo de trabajo
  Future<TipoTrabajo> createTipoTrabajo(Map<String, dynamic> data) async {
    final response =
        await _httpClient.post('/api/tipo-trabajo/create', data: data);
    return TipoTrabajo.fromJson(response.data);
  }

  /// Actualizar tipo de trabajo
  Future<TipoTrabajo> updateTipoTrabajo(
      int id, Map<String, dynamic> data) async {
    final response =
        await _httpClient.put('/api/tipo-trabajo/$id/update', data: data);
    return TipoTrabajo.fromJson(response.data);
  }

  /// Eliminar tipo de trabajo
  Future<void> deleteTipoTrabajo(int id) async {
    await _httpClient.delete('/api/tipo-trabajo/$id/delete');
  }

  /// ==================== PAGOS ====================

  /// Listar pagos
  Future<List<Map<String, dynamic>>> getPagos() async {
    final response = await _httpClient.get('/api/pagos/');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  /// Obtener pago por ID
  Future<Map<String, dynamic>> getPago(int id) async {
    final response = await _httpClient.get('/api/pagos/$id');
    return response.data as Map<String, dynamic>;
  }

  /// Crear pago
  Future<Map<String, dynamic>> createPago(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/api/pagos/create', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// Actualizar pago
  Future<Map<String, dynamic>> updatePago(
      int id, Map<String, dynamic> data) async {
    final response = await _httpClient.put('/api/pagos/$id/update', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// Eliminar pago
  Future<void> deletePago(int id) async {
    await _httpClient.delete('/api/pagos/$id/delete');
  }

  /// ==================== CUOTAS DE CRÉDITO ====================

  /// Listar cuotas de crédito
  Future<List<Map<String, dynamic>>> getCuotasCredito() async {
    final response = await _httpClient.get('/api/cuotas-credito/');
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  /// Obtener cuota de crédito por ID
  Future<Map<String, dynamic>> getCuotaCredito(int id) async {
    final response = await _httpClient.get('/api/cuotas-credito/$id');
    return response.data as Map<String, dynamic>;
  }

  /// Crear cuota de crédito
  Future<Map<String, dynamic>> createCuotaCredito(
      Map<String, dynamic> data) async {
    final response =
        await _httpClient.post('/api/cuotas-credito/create', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// Actualizar cuota de crédito
  Future<Map<String, dynamic>> updateCuotaCredito(
      int id, Map<String, dynamic> data) async {
    final response =
        await _httpClient.put('/api/cuotas-credito/$id/update', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// Eliminar cuota de crédito
  Future<void> deleteCuotaCredito(int id) async {
    await _httpClient.delete('/api/cuotas-credito/$id/delete');
  }

  /// ==================== ENDPOINTS FLUTTER OPTIMIZADOS ====================

  /// Lista de trabajos optimizada para Flutter
  Future<Map<String, dynamic>> getTrabajosFlutter({
    int skip = 0,
    int limit = 50,
    String? estado,
  }) async {
    final response =
        await _httpClient.get('/api/flutter/trabajos/lista', queryParameters: {
      'skip': skip,
      'limit': limit,
      if (estado != null) 'estado': estado,
    });

    return response.data;
  }

  /// Lista de campos optimizada para Flutter
  Future<Map<String, dynamic>> getCamposFlutter() async {
    final response = await _httpClient.get('/api/flutter/campos/lista');
    return response.data;
  }

  /// Lista de máquinas optimizada para Flutter
  Future<Map<String, dynamic>> getMaquinasFlutter() async {
    final response = await _httpClient.get('/api/flutter/maquinas/lista');
    return response.data;
  }

  /// Lista de personal optimizada para Flutter
  Future<Map<String, dynamic>> getPersonalFlutter() async {
    final response = await _httpClient.get('/api/flutter/personal/lista');
    return response.data;
  }

  /// Lista de clientes optimizada para Flutter
  Future<Map<String, dynamic>> getClientesFlutter() async {
    final response = await _httpClient.get('/api/flutter/clientes/lista');
    return response.data;
  }

  /// Lista de costos optimizada para Flutter
  Future<Map<String, dynamic>> getCostosFlutter({
    String? categoria,
    bool? pagado,
  }) async {
    final response =
        await _httpClient.get('/api/flutter/costos/lista', queryParameters: {
      if (categoria != null) 'categoria': categoria,
      if (pagado != null) 'pagado': pagado,
    });

    return response.data;
  }

  /// Lista de facturas optimizada para Flutter
  Future<Map<String, dynamic>> getFacturasFlutter({String? estado}) async {
    final response =
        await _httpClient.get('/api/flutter/facturas/lista', queryParameters: {
      if (estado != null) 'estado': estado,
    });

    return response.data;
  }

  /// Dashboard resumen optimizado para Flutter
  Future<Map<String, dynamic>> getDashboardResumen() async {
    final response = await _httpClient.get('/api/flutter/dashboard/resumen');
    return response.data;
  }

  /// ==================== DASHBOARD ====================

  /// Obtener resumen del dashboard
  Future<Map<String, dynamic>> getDashboardResumenGeneral() async {
    final response = await _httpClient.get('/api/dashboard/resumen');
    return response.data;
  }

  /// Obtener estadísticas generales
  Future<Map<String, dynamic>> getEstadisticas() async {
    final response = await _httpClient.get('/api/dashboard/estadisticas');
    return response.data;
  }

  /// ==================== REPORTES ====================

  /// Generar reporte de trabajos
  Future<Map<String, dynamic>> getReporteTrabajos() async {
    final response = await _httpClient.get('/api/reportes/trabajos');
    return response.data;
  }

  /// Generar reporte financiero
  Future<Map<String, dynamic>> getReporteFinanciero() async {
    final response = await _httpClient.get('/api/reportes/financiero');
    return response.data;
  }

  /// ==================== MÓVIL ====================

  /// Sincronización para aplicación móvil
  Future<Map<String, dynamic>> syncMobile() async {
    final response = await _httpClient.get('/api/mobile/sync');
    return response.data;
  }

  /// Enviar datos desde aplicación móvil
  Future<Map<String, dynamic>> sendMobileData(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/api/mobile/sync', data: data);
    return response.data;
  }

  /// ==================== UTILIDADES ====================

  /// Verificar salud del servidor
  Future<bool> checkHealth() async {
    try {
      final response = await _httpClient.get('/api/health/');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Probar endpoint de campos con autenticación Bearer
  Future<Map<String, dynamic>> testCamposEndpoint() async {
    try {
      _logger
          .info('🧪 Probando endpoint /api/campos/ con autenticación Bearer');
      final response = await _httpClient.get('/api/campos/');

      _logger.info(
          '✅ Respuesta del endpoint /api/campos/: ${response.statusCode}');
      _logger.debug('📊 Datos recibidos: ${response.data}');

      return {
        'success': true,
        'statusCode': response.statusCode,
        'data': response.data,
        'headers': response.headers,
      };
    } catch (e) {
      _logger.error('❌ Error probando endpoint /api/campos/: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Crear movimiento con datos específicos
  Future<Movimiento> createMovimientoCompleto({
    required double monto,
    required DateTime fecha,
    required String descripcion,
    required String categoria,
    required bool pagado,
    required String formaPago,
    required bool esCobro,
    String? destinatario,
    DateTime? fechaPagoLimite,
    DateTime? fechaPago,
    int? idTrabajo,
  }) async {
    _logger.info(
        '💰 Creando movimiento: $descripcion - \$${monto.toStringAsFixed(2)}');

    final movimientoData = {
      'monto': monto,
      'fecha': fecha.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
      'descripcion': descripcion,
      'categoria': categoria,
      'pagado': pagado,
      'forma_pago': formaPago,
      'es_cobro': esCobro,
      if (destinatario != null) 'destinatario': destinatario,
      if (fechaPagoLimite != null)
        'fecha_pago_limite': fechaPagoLimite.toIso8601String().split('T')[0],
      if (fechaPago != null)
        'fecha_pago': fechaPago.toIso8601String().split('T')[0],
      if (idTrabajo != null) 'id_trabajo': idTrabajo,
    };

    _logger.apiCall('POST', '/api/movimientos/create', data: movimientoData);

    final response =
        await _httpClient.post('/api/movimientos/create', data: movimientoData);

    _logger.apiResponse('/api/movimientos/create', response.statusCode!,
        data: response.data);

    return Movimiento.fromJson(response.data);
  }

  /// Limpiar caché del cliente HTTP
  Future<void> clearCache() async {
    await _httpClient.clearCache();
  }

  /// Obtener estadísticas de caché
  Map<String, dynamic> getCacheStats() {
    return _httpClient.getCacheStats();
  }

  /// ==================== MÉTODOS HTTP GENÉRICOS ====================

  /// GET genérico para endpoints personalizados
  Future<dynamic> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    _logger.apiCall('GET', endpoint);
    final response =
        await _httpClient.get(endpoint, queryParameters: queryParameters);
    _logger.apiResponse(endpoint, response.statusCode!, data: response.data);
    return response.data;
  }

  /// POST genérico para endpoints personalizados
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? data}) async {
    _logger.apiCall('POST', endpoint, data: data);
    final response = await _httpClient.post(endpoint, data: data);
    _logger.apiResponse(endpoint, response.statusCode!, data: response.data);
    return response.data;
  }

  /// PUT genérico para endpoints personalizados
  Future<dynamic> put(String endpoint, {Map<String, dynamic>? data}) async {
    _logger.apiCall('PUT', endpoint, data: data);
    final response = await _httpClient.put(endpoint, data: data);
    _logger.apiResponse(endpoint, response.statusCode!, data: response.data);
    return response.data;
  }

  /// DELETE genérico para endpoints personalizados
  Future<void> delete(String endpoint) async {
    _logger.apiCall('DELETE', endpoint);
    final response = await _httpClient.delete(endpoint);
    _logger.apiResponse(endpoint, response.statusCode!);
  }

  /// PATCH genérico para endpoints personalizados (usando PUT)
  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? data}) async {
    _logger.apiCall('PATCH', endpoint, data: data);
    final response = await _httpClient.put(endpoint, data: data);
    _logger.apiResponse(endpoint, response.statusCode!, data: response.data);
    return response.data;
  }

  /// ==================== CLIMA ====================

  /// Obtener pronóstico de clima
  Future<WeatherResponse> getWeatherForecast(double lat, double lon) async {
    try {
      _logger.apiCall('GET', '/api/clima/pronostico', queryParameters: {
        'lat': lat,
        'lon': lon,
      });

      final response =
          await _httpClient.get('/api/clima/pronostico', queryParameters: {
        'lat': lat,
        'lon': lon,
      });

      _logger.apiResponse('/api/clima/pronostico', response.statusCode!,
          data: response.data);

      return WeatherResponse.fromJson(response.data);
    } catch (e) {
      _logger.error('❌ Error al obtener el clima: $e');
      rethrow;
    }
  }
}
