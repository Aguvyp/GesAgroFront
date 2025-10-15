import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'optimized_screens.dart';
import 'optimized_dashboard_screen.dart';
import 'optimized_finanzas_screens.dart';
import 'test_connection_screen.dart';
import 'personal/personal_list_screen.dart';
import 'forms/forms_screens.dart';
import '../providers/optimized_providers.dart';

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
      const OptimizedCostosScreen(),
      const OptimizedProfileScreen(),
    ];
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.landscape),
            label: 'Campos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Trabajos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Costos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
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
      width: 280, // Ancho fijo para mejor visibilidad
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
            ),
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
          _buildDrawerItem(
            context,
            'Dashboard',
            Icons.dashboard,
            0,
          ),
          _buildDrawerItem(
            context,
            'Campos',
            Icons.landscape,
            1,
          ),
          _buildDrawerItem(
            context,
            'Trabajos',
            Icons.work,
            2,
          ),
          _buildDrawerItem(
            context,
            'Costos',
            Icons.attach_money,
            3,
          ),
          _buildDrawerItem(
            context,
            'Personal',
            Icons.people,
            -1, // Navegación especial
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PersonalListScreen()),
              );
            },
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            'Finanzas',
            Icons.account_balance_wallet,
            -1, // Navegación especial
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OptimizedFinanzasMainScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            'Reportes',
            Icons.analytics,
            -1, // Navegación especial
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OptimizedReportesScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            'Prueba Conexión',
            Icons.wifi_find,
            -1, // Navegación especial
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TestConnectionScreen()),
              );
            },
          ),
          const Divider(),
          _buildDrawerItem(
            context,
            'Perfil',
            Icons.person,
            4,
          ),
          _buildDrawerItem(
            context,
            'Configuración',
            Icons.settings,
            -1, // Navegación especial
            onTap: () {
              Navigator.pop(context);
              // TODO: Implementar pantalla de configuración
            },
          ),
          _buildDrawerItem(
            context,
            'Cerrar Sesión',
            Icons.logout,
            -1, // Navegación especial
            isDestructive: true,
            onTap: () {
              Navigator.pop(context);
              // TODO: Implementar logout
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    int index, {
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final isSelected = index == _currentIndex && index >= 0;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : (isSelected ? Theme.of(context).primaryColor : null),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : (isSelected ? Theme.of(context).primaryColor : null),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap ?? () {
        Navigator.pop(context);
        if (index >= 0) {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      selected: isSelected,
      hoverColor: Theme.of(context).primaryColor.withOpacity(0.1),
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
