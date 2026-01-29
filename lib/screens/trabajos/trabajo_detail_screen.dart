import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/trabajo.dart';
import '../../models/trabajo_detalle.dart';
import '../../widgets/optimized_widgets.dart';
import '../../providers/trabajo_detalle_provider.dart';
import '../../utils/constants.dart';
import '../forms/trabajo_form_screen.dart';

class TrabajoDetailScreen extends ConsumerStatefulWidget {
  final Trabajo trabajo;

  const TrabajoDetailScreen({
    Key? key,
    required this.trabajo,
  }) : super(key: key);

  @override
  ConsumerState<TrabajoDetailScreen> createState() =>
      _TrabajoDetailScreenState();
}

class _TrabajoDetailScreenState extends ConsumerState<TrabajoDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar los detalles completos del trabajo usando el nuevo endpoint
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.trabajo.id != null) {
        ref
            .read(trabajoDetalleProvider.notifier)
            .loadTrabajoDetalle(widget.trabajo.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final trabajoDetalleState = ref.watch(trabajoDetalleProvider);

    // Determinar el color basado en el estado (priorizando el detalle cargado)
    final estadoColor = trabajoDetalleState.maybeWhen(
      data: (detalle) =>
          _getTrabajoColor(detalle?.estado ?? widget.trabajo.estado),
      orElse: () => _getTrabajoColor(widget.trabajo.estado),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: estadoColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: trabajoDetalleState.when(
        data: (trabajoDetalle) {
          if (trabajoDetalle == null) {
            return const Center(
              child: Text('Trabajo no encontrado'),
            );
          }
          return _buildTrabajoDetalleContent(trabajoDetalle, estadoColor);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (widget.trabajo.id != null) {
                    ref
                        .read(trabajoDetalleProvider.notifier)
                        .loadTrabajoDetalle(widget.trabajo.id!);
                  }
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _editTrabajo(context),
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(AppConstants.primaryColor).withOpacity(0.1),
                    foregroundColor: const Color(AppConstants.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: const Color(AppConstants.primaryColor)
                            .withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _deleteTrabajo(context),
                  icon: const Icon(Icons.delete),
                  label: const Text('Eliminar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrabajoDetalleContent(
      TrabajoDetalle trabajoDetalle, Color estadoColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con título, fechas y estado
          _buildHeader(trabajoDetalle),
          const SizedBox(height: 16),

          // Progreso si está en curso
          if (trabajoDetalle.isInProgress ||
              trabajoDetalle.estado?.toLowerCase() == 'en progreso') ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (trabajoDetalle.porcentajeProgreso ?? 0.0) / 100,
                backgroundColor: estadoColor.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(estadoColor),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (trabajoDetalle.haRealizadas != null &&
                    trabajoDetalle.campo?.superficieHa != null)
                  Text(
                    '${trabajoDetalle.haRealizadas!.toStringAsFixed(1)} / ${trabajoDetalle.campo!.superficieHa.toStringAsFixed(1)} ha realizadas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Text(
                  '${(trabajoDetalle.porcentajeProgreso ?? 0.0).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16,
                    color: estadoColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          const SizedBox(height: 16),

          // Campo
          _buildSection(
            title: 'Campo',
            content: Text(
              trabajoDetalle.campoInfo,
              style: const TextStyle(fontSize: 16),
            ),
            estado: trabajoDetalle.estado,
          ),
          const SizedBox(height: 24),

          // Cliente
          _buildSection(
            title: 'Cliente',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trabajoDetalle.trabajoInfo,
                  style: const TextStyle(fontSize: 16),
                ),
                if (trabajoDetalle.clienteInfo != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'CUIT: ${trabajoDetalle.clienteInfo!.cuit}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    'Dirección: ${trabajoDetalle.clienteInfo!.direccion}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    'Teléfono: ${trabajoDetalle.clienteInfo!.telefono}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
                if (trabajoDetalle.montoCobrado != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Monto cobrado: \$${NumberFormat('#,##0.00').format(trabajoDetalle.montoCobrado)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
            estado: trabajoDetalle.estado,
          ),
          const SizedBox(height: 24),

          // Personal
          if (trabajoDetalle.personal.isNotEmpty) ...[
            _buildSection(
              title: 'Personal',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${trabajoDetalle.totalPersonal} operario${trabajoDetalle.totalPersonal > 1 ? 's' : ''} - ${trabajoDetalle.totalHectareasPersonal.toStringAsFixed(1)} ha',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  ...trabajoDetalle.personal.map((personal) =>
                      _buildPersonalItem(personal, trabajoDetalle.estado)),
                ],
              ),
              estado: trabajoDetalle.estado,
            ),
            const SizedBox(height: 24),
          ],

          // Máquinas
          if (trabajoDetalle.maquinas.isNotEmpty) ...[
            _buildSection(
              title: 'Máquinas',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${trabajoDetalle.totalMaquinas} máquina${trabajoDetalle.totalMaquinas > 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  ...trabajoDetalle.maquinas.map((maquina) =>
                      _buildMaquinaItem(maquina, trabajoDetalle.estado)),
                ],
              ),
              estado: trabajoDetalle.estado,
            ),
            const SizedBox(height: 24),
          ],

          // Observaciones
          if (trabajoDetalle.observaciones?.isNotEmpty == true) ...[
            _buildSection(
              title: 'Observaciones',
              content: Text(
                trabajoDetalle.observaciones!,
                style: const TextStyle(fontSize: 16),
              ),
              estado: trabajoDetalle.estado,
            ),
            const SizedBox(height: 24),
          ],

          const SizedBox(height: 100), // Espacio para los botones fijos
        ],
      ),
    );
  }

  Widget _buildPersonalItem(PersonalTrabajo personal, String? estado) {
    final color = _getTrabajoColor(estado);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.person, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  personal.nombre,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                Text(
                  'DNI: ${personal.dni}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (personal.rol != null)
                  Text(
                    'Rol: ${personal.rol}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${personal.horas.toStringAsFixed(0)}hs / ${personal.ha.toStringAsFixed(0)}ha',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaquinaItem(MaquinaTrabajo maquina, String? estado) {
    final color = _getTrabajoColor(estado);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.build, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maquina.nombre,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                Text(
                  '${maquina.marca} ${maquina.modelo}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(TrabajoDetalle trabajoDetalle) {
    final fechaInicio =
        DateFormat('dd/MM/yyyy').format(trabajoDetalle.fechaInicio);
    final fechaFin = trabajoDetalle.fechaFin != null
        ? DateFormat('dd/MM/yyyy').format(trabajoDetalle.fechaFin!)
        : 'En curso';
    final duracion = trabajoDetalle.durationDays > 0
        ? ' (${trabajoDetalle.durationDays} días)'
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título principal
        Text(
          '${trabajoDetalle.tipo} - ${trabajoDetalle.cultivo}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        // Fechas
        Text(
          '$fechaInicio - $fechaFin$duracion',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // Estado
        Text(
          trabajoDetalle.estado ?? 'Pendiente',
          style: TextStyle(
            fontSize: 16,
            color: _getTrabajoColor(trabajoDetalle.estado),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Línea elegante con gradiente
        Container(
          height: 3,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getTrabajoColor(trabajoDetalle.estado).withOpacity(0.3),
                _getTrabajoColor(trabajoDetalle.estado),
                _getTrabajoColor(trabajoDetalle.estado).withOpacity(0.3),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required Widget content,
    String? estado, // Nuevo parámetro para el color
  }) {
    final color = _getTrabajoColor(estado);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título con línea vertical distintiva
        Row(
          children: [
            Container(
              height: 24,
              width: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Contenido
        content,
      ],
    );
  }

  Color _getTrabajoColor(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'completado':
        return const Color(AppConstants.successColor);
      case 'en curso':
      case 'en progreso':
        return const Color(AppConstants.accentColor);
      case 'pendiente':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _editTrabajo(BuildContext context) {
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

  void _deleteTrabajo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text(
            '¿Estás seguro de que quieres eliminar este trabajo? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar eliminación del trabajo
              OptimizedSnackBar.showInfo(
                context,
                message: 'Eliminación en desarrollo',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
