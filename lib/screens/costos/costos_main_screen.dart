import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../models/costo.dart';
import '../forms/costo_form_screen.dart';
import 'costos_list_screen.dart';
import 'costos_resumen_screen.dart';
import 'costos_categoria_screen.dart';

/// Pantalla principal de costos con menú
class CostosMainScreen extends ConsumerStatefulWidget {
  final bool showAppBar;
  
  const CostosMainScreen({Key? key, this.showAppBar = false}) : super(key: key);

  @override
  ConsumerState<CostosMainScreen> createState() => _CostosMainScreenState();
}

class _CostosMainScreenState extends ConsumerState<CostosMainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(costosProvider.notifier).loadCostos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = _getBody();
    
    if (widget.showAppBar) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(_getAppBarTitle(_selectedIndex)),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1C1C1E),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: body,
        floatingActionButton: _selectedIndex == 1 || _selectedIndex == 0
            ? FloatingActionButton(
                onPressed: () => _navigateToFormulario(),
                backgroundColor: const Color(0xFF2E7D32),
                child: const Icon(Icons.add),
              )
            : null,
      );
    }
    
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
                title: Text(
                  _getAppBarTitle(_selectedIndex),
                  style: const TextStyle(
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
          SliverToBoxAdapter(
            child: body,
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1 || _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _navigateToFormulario(),
              backgroundColor: const Color(0xFF2E7D32),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'finanzas';
      case 1:
        return 'Movimientos';
      case 2:
        return 'Resumen Gastos/Cobros';
      case 3:
        return 'Resumen por Categoría';
      default:
        return 'Costos';
    }
  }

  Widget _getBody() {
    switch (_selectedIndex) {
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


  Widget _buildDashboard() {
    final costosState = ref.watch(costosProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botones de navegación de finanzas (arriba, más pequeños)
          _buildNavigationButtons(),
          const SizedBox(height: 16),
          
          // Accesos rápidos (más pequeños)
          _buildQuickAccessButtons(),
          const SizedBox(height: 24),
          
          // Resumen rápido
          _buildResumenRapido(costosState),
          const SizedBox(height: 24),
          
          // Movimientos recientes
          _buildMovimientosRecientes(costosState),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildNavButton(
            'Movimientos',
            Icons.list,
            () {
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildNavButton(
            'Resumen',
            Icons.analytics,
            () {
              setState(() {
                _selectedIndex = 2;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildNavButton(
            'Categorías',
            Icons.category,
            () {
              setState(() {
                _selectedIndex = 3;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E7D32),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenRapido(BaseState state) {
    if (state is! LoadedState<List<Costo>>) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final costos = state.data;
    final gastos = costos.where((c) => !c.esCobro).toList();
    final cobros = costos.where((c) => c.esCobro).toList();
    
    final totalGastos = gastos.fold(0.0, (sum, c) => sum + c.monto);
    final totalCobros = cobros.fold(0.0, (sum, c) => sum + c.monto);
    final balance = totalCobros - totalGastos;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen Rápido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildResumenCard(
                    'Gastos',
                    totalGastos,
                    Colors.red,
                    Icons.call_made,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildResumenCard(
                    'Cobros',
                    totalCobros,
                    Colors.green,
                    Icons.call_received,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: balance >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Balance',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '\$${balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickAccessButton(
            'Nuevo Gasto',
            Icons.call_made,
            Colors.red,
            () => _navigateToFormulario(esCobro: false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickAccessButton(
            'Nuevo Cobro',
            Icons.call_received,
            Colors.green,
            () => _navigateToFormulario(esCobro: true),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovimientosRecientes(BaseState state) {
    if (state is LoadingState || state is InitialState) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (state is ErrorState) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(child: Text('Error: ${state.message}')),
        ),
      );
    }

    final costos = (state as LoadedState<List<Costo>>).data;
    if (costos.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'No hay movimientos',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    // Ordenar por fecha (más recientes primero)
    final sortedCostos = List<Costo>.from(costos)
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    final recentCostos = sortedCostos.take(10).toList();

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Movimientos Recientes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  child: const Text('Ver todos'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...recentCostos.map((costo) => _buildMovimientoItem(costo)),
        ],
      ),
    );
  }

  Widget _buildMovimientoItem(Costo costo) {
    final isCobro = costo.esCobro;
    final color = isCobro ? Colors.green : Colors.red;
    final icon = isCobro ? Icons.call_received : Icons.call_made;
    final tipoTexto = isCobro ? 'COBRO' : 'GASTO';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Indicador de tipo (cobro/gasto)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Text(
                  tipoTexto,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Descripción
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  costo.descripcion ?? 'Sin descripción',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (costo.categoria != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    costo.categoria!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Importe
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCobro ? '+' : '-'}\$${costo.monto.toStringAsFixed(2)}',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: costo.pagado 
                    ? Colors.green.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  costo.pagado ? 'Pagado' : 'Pendiente',
                  style: TextStyle(
                    fontSize: 10,
                    color: costo.pagado ? Colors.green[700] : Colors.orange[700],
                    fontWeight: FontWeight.w500,
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
