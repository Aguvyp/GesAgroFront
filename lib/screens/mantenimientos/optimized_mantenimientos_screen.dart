import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/mantenimiento.dart';
import '../../providers/optimized_providers.dart';
import '../forms/mantenimiento_form_screen.dart';

/// Pantalla de mantenimientos
class OptimizedMantenimientosScreen extends ConsumerStatefulWidget {
  const OptimizedMantenimientosScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedMantenimientosScreen> createState() =>
      _OptimizedMantenimientosScreenState();
}

class _OptimizedMantenimientosScreenState
    extends ConsumerState<OptimizedMantenimientosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mantenimientosProvider.notifier).loadMantenimientos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mantenimientosState = ref.watch(mantenimientosProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildMantenimientosList(mantenimientosState),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showMantenimientoForm(context);
        },
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMantenimientosList(BaseState state) {
    if (state is LoadingState) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is ErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              state.message.contains('404')
                  ? 'El endpoint de mantenimientos no está disponible en el servidor'
                  : 'Error: ${state.message}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (state.message.contains('404')) ...[
              const Text(
                'Contacte al administrador para habilitar el módulo de mantenimientos',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: () {
                ref.read(mantenimientosProvider.notifier).loadMantenimientos();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final mantenimientos = (state as LoadedState<List<Mantenimiento>>).data;
    if (mantenimientos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hay mantenimientos',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Toca el botón + para crear el primero',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mantenimientos.length,
      itemBuilder: (context, index) {
        final mantenimiento = mantenimientos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  _getEstadoColor(mantenimiento.estado).withOpacity(0.1),
              child: Icon(_getEstadoIcon(mantenimiento.estado),
                  color: _getEstadoColor(mantenimiento.estado)),
            ),
            title: Text(mantenimiento.descripcion),
            subtitle: Text(mantenimiento.estado.toUpperCase()),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  mantenimiento.costoTotal != null
                      ? '\$${mantenimiento.costoTotal!.toStringAsFixed(2)}'
                      : 'Sin costo',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${mantenimiento.fecha.day}/${mantenimiento.fecha.month}/${mantenimiento.fecha.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            onTap: () {
              _showMantenimientoForm(context, mantenimiento: mantenimiento);
            },
          ),
        );
      },
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'completado':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'atrasado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'completado':
        return Icons.check_circle;
      case 'pendiente':
        return Icons.schedule;
      case 'atrasado':
        return Icons.warning;
      default:
        return Icons.build;
    }
  }

  void _showMantenimientoForm(BuildContext context,
      {Mantenimiento? mantenimiento}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MantenimientoFormScreen(mantenimiento: mantenimiento),
      ),
    ).then(
        (_) => ref.read(mantenimientosProvider.notifier).loadMantenimientos());
  }
}
