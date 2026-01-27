import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../models/campo.dart';
import '../../models/cliente.dart';
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
  bool _esPropio = true;
  int? _clienteId;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.campo?.nombre ?? '');
    _superficieController = TextEditingController(
        text: widget.campo?.superficieHa.toString() ?? '');
    _latitudController =
        TextEditingController(text: widget.campo?.latitud?.toString() ?? '');
    _longitudController =
        TextEditingController(text: widget.campo?.longitud?.toString() ?? '');
    _detallesController =
        TextEditingController(text: widget.campo?.detalles ?? '');

    // Inicializar valores de estado
    if (widget.campo != null) {
      _esPropio = widget.campo!.esPropio;
      _clienteId = widget.campo!.clienteId;
    } else {
      // Por defecto no es propio (0) según requerimiento, o true?
      // Requerimiento: "Ensure that newly created fields default to "Propio = 0" (false)." -> Wait, summary says this.
      // User prompt says: "Modify the field creation form to include a toggle for "Propio" diff: "Propio" (Owned) fields." and "If a field is not "Propio", allow the user to select an associated client."
      // The summary says "newly created fields default to "Propio = 0" (false)". I will follow the summary as it likely reflects previous decisions/context.
      _esPropio = false;
    }

    // Cargar clientes si es necesario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clientesProvider.notifier).loadClientes();
    });
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
    final clientesState = ref.watch(clientesProvider);
    List<Cliente> clientes = [];
    if (clientesState is LoadedState<List<Cliente>>) {
      clientes = clientesState.data;
    }

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
                      validator: (value) => Validators.validateRequired(
                          value, 'Nombre del campo'),
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

              // Propiedad y Cliente
              OptimizedCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Propiedad',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Es campo propio'),
                      value: _esPropio,
                      onChanged: (bool value) {
                        setState(() {
                          _esPropio = value;
                          if (_esPropio) {
                            _clienteId = null;
                          }
                        });
                      },
                      activeColor: const Color(0xFF2E7D32),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (!_esPropio) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _clienteId,
                        decoration: InputDecoration(
                          labelText: 'Cliente Asociado',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        items: clientes.map((cliente) {
                          return DropdownMenuItem<int>(
                            value: cliente.id,
                            child: Text(cliente.nombre ?? 'Sin nombre'),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            _clienteId = newValue;
                          });
                        },
                        validator: (value) {
                          if (!_esPropio && value == null) {
                            return 'Seleccione un cliente';
                          }
                          return null;
                        },
                      ),
                      if (clientesState is LoadingState)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: LinearProgressIndicator(),
                        ),
                    ],
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
                          : Text(widget.campo == null
                              ? 'Crear Campo'
                              : 'Actualizar Campo'),
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
          'latitud': _latitudController.text.isNotEmpty
              ? double.parse(_latitudController.text)
              : null,
          'longitud': _longitudController.text.isNotEmpty
              ? double.parse(_longitudController.text)
              : null,
          'detalles': _detallesController.text.isNotEmpty
              ? _detallesController.text
              : null,
          'propio': _esPropio, // Send boolean directly, Dio handles it
          'cliente_id': _esPropio ? null : _clienteId,
          'id_cliente':
              _esPropio ? null : _clienteId, // Send both keys to be safe
        };

        print('🔵 PAYLOAD CREACIÓN/EDICIÓN CAMPO: $data'); // DEBUG PRINT

        if (widget.campo == null) {
          final newCampo =
              await ref.read(camposProvider.notifier).createCampo(data);
          if (mounted) {
            Navigator.pop(context, newCampo);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Campo creado exitosamente')),
            );
          }
        } else {
          await ref
              .read(camposProvider.notifier)
              .updateCampo(widget.campo!.id!, data);
          if (mounted) {
            // Need to create an updated Campo object to return
            final updatedCampo = widget.campo!.copyWith(
              nombre: _nombreController.text,
              superficieHa: double.parse(_superficieController.text),
              latitud: _latitudController.text.isNotEmpty
                  ? double.parse(_latitudController.text)
                  : null,
              longitud: _longitudController.text.isNotEmpty
                  ? double.parse(_longitudController.text)
                  : null,
              detalles: _detallesController.text,
              esPropio: _esPropio,
              clienteId: _esPropio ? null : _clienteId,
            );

            Navigator.pop(context, updatedCampo);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Campo actualizado exitosamente')),
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
