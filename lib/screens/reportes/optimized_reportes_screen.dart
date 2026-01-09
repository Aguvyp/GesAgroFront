import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_auth_provider.dart';
import '../optimized_main_screen_new.dart';
import '../optimized_screens.dart';
import '../maquinas/maquinas_list_screen.dart';
import '../mantenimientos/optimized_mantenimientos_screen.dart';
import '../personal/personal_list_screen.dart';
import '../finanzas/optimized_finanzas_screens.dart';

/// Pantalla de reportes
class OptimizedReportesScreen extends ConsumerStatefulWidget {
  const OptimizedReportesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedReportesScreen> createState() => _OptimizedReportesScreenState();
}

class _OptimizedReportesScreenState extends ConsumerState<OptimizedReportesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Reportes'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: _buildDrawer(context),
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      width: 320,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          backgroundBlendMode: BlendMode.overlay,
        ),
        child: Column(
          children: [
            // Header con efecto blur y sombra
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.agriculture,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'GesAgro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Sistema de Gestión Agrícola',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Contenido del drawer con padding y scroll
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildModernDrawerItem(
                        context,
                        'Inicio',
                        Icons.home_rounded,
                        0,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const OptimizedMainScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Campos',
                        Icons.landscape_rounded,
                        1,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OptimizedCamposListScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Trabajos',
                        Icons.work_rounded,
                        2,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OptimizedTrabajosListScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Máquinas',
                        Icons.local_shipping_rounded,
                        -1,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OptimizedMaquinasListScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Mantenimientos',
                        Icons.build_rounded,
                        -1,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OptimizedMantenimientosScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Personal',
                        Icons.people_rounded,
                        -1,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PersonalListScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Separador simple
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.grey[300],
                      ),
                      
                      _buildModernDrawerItem(
                        context,
                        'Finanzas',
                        Icons.account_balance_wallet_rounded,
                        -1,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OptimizedFinanzasMainScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Reportes',
                        Icons.analytics_rounded,
                        -1,
                        isSelected: true,
                      ),
                      const SizedBox(height: 16),
                      
                      // Separador simple
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.grey[300],
                      ),
                      
                      _buildModernDrawerItem(
                        context,
                        'Perfil',
                        Icons.person_rounded,
                        4,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OptimizedProfileScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Configuración',
                        Icons.settings_rounded,
                        -1,
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Implementar pantalla de configuración
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Cerrar Sesión',
                        Icons.logout_rounded,
                        -1,
                        isDestructive: true,
                        onTap: () async {
                          Navigator.pop(context);
                          await _handleLogout(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    int index, {
    VoidCallback? onTap,
    bool isDestructive = false,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected 
                ? Theme.of(context).primaryColor.withOpacity(0.08)
                : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: isSelected 
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isDestructive 
                    ? Colors.red.shade600
                    : (isSelected 
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isDestructive 
                        ? Colors.red.shade600
                        : (isSelected 
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade700),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

