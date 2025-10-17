import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    _logger.apiCall('POST', '/auth/login', data: {'email': email});
    
    final response = await _httpClient.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    
    _logger.apiResponse('/auth/login', response.statusCode!, data: response.data);
    return response.data;
  }

  /// Registro de usuario
  Future<Map<String, dynamic>> register({
    required String nombre,
    required String dni,
    required String telefono,
    required String email,
    required String password,
  }) async {
    _logger.apiCall('POST', '/auth/register', data: {
      'nombre': nombre,
      'dni': dni,
      'telefono': telefono,
      'email': email,
    });
    
    final response = await _httpClient.post('/auth/register', data: {
      'nombre': nombre,
      'dni': dni,
      'telefono': telefono,
      'email': email,
      'password': password,
    });
    
    _logger.apiResponse('/auth/register', response.statusCode!, data: response.data);
    return response.data;
  }

  /// Test de conexión
  Future<Map<String, dynamic>> testConnection() async {
    final response = await _httpClient.get('/auth/test');
    return response.data;
  }

  /// ==================== USUARIOS ====================
  
  /// Listar usuarios
  Future<List<Usuario>> getUsuarios({int skip = 0, int limit = 100}) async {
    final response = await _httpClient.get('/usuarios/', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
    
    return (response.data as List).map((json) => Usuario.fromJson(json)).toList();
  }

  /// Obtener usuario por ID
  Future<Usuario> getUsuario(int id) async {
    final response = await _httpClient.get('/usuarios/$id');
    return Usuario.fromJson(response.data);
  }

  /// Crear usuario
  Future<Usuario> createUsuario(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/usuarios/', data: data);
    return Usuario.fromJson(response.data);
  }

  /// Actualizar usuario
  Future<Usuario> updateUsuario(int id, Map<String, dynamic> data) async {
    final response = await _httpClient.put('/usuarios/$id', data: data);
    return Usuario.fromJson(response.data);
  }

  /// Eliminar usuario
  Future<void> deleteUsuario(int id) async {
    await _httpClient.delete('/usuarios/$id');
  }

  /// ==================== CAMPOS ====================
  
  /// Listar campos
  Future<List<Campo>> getCampos({int skip = 0, int limit = 100}) async {
    final response = await _httpClient.get('/campos/', queryParameters: {
      'skip': skip,
      'limit': limit,
    });
    
    return (response.data as List).map((json) => Campo.fromJson(json)).toList();
  }

  /// Obtener campo por ID
  Future<Campo> getCampo(int id) async {
    final response = await _httpClient.get('/campos/$id');
    return Campo.fromJson(response.data);
  }

  /// Crear campo
  Future<Campo> createCampo(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/campos/', data: data);
    return Campo.fromJson(response.data);
  }

  /// Actualizar campo
  Future<Campo> updateCampo(int id, Map<String, dynamic> data) async {
    final response = await _httpClient.put('/campos/$id', data: data);
    return Campo.fromJson(response.data);
  }

  /// Eliminar campo
  Future<void> deleteCampo(int id) async {
    await _httpClient.delete('/campos/$id');
  }

  /// ==================== MÁQUINAS ====================
  
  /// Listar máquinas
  Future<List<Maquina>> getMaquinas() async {
    final response = await _httpClient.get('/maquinas/');
    return (response.data as List).map((json) => Maquina.fromJson(json)).toList();
  }

  /// Obtener máquina por ID
  Future<Maquina> getMaquina(int id) async {
    final response = await _httpClient.get('/maquinas/$id');
    return Maquina.fromJson(response.data);
  }

  /// Crear máquina
  Future<Maquina> createMaquina(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/maquinas/', data: data);
    return Maquina.fromJson(response.data);
  }

  /// Actualizar máquina
  Future<Maquina> updateMaquina(int id, Map<String, dynamic> data) async {
    final response = await _httpClient.put('/maquinas/$id', data: data);
    return Maquina.fromJson(response.data);
  }

  /// Eliminar máquina
  Future<void> deleteMaquina(int id) async {
    await _httpClient.delete('/maquinas/$id');
  }

  /// ==================== PERSONAL ====================
  
  /// Listar personal
  Future<List<Personal>> getPersonal() async {
    final response = await _httpClient.get('/personal/');
    return (response.data as List).map((json) => Personal.fromJson(json)).toList();
  }

  /// Obtener personal por ID
  Future<Personal> getPersonalById(int id) async {
    final response = await _httpClient.get('/personal/$id');
    return Personal.fromJson(response.data);
  }

  /// Crear personal
  Future<Personal> createPersonal(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/personal/', data: data);
    return Personal.fromJson(response.data);
  }

  /// Actualizar personal
  Future<Personal> updatePersonal(int id, Map<String, dynamic> data) async {
    final response = await _httpClient.put('/personal/$id', data: data);
    return Personal.fromJson(response.data);
  }

  /// Eliminar personal
  Future<void> deletePersonal(int id) async {
    await _httpClient.delete('/personal/$id');
  }

  /// Validar DNI
  Future<bool> validateDni(String dni, {int? excludeId}) async {
    final response = await _httpClient.get('/personal/validate-dni', queryParameters: {
      'dni': dni,
      if (excludeId != null) 'exclude_id': excludeId,
    });
    
    return response.data['available'] as bool;
  }

  /// ==================== CLIENTES ====================
  
  /// Listar clientes
  Future<List<Cliente>> getClientes() async {
    final response = await _httpClient.get('/clientes/');
    return (response.data as List).map((json) => Cliente.fromJson(json)).toList();
  }

  /// Obtener cliente por ID
  Future<Cliente> getCliente(int id) async {
    final response = await _httpClient.get('/clientes/$id');
    return Cliente.fromJson(response.data);
  }

  /// Crear cliente
  Future<Cliente> createCliente(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/clientes/', data: data);
    return Cliente.fromJson(response.data);
  }

  /// Actualizar cliente
  Future<Cliente> updateCliente(int id, Map<String, dynamic> data) async {
    final response = await _httpClient.put('/clientes/$id', data: data);
    return Cliente.fromJson(response.data);
  }

  /// Eliminar cliente
  Future<void> deleteCliente(int id) async {
    await _httpClient.delete('/clientes/$id');
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
    final response = await _httpClient.get('/costos/$id');
    return Costo.fromJson(response.data);
  }

  /// Crear costo
  Future<Costo> createCosto(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/costos/', data: data);
    return Costo.fromJson(response.data);
  }

  /// Actualizar costo
  Future<Costo> updateCosto(int id, Map<String, dynamic> data) async {
    final response = await _httpClient.put('/costos/$id', data: data);
    return Costo.fromJson(response.data);
  }

  /// Eliminar costo
  Future<void> deleteCosto(int id) async {
    await _httpClient.delete('/costos/$id');
  }

  /// Obtener costos pagados
  Future<List<Costo>> getCostosPagados() async {
    final response = await _httpClient.get('/costos/pagados/');
    return (response.data as List).map((json) => Costo.fromJson(json)).toList();
  }

  /// Obtener costos pendientes
  Future<List<Costo>> getCostosPendientes() async {
    final response = await _httpClient.get('/costos/pendientes/');
    return (response.data as List).map((json) => Costo.fromJson(json)).toList();
  }

  /// ==================== FACTURAS ====================
  
  /// Listar facturas
  Future<List<Factura>> getFacturas() async {
    final response = await _httpClient.get('/facturas/');
    return (response.data as List).map((json) => Factura.fromJson(json)).toList();
  }

  /// Obtener factura por ID
  Future<Factura> getFactura(int id) async {
    final response = await _httpClient.get('/facturas/$id');
    return Factura.fromJson(response.data);
  }

  /// Crear factura
  Future<Factura> createFactura(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/facturas/', data: data);
    return Factura.fromJson(response.data);
  }

  /// Actualizar factura
  Future<Factura> updateFactura(int id, Map<String, dynamic> data) async {
    final response = await _httpClient.put('/facturas/$id', data: data);
    return Factura.fromJson(response.data);
  }

  /// Eliminar factura
  Future<void> deleteFactura(int id) async {
    await _httpClient.delete('/facturas/$id');
  }

  /// ==================== TRABAJOS ====================
  
  /// Listar trabajos
  Future<List<Trabajo>> getTrabajos() async {
    final response = await _httpClient.get('/trabajos/');
    return (response.data as List).map((json) => Trabajo.fromJson(json)).toList();
  }

  /// Obtener trabajo por ID
  Future<Trabajo> getTrabajo(int id) async {
    final response = await _httpClient.get('/trabajos/$id');
    return Trabajo.fromJson(response.data);
  }

  /// Crear trabajo
  Future<Trabajo> createTrabajo(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/trabajos/', data: data);
    return Trabajo.fromJson(response.data);
  }

  /// Actualizar trabajo
  Future<Trabajo> updateTrabajo(int id, Map<String, dynamic> data) async {
    final response = await _httpClient.put('/trabajos/$id', data: data);
    return Trabajo.fromJson(response.data);
  }

  /// Eliminar trabajo
  Future<void> deleteTrabajo(int id) async {
    await _httpClient.delete('/trabajos/$id');
  }

  /// ==================== INSUMOS ====================
  
  /// Listar insumos
  Future<List<Insumo>> getInsumos() async {
    final response = await _httpClient.get('/insumos/');
    return (response.data as List).map((json) => Insumo.fromJson(json)).toList();
  }

  /// Obtener insumo por ID
  Future<Insumo> getInsumo(int id) async {
    final response = await _httpClient.get('/insumos/$id');
    return Insumo.fromJson(response.data);
  }

  /// Crear insumo
  Future<Insumo> createInsumo(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/insumos/', data: data);
    return Insumo.fromJson(response.data);
  }

  /// Actualizar insumo
  Future<Insumo> updateInsumo(int id, Map<String, dynamic> data) async {
    final response = await _httpClient.put('/insumos/$id', data: data);
    return Insumo.fromJson(response.data);
  }

  /// Eliminar insumo
  Future<void> deleteInsumo(int id) async {
    await _httpClient.delete('/insumos/$id');
  }

  /// ==================== MANTENIMIENTOS ====================
  
  /// Listar mantenimientos
  Future<List<Mantenimiento>> getMantenimientos() async {
    final response = await _httpClient.get('/mantenimientos/');
    return (response.data as List).map((json) => Mantenimiento.fromJson(json)).toList();
  }

  /// Crear mantenimiento
  Future<Mantenimiento> createMantenimiento(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/mantenimientos/', data: data);
    return Mantenimiento.fromJson(response.data);
  }

  /// Actualizar mantenimiento
  Future<Mantenimiento> updateMantenimiento(int id, Map<String, dynamic> data) async {
    final response = await _httpClient.put('/mantenimientos/$id', data: data);
    return Mantenimiento.fromJson(response.data);
  }

  /// Eliminar mantenimiento
  Future<void> deleteMantenimiento(int id) async {
    await _httpClient.delete('/mantenimientos/$id');
  }

  /// ==================== CRÉDITOS ====================
  
  /// Listar créditos
  Future<List<Credito>> getCreditos() async {
    final response = await _httpClient.get('/creditos/');
    return (response.data as List).map((json) => Credito.fromJson(json)).toList();
  }

  /// Crear crédito
  Future<Credito> createCredito(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/creditos/', data: data);
    return Credito.fromJson(response.data);
  }

  /// ==================== MOVIMIENTOS ====================
  Future<List<Movimiento>> getMovimientos() async {
    final response = await _httpClient.get('/movimientos/');
    return (response.data as List).map((json) => Movimiento.fromJson(json)).toList();
  }

  Future<Movimiento> createMovimiento(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/movimientos/', data: data);
    return Movimiento.fromJson(response.data);
  }

  Future<Movimiento> updateMovimiento(int id, Map<String, dynamic> data) async {
    final response = await _httpClient.put('/movimientos/$id', data: data);
    return Movimiento.fromJson(response.data);
  }

  Future<void> deleteMovimiento(int id) async {
    await _httpClient.delete('/movimientos/$id');
  }

  /// Actualizar crédito
  Future<Credito> updateCredito(int id, Map<String, dynamic> data) async {
    final response = await _httpClient.put('/creditos/$id', data: data);
    return Credito.fromJson(response.data);
  }

  /// Eliminar crédito
  Future<void> deleteCredito(int id) async {
    await _httpClient.delete('/creditos/$id');
  }

  /// ==================== ENDPOINTS FLUTTER OPTIMIZADOS ====================
  
  /// Lista de trabajos optimizada para Flutter
  Future<Map<String, dynamic>> getTrabajosFlutter({
    int skip = 0,
    int limit = 50,
    String? estado,
  }) async {
    final response = await _httpClient.get('/flutter/trabajos/lista', queryParameters: {
      'skip': skip,
      'limit': limit,
      if (estado != null) 'estado': estado,
    });
    
    return response.data;
  }

  /// Lista de campos optimizada para Flutter
  Future<Map<String, dynamic>> getCamposFlutter() async {
    final response = await _httpClient.get('/flutter/campos/lista');
    return response.data;
  }

  /// Lista de máquinas optimizada para Flutter
  Future<Map<String, dynamic>> getMaquinasFlutter() async {
    final response = await _httpClient.get('/flutter/maquinas/lista');
    return response.data;
  }

  /// Lista de personal optimizada para Flutter
  Future<Map<String, dynamic>> getPersonalFlutter() async {
    final response = await _httpClient.get('/flutter/personal/lista');
    return response.data;
  }

  /// Lista de clientes optimizada para Flutter
  Future<Map<String, dynamic>> getClientesFlutter() async {
    final response = await _httpClient.get('/flutter/clientes/lista');
    return response.data;
  }

  /// Lista de costos optimizada para Flutter
  Future<Map<String, dynamic>> getCostosFlutter({
    String? categoria,
    bool? pagado,
  }) async {
    final response = await _httpClient.get('/flutter/costos/lista', queryParameters: {
      if (categoria != null) 'categoria': categoria,
      if (pagado != null) 'pagado': pagado,
    });
    
    return response.data;
  }

  /// Lista de facturas optimizada para Flutter
  Future<Map<String, dynamic>> getFacturasFlutter({String? estado}) async {
    final response = await _httpClient.get('/flutter/facturas/lista', queryParameters: {
      if (estado != null) 'estado': estado,
    });
    
    return response.data;
  }

  /// Dashboard resumen optimizado para Flutter
  Future<Map<String, dynamic>> getDashboardResumen() async {
    final response = await _httpClient.get('/flutter/dashboard/resumen');
    return response.data;
  }

  /// ==================== DASHBOARD ====================
  
  /// Obtener resumen del dashboard
  Future<Map<String, dynamic>> getDashboardResumenGeneral() async {
    final response = await _httpClient.get('/dashboard/resumen');
    return response.data;
  }

  /// Obtener estadísticas generales
  Future<Map<String, dynamic>> getEstadisticas() async {
    final response = await _httpClient.get('/dashboard/estadisticas');
    return response.data;
  }

  /// ==================== REPORTES ====================
  
  /// Generar reporte de trabajos
  Future<Map<String, dynamic>> getReporteTrabajos() async {
    final response = await _httpClient.get('/reportes/trabajos');
    return response.data;
  }

  /// Generar reporte financiero
  Future<Map<String, dynamic>> getReporteFinanciero() async {
    final response = await _httpClient.get('/reportes/financiero');
    return response.data;
  }

  /// ==================== MÓVIL ====================
  
  /// Sincronización para aplicación móvil
  Future<Map<String, dynamic>> syncMobile() async {
    final response = await _httpClient.get('/mobile/sync');
    return response.data;
  }

  /// Enviar datos desde aplicación móvil
  Future<Map<String, dynamic>> sendMobileData(Map<String, dynamic> data) async {
    final response = await _httpClient.post('/mobile/sync', data: data);
    return response.data;
  }

  /// ==================== UTILIDADES ====================
  
  /// Verificar salud del servidor
  Future<bool> checkHealth() async {
    try {
      final response = await _httpClient.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Probar endpoint de campos con autenticación Bearer
  Future<Map<String, dynamic>> testCamposEndpoint() async {
    try {
      _logger.info('🧪 Probando endpoint /campos/ con autenticación Bearer');
      final response = await _httpClient.get('/campos/');
      
      _logger.info('✅ Respuesta del endpoint /campos/: ${response.statusCode}');
      _logger.debug('📊 Datos recibidos: ${response.data}');
      
      return {
        'success': true,
        'statusCode': response.statusCode,
        'data': response.data,
        'headers': response.headers,
      };
    } catch (e) {
      _logger.error('❌ Error probando endpoint /campos/: $e');
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
    _logger.info('💰 Creando movimiento: $descripcion - \$${monto.toStringAsFixed(2)}');
    
    final movimientoData = {
      'monto': monto,
      'fecha': fecha.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
      'descripcion': descripcion,
      'categoria': categoria,
      'pagado': pagado,
      'forma_pago': formaPago,
      'es_cobro': esCobro,
      if (destinatario != null) 'destinatario': destinatario,
      if (fechaPagoLimite != null) 'fecha_pago_limite': fechaPagoLimite.toIso8601String().split('T')[0],
      if (fechaPago != null) 'fecha_pago': fechaPago.toIso8601String().split('T')[0],
      if (idTrabajo != null) 'id_trabajo': idTrabajo,
    };

    _logger.apiCall('POST', '/movimientos/', data: movimientoData);
    
    final response = await _httpClient.post('/movimientos/', data: movimientoData);
    
    _logger.apiResponse('/movimientos/', response.statusCode!, data: response.data);
    
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
}