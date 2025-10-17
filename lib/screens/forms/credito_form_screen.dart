import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';
import '../../models/credito.dart';

/// Pantalla completa para crear/editar créditos
class CreditoFormScreen extends ConsumerStatefulWidget {
  final Credito? credito;
  
  const CreditoFormScreen({Key? key, this.credito}) : super(key: key);

  @override
  ConsumerState<CreditoFormScreen> createState() => _CreditoFormScreenState();
}

class _CreditoFormScreenState extends ConsumerState<CreditoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _entidadController;
  late TextEditingController _montoController;
  late TextEditingController _tasaController;
  late TextEditingController _plazoController;
  
  DateTime? _fechaDesembolso;
  String? _estadoSeleccionado;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _entidadController = TextEditingController(text: widget.credito?.entidad ?? '');
    _montoController = TextEditingController(text: widget.credito?.montoOtorgado.toString() ?? '');
    _tasaController = TextEditingController(text: widget.credito?.tasaInteresAnual.toString() ?? '');
    _plazoController = TextEditingController(text: widget.credito?.plazoMeses.toString() ?? '');
    
    _fechaDesembolso = widget.credito?.fechaDesembolso ?? DateTime.now();
    _estadoSeleccionado = widget.credito?.estado ?? 'Activo';
  }

  @override
  void dispose() {
    _entidadController.dispose();
    _montoController.dispose();
    _tasaController.dispose();
    _plazoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.credito != null;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Editar Crédito' : 'Nuevo Crédito',
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
                controller: _entidadController,
                label: 'Entidad Financiera',
                hint: 'Ej: Banco Santander',
                validator: (value) => Validators.validateRequired(value, 'Entidad'),
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _montoController,
                label: 'Monto Otorgado',
                hint: '0.00',
                keyboardType: TextInputType.number,
                validator: (value) => Validators.validateRequired(value, 'Monto'),
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _tasaController,
                label: 'Tasa de Interés Anual',
                hint: '0.00',
                keyboardType: TextInputType.number,
                validator: (value) => Validators.validateRequired(value, 'Tasa de interés'),
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _plazoController,
                label: 'Plazo en Meses',
                hint: '12',
                keyboardType: TextInputType.number,
                validator: (value) => Validators.validateRequired(value, 'Plazo'),
              ),
              const SizedBox(height: 24),
              
              // Fechas y estado
              _buildSectionHeader('Fechas y Estado'),
              const SizedBox(height: 16),
              
              // Campo de fecha de desembolso
              InkWell(
                onTap: _selectFechaDesembolso,
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
                              'Fecha de Desembolso',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _fechaDesembolso != null
                                  ? '${_fechaDesembolso!.day}/${_fechaDesembolso!.month}/${_fechaDesembolso!.year}'
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
              
              // Selector de estado
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                value: _estadoSeleccionado,
                items: const [
                  DropdownMenuItem(value: 'Activo', child: Text('Activo')),
                  DropdownMenuItem(value: 'Finalizado', child: Text('Finalizado')),
                  DropdownMenuItem(value: 'Cancelado', child: Text('Cancelado')),
                  DropdownMenuItem(value: 'Suspendido', child: Text('Suspendido')),
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
                      onPressed: _isSaving ? null : _saveCredito,
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

  Future<void> _selectFechaDesembolso() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _fechaDesembolso ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _fechaDesembolso = date;
      });
    }
  }

  Future<void> _saveCredito() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fechaDesembolso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione una fecha de desembolso')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final credito = Credito(
        id: widget.credito?.id ?? 0,
        entidad: _entidadController.text.trim(),
        montoOtorgado: double.parse(_montoController.text),
        tasaInteresAnual: double.parse(_tasaController.text),
        plazoMeses: int.parse(_plazoController.text),
        fechaDesembolso: _fechaDesembolso!,
        estado: _estadoSeleccionado!,
      );

      if (widget.credito != null) {
        // Actualizar crédito existente
        await ref.read(creditosProvider.notifier).updateCredito(credito);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Crédito actualizado exitosamente')),
        );
      } else {
        // Crear nuevo crédito
        await ref.read(creditosProvider.notifier).createCredito(credito);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Crédito creado exitosamente')),
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
