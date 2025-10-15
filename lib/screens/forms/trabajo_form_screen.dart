import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../models/campo.dart';
import '../../models/maquina.dart';
import '../../models/personal.dart';
import '../../models/cliente.dart';
import '../../services/cliente_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';
import 'campo_form_screen.dart';
import 'maquina_form_screen.dart';
import 'personal_form_screen.dart';

/// Pantalla completa para crear/editar trabajos
class TrabajoFormScreen extends ConsumerStatefulWidget {
  final dynamic trabajo;
  
  const TrabajoFormScreen({Key? key, this.trabajo}) : super(key: key);

  @override
  ConsumerState<TrabajoFormScreen> createState() => _TrabajoFormScreenState();
}

class _TrabajoFormScreenState extends ConsumerState<TrabajoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tipoController;
  late TextEditingController _cultivoController;
  late TextEditingController _descripcionController;
  late TextEditingController _fechaInicioController;
  late TextEditingController _fechaFinController;
  late TextEditingController _clienteController;
  late TextEditingController _montoCobradoController;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  
  // Estados adicionales
  String? _estadoSeleccionado;
  bool _esTercero = false;
  bool _cobrado = false;
  
  // Selectores
  Campo? _campoSeleccionado;
  List<Maquina> _maquinasSeleccionadas = [];
  List<Personal> _personalSeleccionado = [];
  
  // Listas para los selectores
  List<Campo> _campos = [];
  List<Maquina> _maquinas = [];
  List<Personal> _personal = [];
  
  // Variables para cliente y campos filtrados
  Cliente? _clienteSeleccionado;
  List<Campo> _camposFiltrados = []; // Campos filtrados por cliente
  List<Cliente> _clientes = [];
  
  bool _isLoadingData = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tipoController = TextEditingController(text: widget.trabajo?.tipo ?? '');
    _cultivoController = TextEditingController(text: widget.trabajo?.cultivo ?? '');
    _descripcionController = TextEditingController(text: widget.trabajo?.observaciones ?? '');
    _fechaInicioController = TextEditingController(text: widget.trabajo?.fechaInicio?.toString() ?? '');
    _fechaFinController = TextEditingController(text: widget.trabajo?.fechaFin?.toString() ?? '');
    _clienteController = TextEditingController(text: widget.trabajo?.cliente ?? '');
    _montoCobradoController = TextEditingController(text: widget.trabajo?.montoCobrado?.toString() ?? '');
    _fechaInicio = widget.trabajo?.fechaInicio ?? DateTime.now();
    _fechaFin = widget.trabajo?.fechaFin ?? DateTime.now();
    
    // Estados adicionales
    _estadoSeleccionado = widget.trabajo?.estado ?? 'Pendiente';
    
    // FORZAR VALORES CORRECTOS PARA DEBUG
    if (widget.trabajo != null) {
      // Si hay un trabajo, usar sus valores reales
      _esTercero = widget.trabajo!.esTercero;
      _cobrado = widget.trabajo!.cobrado;
    } else {
      // Si es un trabajo nuevo, valores por defecto
      _esTercero = false;
      _cobrado = false;
    }
    
    // Cargar datos necesarios para los selectores
    Future.microtask(() => _loadDataForSelectors());
  }

  @override
  void dispose() {
    _tipoController.dispose();
    _cultivoController.dispose();
    _descripcionController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    _clienteController.dispose();
    _montoCobradoController.dispose();
    super.dispose();
  }

  Future<void> _loadDataForSelectors() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      // Cargar campos
      final camposState = ref.read(camposProvider);
      if (camposState is LoadedState<List<Campo>>) {
        _campos = camposState.data;
      } else {
        await ref.read(camposProvider.notifier).loadCampos();
        final newCamposState = ref.read(camposProvider);
        if (newCamposState is LoadedState<List<Campo>>) {
          _campos = newCamposState.data;
        }
      }

      // Cargar clientes
      try {
        _clientes = await ClienteService.getClientes();
      } catch (e) {
        print('Error cargando clientes: $e');
        _clientes = [];
      }

      // Cargar máquinas
      final maquinasState = ref.read(maquinasProvider);
      if (maquinasState is LoadedState<List<Maquina>>) {
        _maquinas = maquinasState.data;
      } else {
        await ref.read(maquinasProvider.notifier).loadMaquinas();
        final newMaquinasState = ref.read(maquinasProvider);
        if (newMaquinasState is LoadedState<List<Maquina>>) {
          _maquinas = newMaquinasState.data;
        }
      }

      // Cargar personal
      final personalState = ref.read(personalProvider);
      if (personalState is LoadedState<List<Personal>>) {
        _personal = personalState.data;
      } else {
        await ref.read(personalProvider.notifier).loadPersonal();
        final newPersonalState = ref.read(personalProvider);
        if (newPersonalState is LoadedState<List<Personal>>) {
          _personal = newPersonalState.data;
        }
      }

      // Aplicar filtros según el estado actual
      await _aplicarFiltrosCampos();

      // Seleccionar elementos existentes del trabajo
      if (widget.trabajo != null) {
        // Seleccionar cliente si es trabajo a terceros
        if (_esTercero && widget.trabajo!.cliente != null) {
          _clienteSeleccionado = _clientes.firstWhere(
            (cliente) => cliente.nombre == widget.trabajo!.cliente,
            orElse: () => _clientes.isNotEmpty ? _clientes.first : Cliente(id: 0, nombre: ''),
          );
        }

        // Seleccionar campo
        _campoSeleccionado = _camposFiltrados.firstWhere(
          (campo) => campo.id == widget.trabajo!.idCampo,
          orElse: () => _camposFiltrados.isNotEmpty ? _camposFiltrados.first : Campo(id: 0, nombre: '', superficieHa: 0),
        );

        // Seleccionar máquinas
        _maquinasSeleccionadas = _maquinas.where(
          (maquina) => widget.trabajo!.idMaquinas.contains(maquina.id),
        ).toList();

        // Seleccionar personal
        _personalSeleccionado = _personal.where(
          (persona) => widget.trabajo!.idPersonal.contains(persona.id),
        ).toList();
      }
    } catch (e) {
      // Manejar errores silenciosamente
      print('Error cargando datos para selectores: $e');
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  // Método para aplicar filtros de campos según el cliente seleccionado
  Future<void> _aplicarFiltrosCampos() async {
    if (_esTercero && _clienteSeleccionado != null) {
      // Si es trabajo a terceros y hay cliente seleccionado, cargar solo sus campos
      try {
        _camposFiltrados = await ClienteService.getCamposByCliente(_clienteSeleccionado!.id!);
      } catch (e) {
        print('Error cargando campos del cliente: $e');
        _camposFiltrados = [];
      }
    } else {
      // Si no es trabajo a terceros, mostrar todos los campos propios
      _camposFiltrados = List.from(_campos);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.trabajo == null ? 'Nuevo Trabajo' : 'Editar Trabajo',
        showBackButton: true,
        actions: [
          if (!_isLoadingData)
            TextButton(
              onPressed: _isSaving ? null : _submitForm,
              child: _isSaving 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    widget.trabajo == null ? 'Guardar' : 'Actualizar',
                    style: const TextStyle(color: Colors.white),
                  ),
            ),
        ],
      ),
      body: _isLoadingData
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando datos...'),
                ],
              ),
            )
          : SingleChildScrollView(
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
                              controller: _tipoController,
                              label: 'Tipo de Trabajo',
                              hint: 'Ej: Siembra, Cosecha, Pulverización',
                              prefixIcon: const Icon(Icons.work),
                              validator: (value) => Validators.validateRequired(value, 'Tipo de trabajo'),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _cultivoController,
                              label: 'Cultivo',
                              hint: 'Ej: Soja, Maíz, Trigo',
                              prefixIcon: const Icon(Icons.eco),
                              validator: (value) => Validators.validateRequired(value, 'Cultivo'),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _descripcionController,
                              label: 'Descripción',
                              hint: 'Detalles adicionales del trabajo',
                              prefixIcon: const Icon(Icons.description),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Configuración del trabajo
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Configuración del Trabajo',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            
                            // Toggle Es Tercero
                            SwitchListTile(
                              title: const Text('Trabajo a terceros'),
                              subtitle: const Text('Marcar si el trabajo es para un cliente'),
                              value: _esTercero,
                              onChanged: (value) async {
                                setState(() {
                                  _esTercero = value;
                                });
                                
                                // Limpiar selecciones si se desactiva "a terceros"
                                if (!value) {
                                  _clienteSeleccionado = null;
                                  _clienteController.clear();
                                  _campoSeleccionado = null;
                                }
                                
                                // Aplicar filtros de campos
                                await _aplicarFiltrosCampos();
                              },
                            ),
                            
                            // Selector de Cliente (solo visible si es a terceros)
                            if (_esTercero) ...[
                              const SizedBox(height: 16),
                              DropdownButtonFormField<Cliente>(
                                decoration: const InputDecoration(
                                  labelText: 'Cliente',
                                  border: OutlineInputBorder(),
                                  hintText: 'Seleccione un cliente',
                                ),
                                value: _clienteSeleccionado,
                                items: _clientes.map((cliente) {
                                  return DropdownMenuItem<Cliente>(
                                    value: cliente,
                                    child: Text(cliente.nombre),
                                  );
                                }).toList(),
                                onChanged: (Cliente? cliente) async {
                                  setState(() {
                                    _clienteSeleccionado = cliente;
                                    _clienteController.text = cliente?.nombre ?? '';
                                    _campoSeleccionado = null; // Limpiar campo seleccionado
                                  });
                                  // Aplicar filtros de campos para el cliente seleccionado
                                  await _aplicarFiltrosCampos();
                                },
                                validator: (value) {
                                  if (_esTercero && value == null) {
                                    return 'El cliente es requerido para trabajos a terceros';
                                  }
                                  return null;
                                },
                              ),
                            ],
                            
                            const SizedBox(height: 16),
                            
                            // Selector de Estado
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Estado',
                                border: OutlineInputBorder(),
                              ),
                              value: _estadoSeleccionado,
                              items: const [
                                DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
                                DropdownMenuItem(value: 'En progreso', child: Text('En progreso')),
                                DropdownMenuItem(value: 'Completado', child: Text('Completado')),
                                DropdownMenuItem(value: 'Cancelado', child: Text('Cancelado')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _estadoSeleccionado = value;
                                });
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Toggle Cobrado
                            SwitchListTile(
                              title: const Text('Cobrado'),
                              subtitle: const Text('Marcar si ya se cobró el trabajo'),
                              value: _cobrado,
                              onChanged: (value) {
                                setState(() {
                                  _cobrado = value;
                                });
                              },
                            ),
                            
                            // Campo Monto Cobrado (solo si está cobrado)
                            if (_cobrado) ...[
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _montoCobradoController,
                                label: 'Monto Cobrado',
                                hint: 'Ingrese el monto cobrado',
                                prefixIcon: const Icon(Icons.attach_money),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (_cobrado && (value == null || value.isEmpty)) {
                                    return 'El monto es requerido si está cobrado';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Recursos asignados
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recursos Asignados',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            
                            // Selector de Campo
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<Campo>(
                                    decoration: const InputDecoration(
                                      labelText: 'Campo',
                                      border: OutlineInputBorder(),
                                    ),
                                    value: _campoSeleccionado,
                                    items: _camposFiltrados.map((campo) {
                                      return DropdownMenuItem<Campo>(
                                        value: campo,
                                        child: Text(campo.nombre),
                                      );
                                    }).toList(),
                                    onChanged: (Campo? value) {
                                      setState(() {
                                        _campoSeleccionado = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Seleccione un campo';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _showCampoForm(),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Nuevo'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Selector de Máquinas (múltiple)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Máquinas (${_maquinasSeleccionadas.length} seleccionadas)',
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () => _showMaquinaForm(),
                                          icon: const Icon(Icons.add, size: 18),
                                          label: const Text('Nueva'),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (_maquinas.isEmpty)
                                      const Text(
                                        'No hay máquinas disponibles',
                                        style: TextStyle(color: Colors.grey),
                                      )
                                    else
                                      Container(
                                        constraints: const BoxConstraints(maxHeight: 120),
                                        child: SingleChildScrollView(
                                          child: Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: _maquinas.map((maquina) {
                                              final isSelected = _maquinasSeleccionadas.contains(maquina);
                                              return FilterChip(
                                                label: Text(maquina.nombre),
                                                selected: isSelected,
                                                onSelected: (selected) {
                                                  setState(() {
                                                    if (selected) {
                                                      _maquinasSeleccionadas.add(maquina);
                                                    } else {
                                                      _maquinasSeleccionadas.remove(maquina);
                                                    }
                                                  });
                                                },
                                                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                                checkmarkColor: Theme.of(context).primaryColor,
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Selector de Personal (múltiple)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Operarios (${_personalSeleccionado.length} seleccionados)',
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () => _showPersonalForm(),
                                          icon: const Icon(Icons.add, size: 18),
                                          label: const Text('Nuevo'),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (_personal.isEmpty)
                                      const Text(
                                        'No hay operarios disponibles',
                                        style: TextStyle(color: Colors.grey),
                                      )
                                    else
                                      Container(
                                        constraints: const BoxConstraints(maxHeight: 120),
                                        child: SingleChildScrollView(
                                          child: Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: _personal.map((persona) {
                                              final isSelected = _personalSeleccionado.contains(persona);
                                              return FilterChip(
                                                label: Text(persona.nombre),
                                                selected: isSelected,
                                                onSelected: (selected) {
                                                  setState(() {
                                                    if (selected) {
                                                      _personalSeleccionado.add(persona);
                                                    } else {
                                                      _personalSeleccionado.remove(persona);
                                                    }
                                                  });
                                                },
                                                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                                checkmarkColor: Theme.of(context).primaryColor,
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Fechas
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fechas',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _fechaInicioController,
                              label: 'Fecha de Inicio',
                              hint: 'Seleccione la fecha de inicio',
                              prefixIcon: const Icon(Icons.calendar_today),
                              readOnly: true,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _fechaInicio ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() {
                                    _fechaInicio = date;
                                    _fechaInicioController.text = '${date.day}/${date.month}/${date.year}';
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _fechaFinController,
                              label: 'Fecha de Fin',
                              hint: 'Seleccione la fecha de fin',
                              prefixIcon: const Icon(Icons.calendar_today),
                              readOnly: true,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _fechaFin ?? DateTime.now(),
                                  firstDate: _fechaInicio ?? DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() {
                                    _fechaFin = date;
                                    _fechaFinController.text = '${date.day}/${date.month}/${date.year}';
                                  });
                                }
                              },
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
                              : Text(widget.trabajo == null ? 'Crear Trabajo' : 'Actualizar Trabajo'),
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
          'tipo': _tipoController.text,
          'cultivo': _cultivoController.text,
          'observaciones': _descripcionController.text,
          'cliente': _esTercero && _clienteSeleccionado != null 
              ? _clienteSeleccionado!.nombre 
              : (_esTercero ? 'Cliente no seleccionado' : 'Trabajo propio'),
          'estado': _estadoSeleccionado ?? 'Pendiente',
          'a_terceros': _esTercero,
          'cobrado': _cobrado,
          'monto_cobrado': _cobrado && _montoCobradoController.text.isNotEmpty 
              ? double.tryParse(_montoCobradoController.text) 
              : null,
          'fecha_inicio': _fechaInicio?.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
          'fecha_fin': _fechaFin?.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
          'campo_id': _campoSeleccionado?.id ?? 1,
          'maquina_ids': _maquinasSeleccionadas.map((m) => m.id).toList(),
          'personal_ids': _personalSeleccionado.map((p) => p.id).toList(),
        };

        if (widget.trabajo == null) {
          await ref.read(trabajosProvider.notifier).createTrabajo(data);
        } else {
          await ref.read(trabajosProvider.notifier).updateTrabajo(widget.trabajo.id, data);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.trabajo == null ? 'Trabajo creado exitosamente' : 'Trabajo actualizado exitosamente'),
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

  void _showCampoForm() async {
    final result = await Navigator.push<Campo>(
      context,
      MaterialPageRoute(
        builder: (context) => const CampoFormScreen(),
      ),
    );
    
    if (result != null) {
      // Recargar campos y seleccionar el nuevo
      await _loadDataForSelectors();
      setState(() {
        _campoSeleccionado = result;
      });
    }
  }

  void _showMaquinaForm() async {
    final result = await Navigator.push<Maquina>(
      context,
      MaterialPageRoute(
        builder: (context) => const MaquinaFormScreen(),
      ),
    );
    
    if (result != null) {
      // Recargar máquinas y seleccionar la nueva
      await _loadDataForSelectors();
      setState(() {
        _maquinasSeleccionadas.add(result);
      });
    }
  }

  void _showPersonalForm() async {
    final result = await Navigator.push<Personal>(
      context,
      MaterialPageRoute(
        builder: (context) => const PersonalFormScreen(),
      ),
    );
    
    if (result != null) {
      // Recargar personal y seleccionar el nuevo
      await _loadDataForSelectors();
      setState(() {
        _personalSeleccionado.add(result);
      });
    }
  }
}
