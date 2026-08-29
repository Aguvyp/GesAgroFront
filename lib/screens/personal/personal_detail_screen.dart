import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/personal.dart';
import '../../models/trabajo.dart';
import '../../providers/optimized_providers.dart';
import '../../services/trabajo_service.dart';
import '../../widgets/optimized_widgets.dart';
import '../../utils/constants.dart';
import '../trabajos/trabajo_detail_screen.dart';
import '../forms/forms_screens.dart';

class PersonalDetailScreen extends ConsumerStatefulWidget {
  final Personal personal;

  const PersonalDetailScreen({
    Key? key,
    required this.personal,
  }) : super(key: key);

  @override
  ConsumerState<PersonalDetailScreen> createState() =>
      _PersonalDetailScreenState();
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
      final trabajos =
          await TrabajoService.getTrabajosByPersonal(widget.personal.id!);
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
        title: const Text('Detalles del Personal'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con nombre y estado
            _buildHeader(),
            const SizedBox(height: 32),

            // Información de contacto
            _buildSection(
              title: 'Información de Contacto',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('DNI', widget.personal.dni, Icons.badge),
                  if (widget.personal.telefono != null &&
                      widget.personal.telefono!.isNotEmpty)
                    _buildInfoRow(
                        'Teléfono', widget.personal.telefono!, Icons.phone),
                  _buildInfoRow('ID', widget.personal.id?.toString() ?? 'N/A',
                      Icons.fingerprint),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Trabajos realizados
            _buildSection(
              title: 'Trabajos Realizados',
              content: _buildTrabajosSection(),
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
                  onPressed: () => _editPersonal(context),
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
                  onPressed: () => _deletePersonal(context),
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título principal con avatar
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor:
                  const Color(AppConstants.primaryColor).withOpacity(0.1),
              child: Text(
                widget.personal.initials,
                style: const TextStyle(
                  color: Color(AppConstants.primaryColor),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(AppConstants.successColor)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(AppConstants.successColor),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'Personal Activo',
                      style: TextStyle(
                        color: Color(AppConstants.successColor),
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

  Widget _buildInfoRow(String label, String value, IconData icon) {
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
            Text(
                'Fecha: ${DateFormat('dd/MM/yyyy').format(trabajo.fechaInicio)}'),
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
        return const Color(AppConstants.successColor);
      case 'en curso':
        return const Color(AppConstants.accentColor);
      case 'pendiente':
        return const Color(AppConstants.infoColor);
      default:
        return Colors.grey;
    }
  }

  void _editPersonal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalFormScreen(
          personal: widget.personal,
        ),
      ),
    ).then((_) {
      OptimizedSnackBar.showSuccess(
        context,
        message: 'Personal actualizado exitosamente',
      );
    });
  }

  void _deletePersonal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
            '¿Estás seguro de que deseas eliminar a ${widget.personal.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deletePersonalAction();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePersonalAction() async {
    try {
      await ref
          .read(personalProvider.notifier)
          .deletePersonal(widget.personal.id!);
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
