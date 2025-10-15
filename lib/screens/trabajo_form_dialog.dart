import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/optimized_providers.dart';
import '../models/campo.dart';
import '../models/maquina.dart';
import '../models/personal.dart';
import '../models/cliente.dart';
import '../services/cliente_service.dart';
import 'additional_forms.dart';
import 'optimized_forms.dart';
import '../utils/validators.dart';

/// Formulario para crear/editar trabajos
class TrabajoFormDialog extends ConsumerStatefulWidget {
  final dynamic trabajo;
  
  const TrabajoFormDialog({Key? key, this.trabajo}) : super(key: key);

  @override
  ConsumerState<TrabajoFormDialog> createState() => _TrabajoFormDialogState();
}

class _TrabajoFormDialogState extends ConsumerState<TrabajoFormDialog> {
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
    
    // Debug logs
    print('DEBUG: Trabajo esTercero: ${widget.trabajo?.esTercero}');
    print('DEBUG: _esTercero inicializado a: $_esTercero');
    print('DEBUG: Trabajo cliente: ${widget.trabajo?.cliente}');
    print('DEBUG: Trabajo completo: ${widget.trabajo?.toJson()}');
    
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
          try {
            _clienteSeleccionado = _clientes.firstWhere(
              (cliente) => cliente.nombre == widget.trabajo!.cliente,
            );
          } catch (e) {
            // Si no se encuentra el cliente, dejar _clienteSeleccionado como null
            _clienteSeleccionado = null;
            print('DEBUG: Cliente no encontrado: ${widget.trabajo!.cliente}');
          }
        }

        // Seleccionar campo
        try {
          _campoSeleccionado = _camposFiltrados.firstWhere(
            (campo) => campo.id == widget.trabajo!.idCampo,
          );
        } catch (e) {
          // Si no se encuentra el campo, seleccionar el primero disponible o null
          _campoSeleccionado = _camposFiltrados.isNotEmpty ? _camposFiltrados.first : null;
          print('DEBUG: Campo no encontrado: ${widget.trabajo!.idCampo}');
        }

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
    print('DEBUG: _aplicarFiltrosCampos - _esTercero: $_esTercero, _clienteSeleccionado: $_clienteSeleccionado');
    
    if (_esTercero && _clienteSeleccionado != null) {
      // Si es trabajo a terceros y hay cliente seleccionado, cargar solo sus campos
      print('DEBUG: Cargando campos del cliente ${_clienteSeleccionado!.nombre}');
      try {
        _camposFiltrados = await ClienteService.getCamposByCliente(_clienteSeleccionado!.id!);
        print('DEBUG: Campos del cliente cargados: ${_camposFiltrados.length}');
      } catch (e) {
        print('Error cargando campos del cliente: $e');
        _camposFiltrados = [];
      }
    } else {
      // Si no es trabajo a terceros, mostrar todos los campos propios
      print('DEBUG: Mostrando todos los campos propios');
      _camposFiltrados = List.from(_campos);
      print('DEBUG: Campos propios cargados: ${_camposFiltrados.length}');
    }
    
    print('DEBUG: _aplicarFiltrosCampos completado. Campos filtrados: ${_camposFiltrados.length}');
  }

  void _showClienteForm() async {
    final result = await showDialog<Cliente>(
      context: context,
      builder: (context) => const ClienteFormDialog(),
    );
    
    if (result != null) {
      // Recargar clientes y seleccionar el nuevo
      try {
        _clientes = await ClienteService.getClientes();
        setState(() {
          _clienteSeleccionado = result;
          _clienteController.text = result.nombre;
        });
        // Aplicar filtros de campos para el nuevo cliente
        await _aplicarFiltrosCampos();
      } catch (e) {
        print('Error recargando clientes: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return AlertDialog(
        title: Text(widget.trabajo == null ? 'Nuevo Trabajo' : 'Editar Trabajo'),
        content: const SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando datos...'),
              ],
            ),
          ),
        ),
      );
    }

    return AlertDialog(
      title: Text(widget.trabajo == null ? 'Nuevo Trabajo' : 'Editar Trabajo'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _tipoController,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Trabajo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El tipo es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cultivoController,
                  decoration: const InputDecoration(
                    labelText: 'Cultivo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El cultivo es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
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
                
                // Toggle Es Tercero
                Row(
                  children: [
                    const Text('Trabajo a terceros:'),
                    const Spacer(),
                    Switch(
                      value: _esTercero,
                      onChanged: (value) async {
                        print('DEBUG: Switch cambiado a: $value');
                        print('DEBUG: _esTercero antes: $_esTercero');
                        
                        // Actualizar el estado ANTES del setState
                        _esTercero = value;
                        print('DEBUG: _esTercero actualizado a: $_esTercero');
                        
                        // Limpiar selecciones si se desactiva "a terceros"
                        if (!value) {
                          print('DEBUG: Limpiando selecciones porque esTercero = false');
                          _clienteSeleccionado = null;
                          _clienteController.clear();
                          _campoSeleccionado = null;
                        } else {
                          // Si se activa "a terceros", asegurar que _clienteSeleccionado sea válido
                          if (_clienteSeleccionado != null && !_clientes.contains(_clienteSeleccionado)) {
                            print('DEBUG: Limpiando cliente seleccionado porque no está en la lista');
                            _clienteSeleccionado = null;
                            _clienteController.clear();
                          }
                        }
                        
                        // Forzar rebuild del widget
                        setState(() {
                          print('DEBUG: setState ejecutado');
                          // El estado ya se actualizó arriba
                        });
                        
                        print('DEBUG: setState completado');
                        
                        print('DEBUG: Aplicando filtros de campos...');
                        // Aplicar filtros de campos
                        await _aplicarFiltrosCampos();
                        print('DEBUG: Filtros aplicados. _esTercero final: $_esTercero');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Selector de Cliente (solo visible si es a terceros)
                // Debug log
                Builder(builder: (context) {
                  print('DEBUG: Renderizando formulario - _esTercero: $_esTercero');
                  print('DEBUG: _clienteSeleccionado: $_clienteSeleccionado');
                  print('DEBUG: _clientes.length: ${_clientes.length}');
                  print('DEBUG: _clientes: ${_clientes.map((c) => '${c.id}:${c.nombre}').join(', ')}');
                  return Container();
                }),
                
                // TEST: Mostrar estado actual
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Text(
                    'DEBUG: _esTercero = $_esTercero, Cliente visible: ${_esTercero ? "SÍ" : "NO"}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                
                if (_esTercero) ...[
                  // Selector de Cliente con dropdown
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Cliente>(
                          decoration: const InputDecoration(
                            labelText: 'Cliente',
                            border: OutlineInputBorder(),
                            hintText: 'Seleccione un cliente',
                          ),
                          value: _clienteSeleccionado != null && _clientes.any((c) => c.id == _clienteSeleccionado!.id) 
                              ? _clienteSeleccionado 
                              : null,
                          items: [
                            // Opción para crear nuevo cliente
                            const DropdownMenuItem<Cliente>(
                              value: null,
                              child: Row(
                                children: [
                                  Icon(Icons.add, size: 16),
                                  SizedBox(width: 8),
                                  Text('Nuevo Cliente'),
                                ],
                              ),
                            ),
                            // Separador
                            const DropdownMenuItem<Cliente>(
                              enabled: false,
                              child: Divider(),
                            ),
                            // Lista de clientes existentes
                            ..._clientes.map((cliente) {
                              return DropdownMenuItem<Cliente>(
                                value: cliente,
                                child: Text(cliente.nombre),
                              );
                            }).toList(),
                          ],
                          onChanged: (Cliente? cliente) {
                            if (cliente == null) {
                              // Usuario seleccionó "Nuevo Cliente"
                              _showClienteForm();
                            } else {
                              // Usuario seleccionó un cliente existente
                              setState(() {
                                _clienteSeleccionado = cliente;
                                _clienteController.text = cliente.nombre;
                                _campoSeleccionado = null; // Limpiar campo seleccionado
                              });
                              // Aplicar filtros de campos para el cliente seleccionado
                              _aplicarFiltrosCampos();
                            }
                          },
                          validator: (value) {
                            if (_esTercero && value == null) {
                              return 'El cliente es requerido para trabajos a terceros';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _showClienteForm,
                        icon: const Icon(Icons.add),
                        tooltip: 'Agregar Cliente',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Toggle Cobrado
                Row(
                  children: [
                    const Text('Cobrado:'),
                    const Spacer(),
                    Switch(
                      value: _cobrado,
                      onChanged: (value) {
                        setState(() {
                          _cobrado = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Campo Monto Cobrado (solo si está cobrado)
                if (_cobrado) ...[
                  TextFormField(
                    controller: _montoCobradoController,
                    decoration: const InputDecoration(
                      labelText: 'Monto Cobrado',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (_cobrado && (value == null || value.isEmpty)) {
                        return 'El monto es requerido si está cobrado';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
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
                        if (_isLoadingData)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_maquinas.isEmpty)
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
                        if (_isLoadingData)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_personal.isEmpty)
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fechaInicioController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Inicio',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
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
                TextFormField(
                  controller: _fechaFinController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de Fin',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text(widget.trabajo == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
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
          'campo_id': _campoSeleccionado?.id ?? 0,
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
      }
    }
  }

  void _showCampoForm() async {
    final result = await showDialog<Campo>(
      context: context,
      builder: (context) => const CampoFormDialog(),
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
    final result = await showDialog<Maquina>(
      context: context,
      builder: (context) => const MaquinaFormDialog(),
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
    final result = await showDialog<Personal>(
      context: context,
      builder: (context) => const PersonalFormDialog(),
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

/// Formulario para crear/editar clientes
class ClienteFormDialog extends StatefulWidget {
  final Cliente? cliente;
  
  const ClienteFormDialog({Key? key, this.cliente}) : super(key: key);

  @override
  State<ClienteFormDialog> createState() => _ClienteFormDialogState();
}

class _ClienteFormDialogState extends State<ClienteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _cuitController;
  late TextEditingController _observacionesController;

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

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
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

        Navigator.pop(context, cliente);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.cliente == null ? 'Nuevo Cliente' : 'Editar Cliente'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre completo',
                    hintText: 'Ingresa el nombre completo',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => Validators.validateRequired(value, 'Nombre'),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Ingresa el email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => Validators.validateEmail(value),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _telefonoController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    hintText: 'Ingresa el teléfono',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _direccionController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    hintText: 'Ingresa la dirección',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _cuitController,
                  decoration: const InputDecoration(
                    labelText: 'CUIT',
                    hintText: 'Ingresa el CUIT',
                    prefixIcon: Icon(Icons.business),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _observacionesController,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones',
                    hintText: 'Ingresa observaciones adicionales',
                    prefixIcon: Icon(Icons.note),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
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
          child: Text(widget.cliente == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }
}
