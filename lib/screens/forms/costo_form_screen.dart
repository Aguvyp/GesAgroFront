import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';

/// Pantalla completa para crear/editar costos
class CostoFormScreen extends ConsumerStatefulWidget {
  final dynamic costo;
  
  const CostoFormScreen({Key? key, this.costo}) : super(key: key);

  @override
  ConsumerState<CostoFormScreen> createState() => _CostoFormScreenState();
}

class _CostoFormScreenState extends ConsumerState<CostoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descripcionController;
  late TextEditingController _montoController;
  late TextEditingController _categoriaController;
  late TextEditingController _fechaController;
  DateTime? _fecha;
  
  String? _formaPagoSeleccionada;
  bool _pagado = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _descripcionController = TextEditingController(text: widget.costo?.descripcion ?? '');
    _montoController = TextEditingController(text: widget.costo?.monto?.toString() ?? '');
    _categoriaController = TextEditingController(text: widget.costo?.categoria ?? '');
    _fechaController = TextEditingController(text: widget.costo?.fecha?.toString() ?? '');
    _fecha = widget.costo?.fecha ?? DateTime.now();
    _formaPagoSeleccionada = widget.costo?.formaPago ?? 'Efectivo';
    _pagado = widget.costo?.pagado ?? false;
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _montoController.dispose();
    _categoriaController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.costo == null ? 'Nuevo Costo' : 'Editar Costo',
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _submitForm,
            child: _isSaving 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  widget.costo == null ? 'Guardar' : 'Actualizar',
                  style: const TextStyle(color: Colors.white),
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
              // Información básica
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Básica',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _descripcionController,
                        label: 'Descripción',
                        hint: 'Descripción del costo o gasto',
                        prefixIcon: const Icon(Icons.description),
                        validator: (value) => Validators.validateRequired(value, 'Descripción'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
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
                      CustomTextField(
                        controller: _categoriaController,
                        label: 'Categoría',
                        hint: 'Ej: Combustible, Semillas, Fertilizantes',
                        prefixIcon: const Icon(Icons.category),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Información de pago
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información de Pago',
                        style: Theme.of(context).textTheme.titleLarge,
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
                          DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                          DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
                          DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                          DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
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
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Fecha
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _fechaController,
                        label: 'Fecha del Costo',
                        hint: 'Seleccione la fecha del costo',
                        prefixIcon: const Icon(Icons.calendar_today),
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
                              _fechaController.text = '${date.day}/${date.month}/${date.year}';
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
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
                        : Text(widget.costo == null ? 'Crear Costo' : 'Actualizar Costo'),
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
          'fecha': _fecha?.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
          'destinatario': _categoriaController.text,
          'pagado': _pagado,
          'forma_pago': _formaPagoSeleccionada ?? 'Efectivo',
          'categoria': _categoriaController.text,
          'es_cobro': false,
          'cobrar_a': null,
          'fecha_pago_limite': null,
          'id_trabajo': null,
        };

        if (widget.costo == null) {
          await ref.read(costosProvider.notifier).createCosto(data);
        } else {
          await ref.read(costosProvider.notifier).updateCosto(widget.costo.id, data);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.costo == null ? 'Costo creado exitosamente' : 'Costo actualizado exitosamente'),
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
}
