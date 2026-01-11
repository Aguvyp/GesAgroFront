import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'optimized_screens.dart';
import 'optimized_dashboard_screen.dart';
// import 'finanzas/optimized_finanzas_screens.dart'; // Oculto temporalmente
import 'mantenimientos/optimized_mantenimientos_screen.dart';
import 'reportes/optimized_reportes_screen.dart';
import 'test_connection_screen.dart';
import 'test_screen.dart';
import 'personal/personal_list_screen.dart';
import 'maquinas/maquinas_list_screen.dart';
import 'forms/forms_screens.dart';
import 'costos/costos_main_screen.dart';
import '../providers/optimized_providers.dart';
import '../providers/optimized_auth_provider.dart';

class OptimizedSplashScreen extends ConsumerStatefulWidget {
  const OptimizedSplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedSplashScreen> createState() => _OptimizedSplashScreenState();
}

class _OptimizedSplashScreenState extends ConsumerState<OptimizedSplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToMain();
  }

  void _navigateToMain() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OptimizedMainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              'GesAgro',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class OptimizedMainScreen extends ConsumerStatefulWidget {
  const OptimizedMainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedMainScreen> createState() => _OptimizedMainScreenState();
}

class _OptimizedMainScreenState extends ConsumerState<OptimizedMainScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      OptimizedDashboardScreen(
        onNavigateToIndex: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      const OptimizedCamposListScreen(),
      const OptimizedTrabajosListScreen(),
      const OptimizedProfileScreen(),
    ];
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_getAppBarTitle(_currentIndex)),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          // Botón de recargar removido
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Buscador debajo del AppBar
          if (_shouldShowSearchBar(_currentIndex))
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: _buildSearchBar(),
            ),
          // Contenido de la pantalla
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Inicio';
      case 1:
        return 'Campos';
      case 2:
        return 'Trabajos';
      case 3:
        return 'Costos';
      case 4:
        return 'Perfil';
      default:
        return 'GesAgro';
    }
  }

  bool _shouldShowSearchBar(int index) {
    // Mostrar buscador en Campos y Trabajos
    return index == 1 || index == 2;
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: _getSearchHint(_currentIndex),
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) {
        // TODO: Implementar búsqueda
      },
    );
  }

  String _getSearchHint(int index) {
    switch (index) {
      case 1:
        return 'Buscar campos...';
      case 2:
        return 'Buscar trabajos...';
      default:
        return 'Buscar...';
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
                      ),
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Campos',
                        Icons.landscape_rounded,
                        1,
                      ),
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Trabajos',
                        Icons.work_rounded,
                        2,
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
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Finanzas',
                        Icons.receipt_long_rounded,
                        -1,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CostosMainScreen()),
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
                      
                      // Sección de Finanzas oculta temporalmente
                      // _buildModernDrawerItem(
                      //   context,
                      //   'Finanzas',
                      //   Icons.account_balance_wallet_rounded,
                      //   -1,
                      //   onTap: () {
                      //     Navigator.pop(context);
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(builder: (context) => const OptimizedFinanzasMainScreen()),
                      //     );
                      //   },
                      // ),
                      // const SizedBox(height: 8),
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
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Prueba Conexión',
                        Icons.wifi_find_rounded,
                        -1,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TestConnectionScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Pruebas y Análisis',
                        Icons.science_rounded,
                        -1,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TestScreen()),
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
  }) {
    final isSelected = index == _currentIndex && index >= 0;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {
            Navigator.pop(context);
            if (index >= 0) {
              setState(() {
                _currentIndex = index;
              });
            }
          },
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

/// Pantalla de costos optimizada
class OptimizedCostosScreen extends ConsumerStatefulWidget {
  const OptimizedCostosScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedCostosScreen> createState() => _OptimizedCostosScreenState();
}

class _OptimizedCostosScreenState extends ConsumerState<OptimizedCostosScreen> {
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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Costos'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(costosProvider.notifier).loadCostos();
            },
          ),
        ],
      ),
      body: _buildCostosList(costosState),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCostoForm(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCostosList(BaseState state) {
    if (state is LoadingState) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (state is ErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
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
    
    if (state is LoadedState<List<dynamic>>) {
      final costos = state.data;
      
      if (costos.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No hay costos registrados'),
              SizedBox(height: 8),
              Text('Toca el botón + para agregar un nuevo costo'),
            ],
          ),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: costos.length,
        itemBuilder: (context, index) {
          final costo = costos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.receipt,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              title: Text(costo.descripcion ?? 'Sin descripción'),
              subtitle: Text('Monto: \$${costo.monto?.toStringAsFixed(2) ?? '0.00'}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) => _handleCostoAction(value, costo),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 8),
                        Text('Eliminar'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    
    return const Center(child: Text('Estado no reconocido'));
  }

  void _handleCostoAction(String action, dynamic costo) {
    switch (action) {
      case 'edit':
        _showCostoForm(context, costo: costo);
        break;
      case 'delete':
        _showDeleteConfirmation(costo);
        break;
    }
  }

  void _showCostoForm(BuildContext context, {dynamic costo}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CostoFormScreen(costo: costo),
      ),
    );
  }

  void _showDeleteConfirmation(dynamic costo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Costo'),
        content: Text('¿Estás seguro de que quieres eliminar este costo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                if (costo.id != null) {
                  await ref.read(costosProvider.notifier).deleteCosto(costo.id);
                }
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Costo eliminado exitosamente')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar costo: $e')),
                  );
                }
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

/// Pantalla de perfil optimizada
class OptimizedProfileScreen extends ConsumerStatefulWidget {
  const OptimizedProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedProfileScreen> createState() => _OptimizedProfileScreenState();
}

class _OptimizedProfileScreenState extends ConsumerState<OptimizedProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Pantalla de Perfil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('En desarrollo'),
          ],
        ),
      ),
    );
  }
}
