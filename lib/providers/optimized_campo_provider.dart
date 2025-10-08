import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import '../core/logger/app_logger.dart';
import '../services/optimized_api_service.dart';
import '../models/campo.dart';

/// Estados para campos
abstract class CampoState extends Equatable {
  const CampoState();
  
  @override
  List<Object?> get props => [];
}

class CampoInitialState extends CampoState {
  const CampoInitialState();
}

class CampoLoadingState extends CampoState {
  const CampoLoadingState();
}

class CampoLoadedState extends CampoState {
  final List<Campo> campos;
  
  const CampoLoadedState(this.campos);
  
  @override
  List<Object?> get props => [campos];
}

class CampoErrorState extends CampoState {
  final String message;
  
  const CampoErrorState(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Provider de campos ultra optimizado
final campoProvider = StateNotifierProvider<CampoNotifier, CampoState>((ref) {
  return CampoNotifier();
});

class CampoNotifier extends StateNotifier<CampoState> {
  final AppLogger _logger = AppLogger.instance;
  final List<Campo> _campos = [];

  CampoNotifier() : super(const CampoInitialState());

  /// Cargar lista de campos
  Future<void> loadCampos({bool forceRefresh = false}) async {
    try {
      state = const CampoLoadingState();
      
      final apiService = ApiService();
      await apiService.initialize();
      final campos = await apiService.getCampos();
      
      _campos.clear();
      _campos.addAll(campos);
      
      state = CampoLoadedState(List.from(_campos));
      _logger.state('CampoProvider', 'LOAD_SUCCESS', data: {'count': campos.length});
    } catch (e) {
      state = CampoErrorState('Error cargando campos: $e');
      _logger.error('Error loading campos', e);
    }
  }

  /// Obtener campo por ID
  Future<Campo?> getCampoById(int id) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      return await apiService.getCampo(id);
    } catch (e) {
      _logger.error('Error getting campo by id', e);
      return null;
    }
  }

  /// Crear nuevo campo
  Future<Campo?> createCampo(Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      final newCampo = await apiService.createCampo(data);
      
      // Actualizar lista local
      _campos.add(newCampo);
      state = CampoLoadedState(List.from(_campos));
      
      _logger.state('CampoProvider', 'CREATE_SUCCESS', data: {'id': newCampo.id});
      return newCampo;
    } catch (e) {
      _logger.error('Error creating campo', e);
      rethrow;
    }
  }

  /// Actualizar campo
  Future<Campo?> updateCampo(int id, Map<String, dynamic> data) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      final updatedCampo = await apiService.updateCampo(id, data);
      
      // Actualizar lista local
      final index = _campos.indexWhere((campo) => campo.id == id);
      if (index != -1) {
        _campos[index] = updatedCampo;
        state = CampoLoadedState(List.from(_campos));
      }
      
      _logger.state('CampoProvider', 'UPDATE_SUCCESS', data: {'id': id});
      return updatedCampo;
    } catch (e) {
      _logger.error('Error updating campo', e);
      rethrow;
    }
  }

  /// Eliminar campo
  Future<void> deleteCampo(int id) async {
    try {
      final apiService = ApiService();
      await apiService.initialize();
      await apiService.deleteCampo(id);
      
      // Actualizar lista local
      _campos.removeWhere((campo) => campo.id == id);
      state = CampoLoadedState(List.from(_campos));
      
      _logger.state('CampoProvider', 'DELETE_SUCCESS', data: {'id': id});
    } catch (e) {
      _logger.error('Error deleting campo', e);
      rethrow;
    }
  }

  /// Buscar campos por nombre
  List<Campo> searchCampos(String query) {
    if (query.isEmpty) return _campos;
    
    return _campos.where((campo) {
      return campo.nombre.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  /// Obtener campos por superficie
  List<Campo> getCamposBySuperficie(double minSuperficie, double maxSuperficie) {
    return _campos.where((campo) {
      return campo.superficieHa >= minSuperficie && campo.superficieHa <= maxSuperficie;
    }).toList();
  }

  /// Obtener estadísticas de campos
  Map<String, dynamic> getCamposStats() {
    final total = _campos.length;
    final superficieTotal = _campos.fold(0.0, (sum, campo) => sum + campo.superficieHa);
    final superficiePromedio = total > 0 ? superficieTotal / total : 0.0;
    
    return {
      'total': total,
      'superficieTotal': superficieTotal,
      'superficiePromedio': superficiePromedio,
    };
  }

  /// Refrescar datos
  Future<void> refresh() async {
    await loadCampos(forceRefresh: true);
  }

  /// Limpiar caché
  void clearCache() {
    _campos.clear();
    state = const CampoInitialState();
    _logger.cache('CLEARED_ALL', 'campos');
  }
}

/// Provider para obtener la lista de campos
final camposListProvider = Provider<List<Campo>>((ref) {
  final campoState = ref.watch(campoProvider);
  if (campoState is CampoLoadedState) {
    return campoState.campos;
  }
  return [];
});

/// Provider para obtener estadísticas de campos
final camposStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final campoNotifier = ref.read(campoProvider.notifier);
  return campoNotifier.getCamposStats();
});

/// Provider para buscar campos
final searchCamposProvider = Provider.family<List<Campo>, String>((ref, query) {
  final campoNotifier = ref.read(campoProvider.notifier);
  return campoNotifier.searchCampos(query);
});

/// Provider para campos por superficie
final camposBySuperficieProvider = Provider.family<List<Campo>, Map<String, double>>((ref, params) {
  final campoNotifier = ref.read(campoProvider.notifier);
  return campoNotifier.getCamposBySuperficie(params['min']!, params['max']!);
});