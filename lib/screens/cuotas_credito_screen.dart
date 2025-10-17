import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/credito.dart';
import '../services/credito_service.dart';
import 'forms/forms_screens.dart';

/// Pantalla para gestionar cuotas de un crédito específico
class CuotasCreditoScreen extends ConsumerStatefulWidget {
  final Credito credito;

  const CuotasCreditoScreen({
    Key? key,
    required this.credito,
  }) : super(key: key);

  @override
  ConsumerState<CuotasCreditoScreen> createState() => _CuotasCreditoScreenState();
}

class _CuotasCreditoScreenState extends ConsumerState<CuotasCreditoScreen> {
  List<CuotaCredito> _cuotas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCuotas();
  }

  Future<void> _loadCuotas() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final cuotas = await CuotaCreditoService.getCuotasByCredito(widget.credito.id);
      setState(() {
        _cuotas = cuotas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cuotas - ${widget.credito.entidad}'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCuotas,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCuotaForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCuotas,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_cuotas.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay cuotas registradas'),
            SizedBox(height: 8),
            Text('Toca el botón + para agregar una nueva cuota'),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Resumen del crédito
        _buildCreditoSummary(),
        const Divider(),
        // Lista de cuotas
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _cuotas.length,
            itemBuilder: (context, index) {
              final cuota = _cuotas[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getEstadoColor(cuota.estado).withOpacity(0.1),
                    child: Icon(
                      _getEstadoIcon(cuota.estado),
                      color: _getEstadoColor(cuota.estado),
                    ),
                  ),
                  title: Text('Cuota #${cuota.numeroCuota}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vencimiento: ${_formatDate(cuota.fechaVencimiento)}'),
                      Text('Monto: \$${cuota.montoTotal.toStringAsFixed(2)}'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Chip(
                        label: Text(cuota.estado),
                        backgroundColor: _getEstadoColor(cuota.estado),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${cuota.id}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  onTap: () => _showCuotaDetails(context, cuota),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCreditoSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen del Crédito',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildSummaryRow('Entidad:', widget.credito.entidad),
              _buildSummaryRow('Monto Otorgado:', '\$${widget.credito.montoOtorgado.toStringAsFixed(2)}'),
              _buildSummaryRow('Tasa de Interés:', '${widget.credito.tasaInteresAnual.toStringAsFixed(2)}%'),
              _buildSummaryRow('Plazo:', '${widget.credito.plazoMeses} meses'),
              _buildSummaryRow('Estado:', widget.credito.estado),
              const SizedBox(height: 8),
              Text(
                'Total de Cuotas: ${_cuotas.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Pagada':
        return Colors.green;
      case 'Pendiente':
        return Colors.orange;
      case 'Vencida':
        return Colors.red;
      case 'Cancelada':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'Pagada':
        return Icons.check_circle;
      case 'Pendiente':
        return Icons.schedule;
      case 'Vencida':
        return Icons.warning;
      case 'Cancelada':
        return Icons.cancel;
      default:
        return Icons.payment;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCuotaForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CuotaFormScreen(credito: widget.credito),
      ),
    );
  }

  void _showCuotaDetails(BuildContext context, CuotaCredito cuota) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cuota #${cuota.numeroCuota}'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('ID:', cuota.id.toString()),
              _buildDetailRow('Número de Cuota:', cuota.numeroCuota.toString()),
              _buildDetailRow('Fecha de Vencimiento:', _formatDate(cuota.fechaVencimiento)),
              _buildDetailRow('Monto Total:', '\$${cuota.montoTotal.toStringAsFixed(2)}'),
              _buildDetailRow('Estado:', cuota.estado),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CuotaFormScreen(
                    cuota: cuota,
                    credito: widget.credito,
                  ),
                ),
              );
            },
            child: const Text('Editar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
