import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/optimized_providers.dart';
import '../models/maquina.dart';
import '../models/personal.dart';
import '../widgets/optimized_widgets.dart';

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
  late TextEditingController _horasTrabajadasController;
  late TextEditingController _detallesController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.maquina?.nombre ?? '');
    _marcaController = TextEditingController(text: widget.maquina?.marca ?? '');
    _modeloController = TextEditingController(text: widget.maquina?.modelo ?? '');
    _anioController = TextEditingController(text: widget.maquina?.ano.toString() ?? '');
    _anchoTrabajoController = TextEditingController(text: widget.maquina?.anchoTrabajo?.toString() ?? '');
    _horasTrabajadasController = TextEditingController(text: widget.maquina?.horasTrabajadas?.toString() ?? '');
    _detallesController = TextEditingController(text: widget.maquina?.detalles ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _anioController.dispose();
    _anchoTrabajoController.dispose();
    _horasTrabajadasController.dispose();
    _detallesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.maquina == null ? 'Nueva Máquina' : 'Editar Máquina'),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OptimizedCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Básica',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      OptimizedTextField(
                        controller: _nombreController,
                        label: 'Nombre',
                        hint: 'Nombre identificativo de la máquina',
                        prefixIcon: const Icon(Icons.build),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      OptimizedTextField(
                        controller: _marcaController,
                        label: 'Marca',
                        hint: 'Marca de la máquina',
                        prefixIcon: const Icon(Icons.business),
                      ),
                      const SizedBox(height: 24),
                      OptimizedTextField(
                        controller: _modeloController,
                        label: 'Modelo',
                        hint: 'Modelo de la máquina',
                        prefixIcon: const Icon(Icons.model_training),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OptimizedCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Especificaciones Técnicas',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      OptimizedTextField(
                        controller: _anioController,
                        label: 'Año',
                        hint: 'Año de fabricación',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      const SizedBox(height: 24),
                      OptimizedTextField(
                        controller: _anchoTrabajoController,
                        label: 'Ancho de Trabajo (metros)',
                        hint: 'Ancho de trabajo en metros',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.straighten),
                      ),
                      const SizedBox(height: 24),
                      OptimizedTextField(
                        controller: _horasTrabajadasController,
                        label: 'Horas de Uso',
                        hint: 'Horas totales trabajadas',
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        prefixIcon: const Icon(Icons.access_time),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OptimizedCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalles Adicionales',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      OptimizedTextField(
                        controller: _detallesController,
                        label: 'Detalles (opcional)',
                        hint: 'Información adicional sobre la máquina',
                        maxLines: 3,
                        prefixIcon: const Icon(Icons.note),
                      ),
                    ],
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
          child: Text(widget.maquina == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Crear objeto Maquina
        final maquina = Maquina(
          nombre: _nombreController.text,
          marca: _marcaController.text,
          modelo: _modeloController.text,
          ano: _anioController.text.isNotEmpty ? int.parse(_anioController.text) : DateTime.now().year,
          anchoTrabajo: _anchoTrabajoController.text.isNotEmpty ? double.parse(_anchoTrabajoController.text) : null,
          horasTrabajadas: _horasTrabajadasController.text.isNotEmpty ? double.parse(_horasTrabajadasController.text) : null,
          detalles: _detallesController.text.isNotEmpty ? _detallesController.text : null,
        );

        if (widget.maquina == null) {
          await ref.read(maquinasProvider.notifier).createMaquina(maquina);
          Navigator.pop(context);
        } else {
          // Para actualizar, convertir a Map (mantener compatibilidad con updateMaquina)
          final data = maquina.toJson();
          data.remove('id'); // No enviar el id en el update
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
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OptimizedCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Personal',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      OptimizedTextField(
                        controller: _nombreController,
                        label: 'Nombre',
                        hint: 'Nombre completo del operario',
                        prefixIcon: const Icon(Icons.person),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      OptimizedTextField(
                        controller: _dniController,
                        label: 'DNI',
                        hint: 'Número de documento',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.badge),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El DNI es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      OptimizedTextField(
                        controller: _telefonoController,
                        label: 'Teléfono (opcional)',
                        hint: 'Número de teléfono',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone),
                      ),
                    ],
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
