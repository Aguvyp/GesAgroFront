import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trabajo_detalle.dart';
import '../../providers/trabajo_detalle_provider.dart';
import '../../widgets/trabajo_detalle_widget.dart';

/// Pantalla de ejemplo que muestra cómo usar la estructura de datos de TrabajoDetalle
class TrabajoDetalleScreen extends ConsumerStatefulWidget {
  final int trabajoId;

  const TrabajoDetalleScreen({
    Key? key,
    required this.trabajoId,
  }) : super(key: key);

  @override
  ConsumerState<TrabajoDetalleScreen> createState() => _TrabajoDetalleScreenState();
}

class _TrabajoDetalleScreenState extends ConsumerState<TrabajoDetalleScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar los detalles del trabajo cuando se inicializa la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trabajoDetalleProvider.notifier).loadTrabajoDetalle(widget.trabajoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Trabajo'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(trabajoDetalleProvider.notifier).loadTrabajoDetalle(widget.trabajoId);
            },
          ),
        ],
      ),
      body: TrabajoDetalleWidget(
        trabajoId: widget.trabajoId,
        showTitle: false,
      ),
    );
  }
}

/// Pantalla de ejemplo que muestra una lista de trabajos con detalles
class TrabajosDetalleListScreen extends ConsumerStatefulWidget {
  const TrabajosDetalleListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TrabajosDetalleListScreen> createState() => _TrabajosDetalleListScreenState();
}

class _TrabajosDetalleListScreenState extends ConsumerState<TrabajosDetalleListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar la lista de trabajos con detalles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trabajosDetalleProvider.notifier).loadTrabajosDetalle();
    });
  }

  @override
  Widget build(BuildContext context) {
    final trabajosDetalleState = ref.watch(trabajosDetalleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trabajos con Detalles'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(trabajosDetalleProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: trabajosDetalleState.when(
        data: (trabajos) => _buildTrabajosList(trabajos),
        loading: () => const Center(child: CircularProgressIndicator()),
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
                  ref.read(trabajosDetalleProvider.notifier).loadTrabajosDetalle();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrabajosList(List<TrabajoDetalle> trabajos) {
    if (trabajos.isEmpty) {
      return const Center(
        child: Text('No hay trabajos disponibles'),
      );
    }

    return ListView.builder(
      itemCount: trabajos.length,
      itemBuilder: (context, index) {
        final trabajo = trabajos[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('${trabajo.tipo} - ${trabajo.cultivo}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trabajo.campoInfo),
                Text(trabajo.trabajoInfo),
                if (trabajo.personal.isNotEmpty)
                  Text(trabajo.personalInfo),
                if (trabajo.maquinas.isNotEmpty)
                  Text(trabajo.maquinasInfo),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  trabajo.estado ?? 'Pendiente',
                  style: TextStyle(
                    color: _getEstadoColor(trabajo.estado),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  trabajo.formattedDateRange,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrabajoDetalleScreen(trabajoId: trabajo.id!),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getEstadoColor(String? estado) {
    switch (estado) {
      case 'Completado':
        return Colors.green;
      case 'En curso':
        return Colors.orange;
      case 'Pendiente':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

/// Widget de ejemplo que muestra estadísticas de trabajos
class TrabajosEstadisticasWidget extends ConsumerWidget {
  const TrabajosEstadisticasWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trabajosDetalleState = ref.watch(trabajosDetalleProvider);

    return trabajosDetalleState.when(
      data: (trabajos) {
        final estadisticas = ref.read(trabajosDetalleProvider.notifier).getEstadisticas();
        return _buildEstadisticas(context, estadisticas);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Text('Error: $error'),
    );
  }

  Widget _buildEstadisticas(BuildContext context, Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas de Trabajos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    stats['total']?.toString() ?? '0',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Completados',
                    stats['completados']?.toString() ?? '0',
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'En Curso',
                    stats['en_curso']?.toString() ?? '0',
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Pendientes',
                    stats['pendientes']?.toString() ?? '0',
                    Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Terceros',
                    stats['terceros']?.toString() ?? '0',
                    Colors.purple,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    'Propios',
                    stats['propios']?.toString() ?? '0',
                    Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Total Hectáreas: ${stats['total_hectareas']?.toStringAsFixed(1) ?? '0.0'} ha',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              'Total Operarios: ${stats['total_operarios']?.toString() ?? '0'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              'Total Máquinas: ${stats['total_maquinas']?.toString() ?? '0'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
