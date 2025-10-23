import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import '../core/logger/app_logger.dart';
import '../services/optimized_api_service.dart';
import '../services/campo_service.dart';
import '../models/campo.dart';
import '../models/cliente.dart';
import '../models/costo.dart';
import '../models/credito.dart';
import '../models/factura.dart';
import '../models/insumo.dart';
import '../models/mantenimiento.dart';
import '../models/maquina.dart';
import '../models/personal.dart';
import '../models/trabajo.dart';
import '../models/usuario.dart';
import '../models/movimiento.dart';

/// Estados base para todos los providers
abstract class BaseState extends Equatable {
  const BaseState();
  
  @override
  List<Object?> get props => [];
}

class InitialState extends BaseState {
  const InitialState();
  
  @override
  List<Object?> get props => [];
}

class LoadingState extends BaseState {
  const LoadingState();
}

class LoadedState<T> extends BaseState {
  final T data;
  final DateTime lastUpdated;
  
  LoadedState(this.data, {DateTime? lastUpdated}) 
      : lastUpdated = lastUpdated ?? DateTime.now();
  
  @override
  List<Object?> get props => [data, lastUpdated];
}

class ErrorState extends BaseState {
  final String message;
  final dynamic error;
  
  const ErrorState(this.message, [this.error]);
  
  @override
  List<Object?> get props => [message, error];
}

/// ==================== CAMPOS PROVIDER ====================

final camposProvider = StateNotifierProvider<CamposNotifier, BaseState>((ref) {
  return CamposNotifier();
});

class CamposNotifier extends StateNotifier<BaseState> {
  final AppLogger _logger = AppLogger.instance;

  CamposNotifier() : super(const InitialState());

  Future<void> loadCampos() async {
    try {
      state = const LoadingState();
      
      final apiService = ApiService();
      await apiService.initialize();
      final campos = await apiService.getCampos();
      
      state = LoadedState<List<Campo>>(campos);
      _logger.info('Campos loaded successfully: ${campos.length} items');
    } catch (e) {
      state = ErrorState('Error cargando campos: $e');
      _logger.error('Error loading campos', e);
    }
  }

  Future<void> createCampo(Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.createCampo(data);
      
      await loadCampos(); // Recargar lista
      _logger.info('Campo created successfully');
    } catch (e) {
      state = ErrorState('Error creando campo: $e');
      _logger.error('Error creating campo', e);
    }
  }

  Future<void> updateCampo(int id, Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.updateCampo(id, data);
      
      await loadCampos(); // Recargar lista
      _logger.info('Campo updated successfully');
    } catch (e) {
      state = ErrorState('Error actualizando campo: $e');
      _logger.error('Error updating campo', e);
    }
  }

  Future<void> deleteCampo(int id) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.deleteCampo(id);
      
      await loadCampos(); // Recargar lista
      _logger.info('Campo deleted successfully');
    } catch (e) {
      state = ErrorState('Error eliminando campo: $e');
      _logger.error('Error deleting campo', e);
    }
  }
}

/// ==================== CAMPO BY ID PROVIDER ====================

class CampoByIdNotifier extends Notifier<BaseState> {
  final _logger = AppLogger.instance;

  @override
  BaseState build() {
    return const InitialState();
  }

  Future<void> loadCampoById(int id) async {
    state = const LoadingState();
    _logger.info('Loading campo by ID: $id');
    
    try {
      final campo = await CampoService.getCampo(id);
      state = LoadedState(campo);
      _logger.info('Campo loaded successfully: ${campo.nombre}');
    } catch (e) {
      state = ErrorState('Error cargando campo: $e');
      _logger.error('Error loading campo by ID', e);
    }
  }
}

final campoByIdProvider = NotifierProvider<CampoByIdNotifier, BaseState>(() {
  return CampoByIdNotifier();
});

/// ==================== TRABAJOS PROVIDER ====================

final trabajosProvider = StateNotifierProvider<TrabajosNotifier, BaseState>((ref) {
  return TrabajosNotifier();
});

class TrabajosNotifier extends StateNotifier<BaseState> {
  final AppLogger _logger = AppLogger.instance;

  TrabajosNotifier() : super(const InitialState());

  Future<void> loadTrabajos() async {
    try {
      state = const LoadingState();
      
      final apiService = ApiService();
      await apiService.initialize();
      final trabajos = await apiService.getTrabajos();
      
      state = LoadedState<List<Trabajo>>(trabajos);
      _logger.info('Trabajos loaded successfully: ${trabajos.length} items');
    } catch (e) {
      state = ErrorState('Error cargando trabajos: $e');
      _logger.error('Error loading trabajos', e);
    }
  }

  Future<void> createTrabajo(Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.createTrabajo(data);
      
      await loadTrabajos(); // Recargar lista
      _logger.info('Trabajo created successfully');
    } catch (e) {
      state = ErrorState('Error creando trabajo: $e');
      _logger.error('Error creating trabajo', e);
    }
  }

  Future<void> updateTrabajo(int id, Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.updateTrabajo(id, data);
      
      await loadTrabajos(); // Recargar lista
      _logger.info('Trabajo updated successfully');
    } catch (e) {
      state = ErrorState('Error actualizando trabajo: $e');
      _logger.error('Error updating trabajo', e);
    }
  }

  Future<void> deleteTrabajo(int id) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.deleteTrabajo(id);
      
      await loadTrabajos(); // Recargar lista
      _logger.info('Trabajo deleted successfully');
    } catch (e) {
      state = ErrorState('Error eliminando trabajo: $e');
      _logger.error('Error deleting trabajo', e);
    }
  }
}

/// ==================== COSTOS PROVIDER ====================

final costosProvider = StateNotifierProvider<CostosNotifier, BaseState>((ref) {
  return CostosNotifier();
});

class CostosNotifier extends StateNotifier<BaseState> {
  final AppLogger _logger = AppLogger.instance;

  CostosNotifier() : super(const InitialState());

  Future<void> loadCostos() async {
    try {
      state = const LoadingState();
      
      final apiService = ApiService();
      await apiService.initialize();
      final costos = await apiService.getCostos();
      
      state = LoadedState<List<Costo>>(costos);
      _logger.info('Costos loaded successfully: ${costos.length} items');
    } catch (e) {
      state = ErrorState('Error cargando costos: $e');
      _logger.error('Error loading costos', e);
    }
  }

  Future<void> createCosto(Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.createCosto(data);
      
      await loadCostos(); // Recargar lista
      _logger.info('Costo created successfully');
    } catch (e) {
      state = ErrorState('Error creando costo: $e');
      _logger.error('Error creating costo', e);
    }
  }

  Future<void> updateCosto(int id, Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.updateCosto(id, data);
      
      await loadCostos(); // Recargar lista
      _logger.info('Costo updated successfully');
    } catch (e) {
      state = ErrorState('Error actualizando costo: $e');
      _logger.error('Error updating costo', e);
    }
  }

  Future<void> deleteCosto(int id) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.deleteCosto(id);
      
      await loadCostos(); // Recargar lista
      _logger.info('Costo deleted successfully');
    } catch (e) {
      state = ErrorState('Error eliminando costo: $e');
      _logger.error('Error deleting costo', e);
    }
  }
}

/// ==================== MOVIMIENTOS PROVIDER ====================

final movimientosProvider = StateNotifierProvider<MovimientosNotifier, BaseState>((ref) {
  return MovimientosNotifier();
});

class MovimientosNotifier extends StateNotifier<BaseState> {
  final AppLogger _logger = AppLogger.instance;

  MovimientosNotifier() : super(const InitialState());

  Future<void> loadMovimientos() async {
    try {
      state = const LoadingState();
      final apiService = ApiService();
      await apiService.initialize();
      final movimientos = await apiService.getMovimientos();
      state = LoadedState<List<Movimiento>>(movimientos);
      _logger.info('Movimientos loaded successfully: ${movimientos.length} items');
    } catch (e) {
      state = ErrorState('Error cargando movimientos: $e');
      _logger.error('Error loading movimientos', e);
    }
  }

  Future<void> createMovimiento(Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.createMovimiento(data);
      await loadMovimientos();
      _logger.info('Movimiento created successfully');
    } catch (e) {
      state = ErrorState('Error creando movimiento: $e');
      _logger.error('Error creating movimiento', e);
    }
  }

  Future<void> updateMovimiento(int id, Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.updateMovimiento(id, data);
      await loadMovimientos();
      _logger.info('Movimiento updated successfully');
    } catch (e) {
      state = ErrorState('Error actualizando movimiento: $e');
      _logger.error('Error updating movimiento', e);
    }
  }

  Future<void> deleteMovimiento(int id) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.deleteMovimiento(id);
      await loadMovimientos();
      _logger.info('Movimiento deleted successfully');
    } catch (e) {
      state = ErrorState('Error eliminando movimiento: $e');
      _logger.error('Error deleting movimiento', e);
    }
  }
}

/// ==================== MÁQUINAS PROVIDER ====================

final maquinasProvider = StateNotifierProvider<MaquinasNotifier, BaseState>((ref) {
  return MaquinasNotifier();
});

class MaquinasNotifier extends StateNotifier<BaseState> {
  final AppLogger _logger = AppLogger.instance;

  MaquinasNotifier() : super(const InitialState());

  Future<void> loadMaquinas() async {
    try {
      state = const LoadingState();
      
      final apiService = ApiService();
      await apiService.initialize();
      final maquinas = await apiService.getMaquinas();
      
      state = LoadedState<List<Maquina>>(maquinas);
      _logger.info('Maquinas loaded successfully: ${maquinas.length} items');
    } catch (e) {
      state = ErrorState('Error cargando máquinas: $e');
      _logger.error('Error loading maquinas', e);
    }
  }

  Future<void> createMaquina(Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.createMaquina(data);
      
      await loadMaquinas(); // Recargar lista
      _logger.info('Maquina created successfully');
    } catch (e) {
      state = ErrorState('Error creando máquina: $e');
      _logger.error('Error creating maquina', e);
    }
  }

  Future<void> updateMaquina(int id, Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.updateMaquina(id, data);
      
      await loadMaquinas(); // Recargar lista
      _logger.info('Maquina updated successfully');
    } catch (e) {
      state = ErrorState('Error actualizando máquina: $e');
      _logger.error('Error updating maquina', e);
    }
  }

  Future<void> deleteMaquina(int id) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.deleteMaquina(id);
      
      await loadMaquinas(); // Recargar lista
      _logger.info('Maquina deleted successfully');
    } catch (e) {
      state = ErrorState('Error eliminando máquina: $e');
      _logger.error('Error deleting maquina', e);
    }
  }
}

/// ==================== PERSONAL PROVIDER ====================

final personalProvider = StateNotifierProvider<PersonalNotifier, BaseState>((ref) {
  return PersonalNotifier();
});

class PersonalNotifier extends StateNotifier<BaseState> {
  final AppLogger _logger = AppLogger.instance;

  PersonalNotifier() : super(const InitialState());

  Future<void> loadPersonal() async {
    try {
      state = const LoadingState();
      
      final apiService = ApiService();
      await apiService.initialize();
      final personal = await apiService.getPersonal();
      
      state = LoadedState<List<Personal>>(personal);
      _logger.info('Personal loaded successfully: ${personal.length} items');
    } catch (e) {
      state = ErrorState('Error cargando personal: $e');
      _logger.error('Error loading personal', e);
    }
  }

  Future<void> createPersonal(Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.createPersonal(data);
      
      await loadPersonal(); // Recargar lista
      _logger.info('Personal created successfully');
    } catch (e) {
      state = ErrorState('Error creando personal: $e');
      _logger.error('Error creating personal', e);
    }
  }

  Future<void> updatePersonal(int id, Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.updatePersonal(id, data);
      
      await loadPersonal(); // Recargar lista
      _logger.info('Personal updated successfully');
    } catch (e) {
      state = ErrorState('Error actualizando personal: $e');
      _logger.error('Error updating personal', e);
    }
  }

  Future<void> deletePersonal(int id) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.deletePersonal(id);
      
      await loadPersonal(); // Recargar lista
      _logger.info('Personal deleted successfully');
    } catch (e) {
      state = ErrorState('Error eliminando personal: $e');
      _logger.error('Error deleting personal', e);
    }
  }
}

/// ==================== CLIENTES PROVIDER ====================

final clientesProvider = StateNotifierProvider<ClientesNotifier, BaseState>((ref) {
  return ClientesNotifier();
});

class ClientesNotifier extends StateNotifier<BaseState> {
  final AppLogger _logger = AppLogger.instance;

  ClientesNotifier() : super(const InitialState());

  Future<void> loadClientes() async {
    try {
      state = const LoadingState();
      
      final apiService = ApiService();
      await apiService.initialize();
      final clientes = await apiService.getClientes();
      
      state = LoadedState<List<Cliente>>(clientes);
      _logger.info('Clientes loaded successfully: ${clientes.length} items');
    } catch (e) {
      state = ErrorState('Error cargando clientes: $e');
      _logger.error('Error loading clientes', e);
    }
  }

  Future<void> createCliente(Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.createCliente(data);
      
      await loadClientes(); // Recargar lista
      _logger.info('Cliente created successfully');
    } catch (e) {
      state = ErrorState('Error creando cliente: $e');
      _logger.error('Error creating cliente', e);
    }
  }

  Future<void> updateCliente(int id, Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.updateCliente(id, data);
      
      await loadClientes(); // Recargar lista
      _logger.info('Cliente updated successfully');
    } catch (e) {
      state = ErrorState('Error actualizando cliente: $e');
      _logger.error('Error updating cliente', e);
    }
  }

  Future<void> deleteCliente(int id) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.deleteCliente(id);
      
      await loadClientes(); // Recargar lista
      _logger.info('Cliente deleted successfully');
    } catch (e) {
      state = ErrorState('Error eliminando cliente: $e');
      _logger.error('Error deleting cliente', e);
    }
  }
}

/// ==================== FACTURAS PROVIDER ====================

final facturasProvider = StateNotifierProvider<FacturasNotifier, BaseState>((ref) {
  return FacturasNotifier();
});

class FacturasNotifier extends StateNotifier<BaseState> {
  final AppLogger _logger = AppLogger.instance;

  FacturasNotifier() : super(const InitialState());

  Future<void> loadFacturas() async {
    try {
      state = const LoadingState();
      
      final apiService = ApiService();
      await apiService.initialize();
      final facturas = await apiService.getFacturas();
      
      state = LoadedState<List<Factura>>(facturas);
      _logger.info('Facturas loaded successfully: ${facturas.length} items');
    } catch (e) {
      state = ErrorState('Error cargando facturas: $e');
      _logger.error('Error loading facturas', e);
    }
  }

  Future<void> createFactura(Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.createFactura(data);
      
      await loadFacturas(); // Recargar lista
      _logger.info('Factura created successfully');
    } catch (e) {
      state = ErrorState('Error creando factura: $e');
      _logger.error('Error creating factura', e);
    }
  }

  Future<void> updateFactura(int id, Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.updateFactura(id, data);
      
      await loadFacturas(); // Recargar lista
      _logger.info('Factura updated successfully');
    } catch (e) {
      state = ErrorState('Error actualizando factura: $e');
      _logger.error('Error updating factura', e);
    }
  }

  Future<void> deleteFactura(int id) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.deleteFactura(id);
      
      await loadFacturas(); // Recargar lista
      _logger.info('Factura deleted successfully');
    } catch (e) {
      state = ErrorState('Error eliminando factura: $e');
      _logger.error('Error deleting factura', e);
    }
  }
}

/// ==================== INSUMOS PROVIDER ====================

final insumosProvider = StateNotifierProvider<InsumosNotifier, BaseState>((ref) {
  return InsumosNotifier();
});

class InsumosNotifier extends StateNotifier<BaseState> {
  final AppLogger _logger = AppLogger.instance;

  InsumosNotifier() : super(const InitialState());

  Future<void> loadInsumos() async {
    try {
      state = const LoadingState();
      
      final apiService = ApiService();
      await apiService.initialize();
      final insumos = await apiService.getInsumos();
      
      state = LoadedState<List<Insumo>>(insumos);
      _logger.info('Insumos loaded successfully: ${insumos.length} items');
    } catch (e) {
      state = ErrorState('Error cargando insumos: $e');
      _logger.error('Error loading insumos', e);
    }
  }

  Future<void> createInsumo(Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.createInsumo(data);
      
      await loadInsumos(); // Recargar lista
      _logger.info('Insumo created successfully');
    } catch (e) {
      state = ErrorState('Error creando insumo: $e');
      _logger.error('Error creating insumo', e);
    }
  }

  Future<void> updateInsumo(int id, Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.updateInsumo(id, data);
      
      await loadInsumos(); // Recargar lista
      _logger.info('Insumo updated successfully');
    } catch (e) {
      state = ErrorState('Error actualizando insumo: $e');
      _logger.error('Error updating insumo', e);
    }
  }

  Future<void> deleteInsumo(int id) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.deleteInsumo(id);
      
      await loadInsumos(); // Recargar lista
      _logger.info('Insumo deleted successfully');
    } catch (e) {
      state = ErrorState('Error eliminando insumo: $e');
      _logger.error('Error deleting insumo', e);
    }
  }
}

/// ==================== USUARIOS PROVIDER ====================

final usuariosProvider = StateNotifierProvider<UsuariosNotifier, BaseState>((ref) {
  return UsuariosNotifier();
});

class UsuariosNotifier extends StateNotifier<BaseState> {
  final AppLogger _logger = AppLogger.instance;

  UsuariosNotifier() : super(const InitialState());

  Future<void> loadUsuarios() async {
    try {
      state = const LoadingState();
      
      final apiService = ApiService();
      await apiService.initialize();
      final usuarios = await apiService.getUsuarios();
      
      state = LoadedState<List<Usuario>>(usuarios);
      _logger.info('Usuarios loaded successfully: ${usuarios.length} items');
    } catch (e) {
      state = ErrorState('Error cargando usuarios: $e');
      _logger.error('Error loading usuarios', e);
    }
  }

  Future<void> createUsuario(Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.createUsuario(data);
      
      await loadUsuarios(); // Recargar lista
      _logger.info('Usuario created successfully');
    } catch (e) {
      state = ErrorState('Error creando usuario: $e');
      _logger.error('Error creating usuario', e);
    }
  }

  Future<void> updateUsuario(int id, Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.updateUsuario(id, data);
      
      await loadUsuarios(); // Recargar lista
      _logger.info('Usuario updated successfully');
    } catch (e) {
      state = ErrorState('Error actualizando usuario: $e');
      _logger.error('Error updating usuario', e);
    }
  }

  Future<void> deleteUsuario(int id) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.deleteUsuario(id);
      
      await loadUsuarios(); // Recargar lista
      _logger.info('Usuario deleted successfully');
    } catch (e) {
      state = ErrorState('Error eliminando usuario: $e');
      _logger.error('Error deleting usuario', e);
    }
  }
}

/// ==================== MANTENIMIENTOS PROVIDER ====================

final mantenimientosProvider = StateNotifierProvider<MantenimientosNotifier, BaseState>((ref) {
  return MantenimientosNotifier();
});

class MantenimientosNotifier extends StateNotifier<BaseState> {
  final AppLogger _logger = AppLogger.instance;

  MantenimientosNotifier() : super(const InitialState());

  Future<void> loadMantenimientos() async {
    try {
      state = const LoadingState();
      
      final apiService = ApiService();
      await apiService.initialize();
      final mantenimientos = await apiService.getMantenimientos();
      
      state = LoadedState<List<Mantenimiento>>(mantenimientos);
      _logger.info('Mantenimientos loaded successfully: ${mantenimientos.length} items');
    } catch (e) {
      final errorMessage = 'Error cargando mantenimientos: $e';
      state = ErrorState(errorMessage);
      _logger.error('Error loading mantenimientos', e);
      
      // Log adicional para debug
      if (e.toString().contains('404')) {
        _logger.error('Endpoint /mantenimientos/ not found (404)');
      } else if (e.toString().contains('500')) {
        _logger.error('Server error (500) for /mantenimientos/');
      } else if (e.toString().contains('connection')) {
        _logger.error('Connection error to /mantenimientos/');
      }
    }
  }

  Future<void> createMantenimiento(Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.createMantenimiento(data);
      
      await loadMantenimientos(); // Recargar lista
      _logger.info('Mantenimiento created successfully');
    } catch (e) {
      state = ErrorState('Error creando mantenimiento: $e');
      _logger.error('Error creating mantenimiento', e);
    }
  }

  Future<void> updateMantenimiento(int id, Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.updateMantenimiento(id, data);
      
      await loadMantenimientos();
      _logger.info('Mantenimiento updated successfully');
    } catch (e) {
      state = ErrorState('Error actualizando mantenimiento: $e');
      _logger.error('Error updating mantenimiento', e);
    }
  }
}

/// ==================== CRÉDITOS PROVIDER ====================

final creditosProvider = StateNotifierProvider<CreditosNotifier, BaseState>((ref) {
  return CreditosNotifier();
});

class CreditosNotifier extends StateNotifier<BaseState> {
  final AppLogger _logger = AppLogger.instance;

  CreditosNotifier() : super(const InitialState());

  Future<void> loadCreditos() async {
    try {
      state = const LoadingState();
      
      final apiService = ApiService();
      await apiService.initialize();
      final creditos = await apiService.getCreditos();
      
      state = LoadedState<List<Credito>>(creditos);
      _logger.info('Creditos loaded successfully: ${creditos.length} items');
    } catch (e) {
      state = ErrorState('Error cargando créditos: $e');
      _logger.error('Error loading creditos', e);
    }
  }

  Future<void> createCredito(Credito credito) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.createCredito(credito.toCreateJson());
      
      await loadCreditos(); // Recargar lista
      _logger.info('Credito created successfully');
    } catch (e) {
      state = ErrorState('Error creando crédito: $e');
      _logger.error('Error creating credito', e);
    }
  }

  Future<void> updateCredito(Credito credito) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.updateCredito(credito.id, credito.toUpdateJson());
      
      await loadCreditos(); // Recargar lista
      _logger.info('Credito updated successfully');
    } catch (e) {
      state = ErrorState('Error actualizando crédito: $e');
      _logger.error('Error updating credito', e);
    }
  }
}
