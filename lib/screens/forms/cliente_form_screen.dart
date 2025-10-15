import 'package:flutter/material.dart';
import '../../models/cliente.dart';
import '../../services/cliente_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';

/// Pantalla completa para crear/editar clientes
class ClienteFormScreen extends StatefulWidget {
  final Cliente? cliente;
  
  const ClienteFormScreen({Key? key, this.cliente}) : super(key: key);

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _cuitController;
  late TextEditingController _observacionesController;
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.cliente?.nombre ?? '');
    _emailController = TextEditingController(text: widget.cliente?.email ?? '');
    _telefonoController = TextEditingController(text: widget.cliente?.telefono ?? '');
    _direccionController = TextEditingController(text: widget.cliente?.direccion ?? '');
    _cuitController = TextEditingController(text: widget.cliente?.cuit ?? '');
    _observacionesController = TextEditingController(text: widget.cliente?.observaciones ?? '');
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
      appBar: CustomAppBar(
        title: widget.cliente == null ? 'Nuevo Cliente' : 'Editar Cliente',
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
                  widget.cliente == null ? 'Guardar' : 'Actualizar',
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
                        label: 'Nombre completo',
                        hint: 'Ingresa el nombre completo del cliente',
                        prefixIcon: const Icon(Icons.person),
                        validator: (value) => Validators.validateRequired(value, 'Nombre'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Ingresa el email del cliente',
                        prefixIcon: const Icon(Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => Validators.validateEmail(value),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _telefonoController,
                        label: 'Teléfono',
                        hint: 'Ingresa el número de teléfono',
                        prefixIcon: const Icon(Icons.phone),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Información adicional
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Adicional',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _direccionController,
                        label: 'Dirección',
                        hint: 'Ingresa la dirección del cliente',
                        prefixIcon: const Icon(Icons.location_on),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _cuitController,
                        label: 'CUIT',
                        hint: 'Ingresa el CUIT del cliente',
                        prefixIcon: const Icon(Icons.business),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _observacionesController,
                        label: 'Observaciones',
                        hint: 'Ingresa observaciones adicionales',
                        prefixIcon: const Icon(Icons.note),
                        maxLines: 3,
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
                        : Text(widget.cliente == null ? 'Crear Cliente' : 'Actualizar Cliente'),
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
          'email': _emailController.text.isNotEmpty ? _emailController.text : null,
          'telefono': _telefonoController.text.isNotEmpty ? _telefonoController.text : null,
          'direccion': _direccionController.text.isNotEmpty ? _direccionController.text : null,
          'cuit': _cuitController.text.isNotEmpty ? _cuitController.text : null,
          'observaciones': _observacionesController.text.isNotEmpty ? _observacionesController.text : null,
        };

        Cliente cliente;
        if (widget.cliente == null) {
          cliente = await ClienteService.createCliente(data);
        } else {
          cliente = await ClienteService.updateCliente(widget.cliente!.id!, data);
        }

        if (mounted) {
          Navigator.pop(context, cliente);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.cliente == null ? 'Cliente creado exitosamente' : 'Cliente actualizado exitosamente'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
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
