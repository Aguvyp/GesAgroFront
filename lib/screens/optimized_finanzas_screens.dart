import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/optimized_providers.dart';
// import 'optimized_main_screen_new.dart';
import '../models/mantenimiento.dart';
import 'forms/mantenimiento_form_screen.dart';
import '../models/credito.dart';
import '../models/movimiento.dart';
import 'forms/movimiento_form_screen.dart';
import 'package:intl/intl.dart';

/// Pantalla principal de finanzas con menú
class OptimizedFinanzasMainScreen extends ConsumerStatefulWidget {
  const OptimizedFinanzasMainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedFinanzasMainScreen> createState() => _OptimizedFinanzasMainScreenState();
}

class _OptimizedFinanzasMainScreenState extends ConsumerState<OptimizedFinanzasMainScreen> {
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
      appBar: AppBar(
        title: const Text('Dashboard Financiero'),
        elevation: 0,
        backgroundColor: const Color(0xFF7E57C2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Movimientos Recientes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF7E57C2)),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OptimizedMovimientosScreen()),
                  ),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
          title: Text(movimiento.descripcion ?? 'Movimiento'),
          subtitle: Text(
            '${movimiento.tipoMovimiento}${movimiento.fecha != null ? ' • ${movimiento.fecha!.day}/${movimiento.fecha!.month}/${movimiento.fecha!.year}' : ''}'
          ),
          trailing: Text(
            '${movimiento.esCobro ? '+' : '-'}${movimiento.monto.toStringAsFixed(2)}',
            style: TextStyle(
              color: movimiento.esCobro ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Créditos Activos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF7E57C2)),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OptimizedCreditosScreen()),
                  ),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
          title: Text(credito.entidad),
          subtitle: Text(
            'Vence: ${fechaVencimiento.day}/${fechaVencimiento.month}/${fechaVencimiento.year} • ${diasRestantes > 0 ? '$diasRestantes días' : 'Vencido'}'
          ),
          trailing: Text(
            '\$${credito.montoOtorgado.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
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
        backgroundColor: Colors.transparent,
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
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFacturasList(BaseState state) {
    if (state is LoadingState) {
      return const Center(child: CircularProgressIndicator());
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
              onPressed: () => ref.read(facturasProvider.notifier).loadFacturas(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    
    if (state is LoadedState<List<dynamic>>) {
      final facturas = state.data;
      
      if (facturas.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No hay facturas registradas'),
              SizedBox(height: 8),
              Text('Toca el botón + para agregar una nueva factura'),
            ],
          ),
        );
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
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: const Icon(Icons.description, color: Colors.blue),
              ),
              title: Text('Factura #${factura.numero ?? 'N/A'}'),
              subtitle: Text('Cliente: ${factura.cliente ?? 'N/A'}'),
              trailing: Text('\$${factura.total?.toStringAsFixed(2) ?? '0.00'}'),
            ),
          );
        },
      );
    }
    
    return const Center(child: Text('Estado no reconocido'));
  }

  void _showFacturaForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Factura'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Número de Factura',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El número es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Emisión',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        // TODO: Actualizar campo de fecha
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Vencimiento',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        // TODO: Actualizar campo de fecha
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Subtotal',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El subtotal es requerido';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Ingrese un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Impuestos',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Monto Total',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El monto total es requerido';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Ingrese un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Borrador', child: Text('Borrador')),
                      DropdownMenuItem(value: 'Enviada', child: Text('Enviada')),
                      DropdownMenuItem(value: 'Pagada', child: Text('Pagada')),
                      DropdownMenuItem(value: 'Vencida', child: Text('Vencida')),
                    ],
                    onChanged: (value) {
                      // TODO: Implementar selector de estado
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar creación de factura
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Factura creada exitosamente')),
              );
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
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
        backgroundColor: Colors.transparent,
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
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCreditosList(BaseState state) {
    if (state is LoadingState) {
      return const Center(child: CircularProgressIndicator());
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
              onPressed: () => ref.read(creditosProvider.notifier).loadCreditos(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    
    if (state is LoadedState<List<dynamic>>) {
      final creditos = state.data;
      
      if (creditos.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.credit_card, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No hay créditos registrados'),
              SizedBox(height: 8),
              Text('Toca el botón + para agregar un nuevo crédito'),
            ],
          ),
        );
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
                backgroundColor: Colors.green.withOpacity(0.1),
                child: const Icon(Icons.credit_card, color: Colors.green),
              ),
              title: Text('Cliente: ${credito.cliente ?? 'N/A'}'),
              subtitle: Text('Monto: \$${credito.monto?.toStringAsFixed(2) ?? '0.00'}'),
              trailing: Chip(
                label: Text(credito.estado ?? 'Pendiente'),
                backgroundColor: _getEstadoColor(credito.estado),
              ),
            ),
          );
        },
      );
    }
    
    return const Center(child: Text('Estado no reconocido'));
  }

  Color _getEstadoColor(String? estado) {
    switch (estado) {
      case 'Pagado':
        return Colors.green;
      case 'Pendiente':
        return Colors.orange;
      case 'Vencido':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCreditoForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Crédito'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Form(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Cliente ID',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El cliente es requerido';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Ingrese un ID válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El monto es requerido';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Ingrese un número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Inicio',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        // TODO: Actualizar campo de fecha
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Vencimiento',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (date != null) {
                        // TODO: Actualizar campo de fecha
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Tasa de Interés (%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                      DropdownMenuItem(value: 'Pagado', child: Text('Pagado')),
                      DropdownMenuItem(value: 'Vencido', child: Text('Vencido')),
                      DropdownMenuItem(value: 'Cancelado', child: Text('Cancelado')),
                    ],
                    onChanged: (value) {
                      // TODO: Implementar selector de estado
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar creación de crédito
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Crédito creado exitosamente')),
              );
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
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
        backgroundColor: Colors.transparent,
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
    if (items.isEmpty) return const Center(child: Text('Sin movimientos'));
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

/// Pantalla de mantenimientos
class OptimizedMantenimientosScreen extends ConsumerStatefulWidget {
  const OptimizedMantenimientosScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedMantenimientosScreen> createState() => _OptimizedMantenimientosScreenState();
}

class _OptimizedMantenimientosScreenState extends ConsumerState<OptimizedMantenimientosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mantenimientosProvider.notifier).loadMantenimientos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mantState = ref.watch(mantenimientosProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantenimientos'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(mantenimientosProvider.notifier).loadMantenimientos(),
          ),
        ],
      ),
      body: _buildList(mantState),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
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
    final items = (state as LoadedState<List<Mantenimiento>>).data;
    if (items.isEmpty) {
      return const Center(child: Text('Sin mantenimientos'));
    }
    final dateFmt = DateFormat('dd/MM/yyyy');
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemBuilder: (_, i) {
        final m = items[i];
        return ListTile(
          leading: Icon(
            m.esPreventivo ? Icons.schedule_rounded : m.esCorrectivo ? Icons.build_rounded : Icons.analytics_rounded,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(m.descripcion),
          subtitle: Text('Máquina: ${m.maquinaId} • ${m.tipo} • ${dateFmt.format(m.fechaProgramada)}'),
          trailing: Text(m.estado),
          onTap: () => _showForm(context, mantenimiento: m),
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: items.length,
    );
  }

  void _showForm(BuildContext context, {Mantenimiento? mantenimiento}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MantenimientoFormScreen(mantenimiento: mantenimiento),
      ),
    ).then((_) => ref.read(mantenimientosProvider.notifier).loadMantenimientos());
  }
}

/// Pantalla de pagos
class OptimizedPagosScreen extends ConsumerStatefulWidget {
  const OptimizedPagosScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedPagosScreen> createState() => _OptimizedPagosScreenState();
}

class _OptimizedPagosScreenState extends ConsumerState<OptimizedPagosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagos'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Pantalla de Pagos',
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

/// Pantalla de reportes
class OptimizedReportesScreen extends ConsumerStatefulWidget {
  const OptimizedReportesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedReportesScreen> createState() => _OptimizedReportesScreenState();
}

class _OptimizedReportesScreenState extends ConsumerState<OptimizedReportesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Pantalla de Reportes',
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

/// Pantalla de resumen financiero
class OptimizedResumenFinancieroScreen extends ConsumerStatefulWidget {
  const OptimizedResumenFinancieroScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedResumenFinancieroScreen> createState() => _OptimizedResumenFinancieroScreenState();
}

class _OptimizedResumenFinancieroScreenState extends ConsumerState<OptimizedResumenFinancieroScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen Financiero'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Resumen Financiero',
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
