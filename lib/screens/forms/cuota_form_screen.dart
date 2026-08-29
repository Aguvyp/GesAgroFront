import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/optimized_widgets.dart';
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';
import '../../models/credito.dart';
import '../../services/credito_service.dart';

/// Pantalla completa para crear/editar cuotas de crédito
class CuotaFormScreen extends ConsumerStatefulWidget {
  final CuotaCredito? cuota;
  final Credito credito;

  const CuotaFormScreen({
    Key? key,
    this.cuota,
    required this.credito,
  }) : super(key: key);

  @override
  ConsumerState<CuotaFormScreen> createState() => _CuotaFormScreenState();
}

class _CuotaFormScreenState extends ConsumerState<CuotaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numeroController;
  late TextEditingController _montoController;

  DateTime? _fechaVencimiento;
  String? _estadoSeleccionado;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _numeroController =
        TextEditingController(text: widget.cuota?.numeroCuota.toString() ?? '');
    _montoController =
        TextEditingController(text: widget.cuota?.montoTotal.toString() ?? '');

    _fechaVencimiento = widget.cuota?.fechaVencimiento ??
        DateTime.now().add(const Duration(days: 30));
    _estadoSeleccionado = widget.cuota?.estado ?? 'Pendiente';
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.cuota != null;

    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Editar Cuota' : 'Nueva Cuota',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del crédito
              OptimizedCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Crédito',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Entidad:', widget.credito.entidad),
                    _buildInfoRow('Monto:',
                        '\$${widget.credito.montoOtorgado.toStringAsFixed(2)}'),
                    _buildInfoRow('Tasa:',
                        '${widget.credito.tasaInteresAnual.toStringAsFixed(2)}%'),
                    _buildInfoRow(
                        'Plazo:', '${widget.credito.plazoMeses} meses'),
                    _buildInfoRow('Estado:', widget.credito.estado),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Información de la cuota
              OptimizedCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de la Cuota',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    OptimizedTextField(
                      controller: _numeroController,
                      label: 'Número de Cuota',
                      hint: 'Ingrese el número de cuota',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.numbers),
                      validator: (value) =>
                          Validators.validateRequired(value, 'Número de cuota'),
                    ),
                    const SizedBox(height: 24),
                    OptimizedTextField(
                      controller: _montoController,
                      label: 'Monto Total',
                      hint: 'Ingrese el monto de la cuota',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.attach_money),
                      validator: (value) =>
                          Validators.validateRequired(value, 'Monto'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Fecha y estado
              OptimizedCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha y Estado',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha de Vencimiento',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Seleccione la fecha de vencimiento',
                            suffixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text: _fechaVencimiento != null
                                ? '${_fechaVencimiento!.day}/${_fechaVencimiento!.month}/${_fechaVencimiento!.year}'
                                : 'Seleccionar fecha',
                          ),
                          onTap: _selectFechaVencimiento,
                          validator: (value) {
                            if (_fechaVencimiento == null) {
                              return 'Seleccione una fecha de vencimiento';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                      value: _estadoSeleccionado,
                      items: const [
                        DropdownMenuItem(
                            value: 'Pendiente', child: Text('Pendiente')),
                        DropdownMenuItem(
                            value: 'Pagada', child: Text('Pagada')),
                        DropdownMenuItem(
                            value: 'Vencida', child: Text('Vencida')),
                        DropdownMenuItem(
                            value: 'Cancelada', child: Text('Cancelada')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _estadoSeleccionado = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Seleccione un estado';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancelar',
                      onPressed: () => Navigator.pop(context),
                      isOutlined: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: isEditing ? 'Actualizar' : 'Crear',
                      onPressed: _isSaving ? null : _saveCuota,
                      isLoading: _isSaving,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
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

  Future<void> _selectFechaVencimiento() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _fechaVencimiento ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _fechaVencimiento = date;
      });
    }
  }

  Future<void> _saveCuota() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final cuota = CuotaCredito(
        id: widget.cuota?.id ?? 0,
        idCredito: widget.credito.id,
        numeroCuota: int.parse(_numeroController.text),
        fechaVencimiento: _fechaVencimiento!,
        montoTotal: double.parse(_montoController.text),
        estado: _estadoSeleccionado!,
      );

      if (widget.cuota != null) {
        // Actualizar cuota existente
        await CuotaCreditoService.updateCuota(cuota);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuota actualizada exitosamente')),
        );
      } else {
        // Crear nueva cuota
        await CuotaCreditoService.createCuota(cuota);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuota creada exitosamente')),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
}
