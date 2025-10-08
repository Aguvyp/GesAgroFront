import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class CampoDetailScreen extends ConsumerStatefulWidget {
  final dynamic campo;

  const CampoDetailScreen({
    Key? key,
    required this.campo,
  }) : super(key: key);

  @override
  ConsumerState<CampoDetailScreen> createState() => _CampoDetailScreenState();
}

class _CampoDetailScreenState extends ConsumerState<CampoDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadTrabajos();
  }

  Future<void> _loadTrabajos() async {
    await ref.read(trabajosProvider.notifier).loadTrabajos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.campo.nombre,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToForm,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCampoInfo(),
            const SizedBox(height: 24),
            _buildTrabajosSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoInfo() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.agriculture,
                  color: Color(AppConstants.primaryColor),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.campo.nombre,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(AppConstants.textColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.campo.superficieHa.toStringAsFixed(1)} hectáreas',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.campo.detalles != null && widget.campo.detalles!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Detalles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppConstants.textColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.campo.detalles!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
          if (widget.campo.latitud != null && widget.campo.longitud != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Ubicación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppConstants.textColor),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(AppConstants.primaryColor),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.campo.latitud!.toStringAsFixed(4)}, ${widget.campo.longitud!.toStringAsFixed(4)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrabajosSection() {
    return Consumer(
      builder: (context, ref, child) {
        final trabajosState = ref.watch(trabajosProvider);
        if (trabajosState is LoadingState) {
          return const LoadingWidget(message: 'Cargando trabajos...');
        }

        List<dynamic> trabajos = [];
        if (trabajosState is LoadedState) {
          trabajos = trabajosState.data.where((trabajo) => trabajo.idCampo == widget.campo.id).toList();
        }

        return CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Trabajos en este Campo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(AppConstants.textColor),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to trabajos screen with filter
                      Navigator.of(context).pop();
                    },
                    child: const Text('Ver todos'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (trabajos.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No hay trabajos registrados en este campo',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: trabajos.length,
                  itemBuilder: (context, index) {
                    final trabajo = trabajos[index];
                    return _buildTrabajoItem(trabajo);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrabajoItem(trabajo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(trabajo.estado).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(trabajo.estado),
                  color: _getStatusColor(trabajo.estado),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trabajo.tipo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(AppConstants.textColor),
                      ),
                    ),
                    Text(
                      trabajo.cultivo,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  trabajo.estado ?? 'Pendiente',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: _getStatusColor(trabajo.estado),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            trabajo.formattedDateRange,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Completado':
        return const Color(AppConstants.successColor);
      case 'En curso':
        return const Color(AppConstants.accentColor);
      case 'Pendiente':
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'Completado':
        return Icons.check_circle;
      case 'En curso':
        return Icons.play_circle;
      case 'Pendiente':
      default:
        return Icons.schedule;
    }
  }

  void _navigateToForm() {
    // Navigate to optimized campo screen or show edit dialog
    Navigator.of(context).pop();
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Campo'),
        content: Text(
          '¿Estás seguro de que quieres eliminar el campo "${widget.campo.nombre}"? Esta acción no se puede deshacer.',
        ),
        actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(AppConstants.cancelColor),
              ),
              child: const Text('Cancelar'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCampo();
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCampo() async {
    try {
      await ref.read(camposProvider.notifier).deleteCampo(widget.campo.id);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Campo eliminado exitosamente'),
            backgroundColor: Color(AppConstants.successColor),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar campo: $e'),
            backgroundColor: const Color(AppConstants.errorColor),
          ),
        );
      }
    }
  }
}
