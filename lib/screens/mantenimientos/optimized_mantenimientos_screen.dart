import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/mantenimiento.dart';
import '../../providers/optimized_providers.dart';
import '../../providers/optimized_auth_provider.dart';
import '../forms/mantenimiento_form_screen.dart';
import '../optimized_main_screen_new.dart';
import '../optimized_screens.dart';
import '../personal/personal_list_screen.dart';
import '../finanzas/optimized_finanzas_screens.dart';
import '../reportes/optimized_reportes_screen.dart';

/// Pantalla de mantenimientos
class OptimizedMantenimientosScreen extends ConsumerStatefulWidget {
  const OptimizedMantenimientosScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedMantenimientosScreen> createState() => _OptimizedMantenimientosScreenState();
}

class _OptimizedMantenimientosScreenState extends ConsumerState<OptimizedMantenimientosScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mantenimientosProvider.notifier).loadMantenimientos();
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Cerrar sesión usando el provider
      await ref.read(authProvider.notifier).logout();
      
      // Navegar a la pantalla de login
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
    final mantenimientosState = ref.watch(mantenimientosProvider);
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Mantenimientos',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, size: 20),
          color: const Color(0xFF1C1C1E),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: _buildDrawer(context),
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      width: 320, // Ancho más amplio para elementos flotantes
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
                        'Mantenimientos',
                        Icons.build_rounded,
                        -1,
                        isSelected: true,
                        onTap: () {
                          Navigator.pop(context);
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
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OptimizedReportesScreen()),
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
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isDestructive 
                        ? Colors.red.shade600
                        : (isSelected 
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade700),
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
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

