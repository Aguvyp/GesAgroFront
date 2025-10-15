import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/personal.dart';
import '../../models/trabajo.dart';
import '../../providers/optimized_providers.dart';
import '../../services/trabajo_service.dart';
import '../../widgets/optimized_widgets.dart';
import '../trabajo_detail_screen.dart';
import '../forms/forms_screens.dart';

class PersonalDetailScreen extends ConsumerStatefulWidget {
  final Personal personal;

  const PersonalDetailScreen({
    Key? key,
    required this.personal,
  }) : super(key: key);

  @override
  ConsumerState<PersonalDetailScreen> createState() => _PersonalDetailScreenState();
}

class _PersonalDetailScreenState extends ConsumerState<PersonalDetailScreen> {
  List<Trabajo> _trabajos = [];
  bool _isLoadingTrabajos = false;
  String? _errorTrabajos;

  @override
  void initState() {
    super.initState();
    _loadTrabajos();
  }

  Future<void> _loadTrabajos() async {
    if (widget.personal.id == null) return;
    
    setState(() {
      _isLoadingTrabajos = true;
      _errorTrabajos = null;
    });

    try {
      final trabajos = await TrabajoService.getTrabajosByPersonal(widget.personal.id!);
      setState(() {
        _trabajos = trabajos;
        _isLoadingTrabajos = false;
      });
    } catch (e) {
      setState(() {
        _errorTrabajos = e.toString();
        _isLoadingTrabajos = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.personal.nombre),
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
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Text(
                            widget.personal.initials,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.personal.nombre,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'Personal Activo',
                                  style: TextStyle(
                                    color: Colors.green,
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

            // Información de contacto
            OptimizedCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información de Contacto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      'DNI',
                      widget.personal.dni,
                      Icons.badge,
                    ),
                    if (widget.personal.telefono != null && widget.personal.telefono!.isNotEmpty)
                      _buildDetailRow(
                        'Teléfono',
                        widget.personal.telefono!,
                        Icons.phone,
                      ),
                    _buildDetailRow(
                      'ID',
                      widget.personal.id?.toString() ?? 'N/A',
                      Icons.fingerprint,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Trabajos del personal
            OptimizedCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Trabajos Realizados',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (_isLoadingTrabajos)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTrabajosSection(),
                  ],
                ),
              ),
            ),

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
                            label: const Text('Editar Personal'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showDeleteConfirmation(context),
                            icon: const Icon(Icons.delete),
                            label: const Text('Eliminar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
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

  Widget _buildTrabajosSection() {
    if (_isLoadingTrabajos) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorTrabajos != null) {
      return Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[300],
          ),
          const SizedBox(height: 12),
          Text(
            'Error al cargar trabajos',
            style: TextStyle(
              color: Colors.red[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorTrabajos!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadTrabajos,
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    if (_trabajos.isEmpty) {
      return Column(
        children: [
          Icon(
            Icons.work_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No hay trabajos registrados',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Este personal no tiene trabajos asignados',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      );
    }

    return Column(
      children: [
        ..._trabajos.map((trabajo) => _buildTrabajoCard(trabajo)).toList(),
      ],
    );
  }

  Widget _buildTrabajoCard(Trabajo trabajo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTrabajoColor(trabajo.estado).withOpacity(0.1),
          child: Icon(
            Icons.work,
            color: _getTrabajoColor(trabajo.estado),
          ),
        ),
        title: Text(
          '${trabajo.tipo} - ${trabajo.cultivo}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Fecha: ${DateFormat('dd/MM/yyyy').format(trabajo.fechaInicio)}'),
            if (trabajo.estado != null)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTrabajoColor(trabajo.estado).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getTrabajoColor(trabajo.estado),
                    width: 1,
                  ),
                ),
                child: Text(
                  trabajo.estado!,
                  style: TextStyle(
                    color: _getTrabajoColor(trabajo.estado),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrabajoDetailScreen(trabajo: trabajo),
            ),
          );
        },
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

  void _showEditDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalFormScreen(
          personal: widget.personal,
        ),
      ),
    ).then((_) {
      // TODO: Actualizar la lista con el personal editado cuando se cierre el diálogo
      OptimizedSnackBar.showSuccess(
        context,
        message: 'Personal actualizado exitosamente',
      );
    });
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar a ${widget.personal.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deletePersonal();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePersonal() async {
    try {
      await ref.read(personalProvider.notifier).deletePersonal(widget.personal.id!);
      if (mounted) {
        Navigator.pop(context);
        OptimizedSnackBar.showSuccess(
          context,
          message: 'Personal eliminado exitosamente',
        );
      }
    } catch (e) {
      if (mounted) {
        OptimizedSnackBar.showError(
          context,
          message: 'Error al eliminar personal: $e',
        );
      }
    }
  }
}
