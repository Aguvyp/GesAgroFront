import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';

/// Pantalla completa para crear/editar facturas
class FacturaFormScreen extends StatefulWidget {
  final dynamic factura;
  
  const FacturaFormScreen({Key? key, this.factura}) : super(key: key);

  @override
  State<FacturaFormScreen> createState() => _FacturaFormScreenState();
}

class _FacturaFormScreenState extends State<FacturaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numeroController;
  late TextEditingController _clienteController;
  late TextEditingController _subtotalController;
  late TextEditingController _impuestosController;
  late TextEditingController _totalController;
  
  DateTime? _fechaEmision;
  DateTime? _fechaVencimiento;
  String? _estadoSeleccionado;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _numeroController = TextEditingController(text: widget.factura?.numero ?? '');
    _clienteController = TextEditingController(text: widget.factura?.cliente ?? '');
    _subtotalController = TextEditingController(text: widget.factura?.subtotal?.toString() ?? '');
    _impuestosController = TextEditingController(text: widget.factura?.impuestos?.toString() ?? '');
    _totalController = TextEditingController(text: widget.factura?.total?.toString() ?? '');
    
    _fechaEmision = widget.factura?.fechaEmision ?? DateTime.now();
    _fechaVencimiento = widget.factura?.fechaVencimiento ?? DateTime.now().add(const Duration(days: 30));
    _estadoSeleccionado = widget.factura?.estado ?? 'Borrador';
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _clienteController.dispose();
    _subtotalController.dispose();
    _impuestosController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.factura != null;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Editar Factura' : 'Nueva Factura',
        showBackButton: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información básica
              _buildSectionHeader('Información Básica'),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _numeroController,
                label: 'Número de Factura',
                hint: 'FAC-001',
                validator: (value) => Validators.validateRequired(value, 'Número de factura'),
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _clienteController,
                label: 'Cliente',
                hint: 'Nombre del cliente',
                validator: (value) => Validators.validateRequired(value, 'Cliente'),
              ),
              const SizedBox(height: 24),
              
              // Fechas
              _buildSectionHeader('Fechas'),
              const SizedBox(height: 16),
              
              // Campo de fecha de emisión
              InkWell(
                onTap: _selectFechaEmision,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fecha de Emisión',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _fechaEmision != null
                                  ? '${_fechaEmision!.day}/${_fechaEmision!.month}/${_fechaEmision!.year}'
                                  : 'Seleccionar fecha',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Campo de fecha de vencimiento
              InkWell(
                onTap: _selectFechaVencimiento,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fecha de Vencimiento',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _fechaVencimiento != null
                                  ? '${_fechaVencimiento!.day}/${_fechaVencimiento!.month}/${_fechaVencimiento!.year}'
                                  : 'Seleccionar fecha',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Montos
              _buildSectionHeader('Montos'),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _subtotalController,
                label: 'Subtotal',
                hint: '0.00',
                keyboardType: TextInputType.number,
                validator: (value) => Validators.validateRequired(value, 'Subtotal'),
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _impuestosController,
                label: 'Impuestos',
                hint: '0.00',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _totalController,
                label: 'Monto Total',
                hint: '0.00',
                keyboardType: TextInputType.number,
                validator: (value) => Validators.validateRequired(value, 'Monto total'),
              ),
              const SizedBox(height: 24),
              
              // Estado
              _buildSectionHeader('Estado'),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                value: _estadoSeleccionado,
                items: const [
                  DropdownMenuItem(value: 'Borrador', child: Text('Borrador')),
                  DropdownMenuItem(value: 'Enviada', child: Text('Enviada')),
                  DropdownMenuItem(value: 'Pagada', child: Text('Pagada')),
                  DropdownMenuItem(value: 'Vencida', child: Text('Vencida')),
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
                      onPressed: _isSaving ? null : _saveFactura,
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Future<void> _selectFechaEmision() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaEmision ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _fechaEmision = date;
      });
    }
  }

  Future<void> _selectFechaVencimiento() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaVencimiento ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _fechaVencimiento = date;
      });
    }
  }

  Future<void> _saveFactura() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fechaEmision == null || _fechaVencimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione las fechas requeridas')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // TODO: Implementar creación/actualización de factura usando el servicio correspondiente
      // Por ahora solo mostramos un mensaje de éxito
      
      if (widget.factura != null) {
        // Actualizar factura existente
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Factura actualizada exitosamente')),
        );
      } else {
        // Crear nueva factura
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Factura creada exitosamente')),
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
