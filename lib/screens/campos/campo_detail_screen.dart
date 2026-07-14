import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../models/lote.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';
import '../forms/lote_form_screen.dart';

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
    _loadLotes();
  }

  Future<void> _loadTrabajos() async {
    await ref.read(trabajosProvider.notifier).loadTrabajos();
  }

  Future<void> _loadLotes() async {
    if (widget.campo.id != null) {
      await ref
          .read(lotesProvider.notifier)
          .loadLotes(campoId: widget.campo.id);
    }
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
            _buildLotesSection(),
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
                  color:
                      const Color(AppConstants.primaryColor).withOpacity(0.1),
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
          if (widget.campo.detalles != null &&
              widget.campo.detalles!.isNotEmpty) ...[
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
          if (widget.campo.latitud != null &&
              widget.campo.longitud != null) ...[
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

  Widget _buildLotesSection() {
    return Consumer(
      builder: (context, ref, child) {
        final lotesState = ref.watch(lotesProvider);

        return CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Lotes y accesos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(AppConstants.textColor),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _navigateToLoteForm,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Agregar'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (lotesState is LoadingState)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (lotesState is ErrorState)
                Column(
                  children: [
                    Text(lotesState.message,
                        style: const TextStyle(color: Colors.red)),
                    TextButton(
                      onPressed: _loadLotes,
                      child: const Text('Reintentar'),
                    ),
                  ],
                )
              else if (lotesState is LoadedState<List<Lote>>)
                _buildLotesList(lotesState.data)
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLotesList(List<Lote> lotes) {
    if (lotes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                  'Todavía no hay lotes. Agregá uno para marcar acceso, entrada y contorno.'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: lotes.map(_buildLoteItem).toList(),
    );
  }

  Widget _buildLoteItem(Lote lote) {
    final completitud = [
      if (lote.tieneAcceso) 'Acceso OK' else 'Sin acceso',
      if (lote.tieneEntrada) 'Entrada OK' else 'Sin entrada',
      if (lote.tieneContorno) 'Contorno OK' else 'Sin contorno',
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(AppConstants.primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.crop_square_rounded,
              color: Color(AppConstants.primaryColor)),
        ),
        title: Text(
          lote.nombre,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle:
            Text('${lote.hectareas.toStringAsFixed(1)} ha · $completitud'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _navigateToLoteForm(lote: lote);
            } else if (value == 'delete') {
              _deleteLote(lote);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Editar')),
            PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToLoteForm({Lote? lote}) async {
    final result = await Navigator.push<Lote>(
      context,
      MaterialPageRoute(
        builder: (_) => LoteFormScreen(campo: widget.campo, lote: lote),
      ),
    );

    if (result != null) {
      await _loadLotes();
      ref.read(camposProvider.notifier).loadCampos();
    }
  }

  Future<void> _deleteLote(Lote lote) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar lote'),
        content: Text('¿Eliminar ${lote.nombre}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm != true || lote.id == null) return;
    await ref
        .read(lotesProvider.notifier)
        .deleteLote(lote.id!, campoId: widget.campo.id);
    await _loadLotes();
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
          trabajos = trabajosState.data
              .where((trabajo) => trabajo.idCampo == widget.campo.id)
              .toList();
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
