import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../models/costo.dart';

class CostosCategoriaScreen extends ConsumerWidget {
  const CostosCategoriaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final costosState = ref.watch(costosProvider);

    if (costosState is LoadingState || costosState is InitialState) {
      return const Center(child: CircularProgressIndicator());
    }

    if (costosState is ErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text('Error: ${costosState.message}'),
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

    final costos = (costosState as LoadedState<List<Costo>>).data;

    // Agrupar por categoría
    final Map<String, List<Costo>> costosPorCategoria = {};
    final Map<String, double> totalesPorCategoria = {};

    for (final costo in costos) {
      final categoria = costo.categoria ?? 'Sin categoría';
      if (!costosPorCategoria.containsKey(categoria)) {
        costosPorCategoria[categoria] = [];
        totalesPorCategoria[categoria] = 0.0;
      }
      costosPorCategoria[categoria]!.add(costo);
      totalesPorCategoria[categoria] =
          (totalesPorCategoria[categoria] ?? 0.0) + costo.monto;
    }

    // Ordenar categorías por total (mayor a menor)
    final categoriasOrdenadas = totalesPorCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (categoriasOrdenadas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay costos por categoría',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Calcular total general
    final totalGeneral =
        totalesPorCategoria.values.fold(0.0, (sum, total) => sum + total);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(costosProvider.notifier).loadCostos();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen general
            _buildResumenGeneral(totalGeneral, categoriasOrdenadas.length),
            const SizedBox(height: 24),

            // Lista de categorías
            const Text(
              'Distribución por Categoría',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ...categoriasOrdenadas.map((entry) {
              final categoria = entry.key;
              final total = entry.value;
              final porcentaje =
                  totalGeneral > 0 ? (total / totalGeneral * 100) : 0.0;
              final costosCategoria = costosPorCategoria[categoria]!;

              return _buildCategoriaCard(
                categoria,
                total,
                porcentaje,
                costosCategoria,
                context,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenGeneral(double totalGeneral, int cantidadCategorias) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total General',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${totalGeneral.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.category,
                    color: Color(0xFF2E7D32),
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$cantidadCategorias',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const Text(
                    'Categorías',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriaCard(
    String categoria,
    double total,
    double porcentaje,
    List<Costo> costos,
    BuildContext context,
  ) {
    // Separar gastos y cobros
    final gastos = costos.where((c) => !c.esCobro).toList();
    final cobros = costos.where((c) => c.esCobro).toList();
    final totalGastos = gastos.fold(0.0, (sum, c) => sum + c.monto);
    final totalCobros = cobros.fold(0.0, (sum, c) => sum + c.monto);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getColorForCategoria(categoria).withOpacity(0.1),
          child: Icon(
            Icons.category,
            color: _getColorForCategoria(categoria),
          ),
        ),
        title: Text(
          categoria,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '\$${total.toStringAsFixed(2)} (${porcentaje.toStringAsFixed(1)}%)',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: porcentaje / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getColorForCategoria(categoria),
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Desglose de gastos y cobros
                Row(
                  children: [
                    Expanded(
                      child: _buildDesgloseItem(
                        'Gastos',
                        totalGastos,
                        gastos.length,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDesgloseItem(
                        'Cobros',
                        totalCobros,
                        cobros.length,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Lista de costos (máximo 5)
                if (costos.length > 5)
                  Text(
                    'Mostrando 5 de ${costos.length} movimientos',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                const SizedBox(height: 8),
                ...costos.take(5).map((costo) => _buildCostoItem(costo)),
                if (costos.length > 5)
                  TextButton(
                    onPressed: () {
                      _mostrarTodosLosCostos(context, categoria, costos);
                    },
                    child: const Text('Ver todos los movimientos'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesgloseItem(
    String label,
    double monto,
    int cantidad,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${monto.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '$cantidad movimientos',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostoItem(Costo costo) {
    final isCobro = costo.esCobro;
    final color = isCobro ? Colors.green : Colors.red;
    final icon = isCobro ? Icons.call_received : Icons.call_made;

    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        costo.descripcion ?? 'Sin descripción',
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        costo.formattedDate,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
              fontSize: 14,
            ),
          ),
          if (costo.pagado)
            Chip(
              label: const Text('Pagado', style: TextStyle(fontSize: 8)),
              backgroundColor: Colors.green.withOpacity(0.2),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  void _mostrarTodosLosCostos(
      BuildContext context, String categoria, List<Costo> costos) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Todos los movimientos - $categoria'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: costos.length,
            itemBuilder: (context, index) {
              final costo = costos[index];
              return _buildCostoItem(costo);
            },
          ),
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

  Color _getColorForCategoria(String categoria) {
    // Asignar colores consistentes según la categoría
    final colors = [
      const Color(0xFF2E7D32), // Verde
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
    ];

    final index = categoria.hashCode % colors.length;
    return colors[index.abs()];
  }
}
