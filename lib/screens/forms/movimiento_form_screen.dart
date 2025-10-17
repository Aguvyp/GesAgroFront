import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/movimiento.dart';
import '../../providers/optimized_providers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class MovimientoFormScreen extends ConsumerStatefulWidget {
  final Movimiento? movimiento;
  const MovimientoFormScreen({Key? key, this.movimiento}) : super(key: key);

  @override
  ConsumerState<MovimientoFormScreen> createState() => _MovimientoFormScreenState();
}

class _MovimientoFormScreenState extends ConsumerState<MovimientoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _montoController;
  late TextEditingController _descripcionController;
  late TextEditingController _categoriaController;
  DateTime? _fecha;
  bool _esCobro = true;
  bool _pagado = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.movimiento;
    _montoController = TextEditingController(text: m?.monto.toString() ?? '');
    _descripcionController = TextEditingController(text: m?.descripcion ?? '');
    _categoriaController = TextEditingController(text: m?.categoria ?? '');
    _fecha = m?.fecha ?? DateTime.now();
    _esCobro = m?.esCobro ?? true;
    _pagado = m?.pagado ?? false;
  }

  @override
  void dispose() {
    _montoController.dispose();
    _descripcionController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.movimiento != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Movimiento' : 'Nuevo Movimiento'),
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
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<bool>(
                      value: _esCobro,
                      items: const [
                        DropdownMenuItem(value: true, child: Text('Ingreso')),
                        DropdownMenuItem(value: false, child: Text('Gasto')),
                      ],
                      onChanged: (v) => setState(() => _esCobro = v ?? true),
                      decoration: const InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Pagado'),
                      value: _pagado,
                      onChanged: (v) => setState(() => _pagado = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _montoController,
                label: 'Monto',
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _descripcionController,
                label: 'Descripción',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _categoriaController,
                label: 'Categoría',
              ),
              const SizedBox(height: 12),
              _buildDatePicker(context, 'Fecha', _fecha, (d) => setState(() => _fecha = d)),
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
    if (!_formKey.currentState!.validate() || _fecha == null) return;
    setState(() => _isSaving = true);
    try {
      final movimiento = Movimiento(
        id: widget.movimiento?.id ?? 0,
        monto: double.parse(_montoController.text.trim()),
        fecha: _fecha,
        descripcion: _descripcionController.text.trim().isEmpty ? null : _descripcionController.text.trim(),
        categoria: _categoriaController.text.trim().isEmpty ? null : _categoriaController.text.trim(),
        pagado: _pagado,
        esCobro: _esCobro,
      );

      if (widget.movimiento == null) {
        await ref.read(movimientosProvider.notifier).createMovimiento(movimiento.toJson());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Movimiento creado')));
      } else {
        await ref.read(movimientosProvider.notifier).updateMovimiento(movimiento.id, movimiento.toJson());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Movimiento actualizado')));
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }
}



