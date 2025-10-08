import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/optimized_providers.dart';
import '../models/maquina.dart';
import '../models/personal.dart';

/// Formulario para crear/editar máquinas
class MaquinaFormDialog extends ConsumerStatefulWidget {
  final Maquina? maquina;
  
  const MaquinaFormDialog({Key? key, this.maquina}) : super(key: key);

  @override
  ConsumerState<MaquinaFormDialog> createState() => _MaquinaFormDialogState();
}

class _MaquinaFormDialogState extends ConsumerState<MaquinaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _anioController;
  late TextEditingController _anchoTrabajoController;
  late TextEditingController _detallesController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.maquina?.nombre ?? '');
    _marcaController = TextEditingController(text: widget.maquina?.marca ?? '');
    _modeloController = TextEditingController(text: widget.maquina?.modelo ?? '');
    _anioController = TextEditingController(text: widget.maquina?.ano.toString() ?? '');
    _anchoTrabajoController = TextEditingController(text: widget.maquina?.anchoTrabajo?.toString() ?? '');
    _detallesController = TextEditingController(text: widget.maquina?.detalles ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _anioController.dispose();
    _anchoTrabajoController.dispose();
    _detallesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.maquina == null ? 'Nueva Máquina' : 'Editar Máquina'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _marcaController,
                  decoration: const InputDecoration(
                    labelText: 'Marca',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _modeloController,
                  decoration: const InputDecoration(
                    labelText: 'Modelo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _anioController,
                  decoration: const InputDecoration(
                    labelText: 'Año',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _anchoTrabajoController,
                  decoration: const InputDecoration(
                    labelText: 'Ancho de Trabajo (metros)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _detallesController,
                  decoration: const InputDecoration(
                    labelText: 'Detalles',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
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
          onPressed: _submitForm,
          child: Text(widget.maquina == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final data = {
          'nombre': _nombreController.text,
          'marca': _marcaController.text,
          'modelo': _modeloController.text,
          'anio': _anioController.text.isNotEmpty ? int.parse(_anioController.text) : null,
          'ancho_trabajo': _anchoTrabajoController.text.isNotEmpty ? double.parse(_anchoTrabajoController.text) : null,
          'detalles': _detallesController.text.isNotEmpty ? _detallesController.text : null,
        };

        if (widget.maquina == null) {
          await ref.read(maquinasProvider.notifier).createMaquina(data);
          Navigator.pop(context);
        } else {
          await ref.read(maquinasProvider.notifier).updateMaquina(widget.maquina!.id!, data);
          Navigator.pop(context);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.maquina == null ? 'Máquina creada exitosamente' : 'Máquina actualizada exitosamente'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}

/// Formulario para crear/editar personal
class PersonalFormDialog extends ConsumerStatefulWidget {
  final Personal? personal;
  
  const PersonalFormDialog({Key? key, this.personal}) : super(key: key);

  @override
  ConsumerState<PersonalFormDialog> createState() => _PersonalFormDialogState();
}

class _PersonalFormDialogState extends ConsumerState<PersonalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _dniController;
  late TextEditingController _telefonoController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.personal?.nombre ?? '');
    _dniController = TextEditingController(text: widget.personal?.dni ?? '');
    _telefonoController = TextEditingController(text: widget.personal?.telefono ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _dniController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.personal == null ? 'Nuevo Operario' : 'Editar Operario'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dniController,
                  decoration: const InputDecoration(
                    labelText: 'DNI',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El DNI es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                  ),
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
          onPressed: _submitForm,
          child: Text(widget.personal == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final data = {
          'nombre': _nombreController.text,
          'dni': _dniController.text,
          'telefono': _telefonoController.text,
        };

        if (widget.personal == null) {
          await ref.read(personalProvider.notifier).createPersonal(data);
          Navigator.pop(context);
        } else {
          await ref.read(personalProvider.notifier).updatePersonal(widget.personal!.id!, data);
          Navigator.pop(context);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.personal == null ? 'Operario creado exitosamente' : 'Operario actualizado exitosamente'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}
