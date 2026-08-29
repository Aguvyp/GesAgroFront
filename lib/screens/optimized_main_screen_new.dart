import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'personal/personal_list_screen.dart';
import 'clientes/clientes_list_screen.dart';
import 'maquinas/maquinas_list_screen.dart';
import 'usuarios/usuarios_screen.dart';
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
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco_rounded,
                    size: 64, color: Colors.white),
              ).animate().fadeIn(duration: 500.ms).scale(
                  begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
              const SizedBox(height: 20),
              Text(
                'GesAgro',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
              const SizedBox(height: 28),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.7)),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  MAIN SCREEN CON NAV PREMIUM
// ═══════════════════════════════════════════

class OptimizedMainScreen extends ConsumerStatefulWidget {
  const OptimizedMainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedMainScreen> createState() =>
      _OptimizedMainScreenState();
}

class _OptimizedMainScreenState extends ConsumerState<OptimizedMainScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late final List<Widget> _screens;
  late AnimationController _fabAnimController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
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
    _fabAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) => setState(() => _currentIndex = index),
          children: _screens,
        ),
        floatingActionButton: _currentIndex != 4 ? _buildPremiumFAB() : null,
        bottomNavigationBar: _buildPremiumNavBar(),
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  // ─── FAB premium — abre el form correspondiente al tab activo ───
  Widget _buildPremiumFAB() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _handleFABPress(context),
        elevation: 0,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  void _handleFABPress(BuildContext context) {
    HapticFeedback.mediumImpact();
    switch (_currentIndex) {
      case 0:
        // Dashboard → menú rápido de creación
        _showQuickActionMenu(context);
        break;
      case 1:
        // Campos → crear campo directo
        _navigateToFormDirect(context, const CampoFormScreen());
        break;
      case 2:
        // Trabajos → crear trabajo directo
        _navigateToFormDirect(context, const TrabajoFormScreen());
        break;
      case 3:
        // Finanzas → crear costo directo
        _navigateToFormDirect(context, const CostoFormScreen());
        break;
    }
  }

  void _navigateToFormDirect(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  // ─── Bottom nav bar premium ───
  Widget _buildPremiumNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                  0, Icons.home_outlined, Icons.home_rounded, 'Inicio'),
              _buildNavItem(1, Icons.landscape_outlined,
                  Icons.landscape_rounded, 'Campos'),
              _buildNavItem(2, Icons.work_outline_rounded, Icons.work_rounded,
                  'Trabajos'),
              _buildNavItem(3, Icons.account_balance_wallet_outlined,
                  Icons.account_balance_wallet_rounded, 'Finanzas'),
              _buildNavItem(
                  4, Icons.grid_view_rounded, Icons.grid_view_rounded, 'Más'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _currentIndex = index;
            _pageController.jumpToPage(index);
          });
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 16 : 0,
                  vertical: isSelected ? 6 : 0,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? AppTheme.primary : AppTheme.textHint,
                  size: 23,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: isSelected ? AppTheme.primary : AppTheme.textHint,
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Quick Actions Sheet premium ───
  void _showQuickActionMenu(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: AppTheme.shadowLg,
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crear nuevo',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Selecciona qué deseas crear',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Grid de acciones
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.82,
              children: [
                _buildActionItem(
                  context,
                  Icons.work_outline_rounded,
                  'Trabajo',
                  const Color(0xFF1976D2),
                  const Color(0xFFE3F2FD),
                  () => _navigateToForm(context, const TrabajoFormScreen()),
                ),
                _buildActionItem(
                  context,
                  Icons.agriculture_outlined,
                  'Máquina',
                  const Color(0xFF388E3C),
                  const Color(0xFFE8F5E9),
                  () => _navigateToForm(context, const MaquinaFormScreen()),
                ),
                _buildActionItem(
                  context,
                  Icons.person_outline_rounded,
                  'Personal',
                  const Color(0xFF7B1FA2),
                  const Color(0xFFF3E5F5),
                  () => _navigateToForm(context, const PersonalFormScreen()),
                ),
                _buildActionItem(
                  context,
                  Icons.build_outlined,
                  'Manten.',
                  const Color(0xFFF57C00),
                  const Color(0xFFFFF3E0),
                  () =>
                      _navigateToForm(context, const MantenimientoFormScreen()),
                ),
                _buildActionItem(
                  context,
                  Icons.people_outline_rounded,
                  'Cliente',
                  const Color(0xFF00838F),
                  const Color(0xFFE0F7FA),
                  () => _navigateToForm(context, const ClienteFormScreen()),
                ),
                _buildActionItem(
                  context,
                  Icons.landscape_outlined,
                  'Campo',
                  const Color(0xFF558B2F),
                  const Color(0xFFF1F8E9),
                  () => _navigateToForm(context, const CampoFormScreen()),
                ),
                _buildActionItem(
                  context,
                  Icons.payments_outlined,
                  'Costo',
                  const Color(0xFFC62828),
                  const Color(0xFFFFEBEE),
                  () => _navigateToForm(context, const CostoFormScreen()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label,
      Color iconColor, Color bgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: AppTheme.textPrimary,
              letterSpacing: -0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  COSTOS SCREEN (sin cambios de lógica)
// ═══════════════════════════════════════════

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
        child: const Icon(Icons.add_rounded),
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
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.receipt_long_outlined,
                    size: 44, color: AppTheme.primary),
              ),
              const SizedBox(height: 16),
              Text('Sin costos registrados',
                  style: GoogleFonts.inter(
                      fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Toca + para agregar uno',
                  style: GoogleFonts.inter(
                      color: AppTheme.textSecondary, fontSize: 14)),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: costos.length,
        itemBuilder: (context, index) {
          final costo = costos[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.shadowSm,
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_outlined,
                    color: AppTheme.primary, size: 22),
              ),
              title: Text(
                costo.descripcion ?? 'Sin descripción',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, fontSize: 15),
              ),
              subtitle: Text(
                '\$${costo.monto?.toStringAsFixed(2) ?? '0.00'}',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              if (costo.id != null) {
                await ref.read(costosProvider.notifier).deleteCosto(costo.id);
              }
              if (mounted) Navigator.pop(context);
            },
            child:
                const Text('Eliminar', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  PANTALLA "MÁS" PREMIUM
// ═══════════════════════════════════════════

class OptimizedMoreScreen extends ConsumerStatefulWidget {
  const OptimizedMoreScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedMoreScreen> createState() =>
      _OptimizedMoreScreenState();
}

class _OptimizedMoreScreenState extends ConsumerState<OptimizedMoreScreen> {
  @override
  Widget build(BuildContext context) {
    final isSuperadmin = ref.watch(isSuperadminProvider);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 24),
              child: Text(
                'Más opciones',
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -1,
                ),
              ),
            ),

            // Gestión
            _buildSectionLabel('GESTIÓN'),
            _buildGroupCard([
              _buildItem('Trabajos', Icons.work_outline_rounded,
                  const Color(0xFF1976D2), const Color(0xFFE3F2FD), () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const OptimizedTrabajosListScreen(
                            showAppBar: true)));
              }),
              _buildItem('Máquinas', Icons.agriculture_outlined,
                  const Color(0xFF388E3C), const Color(0xFFE8F5E9), () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const OptimizedMaquinasListScreen(
                            showAppBar: true)));
              }),
              _buildItem('Personal', Icons.people_outline_rounded,
                  const Color(0xFF7B1FA2), const Color(0xFFF3E5F5), () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PersonalListScreen()));
              }),
              _buildItem('Clientes', Icons.contacts_outlined,
                  const Color(0xFF00838F), const Color(0xFFE0F7FA), () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ClientesListScreen()));
              }),
              _buildItem('Mantenimientos', Icons.build_outlined,
                  const Color(0xFFF57C00), const Color(0xFFFFF3E0), () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const OptimizedMantenimientosScreen()));
              }),
            ]),
            const SizedBox(height: 24),

            if (isSuperadmin) ...[
              _buildSectionLabel('ADMINISTRACIÓN'),
              _buildGroupCard([
                _buildItem('Usuarios', Icons.manage_accounts_outlined,
                    const Color(0xFF00695C), const Color(0xFFE0F2F1), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UsuariosScreen()),
                  );
                }),
              ]),
              const SizedBox(height: 24),
            ],

            // Reportes
            _buildSectionLabel('REPORTES'),
            _buildGroupCard([
              _buildItem('Reportes', Icons.analytics_outlined,
                  const Color(0xFF5C6BC0), const Color(0xFFE8EAF6), () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const OptimizedReportesScreen()));
              }),
            ]),
            const SizedBox(height: 24),

            // Cuenta
            _buildSectionLabel('CUENTA'),
            _buildGroupCard([
              _buildItem('Mi Perfil', Icons.person_outline_rounded,
                  const Color(0xFF546E7A), const Color(0xFFECEFF1), () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const OptimizedProfileScreen()));
              }),
            ]),
            const SizedBox(height: 24),

            // Cerrar sesión
            _buildLogoutButton(context),
            const SizedBox(height: 20),

            // Versión
            Center(
              child: Text(
                'GesAgro v1.0.0',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.textTertiary,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildGroupCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          return Column(
            children: [
              items[i],
              if (i < items.length - 1)
                Divider(height: 1, indent: 64, color: AppTheme.borderLight),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildItem(String title, IconData icon, Color iconColor, Color bgColor,
      VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppTheme.textHint, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.shadowSm,
      ),
      child: InkWell(
        onTap: () => _handleLogout(context),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: AppTheme.error, size: 20),
              const SizedBox(width: 10),
              Text(
                'Cerrar sesión',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
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

// ═══════════════════════════════════════════
//  PANTALLA DE PERFIL PREMIUM
// ═══════════════════════════════════════════

class OptimizedProfileScreen extends ConsumerWidget {
  const OptimizedProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userName = user?['nombre'] ?? user?['username'] ?? 'Usuario';
    final userEmail = user?['email'] ?? '';

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  size: 20, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppTheme.primaryGradient),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userName,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (userEmail.isNotEmpty)
                      Text(
                        userEmail,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppTheme.shadowSm,
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.construction_rounded,
                            size: 48, color: AppTheme.textHint),
                        const SizedBox(height: 12),
                        Text(
                          'Perfil en desarrollo',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pronto podrás editar tu información personal aquí',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
