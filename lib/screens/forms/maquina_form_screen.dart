import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../models/maquina.dart';
import '../../widgets/optimized_widgets.dart';
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
  late TextEditingController _horasTrabajadasController;
  late TextEditingController _detallesController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreController =
        TextEditingController(text: widget.maquina?.nombre ?? '');
    _marcaController = TextEditingController(text: widget.maquina?.marca ?? '');
    _modeloController =
        TextEditingController(text: widget.maquina?.modelo ?? '');
    _anioController =
        TextEditingController(text: widget.maquina?.ano.toString() ?? '');
    _anchoTrabajoController = TextEditingController(
        text: widget.maquina?.anchoTrabajo?.toString() ?? '');
    _horasTrabajadasController = TextEditingController(
        text: widget.maquina?.horasTrabajadas?.toString() ?? '');
    _detallesController =
        TextEditingController(text: widget.maquina?.detalles ?? '');
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          widget.maquina == null ? 'Nueva Máquina' : 'Editar Máquina',
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
                      label: 'Nombre',
                      hint: 'Nombre identificativo de la máquina',
                      prefixIcon: const Icon(Icons.build),
                      validator: (value) =>
                          Validators.validateRequired(value, 'Nombre'),
                    ),
                    const SizedBox(height: 16),
                    OptimizedTextField(
                      controller: _marcaController,
                      label: 'Marca',
                      hint: 'Marca de la máquina',
                      prefixIcon: const Icon(Icons.business),
                    ),
                    const SizedBox(height: 16),
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

              // Especificaciones técnicas
              OptimizedCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Especificaciones Técnicas',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OptimizedTextField(
                      controller: _anioController,
                      label: 'Año',
                      hint: 'Año de fabricación',
                      prefixIcon: const Icon(Icons.calendar_today),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    OptimizedTextField(
                      controller: _anchoTrabajoController,
                      label: 'Ancho de Trabajo (metros)',
                      hint: 'Ancho de trabajo en metros',
                      prefixIcon: const Icon(Icons.straighten),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    OptimizedTextField(
                      controller: _horasTrabajadasController,
                      label: 'Horas de Uso',
                      hint: 'Horas totales trabajadas',
                      prefixIcon: const Icon(Icons.access_time),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

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
                      hint: 'Información adicional sobre la máquina',
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
                      onPressed:
                          _isSaving ? null : () => Navigator.pop(context),
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
                          : Text(widget.maquina == null
                              ? 'Crear Máquina'
                              : 'Actualizar Máquina'),
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
        // Crear objeto Maquina
        final maquina = Maquina(
          nombre: _nombreController.text,
          marca: _marcaController.text,
          modelo: _modeloController.text,
          ano: _anioController.text.isNotEmpty
              ? int.parse(_anioController.text)
              : DateTime.now().year,
          anchoTrabajo: _anchoTrabajoController.text.isNotEmpty
              ? double.parse(_anchoTrabajoController.text)
              : null,
          horasTrabajadas: _horasTrabajadasController.text.isNotEmpty
              ? double.parse(_horasTrabajadasController.text)
              : null,
          detalles: _detallesController.text.isNotEmpty
              ? _detallesController.text
              : null,
        );

        if (widget.maquina == null) {
          final newMaquina =
              await ref.read(maquinasProvider.notifier).createMaquina(maquina);
          if (mounted) {
            Navigator.pop(context, newMaquina);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Máquina creada exitosamente')),
            );
          }
        } else {
          // Para actualizar, convertir a Map (mantener compatibilidad con updateMaquina)
          final data = maquina.toJson();
          data.remove('id'); // No enviar el id en el update
          await ref
              .read(maquinasProvider.notifier)
              .updateMaquina(widget.maquina!.id!, data);
          if (mounted) {
            Navigator.pop(
                context, widget.maquina); // Return edited (conceptually)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Máquina actualizada exitosamente')),
            );
          }
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
