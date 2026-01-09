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
  ConsumerState<TrabajoDetailScreen> createState() => _TrabajoDetailScreenState();
}

class _TrabajoDetailScreenState extends ConsumerState<TrabajoDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar los detalles completos del trabajo usando el nuevo endpoint
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.trabajo.id != null) {
        ref.read(trabajoDetalleProvider.notifier).loadTrabajoDetalle(widget.trabajo.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final trabajoDetalleState = ref.watch(trabajoDetalleProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Trabajo'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
      ),
      body: trabajoDetalleState.when(
        data: (trabajoDetalle) {
          if (trabajoDetalle == null) {
            return const Center(
              child: Text('Trabajo no encontrado'),
            );
          }
          return _buildTrabajoDetalleContent(trabajoDetalle);
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
                    ref.read(trabajoDetalleProvider.notifier).loadTrabajoDetalle(widget.trabajo.id!);
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
                    backgroundColor: const Color(AppConstants.primaryColor).withOpacity(0.1),
                    foregroundColor: const Color(AppConstants.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: const Color(AppConstants.primaryColor).withOpacity(0.3),
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

  Widget _buildTrabajoDetalleContent(TrabajoDetalle trabajoDetalle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con título, fechas y estado
          _buildHeader(trabajoDetalle),
          const SizedBox(height: 32),

          // Campo
          _buildSection(
            title: 'Campo',
            content: Text(
              trabajoDetalle.campoInfo,
              style: const TextStyle(fontSize: 16),
            ),
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  ...trabajoDetalle.personal.map((personal) => _buildPersonalItem(personal)),
                ],
              ),
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  ...trabajoDetalle.maquinas.map((maquina) => _buildMaquinaItem(maquina)),
                ],
              ),
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
            ),
            const SizedBox(height: 24),
          ],

          const SizedBox(height: 100), // Espacio para los botones fijos
        ],
      ),
    );
  }

  Widget _buildPersonalItem(PersonalTrabajo personal) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  personal.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w600),
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
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${personal.ha.toStringAsFixed(1)} ha',
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

  Widget _buildMaquinaItem(MaquinaTrabajo maquina) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.build, size: 20, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maquina.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w600),
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
    final fechaInicio = DateFormat('dd/MM/yyyy').format(trabajoDetalle.fechaInicio);
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
                const Color(AppConstants.primaryColor).withOpacity(0.3),
                const Color(AppConstants.primaryColor),
                const Color(AppConstants.primaryColor).withOpacity(0.3),
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
  }) {
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
                    const Color(AppConstants.primaryColor),
                    const Color(AppConstants.primaryColor).withOpacity(0.7),
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
        return const Color(AppConstants.infoColor);
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
        content: const Text('¿Estás seguro de que quieres eliminar este trabajo? Esta acción no se puede deshacer.'),
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