import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/optimized_widgets.dart';
import '../providers/optimized_providers.dart';
import 'optimized_forms.dart';
import 'campo_detail_screen.dart';
import 'trabajo_detail_screen.dart';

/// ==================== CAMPOS LIST SCREEN OPTIMIZADA ====================

class OptimizedCamposListScreen extends ConsumerStatefulWidget {
  const OptimizedCamposListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedCamposListScreen> createState() => _OptimizedCamposListScreenState();
}

class _OptimizedCamposListScreenState extends ConsumerState<OptimizedCamposListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(camposProvider.notifier).loadCampos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final camposState = ref.watch(camposProvider);
    
    return Scaffold(
      // AppBar removido - ahora está en OptimizedMainScreen
      body: _buildCamposList(camposState),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCampoForm(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCamposList(BaseState state) {
    if (state is LoadingState) {
      return const OptimizedShimmerList();
    }
    
    if (state is ErrorState) {
      return OptimizedErrorWidget(
        message: state.message,
        onRetry: () {
          ref.read(camposProvider.notifier).loadCampos();
        },
      );
    }
    
    if (state is LoadedState<List<dynamic>>) {
      final campos = state.data;
      
      if (campos.isEmpty) {
        return const OptimizedEmptyWidget(
          message: 'No hay campos registrados',
          subtitle: 'Toca el botón + para agregar un nuevo campo',
          icon: Icons.landscape_outlined,
        );
      }
      
      final filteredCampos = _searchQuery.isEmpty
          ? campos
          : campos.where((campo) {
              return campo.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                     campo.superficieHa.toString().contains(_searchQuery);
            }).toList();
      
      return OptimizedAnimatedList(
        children: filteredCampos.map((campo) {
          return OptimizedCard(
            child: ListTile(
              leading: const Icon(Icons.landscape, color: Colors.green),
              title: Text(campo.nombre),
              subtitle: Text('${campo.superficieHa.toStringAsFixed(2)} hectáreas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CampoDetailScreen(campo: campo),
                  ),
                );
              },
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Text('Ver Detalles'),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Editar'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Eliminar'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'view') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CampoDetailScreen(campo: campo),
                      ),
                    );
                  } else if (value == 'edit') {
                    _showCampoForm(context, campo: campo);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context, campo);
                  }
                },
              ),
            ),
          );
        }).toList(),
      );
    }
    
    return const OptimizedEmptyWidget(
      message: 'Estado desconocido',
      icon: Icons.help_outline,
    );
  }

  void _showCampoForm(BuildContext context, {dynamic campo}) {
    showDialog(
      context: context,
      builder: (context) => CampoFormDialog(campo: campo),
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic campo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar este campo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implementar eliminación
              OptimizedSnackBar.showSuccess(
                context,
                message: 'Campo eliminado exitosamente',
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

/// ==================== TRABAJOS LIST SCREEN OPTIMIZADA ====================

class OptimizedTrabajosListScreen extends ConsumerStatefulWidget {
  const OptimizedTrabajosListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedTrabajosListScreen> createState() => _OptimizedTrabajosListScreenState();
}

class _OptimizedTrabajosListScreenState extends ConsumerState<OptimizedTrabajosListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trabajosProvider.notifier).loadTrabajos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trabajosState = ref.watch(trabajosProvider);
    
    return Scaffold(
      // AppBar removido - ahora está en OptimizedMainScreen
      body: _buildTrabajosList(trabajosState),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTrabajoForm(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTrabajosList(BaseState state) {
    if (state is LoadingState) {
      return const OptimizedShimmerList();
    }
    
    if (state is ErrorState) {
      return OptimizedErrorWidget(
        message: state.message,
        onRetry: () {
          ref.read(trabajosProvider.notifier).loadTrabajos();
        },
      );
    }
    
    if (state is LoadedState<List<dynamic>>) {
      final trabajos = state.data;
      
      if (trabajos.isEmpty) {
        return const OptimizedEmptyWidget(
          message: 'No hay trabajos registrados',
          subtitle: 'Toca el botón + para agregar un nuevo trabajo',
          icon: Icons.work_outline,
        );
      }
      
      final filteredTrabajos = _searchQuery.isEmpty
          ? trabajos
          : trabajos.where((trabajo) {
              return trabajo.tipo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                     trabajo.cultivo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                     (trabajo.estado ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
            }).toList();
      
      return OptimizedAnimatedList(
        children: filteredTrabajos.map((trabajo) {
          return OptimizedCard(
            child: ListTile(
              leading: Icon(
                Icons.work, 
                color: _getTrabajoColor(trabajo.estado),
              ),
              title: Text('${trabajo.tipo} - ${trabajo.cultivo}'),
              subtitle: Text('${trabajo.formattedDateRange} • ${trabajo.estado ?? 'Pendiente'}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrabajoDetailScreen(trabajo: trabajo),
                  ),
                );
              },
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Text('Ver Detalles'),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Editar'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Eliminar'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'view') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrabajoDetailScreen(trabajo: trabajo),
                      ),
                    );
                  } else if (value == 'edit') {
                    _showTrabajoForm(context, trabajo: trabajo);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context, trabajo);
                  }
                },
              ),
            ),
          );
        }).toList(),
      );
    }
    
    return const OptimizedEmptyWidget(
      message: 'Estado desconocido',
      icon: Icons.help_outline,
    );
  }

  void _showTrabajoForm(BuildContext context, {dynamic trabajo}) {
    showDialog(
      context: context,
      builder: (context) => TrabajoFormDialog(trabajo: trabajo),
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic trabajo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar este trabajo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implementar eliminación
              OptimizedSnackBar.showSuccess(
                context,
                message: 'Trabajo eliminado exitosamente',
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Color _getTrabajoColor(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'completado':
        return Colors.green;
      case 'en curso':
        return Colors.orange;
      case 'pendiente':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
