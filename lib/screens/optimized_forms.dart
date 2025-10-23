import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/optimized_providers.dart';
import '../models/campo.dart';
import '../models/maquina.dart';
import '../models/personal.dart';
import '../models/cliente.dart';
import '../services/cliente_service.dart';
import 'additional_forms.dart';

/// Formulario para crear/editar campos
class CampoFormDialog extends ConsumerStatefulWidget {
  final Campo? campo;
  
  const CampoFormDialog({Key? key, this.campo}) : super(key: key);

  @override
  ConsumerState<CampoFormDialog> createState() => _CampoFormDialogState();
}

class _CampoFormDialogState extends ConsumerState<CampoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _superficieController;
  late TextEditingController _latitudController;
  late TextEditingController _longitudController;
  late TextEditingController _detallesController;

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
    return AlertDialog(
      title: Text(widget.campo == null ? 'Nuevo Campo' : 'Editar Campo'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Campo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _superficieController,
                  decoration: const InputDecoration(
                    labelText: 'Superficie (hectáreas)',
                    border: OutlineInputBorder(),
                  ),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitudController,
                        decoration: const InputDecoration(
                          labelText: 'Latitud',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _longitudController,
                        decoration: const InputDecoration(
                          labelText: 'Longitud',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _detallesController,
                  decoration: const InputDecoration(
                    labelText: 'Detalles (opcional)',
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
          child: Text(widget.campo == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final data = {
          'nombre': _nombreController.text,
          'superficie_ha': double.parse(_superficieController.text),
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
      }
    }
  }

}

/// Formulario para crear/editar costos
class CostoFormDialog extends ConsumerStatefulWidget {
  final dynamic costo;
  
  const CostoFormDialog({Key? key, this.costo}) : super(key: key);

  @override
  ConsumerState<CostoFormDialog> createState() => _CostoFormDialogState();
}

class _CostoFormDialogState extends ConsumerState<CostoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descripcionController;
  late TextEditingController _montoController;
  late TextEditingController _categoriaController;
  late TextEditingController _fechaController;
  DateTime? _fecha;

  @override
  void initState() {
    super.initState();
    _descripcionController = TextEditingController(text: widget.costo?.descripcion ?? '');
    _montoController = TextEditingController(text: widget.costo?.monto?.toString() ?? '');
    _categoriaController = TextEditingController(text: widget.costo?.categoria ?? '');
    _fechaController = TextEditingController(text: widget.costo?.fecha?.toString() ?? '');
    _fecha = widget.costo?.fecha ?? DateTime.now();
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _montoController.dispose();
    _categoriaController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.costo == null ? 'Nuevo Costo' : 'Editar Costo'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La descripción es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _montoController,
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El monto es requerido';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Ingrese un número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoriaController,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Forma de Pago',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                    DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
                    DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                    DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                  ],
                  onChanged: (value) {
                    // TODO: Implementar selector de forma de pago
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Pagado'),
                  subtitle: const Text('Marcar si ya fue pagado'),
                  value: false, // TODO: Implementar estado de pago
                  onChanged: (value) {
                    // TODO: Implementar toggle de pago
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fechaController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _fecha ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _fecha = date;
                        _fechaController.text = '${date.day}/${date.month}/${date.year}';
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
          child: Text(widget.costo == null ? 'Crear' : 'Actualizar'),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final data = {
          'descripcion': _descripcionController.text,
          'monto': double.parse(_montoController.text),
          'fecha': _fecha?.toIso8601String().split('T')[0], // Formato YYYY-MM-DD
          'destinatario': _categoriaController.text,
          'pagado': false,
          'forma_pago': 'Efectivo',
          'categoria': _categoriaController.text,
          'es_cobro': false,
          'cobrar_a': null,
          'fecha_pago_limite': null,
          'id_trabajo': null,
        };

        if (widget.costo == null) {
          await ref.read(costosProvider.notifier).createCosto(data);
        } else {
          await ref.read(costosProvider.notifier).updateCosto(widget.costo.id, data);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.costo == null ? 'Costo creado exitosamente' : 'Costo actualizado exitosamente'),
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

}

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
  bool _servicioContratado = false;
  
  // Selectores
  Campo? _campoSeleccionado;
  List<Maquina> _maquinasSeleccionadas = [];
  List<Personal> _personalSeleccionado = [];
  Cliente? _clienteSeleccionado;
  
  // Listas para los selectores
  List<Campo> _campos = [];
  List<Campo> _camposFiltrados = []; // Campos filtrados por cliente
  List<Maquina> _maquinas = [];
  List<Personal> _personal = [];
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
      _servicioContratado = widget.trabajo!.servicioContratado;
    } else {
      // Si es un trabajo nuevo, valores por defecto
      _esTercero = false;
      _cobrado = false;
      _servicioContratado = false;
    }
    
    // Debug logs
    print('DEBUG: Trabajo esTercero: ${widget.trabajo?.esTercero}');
    print('DEBUG: _esTercero inicializado a: $_esTercero');
    print('DEBUG: Trabajo cliente: ${widget.trabajo?.cliente}');
    print('DEBUG: Trabajo completo: ${widget.trabajo?.toJson()}');
    print('DEBUG: JSON original del trabajo: ${widget.trabajo?.toJson()}');
    
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
        // Seleccionar cliente si es servicio contratado
        if (_servicioContratado && widget.trabajo!.cliente != null) {
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
    print('DEBUG: _aplicarFiltrosCampos - _servicioContratado: $_servicioContratado, _clienteSeleccionado: $_clienteSeleccionado');
    
    if (_servicioContratado && _clienteSeleccionado != null) {
      // Si es servicio contratado y hay cliente seleccionado, cargar solo sus campos
      print('DEBUG: Cargando campos del prestador ${_clienteSeleccionado!.nombre}');
      try {
        _camposFiltrados = await ClienteService.getCamposByCliente(_clienteSeleccionado!.id!);
        print('DEBUG: Campos del prestador cargados: ${_camposFiltrados.length}');
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

  @override
  Widget build(BuildContext context) {
    print('DEBUG: build() ejecutado - _esTercero: $_esTercero');
    
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
                
                // Toggle Servicio Contratado
                Row(
                  children: [
                    const Text('Servicio contratado:'),
                    const Spacer(),
                    Switch(
                      value: _servicioContratado,
                      onChanged: (value) {
                        setState(() {
                          _servicioContratado = value;
                          // Limpiar selecciones si se desactiva "servicio contratado"
                          if (!value) {
                            _clienteSeleccionado = null;
                            _clienteController.clear();
                            _campoSeleccionado = null;
                          }
                        });
                      },
                    ),
                  ],
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
                
                if (_servicioContratado) ...[
                  DropdownButtonFormField<Cliente>(
                    decoration: InputDecoration(
                      labelText: _servicioContratado ? 'Prestador de servicio' : 'Cliente',
                      border: const OutlineInputBorder(),
                      hintText: _servicioContratado ? 'Seleccione un prestador' : 'Seleccione un cliente',
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
                      if (_servicioContratado && value == null) {
                        return 'El prestador de servicio es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
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
          'cliente': _servicioContratado && _clienteSeleccionado != null 
              ? _clienteSeleccionado!.nombre 
              : (_servicioContratado ? 'Prestador no seleccionado' : 'Trabajo propio'),
          'estado': _estadoSeleccionado ?? 'Pendiente',
          'a_terceros': _esTercero,
          'cobrado': _cobrado,
          'servicio_contratado': _servicioContratado,
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
