import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/mantenimiento.dart';
import '../../providers/optimized_providers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class MantenimientoFormScreen extends ConsumerStatefulWidget {
  final Mantenimiento? mantenimiento;
  const MantenimientoFormScreen({Key? key, this.mantenimiento}) : super(key: key);

  @override
  ConsumerState<MantenimientoFormScreen> createState() => _MantenimientoFormScreenState();
}

class _MantenimientoFormScreenState extends ConsumerState<MantenimientoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descripcionController;
  late TextEditingController _maquinaIdController;
  late TextEditingController _costoController;
  late TextEditingController _proveedorController;
  late TextEditingController _tecnicoController;
  late TextEditingController _observacionesController;

  String? _tipo;
  String? _estado;
  DateTime? _fechaProgramada;
  DateTime? _fechaRealizada;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.mantenimiento;
    _descripcionController = TextEditingController(text: m?.descripcion ?? '');
    _maquinaIdController = TextEditingController(text: m?.maquinaId.toString() ?? '');
    _costoController = TextEditingController(text: m?.costo?.toString() ?? '');
    _proveedorController = TextEditingController(text: m?.proveedor ?? '');
    _tecnicoController = TextEditingController(text: m?.tecnico ?? '');
    _observacionesController = TextEditingController(text: m?.observaciones ?? '');
    _tipo = m?.tipo ?? 'Preventivo';
    _estado = m?.estado ?? 'Programado';
    _fechaProgramada = m?.fechaProgramada ?? DateTime.now();
    _fechaRealizada = m?.fechaRealizada;
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _maquinaIdController.dispose();
    _costoController.dispose();
    _proveedorController.dispose();
    _tecnicoController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.mantenimiento != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Mantenimiento' : 'Nuevo Mantenimiento'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _tipo,
                items: const [
                  DropdownMenuItem(value: 'Preventivo', child: Text('Preventivo')),
                  DropdownMenuItem(value: 'Correctivo', child: Text('Correctivo')),
                  DropdownMenuItem(value: 'Predictivo', child: Text('Predictivo')),
                ],
                onChanged: (v) => setState(() => _tipo = v),
                decoration: const InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _descripcionController,
                label: 'Descripción',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _maquinaIdController,
                label: 'ID Máquina',
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              _buildDatePicker(context, 'Fecha Programada', _fechaProgramada, (d) => setState(() => _fechaProgramada = d)),
              const SizedBox(height: 12),
              _buildDatePicker(context, 'Fecha Realizada (opcional)', _fechaRealizada, (d) => setState(() => _fechaRealizada = d)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _estado,
                items: const [
                  DropdownMenuItem(value: 'Programado', child: Text('Programado')),
                  DropdownMenuItem(value: 'En Proceso', child: Text('En Proceso')),
                  DropdownMenuItem(value: 'Completado', child: Text('Completado')),
                  DropdownMenuItem(value: 'Cancelado', child: Text('Cancelado')),
                ],
                onChanged: (v) => setState(() => _estado = v),
                decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _costoController,
                label: 'Costo (opcional)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _proveedorController,
                label: 'Proveedor (opcional)',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _tecnicoController,
                label: 'Técnico (opcional)',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _observacionesController,
                label: 'Observaciones (opcional)',
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancelar',
                      isOutlined: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: isEditing ? 'Actualizar' : 'Crear',
                      isLoading: _isSaving,
                      onPressed: _isSaving ? null : _submit,
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

  Widget _buildDatePicker(BuildContext context, String label, DateTime? date, ValueChanged<DateTime?> onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        );
        onChanged(picked);
      },
      child: InputDecorator(
        decoration: const InputDecoration(labelText: 'Fecha', border: OutlineInputBorder()),
        child: Text(date != null ? '${date.day}/${date.month}/${date.year}' : label),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _tipo == null || _estado == null || _fechaProgramada == null) return;
    setState(() => _isSaving = true);
    try {
      final mantenimiento = Mantenimiento(
        id: widget.mantenimiento?.id ?? 0,
        maquinaId: int.parse(_maquinaIdController.text.trim()),
        tipo: _tipo!,
        descripcion: _descripcionController.text.trim(),
        fechaProgramada: _fechaProgramada!,
        fechaRealizada: _fechaRealizada,
        estado: _estado!,
        costo: _costoController.text.trim().isEmpty ? null : double.parse(_costoController.text.trim()),
        proveedor: _proveedorController.text.trim().isEmpty ? null : _proveedorController.text.trim(),
        tecnico: _tecnicoController.text.trim().isEmpty ? null : _tecnicoController.text.trim(),
        observaciones: _observacionesController.text.trim().isEmpty ? null : _observacionesController.text.trim(),
      );

      if (widget.mantenimiento == null) {
        await ref.read(mantenimientosProvider.notifier).createMantenimiento(mantenimiento.toJson());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mantenimiento creado')));
      } else {
        await ref.read(mantenimientosProvider.notifier).updateMantenimiento(mantenimiento.id, mantenimiento.toJson());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mantenimiento actualizado')));
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }
}


