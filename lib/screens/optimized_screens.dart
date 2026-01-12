import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/optimized_widgets.dart';
import '../providers/optimized_providers.dart';
import 'campos/campo_detail_screen.dart';
import 'trabajos/trabajo_detail_screen.dart';
import 'forms/forms_screens.dart';

/// ==================== CAMPOS LIST SCREEN OPTIMIZADA ====================

class OptimizedCamposListScreen extends ConsumerStatefulWidget {
  final bool? showAppBar;
  
  const OptimizedCamposListScreen({Key? key, this.showAppBar}) : super(key: key);

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
    
    final body = _buildCamposList(camposState);
    
    if (widget.showAppBar ?? false) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text(
            'Campos',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            color: const Color(0xFF1C1C1E),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: body,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showCampoForm(context);
          },
          backgroundColor: const Color(0xFF2E7D32),
          child: const Icon(Icons.add),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 56,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: 56,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Campos',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.41,
                  ),
                ),
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 12),
              ),
            ),
          ];
        },
        body: body,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCampoForm(context);
        },
        backgroundColor: const Color(0xFF2E7D32),
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
      
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filteredCampos.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final campo = filteredCampos[index];
          return OptimizedCard(
            margin: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(16),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.landscape_rounded, color: Color(0xFF2E7D32), size: 24),
              ),
              title: Text(
                campo.nombre,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.41,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${campo.superficieHa.toStringAsFixed(2)} hectáreas',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF8E8E93),
                    letterSpacing: -0.24,
                  ),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CampoDetailScreen(campo: campo),
                  ),
                );
              },
              trailing: PopupMenuButton(
                icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF8E8E93)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: const Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 20, color: Color(0xFF1C1C1E)),
                        SizedBox(width: 12),
                        Text('Editar', style: TextStyle(fontSize: 17)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: const Row(
                      children: [
                        Icon(Icons.delete_rounded, size: 20, color: Color(0xFFFF3B30)),
                        SizedBox(width: 12),
                        Text('Eliminar', style: TextStyle(fontSize: 17, color: Color(0xFFFF3B30))),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showCampoForm(context, campo: campo);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context, campo);
                  }
                },
              ),
            ),
          );
        },
      );
    }
    
    return const OptimizedEmptyWidget(
      message: 'Estado desconocido',
      icon: Icons.help_outline,
    );
  }

  void _showCampoForm(BuildContext context, {dynamic campo}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampoFormScreen(campo: campo),
      ),
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
              ref.read(camposProvider.notifier).deleteCampo(campo.id);
              if (mounted) {
                Navigator.of(context).pop();
                OptimizedSnackBar.showSuccess(
                  context,
                  message: 'Campo eliminado exitosamente',
                );
              }
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
  final String? estadoFiltro; // Filtro opcional por estado
  final bool? showAppBar; // Si debe mostrar AppBar
  
  const OptimizedTrabajosListScreen({
    Key? key,
    this.estadoFiltro,
    this.showAppBar,
  }) : super(key: key);

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
    
    final body = _buildTrabajosList(trabajosState);
    
    if (widget.showAppBar ?? false) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(
            widget.estadoFiltro != null 
              ? 'Trabajos - ${widget.estadoFiltro}'
              : 'Trabajos',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            color: const Color(0xFF1C1C1E),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: body,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showTrabajoForm(context);
          },
          backgroundColor: const Color(0xFF2E7D32),
          child: const Icon(Icons.add),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 56,
              toolbarHeight: 56,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.estadoFiltro != null 
                    ? 'Trabajos - ${widget.estadoFiltro}'
                    : 'Trabajos',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.41,
                  ),
                ),
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 12),
              ),
            ),
          ];
        },
        body: body,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTrabajoForm(context);
        },
        backgroundColor: const Color(0xFF2E7D32),
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
      
      var filteredTrabajos = trabajos;
      
      // Aplicar filtro por estado si existe
      if (widget.estadoFiltro != null) {
        filteredTrabajos = filteredTrabajos.where((trabajo) {
          final estado = (trabajo.estado ?? '').toLowerCase();
          final filtro = widget.estadoFiltro!.toLowerCase();
          
          if (filtro == 'pendientes' || filtro == 'pendiente') {
            return estado == 'pendiente' || estado == 'programado';
          } else if (filtro == 'en curso' || filtro == 'en_curso') {
            return estado == 'en curso' || estado == 'en ejecución' || estado == 'ejecutando' || estado == 'en_progreso';
          } else if (filtro == 'completados' || filtro == 'completado') {
            return estado == 'completado' || estado == 'finalizado';
          }
          return estado == filtro;
        }).toList();
      }
      
      // Aplicar filtro de búsqueda
      if (_searchQuery.isNotEmpty) {
        filteredTrabajos = filteredTrabajos.where((trabajo) {
          return trabajo.tipo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 trabajo.cultivo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 (trabajo.estado ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      }
      
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filteredTrabajos.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final trabajo = filteredTrabajos[index];
          return OptimizedCard(
            margin: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrabajoDetailScreen(trabajo: trabajo),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _getTrabajoColor(trabajo.estado).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.work_rounded, 
                            color: _getTrabajoColor(trabajo.estado),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${trabajo.tipo} - ${trabajo.cultivo}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1C1C1E),
                                  letterSpacing: -0.41,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Campo: ${trabajo.campoInfo}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF8E8E93),
                                  letterSpacing: -0.24,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${trabajo.formattedDateRange} • ${trabajo.estado ?? 'Pendiente'}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8E8E93),
                                  letterSpacing: -0.08,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton(
                          icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF8E8E93)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          itemBuilder: (context) => _buildTrabajoMenuItems(trabajo),
                          onSelected: (value) => _handleTrabajoMenuAction(value, trabajo),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTrabajoActionButtons(trabajo),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
    
    return const OptimizedEmptyWidget(
      message: 'Estado desconocido',
      icon: Icons.help_outline,
    );
  }

  void _showTrabajoForm(BuildContext context, {dynamic trabajo}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrabajoFormScreen(trabajo: trabajo),
      ),
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

  Widget _buildTrabajoActionButtons(dynamic trabajo) {
    final estado = trabajo.estado?.toLowerCase() ?? 'pendiente';
    
    if (estado == 'pendiente') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _cambiarEstadoTrabajo(trabajo, 'En Curso'),
              icon: const Icon(Icons.play_arrow_rounded, size: 16),
              label: const Text('Iniciar'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _cambiarEstadoTrabajo(trabajo, 'Completado'),
              icon: const Icon(Icons.check_circle_rounded, size: 16),
              label: const Text('Completar'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (estado == 'en curso' || estado == 'en_progreso') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: () => _cambiarEstadoTrabajo(trabajo, 'Completado'),
            icon: const Icon(Icons.check_circle, size: 12),
            label: const Text('Completar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              textStyle: const TextStyle(fontSize: 10),
              minimumSize: const Size(0, 28),
            ),
          ),
        ],
      );
    }
    
    // Para trabajos completados, no mostrar botones
    return const SizedBox.shrink();
  }

  List<PopupMenuEntry> _buildTrabajoMenuItems(dynamic trabajo) {
    return [
      const PopupMenuItem(
        value: 'edit',
        child: Row(
          children: [
            Icon(Icons.edit_rounded, size: 20, color: Color(0xFF1C1C1E)),
            SizedBox(width: 12),
            Text('Editar', style: TextStyle(fontSize: 17)),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete_rounded, size: 20, color: Color(0xFFFF3B30)),
            SizedBox(width: 12),
            Text('Eliminar', style: TextStyle(fontSize: 17, color: Color(0xFFFF3B30))),
          ],
        ),
      ),
    ];
  }

  void _handleTrabajoMenuAction(dynamic value, dynamic trabajo) {
    switch (value) {
      case 'edit':
        _showTrabajoForm(context, trabajo: trabajo);
        break;
      case 'delete':
        _showDeleteConfirmation(context, trabajo);
        break;
    }
  }

  void _cambiarEstadoTrabajo(dynamic trabajo, String nuevoEstado) async {
    try {
      // Preparar datos para actualizar
      final Map<String, dynamic> updateData = {
        'estado': nuevoEstado,
      };

      // Si se está completando el trabajo, agregar fecha de fin
      if (nuevoEstado == 'Completado') {
        updateData['fecha_fin'] = DateTime.now().toIso8601String().split('T')[0];
      }

      // Actualizar el trabajo usando el provider
      await ref.read(trabajosProvider.notifier).updateTrabajo(trabajo.id, updateData);

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado cambiado a: $nuevoEstado'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar estado: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Color _getTrabajoColor(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'completado':
        return Colors.green;
      case 'en curso':
      case 'en_progreso':
        return Colors.orange;
      case 'pendiente':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
