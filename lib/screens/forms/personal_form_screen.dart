import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../models/personal.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/optimized_widgets.dart';
import '../../utils/validators.dart';

/// Pantalla completa para crear/editar personal
class PersonalFormScreen extends ConsumerStatefulWidget {
  final Personal? personal;
  
  const PersonalFormScreen({Key? key, this.personal}) : super(key: key);

  @override
  ConsumerState<PersonalFormScreen> createState() => _PersonalFormScreenState();
}

class _PersonalFormScreenState extends ConsumerState<PersonalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _dniController;
  late TextEditingController _telefonoController;
  
  bool _isSaving = false;

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
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.personal == null ? 'Nuevo Operario' : 'Editar Operario',
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
                  widget.personal == null ? 'Guardar' : 'Actualizar',
                  style: const TextStyle(color: Colors.white),
                ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información personal
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
                      label: 'Nombre completo',
                      hint: 'Ingresa el nombre completo del operario',
                      prefixIcon: const Icon(Icons.person),
                      validator: (value) => Validators.validateRequired(value, 'Nombre'),
                    ),
                    const SizedBox(height: 24),
                    OptimizedTextField(
                      controller: _dniController,
                      label: 'DNI',
                      hint: 'Ingresa el número de DNI',
                      prefixIcon: const Icon(Icons.badge),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El DNI es requerido';
                        }
                        if (value.length < 7) {
                          return 'El DNI debe tener al menos 7 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    OptimizedTextField(
                      controller: _telefonoController,
                      label: 'Teléfono (opcional)',
                      hint: 'Ingresa el número de teléfono',
                      prefixIcon: const Icon(Icons.phone),
                      keyboardType: TextInputType.phone,
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
                        : Text(widget.personal == null ? 'Crear Operario' : 'Actualizar Operario'),
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
          'dni': _dniController.text,
          'telefono': _telefonoController.text,
        };

        if (widget.personal == null) {
          await ref.read(personalProvider.notifier).createPersonal(data);
        } else {
          await ref.read(personalProvider.notifier).updatePersonal(widget.personal!.id!, data);
        }

        if (mounted) {
          Navigator.pop(context);
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
