import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/cliente.dart';
import '../../providers/optimized_providers.dart';
import '../../widgets/optimized_widgets.dart';

class ClienteFormScreen extends ConsumerStatefulWidget {
  final Cliente? cliente;

  const ClienteFormScreen({
    Key? key,
    this.cliente,
  }) : super(key: key);

  @override
  ConsumerState<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends ConsumerState<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _cuitController = TextEditingController();
  final _observacionesController = TextEditingController();

  bool _isLoading = false;
  bool get _isEditing => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nombreController.text = widget.cliente!.nombre ?? '';
      _emailController.text = widget.cliente!.email ?? '';
      _telefonoController.text = widget.cliente!.telefono ?? '';
      _direccionController.text = widget.cliente!.direccion ?? '';
      _cuitController.text = widget.cliente!.cuit ?? '';
      _observacionesController.text = widget.cliente!.observaciones ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _cuitController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Cliente' : 'Nuevo Cliente',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          color: const Color(0xFF1C1C1E),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información básica
              _buildSection(
                'Información Básica',
                Icons.person,
                [
                  _buildTextField(
                    controller: _nombreController,
                    label: 'Nombre',
                    hint: 'Ingrese el nombre del cliente',
                    icon: Icons.person_outline,
                    maxLength: 255,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'ejemplo@email.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final emailRegex =
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Ingrese un email válido';
                        }
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Información de contacto
              _buildSection(
                'Contacto',
                Icons.contact_phone,
                [
                  _buildTextField(
                    controller: _telefonoController,
                    label: 'Teléfono',
                    hint: '3512345678',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    maxLength: 50,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _direccionController,
                    label: 'Dirección',
                    hint: 'Calle, número, ciudad',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                    maxLength: 500,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Información fiscal
              _buildSection(
                'Información Fiscal',
                Icons.account_balance,
                [
                  _buildTextField(
                    controller: _cuitController,
                    label: 'CUIT',
                    hint: '20-12345678-9',
                    icon: Icons.badge_outlined,
                    keyboardType: TextInputType.number,
                    maxLength: 20,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final cuitRegex = RegExp(r'^\d{2}-\d{8}-\d{1}$');
                        if (!cuitRegex.hasMatch(value)) {
                          return 'Formato: XX-XXXXXXXX-X';
                        }
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Observaciones
              _buildSection(
                'Observaciones',
                Icons.notes,
                [
                  _buildTextField(
                    controller: _observacionesController,
                    label: 'Observaciones',
                    hint: 'Notas adicionales sobre el cliente',
                    icon: Icons.note_outlined,
                    maxLines: 4,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveCliente,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
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

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        counterText: maxLength != null ? '' : null,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
    );
  }

  Future<void> _saveCliente() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final clienteData = {
        if (_nombreController.text.trim().isNotEmpty)
          'nombre': _nombreController.text.trim(),
        if (_emailController.text.trim().isNotEmpty)
          'email': _emailController.text.trim(),
        if (_telefonoController.text.trim().isNotEmpty)
          'telefono': _telefonoController.text.trim(),
        if (_direccionController.text.trim().isNotEmpty)
          'direccion': _direccionController.text.trim(),
        if (_cuitController.text.trim().isNotEmpty)
          'cuit': _cuitController.text.trim(),
        if (_observacionesController.text.trim().isNotEmpty)
          'observaciones': _observacionesController.text.trim(),
      };

      if (_isEditing) {
        await ref.read(clientesProvider.notifier).updateCliente(
              widget.cliente!.id!,
              clienteData,
            );
      } else {
        await ref.read(clientesProvider.notifier).createCliente(clienteData);
      }

      if (mounted) {
        Navigator.pop(context);
        OptimizedSnackBar.showSuccess(
          context,
          message: _isEditing
              ? 'Cliente actualizado exitosamente'
              : 'Cliente creado exitosamente',
        );
      }
    } catch (e) {
      if (mounted) {
        OptimizedSnackBar.showError(
          context,
          message: 'Error al guardar cliente: $e',
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
