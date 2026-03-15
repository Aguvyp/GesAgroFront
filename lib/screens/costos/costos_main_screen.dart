import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../models/costo.dart';
import '../../themes/app_theme.dart';
import '../forms/costo_form_screen.dart';
import 'costos_list_screen.dart';
import 'costos_resumen_screen.dart';
import 'costos_categoria_screen.dart';

/// Pantalla principal de finanzas
class CostosMainScreen extends ConsumerStatefulWidget {
  final bool showAppBar;
  const CostosMainScreen({Key? key, this.showAppBar = false}) : super(key: key);

  @override
  ConsumerState<CostosMainScreen> createState() => _CostosMainScreenState();
}

class _CostosMainScreenState extends ConsumerState<CostosMainScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(costosProvider.notifier).loadCostos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ──
            if (widget.showAppBar)
              _buildBackHeader()
            else
              _buildInlineHeader(),

            // ── Tab bar ──
            _buildTabBar(),

            // ── Content ──
            Expanded(child: _getBody()),
          ],
        ),
      ),
      floatingActionButton: _selectedTab == 0 || _selectedTab == 1
          ? FloatingActionButton(
              onPressed: () => _navigateToFormulario(),
              elevation: 2,
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
    );
  }

  Widget _buildBackHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Finanzas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Finanzas',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Resumen', 'Movimientos', 'Análisis', 'Categorías'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: tabs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final isActive = _selectedTab == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primary : AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive
                        ? AppTheme.primary
                        : AppTheme.border,
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _getBody() {
    switch (_selectedTab) {
      case 0:
        return _buildDashboard();
      case 1:
        return const CostosListScreen();
      case 2:
        return const CostosResumenScreen();
      case 3:
        return const CostosCategoriaScreen();
      default:
        return _buildDashboard();
    }
  }

  // ════════════════════════════════════════════════
  //  DASHBOARD TAB
  // ════════════════════════════════════════════════

  Widget _buildDashboard() {
    final costosState = ref.watch(costosProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(costosProvider.notifier).loadCostos();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // ── Quick actions ──
          _buildQuickActions(),
          const SizedBox(height: 20),

          // ── Balance card ──
          _buildBalanceCard(costosState),
          const SizedBox(height: 20),

          // ── Recent movements ──
          _buildRecentMovements(costosState),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionBtn(
            'Nuevo Gasto',
            Icons.arrow_upward_rounded,
            AppTheme.error,
            () => _navigateToFormulario(esCobro: false),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickActionBtn(
            'Nuevo Cobro',
            Icons.arrow_downward_rounded,
            const Color(0xFF16A34A),
            () => _navigateToFormulario(esCobro: true),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionBtn(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BaseState state) {
    if (state is! LoadedState<List<Costo>>) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final costos = state.data;
    final gastos = costos.where((c) => !c.esCobro).toList();
    final cobros = costos.where((c) => c.esCobro).toList();
    final totalGastos = gastos.fold(0.0, (sum, c) => sum + c.monto);
    final totalCobros = cobros.fold(0.0, (sum, c) => sum + c.monto);
    final balance = totalCobros - totalGastos;
    final isPositive = balance >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Balance general',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${isPositive ? '+' : ''}\$${balance.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isPositive ? const Color(0xFF16A34A) : AppTheme.error,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBalanceMetric(
                  'Cobros',
                  '+\$${totalCobros.toStringAsFixed(0)}',
                  const Color(0xFF16A34A),
                  Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildBalanceMetric(
                  'Gastos',
                  '-\$${totalGastos.toStringAsFixed(0)}',
                  AppTheme.error,
                  Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceMetric(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMovements(BaseState state) {
    if (state is LoadingState || state is InitialState) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (state is ErrorState) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 36, color: AppTheme.textHint),
            const SizedBox(height: 10),
            Text(
              'Error: ${state.message}',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => ref.read(costosProvider.notifier).loadCostos(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final costos = (state as LoadedState<List<Costo>>).data;
    if (costos.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_outlined,
                  size: 32, color: AppTheme.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin movimientos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Registrá tu primer gasto o cobro',
              style: TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    final sorted = List<Costo>.from(costos)
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    final recent = sorted.take(8).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                const Text(
                  'Movimientos recientes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _selectedTab = 1),
                  child: const Text('Ver todos',
                      style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
          ...recent.map((costo) => _buildMovementRow(costo)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMovementRow(Costo costo) {
    final isCobro = costo.esCobro;
    final color = isCobro ? const Color(0xFF16A34A) : AppTheme.error;
    final icon = isCobro
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          // Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  costo.descripcion ?? 'Sin descripción',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (costo.categoria != null)
                  Text(
                    costo.categoria!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textHint,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Amount + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCobro ? '+' : '-'}\$${costo.monto.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (costo.pagado ? const Color(0xFF16A34A) : AppTheme.warning)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  costo.pagado ? 'Pagado' : 'Pendiente',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: costo.pagado
                        ? const Color(0xFF16A34A)
                        : AppTheme.warning,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToFormulario({bool? esCobro}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CostoFormScreen(esCobro: esCobro),
      ),
    ).then((_) {
      ref.read(costosProvider.notifier).loadCostos();
    });
  }
}
