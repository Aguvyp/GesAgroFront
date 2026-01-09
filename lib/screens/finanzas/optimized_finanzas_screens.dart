import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../models/credito.dart';
import '../../models/movimiento.dart';
import '../forms/movimiento_form_screen.dart';
import '../forms/factura_form_screen.dart';
import '../forms/credito_form_screen.dart';

/// Pantalla principal de finanzas con menú
class OptimizedFinanzasMainScreen extends ConsumerStatefulWidget {
  const OptimizedFinanzasMainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedFinanzasMainScreen> createState() => _OptimizedFinanzasMainScreenState();
}

class _OptimizedFinanzasMainScreenState extends ConsumerState<OptimizedFinanzasMainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(movimientosProvider.notifier).loadMovimientos();
      ref.read(creditosProvider.notifier).loadCreditos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Dashboard Financiero'),
        elevation: 0,
        backgroundColor: const Color(0xFF7E57C2),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(movimientosProvider.notifier).loadMovimientos();
              ref.read(creditosProvider.notifier).loadCreditos();
            },
          ),
        ],
      ),
      drawer: _buildFinanzasDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botones de acceso rápido
            _buildQuickAccessButtons(),
            const SizedBox(height: 24),
            
            // Movimientos recientes
            _buildMovimientosSection(),
            const SizedBox(height: 24),
            
            // Créditos con próximos vencimientos
            _buildCreditosSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanzasDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7E57C2), Color(0xFFB39DDB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 40),
                SizedBox(height: 8),
                Text('Finanzas', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text('Dashboard y gestión', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_customize_rounded),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Facturas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OptimizedFacturasScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Créditos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OptimizedCreditosScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Movimientos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OptimizedMovimientosScreen()));
            },
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
            'Facturas',
            Icons.description,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OptimizedFacturasScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickAccessButton(
            'Créditos',
            Icons.credit_card,
            Colors.green,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OptimizedCreditosScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickAccessButton(
            'Movimientos',
            Icons.swap_horiz,
            Colors.orange,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OptimizedMovimientosScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovimientosSection() {
    final movimientosState = ref.watch(movimientosProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.swap_horiz, color: Color(0xFF7E57C2)),
                const SizedBox(width: 8),
                const Text(
                  'Movimientos Recientes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OptimizedMovimientosScreen()),
                  ),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMovimientosList(movimientosState),
          ],
        ),
      ),
    );
  }

  Widget _buildMovimientosList(BaseState state) {
    if (state is LoadingState || state is InitialState) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is ErrorState) {
      return Center(child: Text('Error: ${state.message}'));
    }
    
    final movimientos = (state as LoadedState<List<Movimiento>>).data;
    if (movimientos.isEmpty) {
      return const Center(child: Text('No hay movimientos'));
    }
    
    // Mostrar solo los últimos 5 movimientos
    final recentMovimientos = movimientos.take(5).toList();
    
    return Column(
      children: recentMovimientos.map((movimiento) {
        return ListTile(
          leading: Icon(
            movimiento.esCobro ? Icons.call_received : Icons.call_made,
            color: movimiento.esCobro ? Colors.green : Colors.red,
          ),
          title: Text(
            movimiento.descripcion ?? 'Movimiento',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Text(
            '${movimiento.tipoMovimiento}${movimiento.fecha != null ? ' • ${movimiento.fecha!.day}/${movimiento.fecha!.month}/${movimiento.fecha!.year}' : ''}',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 80),
            child: Text(
              '${movimiento.esCobro ? '+' : '-'}${movimiento.monto.toStringAsFixed(2)}',
              style: TextStyle(
                color: movimiento.esCobro ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          dense: true,
        );
      }).toList(),
    );
  }

  Widget _buildCreditosSection() {
    final creditosState = ref.watch(creditosProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.credit_card, color: Color(0xFF7E57C2)),
                const SizedBox(width: 8),
                const Text(
                  'Créditos Activos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OptimizedCreditosScreen()),
                  ),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCreditosList(creditosState),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditosList(BaseState state) {
    if (state is LoadingState || state is InitialState) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is ErrorState) {
      return Center(child: Text('Error: ${state.message}'));
    }
    
    final creditos = (state as LoadedState<List<Credito>>).data;
    final creditosActivos = creditos.where((c) => c.estaActivo).toList();
    
    if (creditosActivos.isEmpty) {
      return const Center(child: Text('No hay créditos activos'));
    }
    
    // Mostrar solo los primeros 5 créditos activos
    final recentCreditos = creditosActivos.take(5).toList();
    
    return Column(
      children: recentCreditos.map((credito) {
        final fechaVencimiento = credito.fechaDesembolso.add(Duration(days: credito.plazoMeses * 30));
        final diasRestantes = fechaVencimiento.difference(DateTime.now()).inDays;
        
        return ListTile(
          leading: Icon(
            Icons.credit_card,
            color: diasRestantes <= 30 ? Colors.orange : Colors.green,
          ),
          title: Text(
            credito.entidad,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          subtitle: Text(
            'Vence: ${fechaVencimiento.day}/${fechaVencimiento.month}/${fechaVencimiento.year} • ${diasRestantes > 0 ? '$diasRestantes días' : 'Vencido'}',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 80),
            child: Text(
              '\$${credito.montoOtorgado.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          dense: true,
        );
      }).toList(),
    );
  }
}

/// Pantalla de facturas
class OptimizedFacturasScreen extends ConsumerStatefulWidget {
  const OptimizedFacturasScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedFacturasScreen> createState() => _OptimizedFacturasScreenState();
}

class _OptimizedFacturasScreenState extends ConsumerState<OptimizedFacturasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(facturasProvider.notifier).loadFacturas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final facturasState = ref.watch(facturasProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facturas'),
        elevation: 0,
        backgroundColor: const Color(0xFF7E57C2), // Color lila de finanzas
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(facturasProvider.notifier).loadFacturas();
            },
          ),
        ],
      ),
      body: _buildFacturasList(facturasState),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFacturaForm(context);
        },
        backgroundColor: const Color(0xFF7E57C2),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFacturasList(BaseState state) {
    if (state is LoadingState) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is ErrorState) {
      return Center(child: Text(state.message));
    }
    
    final facturas = (state as LoadedState<List<dynamic>>).data;
    if (facturas.isEmpty) {
      return const Center(child: Text('No hay facturas'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: facturas.length,
      itemBuilder: (context, index) {
        final factura = facturas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              child: const Icon(Icons.description, color: Colors.blue),
            ),
            title: Text('Factura #${factura['numero'] ?? 'N/A'}'),
            subtitle: Text('Cliente: ${factura['cliente'] ?? 'N/A'}'),
            trailing: Text('\$${factura['total']?.toStringAsFixed(2) ?? '0.00'}'),
            onTap: () {
              // TODO: Navegar a detalles de la factura
            },
          ),
        );
      },
    );
  }

  void _showFacturaForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FacturaFormScreen(),
      ),
    ).then((_) => ref.read(facturasProvider.notifier).loadFacturas());
  }
}

/// Pantalla de créditos
class OptimizedCreditosScreen extends ConsumerStatefulWidget {
  const OptimizedCreditosScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedCreditosScreen> createState() => _OptimizedCreditosScreenState();
}

class _OptimizedCreditosScreenState extends ConsumerState<OptimizedCreditosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(creditosProvider.notifier).loadCreditos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final creditosState = ref.watch(creditosProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créditos'),
        elevation: 0,
        backgroundColor: const Color(0xFF7E57C2), // Color lila de finanzas
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(creditosProvider.notifier).loadCreditos();
            },
          ),
        ],
      ),
      body: _buildCreditosList(creditosState),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreditoForm(context);
        },
        backgroundColor: const Color(0xFF7E57C2),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCreditosList(BaseState state) {
    if (state is LoadingState) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is ErrorState) {
      return Center(child: Text(state.message));
    }
    
    final creditos = (state as LoadedState<List<Credito>>).data;
    if (creditos.isEmpty) {
      return const Center(child: Text('No hay créditos'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: creditos.length,
      itemBuilder: (context, index) {
        final credito = creditos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withValues(alpha: 0.1),
              child: const Icon(Icons.credit_card, color: Colors.green),
            ),
            title: Text(credito.entidad),
            subtitle: Text('Monto: \$${credito.montoOtorgado.toStringAsFixed(2)}'),
            trailing: Chip(
              label: Text(credito.estado),
              backgroundColor: _getEstadoColor(credito.estado),
            ),
            onTap: () {
              // TODO: Navegar a detalles del crédito
            },
          ),
        );
      },
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Activo':
        return Colors.green;
      case 'Finalizado':
        return Colors.blue;
      case 'Cancelado':
        return Colors.red;
      case 'Suspendido':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showCreditoForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreditoFormScreen(),
      ),
    ).then((_) => ref.read(creditosProvider.notifier).loadCreditos());
  }
}

/// Pantalla de movimientos
class OptimizedMovimientosScreen extends ConsumerStatefulWidget {
  const OptimizedMovimientosScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedMovimientosScreen> createState() => _OptimizedMovimientosScreenState();
}

class _OptimizedMovimientosScreenState extends ConsumerState<OptimizedMovimientosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(movimientosProvider.notifier).loadMovimientos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(movimientosProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimientos'),
        elevation: 0,
        backgroundColor: const Color(0xFF7E57C2), // Color lila de finanzas
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(movimientosProvider.notifier).loadMovimientos(),
          ),
        ],
      ),
      body: _buildList(state),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        backgroundColor: const Color(0xFF7E57C2),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(BaseState state) {
    if (state is LoadingState || state is InitialState) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is ErrorState) {
      return Center(child: Text(state.message));
    }
    final items = (state as LoadedState<List<Movimiento>>).data;
    if (items.isEmpty) {
      return const Center(child: Text('Sin movimientos'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemBuilder: (_, i) {
        final m = items[i];
        return ListTile(
          leading: Icon(m.monto >= 0 ? Icons.call_received : Icons.call_made, color: Theme.of(context).primaryColor),
          title: Text(m.descripcion ?? 'Movimiento'),
          subtitle: Text('${m.tipoMovimiento}${m.fecha != null ? ' • ${m.fecha!.day}/${m.fecha!.month}/${m.fecha!.year}' : ''}'),
          trailing: Text(m.monto.toStringAsFixed(2)),
          onTap: () => _showForm(context, movimiento: m),
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: items.length,
    );
  }

  void _showForm(BuildContext context, {Movimiento? movimiento}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovimientoFormScreen(movimiento: movimiento),
      ),
    ).then((_) => ref.read(movimientosProvider.notifier).loadMovimientos());
  }
}