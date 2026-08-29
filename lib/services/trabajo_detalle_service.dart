import '../models/trabajo_detalle.dart';
import 'optimized_api_service.dart';

class TrabajoDetalleService {
  static final ApiService _apiService = ApiService();

  static Future<void> _ensureInitialized() async {
    if (!_apiService.isInitialized) {
      await _apiService.initialize();
    }
  }

  /// Obtener detalles completos de un trabajo por ID
  /// Incluye campo, cliente, operarios con hectáreas y máquinas
  static Future<TrabajoDetalle> getTrabajoDetalle(int trabajoId) async {
    try {
      await _ensureInitialized();

      // Usar el nuevo endpoint específico para detalles
      final response =
          await _apiService.get('/api/trabajos/detalle/$trabajoId');

      // El endpoint ya devuelve toda la información estructurada
      return TrabajoDetalle.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener detalles del trabajo: $e');
    }
  }

  /// Obtener lista de trabajos con detalles completos
  static Future<List<TrabajoDetalle>> getTrabajosDetalle() async {
    try {
      await _ensureInitialized();

      final trabajos = await _apiService.getTrabajos();
      final trabajosDetalle = <TrabajoDetalle>[];

      // Procesar cada trabajo para obtener sus detalles
      for (final trabajo in trabajos) {
        try {
          final detalle = await getTrabajoDetalle(trabajo.id!);
          trabajosDetalle.add(detalle);
        } catch (e) {
          print('Error procesando trabajo ${trabajo.id}: $e');
          // Agregar trabajo básico sin detalles completos
          trabajosDetalle.add(TrabajoDetalle(
            id: trabajo.id,
            tipo: trabajo.tipo,
            cliente: trabajo.cliente ?? '',
            cultivo: trabajo.cultivo,
            fechaInicio: trabajo.fechaInicio,
            fechaFin: trabajo.fechaFin,
            estado: trabajo.estado,
            observaciones: trabajo.observaciones,
            aTerceros: trabajo.esTercero,
            campoId: trabajo.idCampo,
            cobrado: trabajo.cobrado,
            montoCobrado: trabajo.montoCobrado,
          ));
        }
      }

      return trabajosDetalle;
    } catch (e) {
      throw Exception('Error al obtener lista de trabajos con detalles: $e');
    }
  }

  /// Obtener trabajos con detalles de forma optimizada (paralela)
  static Future<List<TrabajoDetalle>> getTrabajosDetalleOptimizado() async {
    try {
      await _ensureInitialized();

      // Obtener lista de trabajos básicos
      final trabajos = await _apiService.getTrabajos();
      final trabajosDetalle = <TrabajoDetalle>[];

      // Procesar cada trabajo para obtener sus detalles usando el endpoint específico
      for (final trabajo in trabajos) {
        try {
          final detalle = await getTrabajoDetalle(trabajo.id!);
          trabajosDetalle.add(detalle);
        } catch (e) {
          print('Error procesando trabajo ${trabajo.id}: $e');
          // Agregar trabajo básico sin detalles completos como fallback
          trabajosDetalle.add(TrabajoDetalle(
            id: trabajo.id,
            tipo: trabajo.tipo,
            cliente: trabajo.cliente ?? '',
            cultivo: trabajo.cultivo,
            fechaInicio: trabajo.fechaInicio,
            fechaFin: trabajo.fechaFin,
            estado: trabajo.estado,
            observaciones: trabajo.observaciones,
            aTerceros: trabajo.esTercero,
            campoId: trabajo.idCampo,
            cobrado: trabajo.cobrado,
            montoCobrado: trabajo.montoCobrado,
          ));
        }
      }

      return trabajosDetalle;
    } catch (e) {
      throw Exception('Error al obtener trabajos con detalles optimizado: $e');
    }
  }
}
