import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/optimized_providers.dart';
import '../models/campo.dart';
import '../models/maquina.dart';
import '../models/personal.dart';
import '../models/cliente.dart';
import '../models/trabajo.dart';
import '../models/tipo_trabajo.dart';
import '../services/cliente_service.dart';
import '../services/tipo_trabajo_service.dart';
import '../widgets/optimized_widgets.dart';
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
    _superficieController = TextEditingController(
        text: widget.campo?.superficieHa.toString() ?? '');
    _latitudController =
        TextEditingController(text: widget.campo?.latitud?.toString() ?? '');
    _longitudController =
        TextEditingController(text: widget.campo?.longitud?.toString() ?? '');
    _detallesController =
        TextEditingController(text: widget.campo?.detalles ?? '');
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
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OptimizedCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Básica',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      OptimizedTextField(
                        controller: _nombreController,
                        label: 'Nombre del Campo',
                        hint: 'Ingrese el nombre del campo',
                        prefixIcon: const Icon(Icons.landscape),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El nombre es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      OptimizedTextField(
                        controller: _superficieController,
                        label: 'Superficie (hectáreas)',
                        hint: 'Ingrese la superficie',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.straighten),
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
                const SizedBox(height: 24),
                OptimizedCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ubicación',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OptimizedTextField(
                              controller: _latitudController,
                              label: 'Latitud',
                              hint: 'Ej: -34.6037',
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(Icons.location_on),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OptimizedTextField(
                              controller: _longitudController,
                              label: 'Longitud',
                              hint: 'Ej: -58.3816',
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(Icons.location_on),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OptimizedCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalles Adicionales',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      OptimizedTextField(
                        controller: _detallesController,
                        label: 'Detalles (opcional)',
                        hint: 'Información adicional sobre el campo',
                        maxLines: 3,
                        prefixIcon: const Icon(Icons.note),
                      ),
                    ],
                  ),
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
          'nombre': _nombreController.text.trim(),
          'hectareas': double.tryParse(
                  _superficieController.text.replaceAll(',', '.')) ??
              0.0,
          'superficie_ha': double.tryParse(
                  _superficieController.text.replaceAll(',', '.')) ??
              0.0,
          'latitud': _latitudController.text.isNotEmpty
              ? double.tryParse(_latitudController.text.replaceAll(',', '.'))
              : null,
          'longitud': _longitudController.text.isNotEmpty
              ? double.tryParse(_longitudController.text.replaceAll(',', '.'))
              : null,
          'detalles': _detallesController.text.trim().isNotEmpty
              ? _detallesController.text.trim()
              : null,
        };

        if (widget.campo == null) {
          await ref.read(camposProvider.notifier).createCampo(data);
        } else {
          await ref
              .read(camposProvider.notifier)
              .updateCampo(widget.campo!.id!, data);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.campo == null
                  ? 'Campo creado exitosamente'
                  : 'Campo actualizado exitosamente'),
              backgroundColor: Colors.green,
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
  String? _formaPago;
  bool _pagado = false;

  @override
  void initState() {
    super.initState();
    _descripcionController =
        TextEditingController(text: widget.costo?.descripcion ?? '');
    _montoController =
        TextEditingController(text: widget.costo?.monto?.toString() ?? '');
    _categoriaController =
        TextEditingController(text: widget.costo?.categoria ?? '');
    _fechaController =
        TextEditingController(text: widget.costo?.fecha?.toString() ?? '');
    _fecha = widget.costo?.fecha ?? DateTime.now();
    _formaPago = widget.costo?.formaPago ?? 'Efectivo';
    _pagado = widget.costo?.pagado ?? false;
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
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OptimizedCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Básica',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      OptimizedTextField(
                        controller: _descripcionController,
                        label: 'Descripción',
                        hint: 'Ingrese la descripción del costo',
                        prefixIcon: const Icon(Icons.description),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La descripción es requerida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      OptimizedTextField(
                        controller: _montoController,
                        label: 'Monto',
                        hint: 'Ingrese el monto',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(Icons.attach_money),
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
                      const SizedBox(height: 24),
                      OptimizedTextField(
                        controller: _categoriaController,
                        label: 'Categoría',
                        hint: 'Ingrese la categoría',
                        prefixIcon: const Icon(Icons.category),
                      ),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _fechaController,
                            decoration: InputDecoration(
                              hintText: 'Seleccione la fecha',
                              suffixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
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
                                  _fechaController.text =
                                      '${date.day}/${date.month}/${date.year}';
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OptimizedCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información de Pago',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Forma de Pago',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.payment),
                        ),
                        value: _formaPago,
                        items: const [
                          DropdownMenuItem(
                              value: 'Efectivo', child: Text('Efectivo')),
                          DropdownMenuItem(
                              value: 'Transferencia',
                              child: Text('Transferencia')),
                          DropdownMenuItem(
                              value: 'Cheque', child: Text('Cheque')),
                          DropdownMenuItem(
                              value: 'Tarjeta', child: Text('Tarjeta')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _formaPago = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      SwitchListTile(
                        title: const Text('Pagado'),
                        subtitle:
                            const Text('Marcar si el costo ya fue pagado'),
                        value: _pagado,
                        onChanged: (value) {
                          setState(() {
                            _pagado = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
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
          'descripcion': _descripcionController.text.trim(),
          'monto':
              double.tryParse(_montoController.text.replaceAll(',', '.')) ??
                  0.0,
          'fecha': _fecha != null
              ? DateFormat('yyyy-MM-dd').format(_fecha!)
              : DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'destinatario': _categoriaController.text.trim(),
          'pagado': _pagado,
          'forma_pago': _formaPago ?? 'Efectivo',
          'categoria': _categoriaController.text.trim(),
          'es_cobro': false,
          'cobrar_a': null,
          'fecha_pago_limite': null,
          'id_trabajo': null,
        };

        if (widget.costo == null) {
          await ref.read(costosProvider.notifier).createCosto(data);
        } else {
          final int? id =
              widget.costo is Map ? widget.costo['id'] : widget.costo.id;
          if (id != null) {
            await ref.read(costosProvider.notifier).updateCosto(id, data);
          }
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.costo == null
                  ? 'Costo creado exitosamente'
                  : 'Costo actualizado exitosamente'),
              backgroundColor: Colors.green,
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
  int? _tipoTrabajoSeleccionado; // ID del tipo de trabajo seleccionado
  List<TipoTrabajo> _tiposTrabajo = [];
  late TextEditingController _cultivoController;
  late TextEditingController _descripcionController;
  late TextEditingController _fechaInicioController;
  late TextEditingController _fechaFinController;
  late TextEditingController _clienteController;
  late TextEditingController _montoCobradoController;
  late TextEditingController _rindeCosechaController;
  late TextEditingController _humedadCosechaController;
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
    // Si el trabajo tiene idTipoTrabajo, usarlo directamente
    // Si no, intentar encontrarlo por el nombre del tipo (se hará después de cargar los tipos)
    _tipoTrabajoSeleccionado = widget.trabajo?.idTipoTrabajo;
    _cultivoController =
        TextEditingController(text: widget.trabajo?.cultivo ?? '');
    _descripcionController =
        TextEditingController(text: widget.trabajo?.observaciones ?? '');
    _fechaInicioController = TextEditingController(
        text: widget.trabajo?.fechaInicio?.toString() ?? '');
    _fechaFinController =
        TextEditingController(text: widget.trabajo?.fechaFin?.toString() ?? '');
    _clienteController =
        TextEditingController(text: widget.trabajo?.cliente ?? '');
    _montoCobradoController = TextEditingController(
        text: widget.trabajo?.montoCobrado?.toString() ?? '');
    _rindeCosechaController = TextEditingController(
        text: widget.trabajo?.rindeCosecha?.toString() ?? '');
    _humedadCosechaController = TextEditingController(
        text: widget.trabajo?.humedadCosecha?.toString() ?? '');
    _fechaInicio = widget.trabajo?.fechaInicio ?? DateTime.now();
    _fechaFin = widget.trabajo?.fechaFin ?? DateTime.now();

    // Estados adicionales
    _estadoSeleccionado = widget.trabajo?.estado ?? 'Pendiente';

    // Inicializar valores según el trabajo existente
    if (widget.trabajo != null) {
      _esTercero = widget.trabajo!.esTercero;
      _cobrado = widget.trabajo!.cobrado;
      _servicioContratado = widget.trabajo!.servicioContratado;
    } else {
      _esTercero = false;
      _cobrado = false;
      _servicioContratado = false;
    }

    // Cargar datos necesarios para los selectores
    Future.microtask(() => _loadDataForSelectors());
  }

  @override
  void dispose() {
    _cultivoController.dispose();
    _descripcionController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    _clienteController.dispose();
    _montoCobradoController.dispose();
    _rindeCosechaController.dispose();
    _humedadCosechaController.dispose();
    super.dispose();
  }

  Future<void> _loadDataForSelectors() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      // Cargar tipos de trabajo
      try {
        _tiposTrabajo = await TipoTrabajoService.getTiposTrabajo();

        // Si el trabajo tiene tipoTrabajoNombre pero no idTipoTrabajo, buscar el ID
        if (widget.trabajo != null &&
            widget.trabajo!.idTipoTrabajo == null &&
            widget.trabajo!.tipoTrabajoNombre != null) {
          final tipoEncontrado = _tiposTrabajo.firstWhere(
            (tipo) => tipo.trabajo == widget.trabajo!.tipoTrabajoNombre,
            orElse: () => _tiposTrabajo.isNotEmpty
                ? _tiposTrabajo.first
                : TipoTrabajo(id: 0, trabajo: ''),
          );
          if (tipoEncontrado.id != 0) {
            setState(() {
              _tipoTrabajoSeleccionado = tipoEncontrado.id;
            });
          }
        }
      } catch (e) {
        _tiposTrabajo = [];
      }

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
        // Seleccionar cliente si es servicio contratado o trabajo a terceros
        if ((_servicioContratado || _esTercero) &&
            widget.trabajo!.cliente != null) {
          final found =
              _clientes.where((c) => c.nombre == widget.trabajo!.cliente);
          _clienteSeleccionado = found.isNotEmpty ? found.first : null;
        }

        // Seleccionar campo
        if (widget.trabajo!.idCampo != null) {
          final found =
              _camposFiltrados.where((c) => c.id == widget.trabajo!.idCampo);
          _campoSeleccionado = found.isNotEmpty ? found.first : null;
        }

        // Seleccionar máquinas
        _maquinasSeleccionadas = _maquinas
            .where((maquina) =>
                (widget.trabajo!.idMaquinas as List).contains(maquina.id))
            .toList();

        // Seleccionar personal
        _personalSeleccionado = _personal
            .where((persona) =>
                (widget.trabajo!.idPersonal as List).contains(persona.id))
            .toList();
      }
    } catch (e) {
      // Manejar errores silenciosamente
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  // Método para aplicar filtros de campos según el cliente seleccionado
  Future<void> _aplicarFiltrosCampos() async {
    if ((_servicioContratado || _esTercero) && _clienteSeleccionado != null) {
      // Si es servicio contratado o trabajo a terceros y hay cliente seleccionado, cargar solo sus campos
      try {
        _camposFiltrados =
            await ClienteService.getCamposByCliente(_clienteSeleccionado!.id!);
      } catch (e) {
        _camposFiltrados = [];
      }
    } else {
      // Si no es trabajo a terceros, mostrar todos los campos propios
      _camposFiltrados = List.from(_campos);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return AlertDialog(
        title:
            Text(widget.trabajo == null ? 'Nuevo Trabajo' : 'Editar Trabajo'),
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
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sección: Información General
                OptimizedCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información General',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Trabajo',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work),
                        ),
                        value: _tipoTrabajoSeleccionado,
                        items: _tiposTrabajo.map((tipo) {
                          return DropdownMenuItem<int>(
                            value: tipo.id,
                            child: Text(tipo.trabajo),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            _tipoTrabajoSeleccionado = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'El tipo de trabajo es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      OptimizedTextField(
                        controller: _cultivoController,
                        label: 'Cultivo',
                        hint: 'Ingrese el tipo de cultivo',
                        prefixIcon: const Icon(Icons.eco),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El cultivo es requerido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      OptimizedTextField(
                        controller: _descripcionController,
                        label: 'Descripción',
                        hint: 'Observaciones adicionales',
                        maxLines: 3,
                        prefixIcon: const Icon(Icons.description),
                      ),
                      // Campos específicos para cosecha (tipo de trabajo id = 1)
                      if (_tipoTrabajoSeleccionado == 1) ...[
                        const SizedBox(height: 24),
                        OptimizedTextField(
                          controller: _rindeCosechaController,
                          label: 'Rinde Cosecha (kg/ha)',
                          hint: 'Ingrese el rinde de la cosecha',
                          prefixIcon: const Icon(Icons.trending_up),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 24),
                        OptimizedTextField(
                          controller: _humedadCosechaController,
                          label: 'Humedad Cosecha (%)',
                          hint: 'Ingrese el porcentaje de humedad',
                          prefixIcon: const Icon(Icons.water_drop),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Sección: Configuración
                OptimizedCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configuración',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      SwitchListTile(
                        title: const Text('Servicio Contratado'),
                        subtitle: const Text(
                            'Trabajo realizado por un prestador externo'),
                        value: _servicioContratado,
                        onChanged: (value) {
                          setState(() {
                            _servicioContratado = value;
                            if (value) {
                              _esTercero = false;
                            }
                            if (!value) {
                              _clienteSeleccionado = null;
                              _clienteController.clear();
                              _campoSeleccionado = null;
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Trabajo a Terceros'),
                        subtitle:
                            const Text('Trabajo realizado para un cliente'),
                        value: _esTercero,
                        onChanged: (value) async {
                          setState(() {
                            _esTercero = value;
                            if (value) {
                              _servicioContratado = false;
                            }
                            if (!value) {
                              _clienteSeleccionado = null;
                              _clienteController.clear();
                              _campoSeleccionado = null;
                            }
                          });
                          await _aplicarFiltrosCampos();
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      const Divider(),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.info),
                        ),
                        value: _estadoSeleccionado,
                        items: const [
                          DropdownMenuItem(
                              value: 'Pendiente', child: Text('Pendiente')),
                          DropdownMenuItem(
                              value: 'En progreso', child: Text('En progreso')),
                          DropdownMenuItem(
                              value: 'Completado', child: Text('Completado')),
                          DropdownMenuItem(
                              value: 'Cancelado', child: Text('Cancelado')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _estadoSeleccionado = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Cobrado'),
                        subtitle:
                            const Text('Marcar si el trabajo ya fue cobrado'),
                        value: _cobrado,
                        onChanged: (value) {
                          setState(() {
                            _cobrado = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_cobrado) ...[
                        const SizedBox(height: 16),
                        OptimizedTextField(
                          controller: _montoCobradoController,
                          label: 'Monto Cobrado',
                          hint: 'Ingrese el monto',
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.attach_money),
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
                const SizedBox(height: 24),

                // Sección: Cliente y Campo
                OptimizedCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cliente y Campo',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      if (_esTercero) ...[
                        DropdownButtonFormField<Cliente>(
                          decoration: const InputDecoration(
                            labelText: 'Cliente',
                            border: OutlineInputBorder(),
                            hintText: 'Seleccione un cliente',
                            prefixIcon: Icon(Icons.person),
                          ),
                          value: _clienteSeleccionado,
                          items: _clientes.map((cliente) {
                            return DropdownMenuItem<Cliente>(
                              value: cliente,
                              child: Text(cliente.nombre ?? 'Sin nombre'),
                            );
                          }).toList(),
                          onChanged: (Cliente? newValue) async {
                            setState(() {
                              _clienteSeleccionado = newValue;
                              _clienteController.text = newValue?.nombre ?? '';
                              _campoSeleccionado = null;
                            });
                            await _aplicarFiltrosCampos();
                            if (mounted) setState(() {});
                          },
                          validator: (value) {
                            if (_esTercero && value == null) {
                              return 'El cliente es requerido para trabajos a terceros';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (_servicioContratado) ...[
                        DropdownButtonFormField<Cliente>(
                          decoration: const InputDecoration(
                            labelText: 'Prestador de Servicio',
                            border: OutlineInputBorder(),
                            hintText: 'Seleccione un prestador',
                            prefixIcon: Icon(Icons.business),
                          ),
                          value: _clienteSeleccionado,
                          items: _clientes.map((cliente) {
                            return DropdownMenuItem<Cliente>(
                              value: cliente,
                              child: Text(cliente.nombre ?? 'Sin nombre'),
                            );
                          }).toList(),
                          onChanged: (Cliente? cliente) async {
                            setState(() {
                              _clienteSeleccionado = cliente;
                              _clienteController.text = cliente?.nombre ?? '';
                              _campoSeleccionado = null;
                            });
                            await _aplicarFiltrosCampos();
                            if (mounted) setState(() {});
                          },
                          validator: (value) {
                            if (_servicioContratado && value == null) {
                              return 'El prestador de servicio es requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<Campo>(
                              decoration: const InputDecoration(
                                labelText: 'Campo',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.landscape),
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
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => _showCampoForm(),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Nuevo'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Sección: Recursos
                OptimizedCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recursos',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      // Máquinas
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Máquinas',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          Text(
                            '${_maquinasSeleccionadas.length} seleccionadas',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => _showMaquinaForm(),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Nueva'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isLoadingData)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_maquinas.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No hay máquinas disponibles',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        )
                      else
                        Container(
                          constraints: const BoxConstraints(maxHeight: 150),
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _maquinas.map((maquina) {
                                final isSelected = _maquinasSeleccionadas
                                    .any((m) => m.id == maquina.id);
                                return FilterChip(
                                  label: Text(maquina.nombre),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _maquinasSeleccionadas.add(maquina);
                                      } else {
                                        _maquinasSeleccionadas.removeWhere(
                                            (m) => m.id == maquina.id);
                                      }
                                    });
                                  },
                                  selectedColor: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.2),
                                  checkmarkColor:
                                      Theme.of(context).primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 16),
                      // Personal
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Operarios',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          Text(
                            '${_personalSeleccionado.length} seleccionados',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                    ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => _showPersonalForm(),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Nuevo'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isLoadingData)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_personal.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No hay operarios disponibles',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        )
                      else
                        Container(
                          constraints: const BoxConstraints(maxHeight: 150),
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _personal.map((persona) {
                                final isSelected = _personalSeleccionado
                                    .any((p) => p.id == persona.id);
                                return FilterChip(
                                  label: Text(persona.nombre),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _personalSeleccionado.add(persona);
                                      } else {
                                        _personalSeleccionado.removeWhere(
                                            (p) => p.id == persona.id);
                                      }
                                    });
                                  },
                                  selectedColor: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.2),
                                  checkmarkColor:
                                      Theme.of(context).primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Sección: Fechas
                OptimizedCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fechas',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha de Inicio',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _fechaInicioController,
                            decoration: InputDecoration(
                              hintText: 'Seleccione la fecha de inicio',
                              suffixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
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
                                  _fechaInicioController.text =
                                      DateFormat('dd/MM/yyyy').format(date);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha de Fin',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _fechaFinController,
                            decoration: InputDecoration(
                              hintText: 'Seleccione la fecha de fin',
                              suffixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).cardColor,
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
                                  _fechaFinController.text =
                                      DateFormat('dd/MM/yyyy').format(date);
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
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
    print('🔵 _submitForm llamado (Dialog)');
    if (_formKey.currentState!.validate()) {
      print('🔵 Validación del formulario exitosa (Dialog)');
      try {
        print('🔵 Iniciando construcción del request... (Dialog)');

        // Obtener listas de IDs
        final List<int> idMaquinas =
            _maquinasSeleccionadas.map((m) => m.id!).toList();
        final List<int> idPersonal =
            _personalSeleccionado.map((p) => p.id!).toList();

        // Construir el request según el formato requerido por el endpoint
        final data = <String, dynamic>{
          'id_tipo_trabajo': _tipoTrabajoSeleccionado,
          'cliente': (_servicioContratado || _esTercero) &&
                  _clienteSeleccionado != null
              ? _clienteSeleccionado!.nombre
              : null,
          'fecha_inicio': _fechaInicio != null
              ? DateFormat('yyyy-MM-dd').format(_fechaInicio!)
              : null,
          'id_campo': _campoSeleccionado?.id,
          'campo_id':
              _campoSeleccionado?.id, // Enviamos ambos por compatibilidad
          'cultivo': _cultivoController.text,
          'observaciones': _descripcionController.text.isNotEmpty
              ? _descripcionController.text
              : null,
          'estado': _estadoSeleccionado ?? 'Pendiente',
          'a_terceros': _esTercero,
          'servicio_contratado': _servicioContratado,
          'fecha_fin': _fechaFin != null
              ? DateFormat('yyyy-MM-dd').format(_fechaFin!)
              : null,
          'id_maquinas': idMaquinas,
          'id_personal': idPersonal,
          'cobrado': _cobrado,
          'monto_cobrado':
              _cobrado ? double.tryParse(_montoCobradoController.text) : 0.0,
        };

        // Agregar campos de cosecha: si es cosecha (id = 1) usar valores ingresados, sino enviar 0
        if (_tipoTrabajoSeleccionado == 1) {
          if (_rindeCosechaController.text.isNotEmpty) {
            data['rinde_cosecha'] =
                double.tryParse(_rindeCosechaController.text);
          }
          if (_humedadCosechaController.text.isNotEmpty) {
            data['humedad_cosecha'] =
                double.tryParse(_humedadCosechaController.text);
          }
        } else {
          data['rinde_cosecha'] = 0.0;
          data['humedad_cosecha'] = 0.0;
        }

        // Log del body
        debugPrint('📤 REQUEST BODY: $data');

        if (widget.trabajo == null) {
          await ref.read(trabajosProvider.notifier).createTrabajo(data);
        } else {
          final int id = widget.trabajo is Trabajo
              ? widget.trabajo.id!
              : widget.trabajo.id;
          await ref.read(trabajosProvider.notifier).updateTrabajo(id, data);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.trabajo == null
                  ? 'Trabajo creado exitosamente'
                  : 'Trabajo actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('❌ Error en _submitForm: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
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
