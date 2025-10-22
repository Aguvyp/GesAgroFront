import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trabajo_detalle.dart';
import '../services/trabajo_detalle_service.dart';

/// Provider para obtener detalles de un trabajo específico
final trabajoDetalleProvider = StateNotifierProvider<TrabajoDetalleNotifier, AsyncValue<TrabajoDetalle?>>((ref) {
  return TrabajoDetalleNotifier();
});

/// Provider para obtener lista de trabajos con detalles
final trabajosDetalleProvider = StateNotifierProvider<TrabajosDetalleNotifier, AsyncValue<List<TrabajoDetalle>>>((ref) {
  return TrabajosDetalleNotifier();
});

/// Notifier para manejar el estado de un trabajo específico con detalles
class TrabajoDetalleNotifier extends StateNotifier<AsyncValue<TrabajoDetalle?>> {
  TrabajoDetalleNotifier() : super(const AsyncValue.loading());

  /// Cargar detalles de un trabajo por ID
  Future<void> loadTrabajoDetalle(int trabajoId) async {
    state = const AsyncValue.loading();
    
    try {
      final trabajoDetalle = await TrabajoDetalleService.getTrabajoDetalle(trabajoId);
      state = AsyncValue.data(trabajoDetalle);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Limpiar el estado
  void clear() {
    state = const AsyncValue.loading();
  }
}

/// Notifier para manejar el estado de la lista de trabajos con detalles
class TrabajosDetalleNotifier extends StateNotifier<AsyncValue<List<TrabajoDetalle>>> {
  TrabajosDetalleNotifier() : super(const AsyncValue.loading());

  /// Cargar lista de trabajos con detalles
  Future<void> loadTrabajosDetalle() async {
    state = const AsyncValue.loading();
    
    try {
      final trabajosDetalle = await TrabajoDetalleService.getTrabajosDetalleOptimizado();
      state = AsyncValue.data(trabajosDetalle);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refrescar la lista
  Future<void> refresh() async {
    await loadTrabajosDetalle();
  }

  /// Filtrar trabajos por estado
  List<TrabajoDetalle> getTrabajosByEstado(String estado) {
    return state.when(
      data: (trabajos) => trabajos.where((t) => t.estado == estado).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// Filtrar trabajos por tipo
  List<TrabajoDetalle> getTrabajosByTipo(String tipo) {
    return state.when(
      data: (trabajos) => trabajos.where((t) => t.tipo.toLowerCase().contains(tipo.toLowerCase())).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// Filtrar trabajos por cultivo
  List<TrabajoDetalle> getTrabajosByCultivo(String cultivo) {
    return state.when(
      data: (trabajos) => trabajos.where((t) => t.cultivo.toLowerCase().contains(cultivo.toLowerCase())).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// Filtrar trabajos por campo
  List<TrabajoDetalle> getTrabajosByCampo(String campoNombre) {
    return state.when(
      data: (trabajos) => trabajos.where((t) => 
        t.campo?.nombre.toLowerCase().contains(campoNombre.toLowerCase()) ?? false
      ).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// Obtener trabajos de terceros
  List<TrabajoDetalle> getTrabajosTerceros() {
    return state.when(
      data: (trabajos) => trabajos.where((t) => t.aTerceros).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// Obtener trabajos propios
  List<TrabajoDetalle> getTrabajosPropios() {
    return state.when(
      data: (trabajos) => trabajos.where((t) => !t.aTerceros).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// Obtener trabajos cobrados
  List<TrabajoDetalle> getTrabajosCobrados() {
    return state.when(
      data: (trabajos) => trabajos.where((t) => t.cobrado).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// Obtener trabajos pendientes de cobro
  List<TrabajoDetalle> getTrabajosPendientesCobro() {
    return state.when(
      data: (trabajos) => trabajos.where((t) => !t.cobrado).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  /// Obtener estadísticas generales
  Map<String, dynamic> getEstadisticas() {
    return state.when(
      data: (trabajos) {
        final total = trabajos.length;
        final completados = trabajos.where((t) => t.isCompleted).length;
        final enCurso = trabajos.where((t) => t.isInProgress).length;
        final pendientes = trabajos.where((t) => t.isPending).length;
        final terceros = trabajos.where((t) => t.aTerceros).length;
        final propios = trabajos.where((t) => !t.aTerceros).length;
        final cobrados = trabajos.where((t) => t.cobrado).length;
        final pendientesCobro = trabajos.where((t) => !t.cobrado).length;
        
        final totalHectareas = trabajos.fold(0.0, (sum, t) => sum + t.totalHectareasPersonal);
        final totalPersonal = trabajos.fold(0, (sum, t) => sum + t.totalPersonal);
        final totalMaquinas = trabajos.fold(0, (sum, t) => sum + t.totalMaquinas);
        
        return {
          'total': total,
          'completados': completados,
          'en_curso': enCurso,
          'pendientes': pendientes,
          'terceros': terceros,
          'propios': propios,
          'cobrados': cobrados,
          'pendientes_cobro': pendientesCobro,
          'total_hectareas': totalHectareas,
          'total_personal': totalPersonal,
          'total_maquinas': totalMaquinas,
        };
      },
      loading: () => {},
      error: (_, __) => {},
    );
  }
}
