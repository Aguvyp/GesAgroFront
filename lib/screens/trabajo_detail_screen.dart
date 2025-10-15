import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/trabajo.dart';
import '../models/campo.dart';
import '../widgets/optimized_widgets.dart';
import '../providers/optimized_providers.dart';
import '../utils/constants.dart';
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
        title: const Text('Detalles del Trabajo'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con título, fechas y estado
            _buildHeader(campo),
            const SizedBox(height: 32),

            // Campo
            _buildSection(
              title: 'Campo',
              content: Text(
                '${campo?.nombre ?? 'Campo ID: ${widget.trabajo.idCampo}'} - ${campo?.superficieHa.toInt() ?? 0}ha',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Cliente
            _buildSection(
              title: 'Cliente',
              content: Text(
                widget.trabajo.esTercero 
                  ? 'Trabajo a Terceros | ${widget.trabajo.cliente ?? 'No especificado'}'
                  : 'Trabajo Propio',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),

            // Personal y Máquinas
            _buildSection(
              title: 'Personal y Máquinas',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Máquina 1 - Máquina 2', // TODO: Implementar lista real de máquinas
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Espacio para los botones fijos
          ],
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

  Widget _buildHeader(Campo? campo) {
    final fechaInicio = DateFormat('dd/MM/yyyy').format(widget.trabajo.fechaInicio);
    final fechaFin = widget.trabajo.fechaFin != null 
        ? DateFormat('dd/MM/yyyy').format(widget.trabajo.fechaFin!)
        : 'En curso';
    final duracion = widget.trabajo.durationDays > 0 
        ? ' (${widget.trabajo.durationDays} días)'
        : '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título principal
        Text(
          '${widget.trabajo.tipo} - ${widget.trabajo.cultivo}',
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
          widget.trabajo.estado ?? 'Pendiente',
          style: TextStyle(
            fontSize: 16,
            color: _getTrabajoColor(widget.trabajo.estado),
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