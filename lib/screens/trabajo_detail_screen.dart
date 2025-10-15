import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/trabajo.dart';
import '../models/campo.dart';
import '../widgets/optimized_widgets.dart';
import '../providers/optimized_providers.dart';
import 'forms/forms_screens.dart';

class TrabajoDetailScreen extends ConsumerStatefulWidget {
  final Trabajo trabajo;

  const TrabajoDetailScreen({
    Key? key,
    required this.trabajo,
  }) : super(key: key);

  @override
  ConsumerState<TrabajoDetailScreen> createState() => _TrabajoDetailScreenState();
}

class _TrabajoDetailScreenState extends ConsumerState<TrabajoDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar el campo por ID al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(campoByIdProvider.notifier).loadCampoById(widget.trabajo.idCampo);
    });
  }

  @override
  Widget build(BuildContext context) {
    final campoState = ref.watch(campoByIdProvider);
    
    // Obtener el campo del estado
    Campo? campo;
    if (campoState is LoadedState<dynamic>) {
      campo = campoState.data as Campo?;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.trabajo.tipo} - ${widget.trabajo.cultivo}'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información principal
            OptimizedCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.work,
                          color: _getTrabajoColor(widget.trabajo.estado),
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.trabajo.tipo} - ${widget.trabajo.cultivo}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTrabajoColor(widget.trabajo.estado).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getTrabajoColor(widget.trabajo.estado),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  widget.trabajo.estado ?? 'Pendiente',
                                  style: TextStyle(
                                    color: _getTrabajoColor(widget.trabajo.estado),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Información de fechas
            OptimizedCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fechas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Fecha de Inicio',
                      DateFormat('dd/MM/yyyy').format(widget.trabajo.fechaInicio),
                      Icons.play_arrow,
                    ),
                    if (widget.trabajo.fechaFin != null)
                      _buildDetailRow(
                        'Fecha de Fin',
                        DateFormat('dd/MM/yyyy').format(widget.trabajo.fechaFin!),
                        Icons.stop,
                      ),
                    if (widget.trabajo.durationDays > 0)
                      _buildDetailRow(
                        'Duración',
                        '${widget.trabajo.durationDays} días',
                        Icons.schedule,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Información adicional
            OptimizedCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información Adicional',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'Campo',
                      campo != null 
                          ? campo.nombre 
                          : campoState is LoadingState 
                              ? 'Cargando...' 
                              : 'Campo ID: ${widget.trabajo.idCampo}',
                      Icons.landscape,
                    ),
                    if (campo != null)
                      _buildDetailRow(
                        'Hectáreas',
                        '${campo.superficieHa.toStringAsFixed(2)} ha',
                        Icons.straighten,
                      ),
                    _buildDetailRow(
                      'Personal Asignado',
                      '${widget.trabajo.idPersonal.length} persona(s)',
                      Icons.people,
                    ),
                    _buildDetailRow(
                      'Máquinas Asignadas',
                      '${widget.trabajo.idMaquinas.length} máquina(s)',
                      Icons.build,
                    ),
                    if (widget.trabajo.esTercero)
                      _buildDetailRow(
                        'Tipo de Trabajo',
                        'Servicio a Terceros',
                        Icons.business,
                      ),
                    if (widget.trabajo.cliente != null)
                      _buildDetailRow(
                        'Cliente',
                        widget.trabajo.cliente!,
                        Icons.person,
                      ),
                    if (widget.trabajo.cobrado)
                      _buildDetailRow(
                        'Estado de Pago',
                        widget.trabajo.montoCobrado != null
                            ? 'Cobrado - \$${widget.trabajo.montoCobrado!.toStringAsFixed(2)}'
                            : 'Cobrado',
                        Icons.payment,
                      ),
                  ],
                ),
              ),
            ),

            if (widget.trabajo.observaciones != null && widget.trabajo.observaciones!.isNotEmpty) ...[
              const SizedBox(height: 16),
              OptimizedCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Observaciones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.trabajo.observaciones!,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Acciones rápidas
            OptimizedCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Acciones',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showEditDialog(context),
                            icon: const Icon(Icons.edit),
                            label: const Text('Editar Trabajo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implementar cambiar estado
                              OptimizedSnackBar.showInfo(
                                context,
                                message: 'Cambiar estado en desarrollo',
                              );
                            },
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text('Cambiar Estado'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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

  void _showEditDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrabajoFormScreen(
          trabajo: widget.trabajo,
        ),
      ),
    ).then((_) {
      // TODO: Actualizar la lista con el trabajo editado cuando se cierre el diálogo
      OptimizedSnackBar.showSuccess(
        context,
        message: 'Trabajo actualizado exitosamente',
      );
    });
  }
}
