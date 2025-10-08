import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../widgets/optimized_widgets.dart';
import '../providers/optimized_providers.dart';
import '../models/campo.dart';

/// Pantalla de campos ultra optimizada
class OptimizedCamposScreen extends ConsumerStatefulWidget {
  const OptimizedCamposScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedCamposScreen> createState() => _OptimizedCamposScreenState();
}

class _OptimizedCamposScreenState extends ConsumerState<OptimizedCamposScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _fabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final camposState = ref.watch(camposProvider);
    final camposList = camposState is LoadedState ? camposState.data : <Campo>[];
    final camposStats = _getCamposStats(camposList);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campos'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(camposProvider.notifier).loadCampos();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          _buildSearchAndFilters(),
          
          // Estadísticas rápidas
          _buildQuickStats(camposStats),
          
          // Lista de campos
          Expanded(
            child: _buildCamposList(camposState, camposList),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCampoDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Campo'),
      )
          .animate()
          .scale(delay: 500.ms, duration: 300.ms)
          .fadeIn(delay: 500.ms, duration: 300.ms),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          OptimizedTextField(
            controller: _searchController,
            hint: 'Buscar campos...',
            prefixIcon: const Icon(Icons.search),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip('Todos', true, () {}),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip('Pequeños', false, () {}),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip('Grandes', false, () {}),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor,
          ),
        ),
        child: AutoSizeText(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .scale(delay: 100.ms, duration: 200.ms);
  }

  Widget _buildQuickStats(Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              stats['total']?.toString() ?? '0',
              Icons.landscape,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Superficie',
              '${stats['superficieTotal']?.toStringAsFixed(1) ?? '0'} ha',
              Icons.straighten,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Promedio',
              '${stats['superficiePromedio']?.toStringAsFixed(1) ?? '0'} ha',
              Icons.trending_up,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return OptimizedCard(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          )
              .animate()
              .scale(delay: 200.ms, duration: 300.ms),
          const SizedBox(height: 8),
          AutoSizeText(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 300.ms),
          AutoSizeText(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
            maxLines: 1,
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 300.ms),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCamposStats(List<Campo> campos) {
    final total = campos.length;
    final superficieTotal = campos.fold(0.0, (sum, campo) => sum + campo.superficieHa);
    final superficiePromedio = total > 0 ? superficieTotal / total : 0.0;
    
    return {
      'total': total,
      'superficieTotal': superficieTotal,
      'superficiePromedio': superficiePromedio,
    };
  }

  Widget _buildCamposList(BaseState camposState, List<Campo> camposList) {
    if (camposState is LoadingState) {
      return const OptimizedShimmerList(itemCount: 6, itemHeight: 120);
    }

    if (camposState is ErrorState) {
      return OptimizedErrorWidget(
        message: camposState.message,
        onRetry: () => ref.read(camposProvider.notifier).loadCampos(),
      );
    }

    final filteredCampos = _searchQuery.isEmpty
        ? camposList
        : camposList.where((campo) =>
            campo.nombre.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    if (filteredCampos.isEmpty) {
      return OptimizedEmptyWidget(
        message: _searchQuery.isEmpty ? 'No hay campos registrados' : 'No se encontraron campos',
        subtitle: _searchQuery.isEmpty
            ? 'Comienza agregando tu primer campo'
            : 'Intenta con otros términos de búsqueda',
        icon: Icons.landscape_outlined,
        action: _searchQuery.isEmpty
            ? OptimizedButton(
                text: 'Agregar Campo',
                icon: Icons.add,
                onPressed: () => _showCreateCampoDialog(),
              )
            : null,
      );
    }

    return OptimizedAnimatedList(
      children: filteredCampos.map((campo) => _buildCampoCard(campo)).toList(),
    );
  }

  Widget _buildCampoCard(Campo campo) {
    return OptimizedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.landscape,
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
              )
                  .animate()
                  .scale(delay: 200.ms, duration: 300.ms),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      campo.nombre,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 300.ms)
                        .slideX(begin: 0.2, end: 0, delay: 300.ms, duration: 300.ms),
                    AutoSizeText(
                      '${campo.superficieHa} hectáreas',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      maxLines: 1,
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 300.ms)
                        .slideX(begin: 0.2, end: 0, delay: 400.ms, duration: 300.ms),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleCampoAction(value, campo),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 8),
                        Text('Eliminar'),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 300.ms)
                  .scale(delay: 500.ms, duration: 300.ms),
            ],
          ),
          if (campo.detalles != null && campo.detalles!.isNotEmpty) ...[
            const SizedBox(height: 12),
            AutoSizeText(
              campo.detalles!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
              maxLines: 2,
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 300.ms)
                .slideY(begin: 0.2, end: 0, delay: 600.ms, duration: 300.ms),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (campo.latitud != null && campo.longitud != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      AutoSizeText(
                        'Ubicación',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 300.ms)
                    .scale(delay: 700.ms, duration: 300.ms),
              const Spacer(),
              OptimizedButton(
                text: 'Ver Detalles',
                onPressed: () => _showCampoDetails(campo),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 300.ms)
                  .slideX(begin: 0.2, end: 0, delay: 800.ms, duration: 300.ms),
            ],
          ),
        ],
      ),
    );
  }

  void _handleCampoAction(String action, Campo campo) {
    switch (action) {
      case 'edit':
        _showEditCampoDialog(campo);
        break;
      case 'delete':
        _showDeleteConfirmation(campo);
        break;
    }
  }

  void _showCreateCampoDialog() {
    showDialog(
      context: context,
      builder: (context) => _CampoDialog(
        title: 'Nuevo Campo',
        onSubmit: (data) async {
          try {
            await ref.read(camposProvider.notifier).createCampo(data);
            if (mounted) {
              OptimizedSnackBar.showSuccess(
                context,
                message: 'Campo creado exitosamente',
              );
              Navigator.pop(context);
            }
          } catch (e) {
            if (mounted) {
              OptimizedSnackBar.showError(
                context,
                message: 'Error al crear campo: $e',
              );
            }
          }
        },
      ),
    );
  }

  void _showEditCampoDialog(Campo campo) {
    showDialog(
      context: context,
      builder: (context) => _CampoDialog(
        title: 'Editar Campo',
        initialData: {
          'nombre': campo.nombre,
          'superficie_ha': campo.superficieHa,
          'latitud': campo.latitud,
          'longitud': campo.longitud,
          'detalles': campo.detalles,
        },
        onSubmit: (data) async {
          try {
            if (campo.id != null) {
              await ref.read(camposProvider.notifier).updateCampo(campo.id!, data);
            }
            if (mounted) {
              OptimizedSnackBar.showSuccess(
                context,
                message: 'Campo actualizado exitosamente',
              );
              Navigator.pop(context);
            }
          } catch (e) {
            if (mounted) {
              OptimizedSnackBar.showError(
                context,
                message: 'Error al actualizar campo: $e',
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(Campo campo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Campo'),
        content: Text('¿Estás seguro de que quieres eliminar el campo "${campo.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                if (campo.id != null) {
                  await ref.read(camposProvider.notifier).deleteCampo(campo.id!);
                }
                if (mounted) {
                  OptimizedSnackBar.showSuccess(
                    context,
                    message: 'Campo eliminado exitosamente',
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  OptimizedSnackBar.showError(
                    context,
                    message: 'Error al eliminar campo: $e',
                  );
                }
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showCampoDetails(Campo campo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                campo.nombre,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Superficie', '${campo.superficieHa} hectáreas'),
              if (campo.latitud != null && campo.longitud != null)
                _buildDetailRow('Coordenadas', '${campo.latitud}, ${campo.longitud}'),
              if (campo.detalles != null && campo.detalles!.isNotEmpty)
                _buildDetailRow('Detalles', campo.detalles!),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: AutoSizeText(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
            ),
          ),
          Expanded(
            child: AutoSizeText(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog para crear/editar campos
class _CampoDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onSubmit;

  const _CampoDialog({
    required this.title,
    this.initialData,
    required this.onSubmit,
  });

  @override
  State<_CampoDialog> createState() => _CampoDialogState();
}

class _CampoDialogState extends State<_CampoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _superficieController;
  late TextEditingController _latitudController;
  late TextEditingController _longitudController;
  late TextEditingController _detallesController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.initialData?['nombre'] ?? '');
    _superficieController = TextEditingController(text: widget.initialData?['superficie_ha']?.toString() ?? '');
    _latitudController = TextEditingController(text: widget.initialData?['latitud']?.toString() ?? '');
    _longitudController = TextEditingController(text: widget.initialData?['longitud']?.toString() ?? '');
    _detallesController = TextEditingController(text: widget.initialData?['detalles'] ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _superficieController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _detallesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AutoSizeText(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 24),
              OptimizedTextField(
                controller: _nombreController,
                label: 'Nombre del Campo',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              OptimizedTextField(
                controller: _superficieController,
                label: 'Superficie (hectáreas)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La superficie es requerida';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OptimizedTextField(
                      controller: _latitudController,
                      label: 'Latitud',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OptimizedTextField(
                      controller: _longitudController,
                      label: 'Longitud',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              OptimizedTextField(
                controller: _detallesController,
                label: 'Detalles (opcional)',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 16),
                  OptimizedButton(
                    text: 'Guardar',
                    onPressed: _submitForm,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'nombre': _nombreController.text,
        'superficie_ha': double.parse(_superficieController.text),
        'latitud': _latitudController.text.isNotEmpty ? double.parse(_latitudController.text) : null,
        'longitud': _longitudController.text.isNotEmpty ? double.parse(_longitudController.text) : null,
        'detalles': _detallesController.text.isNotEmpty ? _detallesController.text : null,
      };
      widget.onSubmit(data);
    }
  }
}
