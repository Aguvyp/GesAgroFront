import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/optimized_providers.dart';
import 'optimized_main_screen_new.dart';

/// Pantalla principal de finanzas con menú
class OptimizedFinanzasMainScreen extends ConsumerStatefulWidget {
  const OptimizedFinanzasMainScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedFinanzasMainScreen> createState() => _OptimizedFinanzasMainScreenState();
}

class _OptimizedFinanzasMainScreenState extends ConsumerState<OptimizedFinanzasMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildFinanzaCard(
              context,
              'Costos',
              Icons.receipt_long,
              Colors.red,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OptimizedCostosScreen()),
              ),
            ),
            _buildFinanzaCard(
              context,
              'Facturas',
              Icons.description,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OptimizedFacturasScreen()),
              ),
            ),
            _buildFinanzaCard(
              context,
              'Créditos',
              Icons.credit_card,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OptimizedCreditosScreen()),
              ),
            ),
            _buildFinanzaCard(
              context,
              'Pagos',
              Icons.payment,
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OptimizedPagosScreen()),
              ),
            ),
            _buildFinanzaCard(
              context,
              'Reportes',
              Icons.analytics,
              Colors.purple,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OptimizedReportesScreen()),
              ),
            ),
            _buildFinanzaCard(
              context,
              'Resumen',
              Icons.dashboard,
              Colors.teal,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OptimizedResumenFinancieroScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanzaCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
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
