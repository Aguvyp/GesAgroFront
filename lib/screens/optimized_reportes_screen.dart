import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pantalla de reportes
class OptimizedReportesScreen extends ConsumerStatefulWidget {
  const OptimizedReportesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedReportesScreen> createState() => _OptimizedReportesScreenState();
}

class _OptimizedReportesScreenState extends ConsumerState<OptimizedReportesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de reportes financieros
            _buildReportSection(
              title: 'Reportes Financieros',
              icon: Icons.account_balance_wallet,
              color: Colors.green,
              reports: [
                _buildReportItem('Resumen de Ingresos', 'Vista general de todos los ingresos', () {}),
                _buildReportItem('Resumen de Gastos', 'Vista general de todos los gastos', () {}),
                _buildReportItem('Flujo de Caja', 'Análisis del flujo de efectivo', () {}),
                _buildReportItem('Estado de Cuentas', 'Estado actual de cuentas por cobrar y pagar', () {}),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Sección de reportes operativos
            _buildReportSection(
              title: 'Reportes Operativos',
              icon: Icons.work,
              color: Colors.blue,
              reports: [
                _buildReportItem('Resumen de Trabajos', 'Estado y progreso de trabajos', () {}),
                _buildReportItem('Productividad por Campo', 'Análisis de productividad por campo', () {}),
                _buildReportItem('Uso de Maquinaria', 'Reporte de utilización de maquinaria', () {}),
                _buildReportItem('Mantenimientos', 'Historial y programación de mantenimientos', () {}),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Sección de reportes de personal
            _buildReportSection(
              title: 'Reportes de Personal',
              icon: Icons.people,
              color: Colors.orange,
              reports: [
                _buildReportItem('Horas Trabajadas', 'Resumen de horas trabajadas por personal', () {}),
                _buildReportItem('Productividad Personal', 'Análisis de productividad del personal', () {}),
                _buildReportItem('Asistencia', 'Reporte de asistencia y faltas', () {}),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Sección de reportes de inventario
            _buildReportSection(
              title: 'Reportes de Inventario',
              icon: Icons.inventory,
              color: Colors.purple,
              reports: [
                _buildReportItem('Stock de Insumos', 'Estado actual del inventario', () {}),
                _buildReportItem('Consumo por Campo', 'Análisis de consumo por campo', () {}),
                _buildReportItem('Compras', 'Historial de compras de insumos', () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> reports,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...reports,
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(String title, String description, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

