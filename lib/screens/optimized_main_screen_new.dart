import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'optimized_screens.dart';
import 'optimized_dashboard_screen.dart';
import 'costos/costos_main_screen.dart';
import 'forms/trabajo_form_screen.dart';
import 'forms/maquina_form_screen.dart';
import 'forms/personal_form_screen.dart';
import 'forms/mantenimiento_form_screen.dart';
import 'forms/cliente_form_screen.dart';
import 'forms/campo_form_screen.dart';
import 'forms/costo_form_screen.dart';
import 'mantenimientos/optimized_mantenimientos_screen.dart';
import 'reportes/optimized_reportes_screen.dart';
import 'test_connection_screen.dart';
import 'test_screen.dart';
import 'personal/personal_list_screen.dart';
import 'clientes/clientes_list_screen.dart';
import 'maquinas/maquinas_list_screen.dart';
import '../providers/optimized_providers.dart';
import '../providers/optimized_auth_provider.dart';
import '../themes/app_theme.dart';

class OptimizedSplashScreen extends ConsumerStatefulWidget {
  const OptimizedSplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedSplashScreen> createState() =>
      _OptimizedSplashScreenState();
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
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.agriculture, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'GesAgro',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              ),
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
  ConsumerState<OptimizedMainScreen> createState() =>
      _OptimizedMainScreenState();
}

class _OptimizedMainScreenState extends ConsumerState<OptimizedMainScreen> {
  int _currentIndex = 0;
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
            _pageController.jumpToPage(index);
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
      backgroundColor: AppTheme.background,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: _screens,
      ),
      floatingActionButton: _currentIndex != 4
          ? FloatingActionButton(
              onPressed: () => _showQuickActionMenu(context),
              elevation: 2,
              child: const Icon(Icons.add, size: 28),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(color: AppTheme.border, width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Inicio'),
                _buildNavItem(1, Icons.landscape_outlined, Icons.landscape_rounded, 'Campos'),
                _buildNavItem(2, Icons.work_outline_rounded, Icons.work_rounded, 'Trabajos'),
                _buildNavItem(3, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Finanzas'),
                _buildNavItem(4, Icons.menu_rounded, Icons.menu_rounded, 'Más'),
              ],
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
            _pageController.jumpToPage(index);
          });
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? AppTheme.primary : AppTheme.textHint,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primary : AppTheme.textHint,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Crear nuevo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
              children: [
                _buildActionItem(context, Icons.work_outline_rounded, 'Trabajo',
                    () => _navigateToForm(context, const TrabajoFormScreen())),
                _buildActionItem(context, Icons.agriculture_outlined, 'Máquina',
                    () => _navigateToForm(context, const MaquinaFormScreen())),
                _buildActionItem(context, Icons.person_outline_rounded, 'Personal',
                    () => _navigateToForm(context, const PersonalFormScreen())),
                _buildActionItem(context, Icons.build_outlined, 'Manten.',
                    () => _navigateToForm(context, const MantenimientoFormScreen())),
                _buildActionItem(context, Icons.people_outline_rounded, 'Cliente',
                    () => _navigateToForm(context, const ClienteFormScreen())),
                _buildActionItem(context, Icons.landscape_outlined, 'Campo',
                    () => _navigateToForm(context, const CampoFormScreen())),
                _buildActionItem(context, Icons.attach_money_rounded, 'Costo',
                    () => _navigateToForm(context, const CostoFormScreen())),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildActionItem(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Pantalla de costos optimizada
class OptimizedCostosScreen extends ConsumerStatefulWidget {
  const OptimizedCostosScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedCostosScreen> createState() =>
      _OptimizedCostosScreenState();
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
      appBar: AppBar(title: const Text('Costos')),
      body: _buildCostosList(costosState),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCostoForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCostosList(BaseState state) {
    if (state is LoadingState) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is ErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.textHint),
            const SizedBox(height: 12),
            Text('Error: ${state.message}',
                style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => ref.read(costosProvider.notifier).loadCostos(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (state is LoadedState<List<dynamic>>) {
      final costos = state.data;
      if (costos.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.textHint),
              const SizedBox(height: 12),
              const Text('Sin costos registrados',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              const Text('Toca + para agregar uno',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
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
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_outlined, color: AppTheme.primary, size: 22),
              ),
              title: Text(costo.descripcion ?? 'Sin descripción'),
              subtitle: Text('\$${costo.monto?.toStringAsFixed(2) ?? '0.00'}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) => _handleCostoAction(value, costo),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
            ),
          );
        },
      );
    }
    return const SizedBox();
  }

  void _handleCostoAction(String action, dynamic costo) {
    if (action == 'edit') {
      _showCostoForm(context, costo: costo);
    } else if (action == 'delete') {
      _showDeleteConfirmation(costo);
    }
  }

  void _showCostoForm(BuildContext context, {dynamic costo}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CostoFormScreen(costo: costo)),
    );
  }

  void _showDeleteConfirmation(dynamic costo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar'),
        content: const Text('¿Eliminar este costo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              if (costo.id != null) {
                await ref.read(costosProvider.notifier).deleteCosto(costo.id);
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

/// Pantalla "Más" — Simple estilo Settings de iOS
class OptimizedMoreScreen extends ConsumerStatefulWidget {
  const OptimizedMoreScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedMoreScreen> createState() => _OptimizedMoreScreenState();
}

class _OptimizedMoreScreenState extends ConsumerState<OptimizedMoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 20),
              child: Text(
                'Más opciones',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // Gestión
            _buildSectionLabel('GESTIÓN'),
            _buildGroupCard([
              _buildItem('Trabajos', Icons.work_outline_rounded, () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const OptimizedTrabajosListScreen(showAppBar: true)));
              }),
              _buildItem('Máquinas', Icons.agriculture_outlined, () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const OptimizedMaquinasListScreen(showAppBar: true)));
              }),
              _buildItem('Personal', Icons.people_outline_rounded, () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const PersonalListScreen()));
              }),
              _buildItem('Clientes', Icons.contacts_outlined, () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const ClientesListScreen()));
              }),
              _buildItem('Mantenimientos', Icons.build_outlined, () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const OptimizedMantenimientosScreen()));
              }),
            ]),
            const SizedBox(height: 20),

            // Reportes
            _buildSectionLabel('REPORTES'),
            _buildGroupCard([
              _buildItem('Reportes', Icons.analytics_outlined, () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const OptimizedReportesScreen()));
              }),
            ]),
            const SizedBox(height: 20),

            // Cuenta
            _buildSectionLabel('CUENTA'),
            _buildGroupCard([
              _buildItem('Mi Perfil', Icons.person_outline_rounded, () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const OptimizedProfileScreen()));
              }),
            ]),
            const SizedBox(height: 20),

            // Cerrar sesión
            _buildLogoutButton(context),
            const SizedBox(height: 16),

            // Versión
            Center(
              child: Text(
                'GesAgro v1.0.0',
                style: TextStyle(fontSize: 12, color: AppTheme.textHint),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildGroupCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          return Column(
            children: [
              items[i],
              if (i < items.length - 1)
                Divider(height: 1, indent: 56, color: AppTheme.border),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textHint, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: InkWell(
        onTap: () => _handleLogout(context),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: AppTheme.error, size: 20),
              const SizedBox(width: 8),
              Text(
                'Cerrar sesión',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.error,
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
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar tu sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(authProvider.notifier).logout();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}

/// Pantalla de perfil
class OptimizedProfileScreen extends ConsumerWidget {
  const OptimizedProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline_rounded, size: 64, color: AppTheme.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'Mi Perfil',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Próximamente',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
