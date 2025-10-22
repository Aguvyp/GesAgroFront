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
              backgroundColor: _getTipoColor(mantenimiento.tipo).withOpacity(0.1),
              child: Icon(_getTipoIcon(mantenimiento.tipo), color: _getTipoColor(mantenimiento.tipo)),
            ),
            title: Text(mantenimiento.descripcion),
            subtitle: Text('${mantenimiento.tipo} • ${mantenimiento.estado}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  mantenimiento.costo != null ? '\$${mantenimiento.costo!.toStringAsFixed(2)}' : 'Sin costo',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  mantenimiento.fechaProgramada != null 
                    ? '${mantenimiento.fechaProgramada!.day}/${mantenimiento.fechaProgramada!.month}/${mantenimiento.fechaProgramada!.year}'
                    : 'Sin fecha',
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

  Color _getTipoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'preventivo':
        return Colors.green;
      case 'correctivo':
        return Colors.red;
      case 'predictivo':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'preventivo':
        return Icons.event_outlined;
      case 'correctivo':
        return Icons.build;
      case 'predictivo':
        return Icons.trending_up;
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

