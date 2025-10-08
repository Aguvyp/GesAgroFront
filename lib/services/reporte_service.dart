import '../utils/constants.dart';
import 'api_service.dart';

class ReporteService {
  // Obtener reporte en formato JSON
  static Future<Map<String, dynamic>> getReporte(String tipo) async {
    try {
      final response = await ApiService.get('${AppConstants.reportesEndpoint}/$tipo');
      return response;
    } catch (e) {
      throw Exception('Error al obtener reporte $tipo: $e');
    }
  }

  // Obtener reporte en formato Excel (CSV)
  static Future<String> getReporteExcel(String tipo) async {
    try {
      final response = await ApiService.get('${AppConstants.reportesEndpoint}/$tipo/excel');
      return response.toString();
    } catch (e) {
      throw Exception('Error al obtener reporte Excel $tipo: $e');
    }
  }

  // Obtener reporte en formato PDF
  static Future<String> getReportePdf(String tipo) async {
    try {
      final response = await ApiService.get('${AppConstants.reportesEndpoint}/$tipo/pdf');
      return response.toString();
    } catch (e) {
      throw Exception('Error al obtener reporte PDF $tipo: $e');
    }
  }

  // Reporte de rentabilidad
  static Future<Map<String, dynamic>> getReporteRentabilidad() async {
    return getReporte('rentabilidad');
  }

  // Reporte de máquinas
  static Future<Map<String, dynamic>> getReporteMaquinas() async {
    return getReporte('maquinas');
  }

  // Reporte de clientes
  static Future<Map<String, dynamic>> getReporteClientes() async {
    return getReporte('clientes');
  }

  // Reporte de campos
  static Future<Map<String, dynamic>> getReporteCampos() async {
    return getReporte('campos');
  }

  // Obtener tipos de reportes disponibles
  static Future<List<String>> getTiposReportes() async {
    try {
      final response = await ApiService.get(AppConstants.reportesEndpoint);
      return List<String>.from(response['tipos'] ?? []);
    } catch (e) {
      throw Exception('Error al obtener tipos de reportes: $e');
    }
  }

  // Exportar reporte como archivo
  static Future<void> exportarReporte(String tipo, String formato) async {
    try {
      String endpoint;
      switch (formato.toLowerCase()) {
        case 'excel':
        case 'csv':
          endpoint = '${AppConstants.reportesEndpoint}/$tipo/excel';
          break;
        case 'pdf':
          endpoint = '${AppConstants.reportesEndpoint}/$tipo/pdf';
          break;
        default:
          throw Exception('Formato no soportado: $formato');
      }
      
      final response = await ApiService.get(endpoint);
      // Aquí se implementaría la descarga del archivo
      // Por ahora solo retornamos el contenido
    } catch (e) {
      throw Exception('Error al exportar reporte $tipo en formato $formato: $e');
    }
  }
}
