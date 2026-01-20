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
  late PageController _pageController;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _screens = [
      OptimizedDashboardScreen(
        onNavigateToIndex: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
      ),
      const OptimizedCamposListScreen(),
      const OptimizedTrabajosListScreen(),
      const CostosMainScreen(),
      const OptimizedMoreScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Deshabilitar swipe manual
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final navBackground =
        theme.bottomNavigationBarTheme.backgroundColor ?? colorScheme.surfaceVariant;
    final borderColor = theme.dividerColor.withOpacity(0.35);

    return Container(
      decoration: BoxDecoration(
        color: navBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(color: borderColor, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 26,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: navBackground,
          selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor ??
              colorScheme.primary,
          unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor ??
              colorScheme.onSurface.withOpacity(0.6),
          selectedLabelStyle: theme.bottomNavigationBarTheme.selectedLabelStyle,
          unselectedLabelStyle:
              theme.bottomNavigationBarTheme.unselectedLabelStyle,
          selectedIconTheme: theme.bottomNavigationBarTheme.selectedIconTheme,
          unselectedIconTheme:
              theme.bottomNavigationBarTheme.unselectedIconTheme,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 26),
              activeIcon: Icon(Icons.home_rounded, size: 28),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.landscape_rounded, size: 26),
              activeIcon: Icon(Icons.landscape_rounded, size: 28),
              label: 'Campos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work_rounded, size: 26),
              activeIcon: Icon(Icons.work_rounded, size: 28),
              label: 'Trabajos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded, size: 26),
              activeIcon: Icon(Icons.receipt_long_rounded, size: 28),
              label: 'Finanzas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz_rounded, size: 26),
              activeIcon: Icon(Icons.more_horiz_rounded, size: 28),
              label: 'Más',
            ),
          ],
        ),
      ),
    );
  }

  // Métodos removidos - ahora se usa Bottom Navigation Bar
  // El drawer se movió a la pantalla "Más"
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

/// Pantalla "Más" con opciones secundarias
class OptimizedMoreScreen extends ConsumerStatefulWidget {
  const OptimizedMoreScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedMoreScreen> createState() => _OptimizedMoreScreenState();
}

class _OptimizedMoreScreenState extends ConsumerState<OptimizedMoreScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // AppBar moderno estilo iOS
          SliverAppBar(
            expandedHeight: 56,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            toolbarHeight: 56,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Más',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E),
                  letterSpacing: -0.41,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 12),
            ),
          ),
          
          // Contenido
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Perfil
                  _buildSectionCard(
                    'Perfil',
                    [
                      _buildMoreItem(
                        'Mi Perfil',
                        Icons.person_rounded,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OptimizedProfileScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Gestión
                  _buildSectionCard(
                    'Gestión',
                    [
                      _buildMoreItem(
                        'Máquinas',
                        Icons.local_shipping_rounded,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OptimizedMaquinasListScreen(showAppBar: true),
                            ),
                          );
                        },
                      ),
                      _buildMoreItem(
                        'Personal',
                        Icons.people_rounded,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PersonalListScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMoreItem(
                        'Mantenimientos',
                        Icons.build_rounded,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OptimizedMantenimientosScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Reportes y Análisis
                  _buildSectionCard(
                    'Reportes',
                    [
                      _buildMoreItem(
                        'Reportes',
                        Icons.analytics_rounded,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OptimizedReportesScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Configuración
                  _buildSectionCard(
                    'Configuración',
                    [
                      _buildMoreItem(
                        'Configuración',
                        Icons.settings_rounded,
                        () {
                          // TODO: Implementar pantalla de configuración
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Próximamente')),
                          );
                        },
                      ),
                      _buildMoreItem(
                        'Prueba Conexión',
                        Icons.wifi_find_rounded,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TestConnectionScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMoreItem(
                        'Pruebas y Análisis',
                        Icons.science_rounded,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TestScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Cerrar Sesión
                  _buildLogoutButton(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: -0.08,
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 0.5,
            ),
          ),
          margin: EdgeInsets.zero,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildMoreItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2E7D32),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1C1C1E),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _handleLogout(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: Colors.red[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Cerrar Sesión',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
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
            SnackBar(content: Text('Error al cerrar sesión: $e')),
          );
        }
      }
    }
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Perfil'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1C1C1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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
