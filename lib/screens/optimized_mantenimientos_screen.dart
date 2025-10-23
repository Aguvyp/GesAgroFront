import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mantenimiento.dart';
import '../providers/optimized_providers.dart';
import 'forms/mantenimiento_form_screen.dart';

/// Pantalla de mantenimientos
class OptimizedMantenimientosScreen extends ConsumerStatefulWidget {
  const OptimizedMantenimientosScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedMantenimientosScreen> createState() => _OptimizedMantenimientosScreenState();
}

class _OptimizedMantenimientosScreenState extends ConsumerState<OptimizedMantenimientosScreen> {
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
      body: _buildMantenimientosList(mantenimientosState),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showMantenimientoForm(context);
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMantenimientosList(BaseState state) {
    if (state is LoadingState) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is ErrorState) {
      return Center(child: Text('Error: ${state.message}'));
    }
    
    final mantenimientos = (state as LoadedState<List<Mantenimiento>>).data;
    if (mantenimientos.isEmpty) {
      return const Center(child: Text('No hay mantenimientos'));
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
              backgroundColor: _getEstadoColor(mantenimiento.estado).withOpacity(0.1),
              child: Icon(_getEstadoIcon(mantenimiento.estado), color: _getEstadoColor(mantenimiento.estado)),
            ),
            title: Text(mantenimiento.descripcion),
            subtitle: Text(mantenimiento.estado.toUpperCase()),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  mantenimiento.costoTotal != null ? '\$${mantenimiento.costoTotal!.toStringAsFixed(2)}' : 'Sin costo',
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

  void _showMantenimientoForm(BuildContext context, {Mantenimiento? mantenimiento}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MantenimientoFormScreen(mantenimiento: mantenimiento),
      ),
    ).then((_) => ref.read(mantenimientosProvider.notifier).loadMantenimientos());
  }
}

