import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../models/campo.dart';
import '../../widgets/optimized_widgets.dart';
import '../../utils/validators.dart';

/// Pantalla completa para crear/editar campos
class CampoFormScreen extends ConsumerStatefulWidget {
  final Campo? campo;
  
  const CampoFormScreen({Key? key, this.campo}) : super(key: key);

  @override
  ConsumerState<CampoFormScreen> createState() => _CampoFormScreenState();
}

class _CampoFormScreenState extends ConsumerState<CampoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _superficieController;
  late TextEditingController _latitudController;
  late TextEditingController _longitudController;
  late TextEditingController _detallesController;
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.campo?.nombre ?? '');
    _superficieController = TextEditingController(text: widget.campo?.superficieHa.toString() ?? '');
    _latitudController = TextEditingController(text: widget.campo?.latitud?.toString() ?? '');
    _longitudController = TextEditingController(text: widget.campo?.longitud?.toString() ?? '');
    _detallesController = TextEditingController(text: widget.campo?.detalles ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _superficieController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _detallesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.campo == null ? 'Nuevo Campo' : 'Editar Campo',
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información básica
              OptimizedCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información Básica',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OptimizedTextField(
                      controller: _nombreController,
                      label: 'Nombre del Campo',
                      hint: 'Ingresa el nombre del campo',
                      prefixIcon: const Icon(Icons.landscape),
                      validator: (value) => Validators.validateRequired(value, 'Nombre del campo'),
                    ),
                    const SizedBox(height: 16),
                    OptimizedTextField(
                      controller: _superficieController,
                      label: 'Superficie (hectáreas)',
                      hint: 'Ingresa la superficie en hectáreas',
                      prefixIcon: const Icon(Icons.straighten),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La superficie es requerida';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingrese un número válido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Ubicación
              OptimizedCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ubicación',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OptimizedTextField(
                            controller: _latitudController,
                            label: 'Latitud',
                            hint: 'Ej: -34.6037',
                            prefixIcon: const Icon(Icons.location_on),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OptimizedTextField(
                            controller: _longitudController,
                            label: 'Longitud',
                            hint: 'Ej: -58.3816',
                            prefixIcon: const Icon(Icons.location_on),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Las coordenadas son opcionales y se pueden obtener desde Google Maps',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Detalles adicionales
              OptimizedCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalles Adicionales',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OptimizedTextField(
                      controller: _detallesController,
                      label: 'Detalles (opcional)',
                      hint: 'Información adicional sobre el campo',
                      prefixIcon: const Icon(Icons.note),
                      maxLines: 4,
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
                        : Text(widget.campo == null ? 'Crear Campo' : 'Actualizar Campo'),
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
          'hectareas': double.parse(_superficieController.text),
          'latitud': _latitudController.text.isNotEmpty ? double.parse(_latitudController.text) : null,
          'longitud': _longitudController.text.isNotEmpty ? double.parse(_longitudController.text) : null,
          'detalles': _detallesController.text.isNotEmpty ? _detallesController.text : null,
        };

        if (widget.campo == null) {
          await ref.read(camposProvider.notifier).createCampo(data);
        } else {
          await ref.read(camposProvider.notifier).updateCampo(widget.campo!.id!, data);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.campo == null ? 'Campo creado exitosamente' : 'Campo actualizado exitosamente'),
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
