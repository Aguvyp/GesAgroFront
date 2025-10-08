import '../utils/constants.dart';
import 'api_service.dart';

class MobileService {
  // Resumen móvil general
  static Future<Map<String, dynamic>> getResumenMobile() async {
    try {
      final response = await ApiService.get(AppConstants.resumenMobileEndpoint);
      return response;
    } catch (e) {
      throw Exception('Error al obtener resumen móvil: $e');
    }
  }

  // Estadísticas rápidas
  static Future<Map<String, dynamic>> getEstadisticasMobile() async {
    try {
      final response = await ApiService.get(AppConstants.estadisticasMobileEndpoint);
      return response;
    } catch (e) {
      throw Exception('Error al obtener estadísticas móviles: $e');
    }
  }

  // Trabajos recientes
  static Future<List<Map<String, dynamic>>> getTrabajosRecientes({int limit = 5}) async {
    try {
      final response = await ApiService.get('${AppConstants.trabajosRecientesEndpoint}?limit=$limit');
      final List<dynamic> trabajosData = response is List ? response : (response['data'] ?? []);
      return trabajosData.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error al obtener trabajos recientes: $e');
    }
  }

  // Mantenimientos próximos
  static Future<List<Map<String, dynamic>>> getMantenimientosProximos({int limit = 5}) async {
    try {
      final response = await ApiService.get('${AppConstants.mantenimientosProximosEndpoint}?limit=$limit');
      final List<dynamic> mantenimientosData = response is List ? response : (response['data'] ?? []);
      return mantenimientosData.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error al obtener mantenimientos próximos: $e');
    }
  }

  // Insumos bajo stock
  static Future<List<Map<String, dynamic>>> getInsumosBajoStock() async {
    try {
      final response = await ApiService.get(AppConstants.insumosBajoStockEndpoint);
      final List<dynamic> insumosData = response is List ? response : (response['data'] ?? []);
      return insumosData.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error al obtener insumos bajo stock: $e');
    }
  }

  // Resumen de finanzas
  static Future<Map<String, dynamic>> getFinanzasResumen() async {
    try {
      final response = await ApiService.get(AppConstants.finanzasResumenEndpoint);
      return response;
    } catch (e) {
      throw Exception('Error al obtener resumen de finanzas: $e');
    }
  }
}
