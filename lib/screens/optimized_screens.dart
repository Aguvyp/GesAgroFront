import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/optimized_widgets.dart';
import '../providers/optimized_providers.dart';
import 'campos/campo_detail_screen.dart';
import 'trabajos/trabajo_detail_screen.dart';
import 'forms/forms_screens.dart';
import 'forms/registrar_horas_form.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

/// ==================== CAMPOS LIST SCREEN OPTIMIZADA ====================

class OptimizedCamposListScreen extends ConsumerStatefulWidget {
  final bool? showAppBar;

  const OptimizedCamposListScreen({Key? key, this.showAppBar})
      : super(key: key);

  @override
  ConsumerState<OptimizedCamposListScreen> createState() =>
      _OptimizedCamposListScreenState();
}

class _OptimizedCamposListScreenState
    extends ConsumerState<OptimizedCamposListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(camposProvider.notifier).loadCampos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final camposState = ref.watch(camposProvider);

    final body = _buildCamposList(camposState);

    if (widget.showAppBar ?? false) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text(
            'Campos',
            style: TextStyle(
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
        body: body,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showCampoForm(context);
          },
          backgroundColor: const Color(0xFF2E7D32),
          child: const Icon(Icons.add),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 80,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                            decoration: const InputDecoration(
                              hintText: 'Buscar campo...',
                              hintStyle: TextStyle(
                                  fontSize: 15, color: Color(0xFF8E8E93)),
                              prefixIcon: Icon(Icons.search_rounded,
                                  color: Color(0xFF8E8E93), size: 20),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildClienteFilterIcon(),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: body,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCampoForm(context);
        },
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  int? _selectedClienteId;

  Widget _buildClienteFilterIcon() {
    final clientesState = ref.watch(clientesProvider);
    return Container(
      decoration: BoxDecoration(
        color: _selectedClienteId != null
            ? const Color(0xFF2E7D32).withOpacity(0.1)
            : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(
          Icons.person_outline_rounded,
          color: _selectedClienteId != null
              ? const Color(0xFF2E7D32)
              : const Color(0xFF8E8E93),
          size: 20,
        ),
        onPressed: () {
          if (clientesState is LoadedState<List<dynamic>>) {
            _showClienteFilterDialog(clientesState.data);
          }
        },
      ),
    );
  }

  void _showClienteFilterDialog(List<dynamic> clientes) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filtrar por Cliente',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() => _selectedClienteId = null);
                        Navigator.pop(context);
                      },
                      child: const Text('Limpiar'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: clientes.length,
                    itemBuilder: (context, index) {
                      final cliente = clientes[index];
                      final isSelected = _selectedClienteId == cliente.id;
                      return ListTile(
                        title: Text(cliente.nombre),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: Color(0xFF2E7D32))
                            : null,
                        onTap: () {
                          setState(() => _selectedClienteId = cliente.id);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildCamposList(BaseState state) {
    if (state is LoadingState) {
      return const OptimizedShimmerList();
    }

    if (state is ErrorState) {
      return OptimizedErrorWidget(
        message: state.message,
        onRetry: () {
          ref.read(camposProvider.notifier).loadCampos();
        },
      );
    }

    if (state is LoadedState<List<dynamic>>) {
      final campos = state.data;

      if (campos.isEmpty) {
        return const OptimizedEmptyWidget(
          message: 'No hay campos guardados',
          subtitle: 'Toca el botón + para agregar un nuevo campo',
          icon: Icons.landscape_outlined,
        );
      }

      var filteredCampos = campos;

      if (_selectedClienteId != null) {
        filteredCampos = filteredCampos
            .where((campo) => campo.clienteId == _selectedClienteId)
            .toList();
      }

      if (_searchQuery.isNotEmpty) {
        filteredCampos = filteredCampos.where((campo) {
          final query = _searchQuery.toLowerCase();
          return campo.nombre.toLowerCase().contains(query) ||
              (campo.detalles ?? '').toLowerCase().contains(query);
        }).toList();
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filteredCampos.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final campo = filteredCampos[index];
          return OptimizedCard(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: const Color(0xFF2E7D32),
                    width: 4,
                  ),
                ),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.landscape_rounded,
                      color: Color(0xFF2E7D32), size: 24),
                ),
                title: Text(
                  campo.nombre,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.41,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${campo.superficieHa.toStringAsFixed(2)} hectáreas',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8E8E93),
                      letterSpacing: -0.24,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CampoDetailScreen(campo: campo),
                    ),
                  );
                },
                trailing: PopupMenuButton(
                  icon: const Icon(Icons.more_vert_rounded,
                      color: Color(0xFF8E8E93)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: const Row(
                        children: [
                          Icon(Icons.edit_rounded,
                              size: 20, color: Color(0xFF1C1C1E)),
                          SizedBox(width: 12),
                          Text('Editar', style: TextStyle(fontSize: 17)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: const Row(
                        children: [
                          Icon(Icons.delete_rounded,
                              size: 20, color: Color(0xFFFF3B30)),
                          SizedBox(width: 12),
                          Text('Eliminar',
                              style: TextStyle(
                                  fontSize: 17, color: Color(0xFFFF3B30))),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showCampoForm(context, campo: campo);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, campo);
                    }
                  },
                ),
              ),
            ),
          );
        },
      );
    }

    return const OptimizedEmptyWidget(
      message: 'Estado desconocido',
      icon: Icons.help_outline,
    );
  }

  void _showCampoForm(BuildContext context, {dynamic campo}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampoFormScreen(campo: campo),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic campo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content:
            const Text('¿Estás seguro de que quieres eliminar este campo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(camposProvider.notifier).deleteCampo(campo.id);
              if (mounted) {
                Navigator.of(context).pop();
                OptimizedSnackBar.showSuccess(
                  context,
                  message: 'Campo eliminado exitosamente',
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

/// ==================== TRABAJOS LIST SCREEN OPTIMIZADA ====================

class OptimizedTrabajosListScreen extends ConsumerStatefulWidget {
  final String? estadoFiltro; // Filtro opcional por estado
  final bool? showAppBar; // Si debe mostrar AppBar

  const OptimizedTrabajosListScreen({
    Key? key,
    this.estadoFiltro,
    this.showAppBar,
  }) : super(key: key);

  @override
  ConsumerState<OptimizedTrabajosListScreen> createState() =>
      _OptimizedTrabajosListScreenState();
}

class _OptimizedTrabajosListScreenState
    extends ConsumerState<OptimizedTrabajosListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Filtros
  DateTime? _fechaFiltro;
  int? _clienteIdFiltro;
  String? _ownershipFiltro; // 'propio', 'tercero', 'contratado'
  String? _statusFiltro;
  String? _tipoFiltro;
  String? _cultivoFiltro;
  int? _campoIdFiltro;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trabajosProvider.notifier).loadTrabajos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trabajosState = ref.watch(trabajosProvider);

    final body = _buildTrabajosList(trabajosState);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 80,
              toolbarHeight: 80,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                            decoration: const InputDecoration(
                              hintText: 'Buscar trabajo...',
                              hintStyle: TextStyle(
                                  fontSize: 15, color: Color(0xFF8E8E93)),
                              prefixIcon: Icon(Icons.search_rounded,
                                  color: Color(0xFF8E8E93), size: 20),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterButtons(trabajosState),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: body,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTrabajoForm(context);
        },
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterButtons(BaseState trabajosState) {
    bool hasActiveFilters = _fechaFiltro != null ||
        _clienteIdFiltro != null ||
        _ownershipFiltro != null ||
        _statusFiltro != null ||
        _tipoFiltro != null ||
        _cultivoFiltro != null ||
        _campoIdFiltro != null;

    return Container(
      decoration: BoxDecoration(
        color: hasActiveFilters
            ? const Color(0xFF2E7D32).withOpacity(0.1)
            : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(
          hasActiveFilters
              ? Icons.filter_alt_rounded
              : Icons.filter_alt_outlined,
          color: hasActiveFilters
              ? const Color(0xFF2E7D32)
              : const Color(0xFF8E8E93),
          size: 20,
        ),
        onPressed: () => _showFilterSheet(trabajosState),
      ),
    );
  }

  void _showFilterSheet(BaseState trabajosState) {
    final clientesState = ref.read(clientesProvider);
    final camposState = ref.read(camposProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtros de Trabajos',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _fechaFiltro = null;
                            _clienteIdFiltro = null;
                            _ownershipFiltro = null;
                            _statusFiltro = null;
                            _tipoFiltro = null;
                            _cultivoFiltro = null;
                            _campoIdFiltro = null;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Limpiar'),
                      ),
                    ],
                  ),
                  const Divider(),

                  // Fecha
                  _buildFilterTitle('Fecha'),
                  ListTile(
                    title: Text(_fechaFiltro == null
                        ? 'Cualquier fecha'
                        : DateFormat('dd/MM/yyyy').format(_fechaFiltro!)),
                    trailing:
                        const Icon(Icons.calendar_today_rounded, size: 20),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _fechaFiltro ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setModalState(() => _fechaFiltro = picked);
                        setState(() => _fechaFiltro = picked);
                      }
                    },
                  ),

                  // Propiedad
                  _buildFilterTitle('Propiedad'),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip('Propio', _ownershipFiltro == 'propio',
                          () {
                        setModalState(() => _ownershipFiltro = 'propio');
                        setState(() => _ownershipFiltro = 'propio');
                      }),
                      _buildFilterChip(
                          'De Terceros', _ownershipFiltro == 'tercero', () {
                        setModalState(() => _ownershipFiltro = 'tercero');
                        setState(() => _ownershipFiltro = 'tercero');
                      }),
                      _buildFilterChip(
                          'Contratado', _ownershipFiltro == 'contratado', () {
                        setModalState(() => _ownershipFiltro = 'contratado');
                        setState(() => _ownershipFiltro = 'contratado');
                      }),
                    ],
                  ),

                  // Estado
                  _buildFilterTitle('Estado'),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip(
                          'Pendiente', _statusFiltro == 'pendiente', () {
                        setModalState(() => _statusFiltro = 'pendiente');
                        setState(() => _statusFiltro = 'pendiente');
                      }),
                      _buildFilterChip('En Curso', _statusFiltro == 'en curso',
                          () {
                        setModalState(() => _statusFiltro = 'en curso');
                        setState(() => _statusFiltro = 'en curso');
                      }),
                      _buildFilterChip(
                          'Completado', _statusFiltro == 'completado', () {
                        setModalState(() => _statusFiltro = 'completado');
                        setState(() => _statusFiltro = 'completado');
                      }),
                    ],
                  ),

                  if (clientesState is LoadedState<List<dynamic>>) ...[
                    _buildFilterTitle('Cliente'),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: clientesState.data.length,
                        itemBuilder: (context, index) {
                          final cliente = clientesState.data[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildFilterChip(
                                cliente.nombre, _clienteIdFiltro == cliente.id,
                                () {
                              setModalState(
                                  () => _clienteIdFiltro = cliente.id);
                              setState(() => _clienteIdFiltro = cliente.id);
                            }),
                          );
                        },
                      ),
                    ),
                  ],

                  if (camposState is LoadedState<List<dynamic>>) ...[
                    _buildFilterTitle('Campo'),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: camposState.data.length,
                        itemBuilder: (context, index) {
                          final campo = camposState.data[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildFilterChip(
                                campo.nombre, _campoIdFiltro == campo.id, () {
                              setModalState(() => _campoIdFiltro = campo.id);
                              setState(() => _campoIdFiltro = campo.id);
                            }),
                          );
                        },
                      ),
                    ),
                  ],

                  if (trabajosState is LoadedState<List<dynamic>>) ...[
                    // Tipo
                    _buildFilterTitle('Tipo de Trabajo'),
                    Wrap(
                      spacing: 8,
                      children: trabajosState.data
                          .map((t) => t.tipo.toString())
                          .toSet()
                          .map((tipo) =>
                              _buildFilterChip(tipo, _tipoFiltro == tipo, () {
                                setModalState(() => _tipoFiltro =
                                    _tipoFiltro == tipo ? null : tipo);
                                setState(() => _tipoFiltro =
                                    _tipoFiltro == tipo ? null : tipo);
                              }))
                          .toList(),
                    ),

                    // Cultivo
                    _buildFilterTitle('Cultivo'),
                    Wrap(
                      spacing: 8,
                      children: trabajosState.data
                          .map((t) => t.cultivo.toString())
                          .where((c) => c.isNotEmpty)
                          .toSet()
                          .map((cultivo) => _buildFilterChip(
                                  cultivo, _cultivoFiltro == cultivo, () {
                                setModalState(() => _cultivoFiltro =
                                    _cultivoFiltro == cultivo ? null : cultivo);
                                setState(() => _cultivoFiltro =
                                    _cultivoFiltro == cultivo ? null : cultivo);
                              }))
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Aplicar Filtros'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildFilterTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFF2E7D32).withOpacity(0.2),
      checkmarkColor: const Color(0xFF2E7D32),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildTrabajosList(BaseState state) {
    if (state is LoadingState) {
      return const OptimizedShimmerList();
    }

    if (state is ErrorState) {
      return OptimizedErrorWidget(
        message: state.message,
        onRetry: () {
          ref.read(trabajosProvider.notifier).loadTrabajos();
        },
      );
    }

    if (state is LoadedState<List<dynamic>>) {
      final trabajos = state.data;

      if (trabajos.isEmpty) {
        return const OptimizedEmptyWidget(
          message: 'No hay trabajos guardados',
          subtitle: 'Toca el botón + para agregar un nuevo trabajo',
          icon: Icons.work_outline,
        );
      }

      var filteredTrabajos = trabajos;

      // Filtros de búsqueda (texto libre)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        filteredTrabajos = filteredTrabajos.where((t) {
          return (t.tipo ?? '').toLowerCase().contains(query) ||
              (t.cultivo ?? '').toLowerCase().contains(query) ||
              (t.campoNombre ?? '').toLowerCase().contains(query) ||
              (t.cliente ?? '').toLowerCase().contains(query);
        }).toList();
      }

      // Filtro de fecha
      if (_fechaFiltro != null) {
        filteredTrabajos = filteredTrabajos.where((t) {
          return t.fechaInicio.year == _fechaFiltro!.year &&
              t.fechaInicio.month == _fechaFiltro!.month &&
              t.fechaInicio.day == _fechaFiltro!.day;
        }).toList();
      }

      // Filtro de propiedad
      if (_ownershipFiltro != null) {
        filteredTrabajos = filteredTrabajos.where((t) {
          if (_ownershipFiltro == 'propio')
            return !t.esTercero && !t.servicioContratado;
          if (_ownershipFiltro == 'tercero') return t.esTercero;
          if (_ownershipFiltro == 'contratado') return t.servicioContratado;
          return true;
        }).toList();
      }

      // Filtro de estado (avanzado)
      if (_statusFiltro != null) {
        filteredTrabajos = filteredTrabajos.where((t) {
          final est = (t.estado ?? '').toLowerCase();
          if (_statusFiltro == 'pendiente')
            return est == 'pendiente' || est == 'programado';
          if (_statusFiltro == 'en curso')
            return est.contains('curso') ||
                est.contains('ejecución') ||
                est.contains('progreso');
          if (_statusFiltro == 'completado')
            return est == 'completado' || est == 'finalizado';
          return true;
        }).toList();
      }

      // Filtro de cliente
      if (_clienteIdFiltro != null) {
        final clienteState = ref.read(clientesProvider);
        if (clienteState is LoadedState<List<dynamic>>) {
          final cliente = clienteState.data
              .firstWhere((c) => c.id == _clienteIdFiltro, orElse: () => null);
          if (cliente != null) {
            filteredTrabajos = filteredTrabajos.where((t) {
              return t.cliente == cliente.nombre;
            }).toList();
          }
        }
      }

      // Filtro de campo
      if (_campoIdFiltro != null) {
        filteredTrabajos =
            filteredTrabajos.where((t) => t.idCampo == _campoIdFiltro).toList();
      }

      // Aplicar filtro por estado si existe (del widget - legacy)
      if (widget.estadoFiltro != null && _statusFiltro == null) {
        filteredTrabajos = filteredTrabajos.where((trabajo) {
          final estado = (trabajo.estado ?? '').toLowerCase();
          final filtro = widget.estadoFiltro!.toLowerCase();

          if (filtro == 'pendientes' || filtro == 'pendiente') {
            return estado == 'pendiente' || estado == 'programado';
          } else if (filtro == 'en curso' || filtro == 'en_curso') {
            return estado == 'en curso' ||
                estado == 'en ejecución' ||
                estado == 'ejecutando' ||
                estado == 'en_progreso';
          } else if (filtro == 'completados' || filtro == 'completado') {
            return estado == 'completado' || estado == 'finalizado';
          } else if (filtro == 'todos') {
            return true;
          }
          return estado == filtro;
        }).toList();
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filteredTrabajos.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final trabajo = filteredTrabajos[index];
          final estado = trabajo.estado?.toLowerCase().trim() ?? '';
          final isEnCurso = [
            'en curso',
            'en_curso',
            'en progreso',
            'en_progreso',
            'ejecutando',
            'en ejecución'
          ].contains(estado);
          final isCompletado = ['completado', 'finalizado'].contains(estado);

          Color statusColor;
          IconData statusIcon;

          if (isEnCurso) {
            statusColor = const Color(AppConstants.accentColor);
            statusIcon = Icons.play_arrow_rounded;
          } else if (isCompletado) {
            statusColor = const Color(AppConstants.successColor);
            statusIcon = Icons.check_circle_rounded;
          } else {
            statusColor = const Color(AppConstants.infoColor);
            statusIcon = Icons.schedule_rounded;
          }

          String ownershipInfo = 'Propio';
          if (trabajo.esTercero) {
            ownershipInfo =
                trabajo.cliente != null && trabajo.cliente!.isNotEmpty
                    ? 'Cliente: ${trabajo.cliente}'
                    : 'A terceros';
          } else if (trabajo.servicioContratado) {
            ownershipInfo = 'Servicio Contratado';
          }

          return OptimizedCard(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: statusColor,
                    width: 4,
                  ),
                ),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                  ),
                ),
                title: Text(
                  '${trabajo.tipo} - ${trabajo.cultivo}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ownershipInfo,
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.landscape_rounded,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            trabajo.campoInfo,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        trabajo.estado ?? 'Desconocido',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isEnCurso)
                      IconButton(
                        icon: const Icon(Icons.add_circle, size: 28),
                        color: Colors.green,
                        tooltip: 'Registrar Horas',
                        onPressed: () {
                          // Calcular hectáreas disponibles
                          double? maxHectares;
                          if (trabajo.campoHa != null &&
                              trabajo.haRealizadas != null) {
                            maxHectares =
                                trabajo.campoHa! - trabajo.haRealizadas!;
                            if (maxHectares! < 0) maxHectares = 0;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegistrarHorasForm(
                                trabajoId: trabajo.id,
                                trabajoTitulo:
                                    '${trabajo.tipo} - ${trabajo.cultivo}',
                                maxHectares: maxHectares,
                              ),
                            ),
                          );
                        },
                      ),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert_rounded,
                          color: Color(0xFF8E8E93)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => _buildTrabajoMenuItems(trabajo),
                      onSelected: (value) =>
                          _handleTrabajoMenuAction(value, trabajo),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TrabajoDetailScreen(trabajo: trabajo),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    }

    return const OptimizedEmptyWidget(
      message: 'Estado desconocido',
      icon: Icons.help_outline,
    );
  }

  void _showTrabajoForm(BuildContext context, {dynamic trabajo}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrabajoFormScreen(trabajo: trabajo),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic trabajo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content:
            const Text('¿Estás seguro de que quieres eliminar este trabajo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Cerrar diálogo primero

              // Mostrar indicador de carga o simplemente borrar
              try {
                if (trabajo.id != null) {
                  await ref
                      .read(trabajosProvider.notifier)
                      .deleteTrabajo(trabajo.id!);
                  if (mounted) {
                    OptimizedSnackBar.showSuccess(
                      context,
                      message: 'Trabajo eliminado exitosamente',
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  OptimizedSnackBar.showError(
                    context,
                    message: 'Error al eliminar: $e',
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry> _buildTrabajoMenuItems(dynamic trabajo) {
    final estado = trabajo.estado?.toLowerCase() ?? 'pendiente';
    List<PopupMenuEntry> items = [];

    // State actions
    if (estado == 'pendiente' || estado == 'programado') {
      items.add(const PopupMenuItem(
        value: 'start',
        child: Row(
          children: [
            Icon(Icons.play_arrow_rounded,
                size: 20, color: Color(AppConstants.accentColor)),
            SizedBox(width: 12),
            Text('Iniciar', style: TextStyle(fontSize: 17)),
          ],
        ),
      ));
      items.add(const PopupMenuItem(
        value: 'complete',
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                size: 20, color: Color(AppConstants.successColor)),
            SizedBox(width: 12),
            Text('Completar', style: TextStyle(fontSize: 17)),
          ],
        ),
      ));
    } else if (['en curso', 'en_curso', 'en progreso'].contains(estado)) {
      items.add(const PopupMenuItem(
        value: 'complete',
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                size: 20, color: Color(AppConstants.successColor)),
            SizedBox(width: 12),
            Text('Completar', style: TextStyle(fontSize: 17)),
          ],
        ),
      ));
    }

    // Divider
    if (items.isNotEmpty) {
      items.add(const PopupMenuDivider());
    }

    items.add(const PopupMenuItem(
      value: 'edit',
      child: Row(
        children: [
          Icon(Icons.edit_rounded, size: 20, color: Color(0xFF1C1C1E)),
          SizedBox(width: 12),
          Text('Editar', style: TextStyle(fontSize: 17)),
        ],
      ),
    ));
    items.add(const PopupMenuItem(
      value: 'delete',
      child: Row(
        children: [
          Icon(Icons.delete_rounded, size: 20, color: Color(0xFFFF3B30)),
          SizedBox(width: 12),
          Text('Eliminar',
              style: TextStyle(fontSize: 17, color: Color(0xFFFF3B30))),
        ],
      ),
    ));

    return items;
  }

  void _handleTrabajoMenuAction(dynamic value, dynamic trabajo) {
    switch (value) {
      case 'start':
        _cambiarEstadoTrabajo(trabajo, 'En Curso');
        break;
      case 'complete':
        _cambiarEstadoTrabajo(trabajo, 'Completado');
        break;
      case 'edit':
        _showTrabajoForm(context, trabajo: trabajo);
        break;
      case 'delete':
        _showDeleteConfirmation(context, trabajo);
        break;
    }
  }

  void _cambiarEstadoTrabajo(dynamic trabajo, String nuevoEstado) async {
    try {
      // Preparar datos para actualizar
      final Map<String, dynamic> updateData = {
        'estado': nuevoEstado,
      };

      // Si se está completando el trabajo, agregar fecha de fin
      if (nuevoEstado == 'Completado') {
        updateData['fecha_fin'] =
            DateTime.now().toIso8601String().split('T')[0];
      }

      // Actualizar el trabajo usando el provider
      await ref
          .read(trabajosProvider.notifier)
          .updateTrabajo(trabajo.id, updateData);

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado cambiado a: $nuevoEstado'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar estado: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
