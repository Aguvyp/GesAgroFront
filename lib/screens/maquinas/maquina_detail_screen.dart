import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/maquina.dart';
import '../forms/maquina_form_screen.dart';

/// Pantalla de detalles de máquina
class MaquinaDetailScreen extends ConsumerStatefulWidget {
  final Maquina maquina;
  
  const MaquinaDetailScreen({Key? key, required this.maquina}) : super(key: key);

  @override
  ConsumerState<MaquinaDetailScreen> createState() => _MaquinaDetailScreenState();
}

class _MaquinaDetailScreenState extends ConsumerState<MaquinaDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.maquina.nombre),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editMaquina(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información básica
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.build,
                            color: Theme.of(context).primaryColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.maquina.nombre,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.maquina.marca} ${widget.maquina.modelo}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Marca', widget.maquina.marca),
                    _buildInfoRow('Modelo', widget.maquina.modelo),
                    if (widget.maquina.ano > 0)
                      _buildInfoRow('Año', widget.maquina.ano.toString()),
                    if (widget.maquina.anchoTrabajo != null)
                      _buildInfoRow('Ancho de Trabajo', '${widget.maquina.anchoTrabajo}m'),
                    if (widget.maquina.estado != null)
                      _buildInfoRow('Estado', widget.maquina.estado!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Detalles adicionales
            if (widget.maquina.detalles != null && widget.maquina.detalles!.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalles',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.maquina.detalles!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

            // Estadísticas de trabajo
            if (widget.maquina.superficieTotalHa != null || widget.maquina.horasTrabajadas != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estadísticas de Trabajo',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (widget.maquina.superficieTotalHa != null)
                        _buildStatCard(
                          'Superficie Total',
                          '${widget.maquina.superficieTotalHa!.toStringAsFixed(2)} ha',
                          Icons.landscape,
                          Colors.green,
                        ),
                      if (widget.maquina.horasTrabajadas != null) ...[
                        const SizedBox(height: 12),
                        _buildStatCard(
                          'Horas Trabajadas',
                          '${widget.maquina.horasTrabajadas!.toStringAsFixed(1)} h',
                          Icons.schedule,
                          Colors.blue,
                        ),
                      ],
                      if (widget.maquina.ultimoTrabajo != null) ...[
                        const SizedBox(height: 12),
                        _buildStatCard(
                          'Último Trabajo',
                          widget.maquina.ultimoTrabajo!,
                          Icons.work,
                          Colors.orange,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _editMaquina,
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editMaquina() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MaquinaFormScreen(maquina: widget.maquina),
      ),
    ).then((_) {
      // Recargar la lista después de editar
      Navigator.pop(context);
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editMaquina();
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Máquina'),
        content: Text('¿Estás seguro de que quieres eliminar la máquina "${widget.maquina.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Aquí deberías llamar al provider para eliminar la máquina
                // await ref.read(maquinasProvider.notifier).deleteMaquina(widget.maquina.id!);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Máquina eliminada exitosamente')),
                  );
                  Navigator.pop(context); // Volver a la lista
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar máquina: $e')),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
