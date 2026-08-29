import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../widgets/optimized_widgets.dart';
import '../../utils/validators.dart';

/// Pantalla completa para crear/editar costos
class CostoFormScreen extends ConsumerStatefulWidget {
  final dynamic costo;
  final bool? esCobro; // Permite pre-seleccionar el tipo

  const CostoFormScreen({Key? key, this.costo, this.esCobro}) : super(key: key);

  @override
  ConsumerState<CostoFormScreen> createState() => _CostoFormScreenState();
}

class _CostoFormScreenState extends ConsumerState<CostoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descripcionController;
  late TextEditingController _montoController;
  late TextEditingController _categoriaController;
  late TextEditingController _destinatarioController;
  late TextEditingController _cobrarAController;
  late TextEditingController _fechaController;
  late TextEditingController _fechaPagoLimiteController;
  late TextEditingController _trabajoIdController;
  DateTime? _fecha;
  DateTime? _fechaPagoLimite;

  String? _formaPagoSeleccionada;
  bool _pagado = false;
  bool _esCobro = false; // false = Gasto, true = Cobro
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Determinar si es cobro o gasto
    if (widget.esCobro != null) {
      _esCobro = widget.esCobro!;
    } else if (widget.costo != null) {
      _esCobro = widget.costo.esCobro ?? false;
    }

    _descripcionController =
        TextEditingController(text: widget.costo?.descripcion ?? '');
    _montoController =
        TextEditingController(text: widget.costo?.monto?.toString() ?? '');
    _categoriaController =
        TextEditingController(text: widget.costo?.categoria ?? '');
    _destinatarioController =
        TextEditingController(text: widget.costo?.destinatario ?? '');
    _cobrarAController =
        TextEditingController(text: widget.costo?.cobrarA ?? '');
    _trabajoIdController =
        TextEditingController(text: widget.costo?.trabajoId?.toString() ?? '');

    if (widget.costo?.fecha != null) {
      _fecha = widget.costo.fecha;
      _fechaController = TextEditingController(
        text: '${_fecha!.day}/${_fecha!.month}/${_fecha!.year}',
      );
    } else {
      _fecha = DateTime.now();
      _fechaController = TextEditingController();
    }

    if (widget.costo?.fechaPagoLimite != null) {
      _fechaPagoLimite = widget.costo.fechaPagoLimite;
      _fechaPagoLimiteController = TextEditingController(
        text:
            '${_fechaPagoLimite!.day}/${_fechaPagoLimite!.month}/${_fechaPagoLimite!.year}',
      );
    } else {
      _fechaPagoLimiteController = TextEditingController();
    }

    _formaPagoSeleccionada = widget.costo?.formaPago ?? 'Efectivo';
    _pagado = widget.costo?.pagado ?? false;
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _montoController.dispose();
    _categoriaController.dispose();
    _destinatarioController.dispose();
    _cobrarAController.dispose();
    _fechaController.dispose();
    _fechaPagoLimiteController.dispose();
    _trabajoIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          widget.costo == null
              ? (_esCobro ? 'Nuevo Cobro' : 'Nuevo Gasto')
              : 'Editar ${_esCobro ? 'Cobro' : 'Gasto'}',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          color: const Color(0xFF1C1C1E),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _submitForm,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Guardar',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de tipo: Gasto o Cobro
              OptimizedCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo de Movimiento',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTipoSelector(
                            'Gasto',
                            Icons.call_made,
                            Colors.red,
                            !_esCobro,
                            () {
                              setState(() {
                                _esCobro = false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTipoSelector(
                            'Cobro',
                            Icons.call_received,
                            Colors.green,
                            _esCobro,
                            () {
                              setState(() {
                                _esCobro = true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Información básica
              OptimizedCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Básica',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                    ),
                    const SizedBox(height: 16),
                    OptimizedTextField(
                      controller: _descripcionController,
                      label: 'Descripción',
                      hint: 'Descripción del costo o gasto',
                      prefixIcon: const Icon(Icons.description, size: 20),
                      validator: (value) =>
                          Validators.validateRequired(value, 'Descripción'),
                    ),
                    const SizedBox(height: 16),
                    OptimizedTextField(
                      controller: _montoController,
                      label: 'Monto',
                      hint: 'Ingresa el monto del costo',
                      prefixIcon: const Icon(Icons.attach_money),
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
                    // Campos condicionales según el tipo
                    if (!_esCobro) ...[
                      // Campos para GASTO
                      OptimizedTextField(
                        controller: _destinatarioController,
                        label: 'Destinatario',
                        hint: 'A quién se le paga',
                        prefixIcon: const Icon(Icons.person),
                        validator: (value) =>
                            Validators.validateRequired(value, 'Destinatario'),
                      ),
                      const SizedBox(height: 16),
                      OptimizedTextField(
                        controller: _categoriaController,
                        label: 'Categoría',
                        hint: 'Ej: Combustible, Semillas, Fertilizantes',
                        prefixIcon: const Icon(Icons.category),
                      ),
                    ] else ...[
                      // Campos para COBRO
                      OptimizedTextField(
                        controller: _cobrarAController,
                        label: 'Cobrar a',
                        hint: 'A quién se le cobra',
                        prefixIcon: const Icon(Icons.person),
                        validator: (value) =>
                            Validators.validateRequired(value, 'Cobrar a'),
                      ),
                      const SizedBox(height: 16),
                      OptimizedTextField(
                        controller: _trabajoIdController,
                        label: 'ID Trabajo (Opcional)',
                        hint: 'ID del trabajo relacionado',
                        prefixIcon: const Icon(Icons.work),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Información de pago
              OptimizedCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información de Pago',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Forma de Pago',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.payment),
                      ),
                      value: _formaPagoSeleccionada,
                      items: const [
                        DropdownMenuItem(
                            value: 'Efectivo', child: Text('Efectivo')),
                        DropdownMenuItem(
                            value: 'Transferencia',
                            child: Text('Transferencia')),
                        DropdownMenuItem(
                            value: 'Cheque', child: Text('Cheque')),
                        DropdownMenuItem(
                            value: 'Tarjeta', child: Text('Tarjeta')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _formaPagoSeleccionada = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Pagado'),
                      subtitle: const Text('Marcar si ya fue pagado'),
                      value: _pagado,
                      onChanged: (value) {
                        setState(() {
                          _pagado = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Fecha
              OptimizedCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha del Costo',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _fechaController,
                          decoration: InputDecoration(
                            hintText: 'Seleccione la fecha del costo',
                            suffixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                          ),
                          readOnly: true,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _fecha ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setState(() {
                                _fecha = date;
                                _fechaController.text =
                                    '${date.day}/${date.month}/${date.year}';
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Fecha de pago límite (opcional)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha de Pago Límite (Opcional)',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _fechaPagoLimiteController,
                          decoration: InputDecoration(
                            hintText: 'Seleccione la fecha límite de pago',
                            suffixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                          ),
                          readOnly: true,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _fechaPagoLimite ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                _fechaPagoLimite = date;
                                _fechaPagoLimiteController.text =
                                    '${date.day}/${date.month}/${date.year}';
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSaving ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _submitForm,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.costo == null
                              ? (_esCobro ? 'Crear Cobro' : 'Crear Gasto')
                              : 'Actualizar ${_esCobro ? 'Cobro' : 'Gasto'}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final data = {
          'descripcion': _descripcionController.text,
          'monto': double.parse(_montoController.text),
          'fecha':
              _fecha?.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
          'pagado': _pagado,
          'forma_pago': _formaPagoSeleccionada ?? 'Efectivo',
          'es_cobro': _esCobro,
          'fecha_pago_limite':
              _fechaPagoLimite?.toIso8601String().split('T')[0],
        };

        // Campos específicos según el tipo
        if (_esCobro) {
          // Es un COBRO
          data['cobrar_a'] = _cobrarAController.text.isNotEmpty
              ? _cobrarAController.text
              : null;
          data['id_trabajo'] = _trabajoIdController.text.isNotEmpty
              ? int.tryParse(_trabajoIdController.text)
              : null;
          data['destinatario'] = _cobrarAController.text.isNotEmpty
              ? _cobrarAController.text
              : 'Cliente';
          data['categoria'] = _categoriaController.text.isNotEmpty
              ? _categoriaController.text
              : 'Cobro';
        } else {
          // Es un GASTO
          data['destinatario'] = _destinatarioController.text;
          data['categoria'] = _categoriaController.text.isNotEmpty
              ? _categoriaController.text
              : 'Otros';
          data['cobrar_a'] = null;
          data['id_trabajo'] = null;
        }

        if (widget.costo == null) {
          await ref.read(costosProvider.notifier).createCosto(data);
        } else {
          await ref
              .read(costosProvider.notifier)
              .updateCosto(widget.costo.id, data);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.costo == null
                    ? (_esCobro
                        ? 'Cobro creado exitosamente'
                        : 'Gasto creado exitosamente')
                    : '${_esCobro ? 'Cobro' : 'Gasto'} actualizado exitosamente',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  Widget _buildTipoSelector(
    String title,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
