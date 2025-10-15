import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../models/maquina.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';

/// Pantalla completa para crear/editar máquinas
class MaquinaFormScreen extends ConsumerStatefulWidget {
  final Maquina? maquina;
  
  const MaquinaFormScreen({Key? key, this.maquina}) : super(key: key);

  @override
  ConsumerState<MaquinaFormScreen> createState() => _MaquinaFormScreenState();
}

class _MaquinaFormScreenState extends ConsumerState<MaquinaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _anioController;
  late TextEditingController _anchoTrabajoController;
  late TextEditingController _detallesController;
  
  bool _isSaving = false;

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
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.maquina == null ? 'Nueva Máquina' : 'Editar Máquina',
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
                  widget.maquina == null ? 'Guardar' : 'Actualizar',
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
                        controller: _nombreController,
                        label: 'Nombre',
                        hint: 'Nombre identificativo de la máquina',
                        prefixIcon: const Icon(Icons.build),
                        validator: (value) => Validators.validateRequired(value, 'Nombre'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _marcaController,
                        label: 'Marca',
                        hint: 'Marca de la máquina',
                        prefixIcon: const Icon(Icons.business),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _modeloController,
                        label: 'Modelo',
                        hint: 'Modelo de la máquina',
                        prefixIcon: const Icon(Icons.model_training),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Especificaciones técnicas
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Especificaciones Técnicas',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _anioController,
                        label: 'Año',
                        hint: 'Año de fabricación',
                        prefixIcon: const Icon(Icons.calendar_today),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _anchoTrabajoController,
                        label: 'Ancho de Trabajo (metros)',
                        hint: 'Ancho de trabajo en metros',
                        prefixIcon: const Icon(Icons.straighten),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Detalles adicionales
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalles Adicionales',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _detallesController,
                        label: 'Detalles',
                        hint: 'Información adicional sobre la máquina',
                        prefixIcon: const Icon(Icons.description),
                        maxLines: 4,
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
                        : Text(widget.maquina == null ? 'Crear Máquina' : 'Actualizar Máquina'),
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
          'nombre': _nombreController.text,
          'marca': _marcaController.text,
          'modelo': _modeloController.text,
          'anio': _anioController.text.isNotEmpty ? int.parse(_anioController.text) : null,
          'ancho_trabajo': _anchoTrabajoController.text.isNotEmpty ? double.parse(_anchoTrabajoController.text) : null,
          'detalles': _detallesController.text.isNotEmpty ? _detallesController.text : null,
        };

        if (widget.maquina == null) {
          await ref.read(maquinasProvider.notifier).createMaquina(data);
        } else {
          await ref.read(maquinasProvider.notifier).updateMaquina(widget.maquina!.id!, data);
        }

        if (mounted) {
          Navigator.pop(context);
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
