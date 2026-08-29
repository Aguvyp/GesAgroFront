import '../models/tipo_trabajo.dart';
import 'optimized_api_service.dart';

class TipoTrabajoService {
  static final ApiService _apiService = ApiService();

  static Future<void> _ensureInitialized() async {
    if (!_apiService.isInitialized) {
      await _apiService.initialize();
    }
  }

  static Future<List<TipoTrabajo>> getTiposTrabajo() async {
    try {
      await _ensureInitialized();
      return await _apiService.getTiposTrabajo();
    } catch (e) {
      throw Exception('Error al obtener tipos de trabajo: $e');
    }
  }

  static Future<TipoTrabajo> getTipoTrabajo(int id) async {
    try {
      await _ensureInitialized();
      return await _apiService.getTipoTrabajo(id);
    } catch (e) {
      throw Exception('Error al obtener tipo de trabajo: $e');
    }
  }
}
