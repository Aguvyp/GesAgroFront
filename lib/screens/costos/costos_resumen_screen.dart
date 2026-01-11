import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../models/costo.dart';

class CostosResumenScreen extends ConsumerWidget {
  const CostosResumenScreen({Key? key}) : super(key: key);

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
    
    // Separar gastos y cobros
    final gastos = costos.where((c) => !c.esCobro).toList();
    final cobros = costos.where((c) => c.esCobro).toList();
    
    // Calcular totales
    final totalGastos = gastos.fold(0.0, (sum, c) => sum + c.monto);
    final totalCobros = cobros.fold(0.0, (sum, c) => sum + c.monto);
    final balance = totalCobros - totalGastos;
    
    // Gastos pagados vs pendientes
    final gastosPagados = gastos.where((c) => c.pagado).toList();
    final gastosPendientes = gastos.where((c) => !c.pagado).toList();
    final totalGastosPagados = gastosPagados.fold(0.0, (sum, c) => sum + c.monto);
    final totalGastosPendientes = gastosPendientes.fold(0.0, (sum, c) => sum + c.monto);
    
    // Cobros pagados vs pendientes
    final cobrosPagados = cobros.where((c) => c.pagado).toList();
    final cobrosPendientes = cobros.where((c) => !c.pagado).toList();
    final totalCobrosPagados = cobrosPagados.fold(0.0, (sum, c) => sum + c.monto);
    final totalCobrosPendientes = cobrosPendientes.fold(0.0, (sum, c) => sum + c.monto);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(costosProvider.notifier).loadCostos();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen principal
            _buildResumenPrincipal(totalGastos, totalCobros, balance),
            const SizedBox(height: 24),
            
            // Gastos: Pagados vs Pendientes
            _buildSeccionEstado(
              'Gastos',
              Colors.red,
              Icons.call_made,
              totalGastosPagados,
              totalGastosPendientes,
              gastosPagados.length,
              gastosPendientes.length,
            ),
            const SizedBox(height: 24),
            
            // Cobros: Pagados vs Pendientes
            _buildSeccionEstado(
              'Cobros',
              Colors.green,
              Icons.call_received,
              totalCobrosPagados,
              totalCobrosPendientes,
              cobrosPagados.length,
              cobrosPendientes.length,
            ),
            const SizedBox(height: 24),
            
            // Estadísticas adicionales
            _buildEstadisticasAdicionales(
              gastos.length,
              cobros.length,
              gastosPagados.length + cobrosPagados.length,
              gastosPendientes.length + cobrosPendientes.length,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenPrincipal(double totalGastos, double totalCobros, double balance) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen General',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildResumenCard(
                    'Total Gastos',
                    totalGastos,
                    Colors.red,
                    Icons.call_made,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildResumenCard(
                    'Total Cobros',
                    totalCobros,
                    Colors.green,
                    Icons.call_received,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: balance >= 0 
                  ? Colors.green.withOpacity(0.1) 
                  : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: balance >= 0 ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        balance >= 0 ? Icons.trending_up : Icons.trending_down,
                        color: balance >= 0 ? Colors.green : Colors.red,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Balance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '\$${balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: balance >= 0 ? Colors.green : Colors.red,
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

  Widget _buildResumenCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionEstado(
    String titulo,
    Color color,
    IconData icon,
    double totalPagados,
    double totalPendientes,
    int cantidadPagados,
    int cantidadPendientes,
  ) {
    final total = totalPagados + totalPendientes;
    final porcentajePagados = total > 0 ? (totalPagados / total * 100) : 0.0;
    final porcentajePendientes = total > 0 ? (totalPendientes / total * 100) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Pagados
            _buildEstadoItem(
              'Pagados',
              totalPagados,
              cantidadPagados,
              porcentajePagados,
              Colors.green,
            ),
            const SizedBox(height: 12),
            
            // Pendientes
            _buildEstadoItem(
              'Pendientes',
              totalPendientes,
              cantidadPendientes,
              porcentajePendientes,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadoItem(
    String label,
    double monto,
    int cantidad,
    double porcentaje,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '\$${monto.toStringAsFixed(2)} (${cantidad})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: porcentaje / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${porcentaje.toStringAsFixed(1)}% del total',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEstadisticasAdicionales(
    int totalGastos,
    int totalCobros,
    int totalPagados,
    int totalPendientes,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estadísticas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Gastos',
                    totalGastos.toString(),
                    Icons.call_made,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Total Cobros',
                    totalCobros.toString(),
                    Icons.call_received,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Pagados',
                    totalPagados.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Pendientes',
                    totalPendientes.toString(),
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
