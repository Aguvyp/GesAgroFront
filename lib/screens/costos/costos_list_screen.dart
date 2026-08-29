import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/optimized_providers.dart';
import '../../models/costo.dart';
import '../forms/costo_form_screen.dart';

class CostosListScreen extends ConsumerStatefulWidget {
  const CostosListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CostosListScreen> createState() => _CostosListScreenState();
}

class _CostosListScreenState extends ConsumerState<CostosListScreen> {
  String _filtroTipo = 'Todos'; // Todos, Gastos, Cobros
  String _filtroEstado = 'Todos'; // Todos, Pagado, Pendiente
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(costosProvider.notifier).loadCostos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final costosState = ref.watch(costosProvider);

    return Column(
      children: [
        // Barra de filtros
        _buildFiltrosBar(),

        // Lista de costos
        Expanded(
          child: _buildCostosList(costosState),
        ),
      ],
    );
  }

  Widget _buildFiltrosBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          // Buscador
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por descripción...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                _busqueda = value;
              });
            },
          ),
          const SizedBox(height: 12),

          // Filtros rápidos
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFiltroChip('Todos', _filtroTipo == 'Todos', (value) {
                  setState(() {
                    _filtroTipo = value;
                  });
                }),
                const SizedBox(width: 8),
                _buildFiltroChip('Gastos', _filtroTipo == 'Gastos', (value) {
                  setState(() {
                    _filtroTipo = value;
                  });
                }),
                const SizedBox(width: 8),
                _buildFiltroChip('Cobros', _filtroTipo == 'Cobros', (value) {
                  setState(() {
                    _filtroTipo = value;
                  });
                }),
                const SizedBox(width: 8),
                _buildFiltroChip('Pagados', _filtroEstado == 'Pagado', (value) {
                  setState(() {
                    _filtroEstado =
                        _filtroEstado == 'Pagado' ? 'Todos' : 'Pagado';
                  });
                }),
                const SizedBox(width: 8),
                _buildFiltroChip('Pendientes', _filtroEstado == 'Pendiente',
                    (value) {
                  setState(() {
                    _filtroEstado =
                        _filtroEstado == 'Pendiente' ? 'Todos' : 'Pendiente';
                  });
                }),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _mostrarFiltrosAvanzados,
                  tooltip: 'Filtros avanzados',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroChip(
      String label, bool isSelected, Function(String) onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onTap(label),
      selectedColor: const Color(0xFF2E7D32).withOpacity(0.2),
      checkmarkColor: const Color(0xFF2E7D32),
    );
  }

  void _mostrarFiltrosAvanzados() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros Avanzados'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Rango de Fechas'),
              subtitle: Text(
                _fechaInicio != null && _fechaFin != null
                    ? '${DateFormat('dd/MM/yyyy').format(_fechaInicio!)} - ${DateFormat('dd/MM/yyyy').format(_fechaFin!)}'
                    : 'Seleccionar fechas',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _fechaInicio != null && _fechaFin != null
                      ? DateTimeRange(start: _fechaInicio!, end: _fechaFin!)
                      : null,
                );
                if (picked != null) {
                  setState(() {
                    _fechaInicio = picked.start;
                    _fechaFin = picked.end;
                  });
                  Navigator.pop(context);
                }
              },
            ),
            if (_fechaInicio != null && _fechaFin != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _fechaInicio = null;
                    _fechaFin = null;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Limpiar fechas'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCostosList(BaseState state) {
    if (state is LoadingState || state is InitialState) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is ErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text('Error: ${state.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(costosProvider.notifier).loadCostos();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final costos = (state as LoadedState<List<Costo>>).data;

    // Aplicar filtros
    var costosFiltrados = costos.where((costo) {
      // Filtro por tipo
      if (_filtroTipo == 'Gastos' && costo.esCobro) return false;
      if (_filtroTipo == 'Cobros' && !costo.esCobro) return false;

      // Filtro por estado
      if (_filtroEstado == 'Pagado' && !costo.pagado) return false;
      if (_filtroEstado == 'Pendiente' && costo.pagado) return false;

      // Filtro por búsqueda
      if (_busqueda.isNotEmpty) {
        final busquedaLower = _busqueda.toLowerCase();
        if (!(costo.descripcion?.toLowerCase().contains(busquedaLower) ??
                false) &&
            !(costo.categoria?.toLowerCase().contains(busquedaLower) ??
                false) &&
            !(costo.destinatario.toLowerCase().contains(busquedaLower)) &&
            !(costo.cobrarA?.toLowerCase().contains(busquedaLower) ?? false)) {
          return false;
        }
      }

      // Filtro por fecha
      if (_fechaInicio != null && _fechaFin != null) {
        final fechaCosto =
            DateTime(costo.fecha.year, costo.fecha.month, costo.fecha.day);
        if (fechaCosto.isBefore(_fechaInicio!) ||
            fechaCosto.isAfter(_fechaFin!)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Ordenar por fecha (más recientes primero)
    costosFiltrados.sort((a, b) => b.fecha.compareTo(a.fecha));

    if (costosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay movimientos',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            if (_busqueda.isNotEmpty ||
                _filtroTipo != 'Todos' ||
                _filtroEstado != 'Todos')
              TextButton(
                onPressed: () {
                  setState(() {
                    _busqueda = '';
                    _filtroTipo = 'Todos';
                    _filtroEstado = 'Todos';
                    _fechaInicio = null;
                    _fechaFin = null;
                  });
                },
                child: const Text('Limpiar filtros'),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: costosFiltrados.length,
      itemBuilder: (context, index) {
        final costo = costosFiltrados[index];
        return _buildCostoCard(costo);
      },
    );
  }

  Widget _buildCostoCard(Costo costo) {
    final isCobro = costo.esCobro;
    final color = isCobro ? Colors.green : Colors.red;
    final icon = isCobro ? Icons.call_received : Icons.call_made;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          costo.descripcion ?? 'Sin descripción',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              isCobro
                  ? 'Cobrar a: ${costo.cobrarA ?? 'N/A'}'
                  : 'Destinatario: ${costo.destinatario}',
            ),
            const SizedBox(height: 2),
            Text(
              '${costo.categoria ?? 'Sin categoría'} • ${costo.formattedDate}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (costo.trabajoId != null)
              Text(
                'Trabajo ID: ${costo.trabajoId}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isCobro ? '+' : '-'}\$${costo.monto.toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(
                costo.pagado ? 'Pagado' : 'Pendiente',
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: costo.pagado
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        onTap: () => _editarCosto(costo),
        onLongPress: () => _mostrarOpciones(costo),
      ),
    );
  }

  void _editarCosto(Costo costo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CostoFormScreen(costo: costo),
      ),
    ).then((_) {
      ref.read(costosProvider.notifier).loadCostos();
    });
  }

  void _mostrarOpciones(Costo costo) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                _editarCosto(costo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title:
                  const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmarEliminacion(costo);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminacion(Costo costo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Movimiento'),
        content: Text(
            '¿Estás seguro de que quieres eliminar este ${costo.esCobro ? 'cobro' : 'gasto'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                if (costo.id != null) {
                  await ref
                      .read(costosProvider.notifier)
                      .deleteCosto(costo.id!);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Movimiento eliminado exitosamente')),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar: $e')),
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
