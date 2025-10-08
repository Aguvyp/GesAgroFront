import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/personal.dart';
import '../../services/personal_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/optimized_widgets.dart';
import '../../utils/validators.dart';

class PersonalFormDialog extends StatefulWidget {
  final Personal? personal;
  final VoidCallback? onSaved;

  const PersonalFormDialog({
    Key? key,
    this.personal,
    this.onSaved,
  }) : super(key: key);

  @override
  State<PersonalFormDialog> createState() => _PersonalFormDialogState();
}

class _PersonalFormDialogState extends State<PersonalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _dniController = TextEditingController();
  final _telefonoController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.personal != null;
    
    if (_isEditing) {
      _nombreController.text = widget.personal!.nombre;
      _dniController.text = widget.personal!.dni;
      _telefonoController.text = widget.personal!.telefono ?? '';
    }
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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    _isEditing ? Icons.edit : Icons.person_add,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isEditing ? 'Editar Personal' : 'Nuevo Personal',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Formulario
              CustomTextField(
                controller: _nombreController,
                label: 'Nombre completo',
                hint: 'Ingresa el nombre completo',
                prefixIcon: const Icon(Icons.person),
                validator: (value) => Validators.validateRequired(value, 'Nombre'),
              ),
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _dniController,
                label: 'DNI',
                hint: 'Ingresa el DNI',
                prefixIcon: const Icon(Icons.badge),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
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
              
              const SizedBox(height: 16),
              
              CustomTextField(
                controller: _telefonoController,
                label: 'Teléfono (opcional)',
                hint: 'Ingresa el número de teléfono',
                prefixIcon: const Icon(Icons.phone),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(_isEditing ? 'Actualizar' : 'Guardar'),
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final personal = Personal(
        id: widget.personal?.id,
        nombre: _nombreController.text.trim(),
        dni: _dniController.text.trim(),
        telefono: _telefonoController.text.trim().isEmpty 
            ? null 
            : _telefonoController.text.trim(),
      );

      if (_isEditing) {
        await PersonalService.updatePersonal(personal);
      } else {
        await PersonalService.createPersonal(personal);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved?.call();
      }
    } catch (e) {
      if (mounted) {
        OptimizedSnackBar.showError(
          context,
          message: 'Error al ${_isEditing ? 'actualizar' : 'crear'} personal: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
