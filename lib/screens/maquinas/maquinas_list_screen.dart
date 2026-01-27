import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../models/maquina.dart';
import '../forms/maquina_form_screen.dart';
import 'maquina_detail_screen.dart';
import '../../widgets/optimized_widgets.dart';

/// Pantalla de lista de máquinas
class OptimizedMaquinasListScreen extends ConsumerStatefulWidget {
  final bool? showAppBar;

  const OptimizedMaquinasListScreen({Key? key, this.showAppBar})
      : super(key: key);

  @override
  ConsumerState<OptimizedMaquinasListScreen> createState() =>
      _OptimizedMaquinasListScreenState();
}

class _OptimizedMaquinasListScreenState
    extends ConsumerState<OptimizedMaquinasListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(maquinasProvider.notifier).loadMaquinas();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maquinasState = ref.watch(maquinasProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Máquinas',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: (widget.showAppBar ?? false)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                color: const Color(0xFF1C1C1E),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            color: const Color(0xFF1C1C1E),
            onPressed: () {
              ref.read(maquinasProvider.notifier).loadMaquinas();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar máquinas...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // Lista de máquinas
          Expanded(
            child: _buildMaquinasList(maquinasState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showMaquinaForm(context);
        },
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMaquinasList(BaseState state) {
    if (state is LoadingState) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is ErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar máquinas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(maquinasProvider.notifier).loadMaquinas();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final maquinas =
        state is LoadedState<List<Maquina>> ? state.data : <Maquina>[];
    final filteredMaquinas = maquinas.where((maquina) {
      if (_searchQuery.isEmpty) return true;
      return maquina.nombre.toLowerCase().contains(_searchQuery) ||
          maquina.marca.toLowerCase().contains(_searchQuery) ||
          maquina.modelo.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredMaquinas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.build,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No se encontraron máquinas'
                  : 'No hay máquinas guardadas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Intenta con otros términos de búsqueda'
                  : 'Agrega tu primera máquina tocando el botón +',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(maquinasProvider.notifier).loadMaquinas();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredMaquinas.length,
        itemBuilder: (context, index) {
          final maquina = filteredMaquinas[index];
          return _buildMaquinaCard(maquina);
        },
      ),
    );
  }

  Widget _buildMaquinaCard(Maquina maquina) {
    return OptimizedCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showMaquinaDetail(maquina),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: _getEstadoColor(maquina.estado ?? 'Activo'),
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(maquina.estado ?? 'Activo')
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.build,
                      color: _getEstadoColor(maquina.estado ?? 'Activo'),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          maquina.nombre,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${maquina.marca} ${maquina.modelo}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, maquina),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (maquina.ano > 0) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Año: ${maquina.ano}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ],
              if (maquina.anchoTrabajo != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.straighten,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ancho: ${maquina.anchoTrabajo}m',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ],
              if (maquina.estado != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getEstadoColor(maquina.estado!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    maquina.estado!,
                    style: TextStyle(
                      color: _getEstadoColor(maquina.estado!),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'activo':
      case 'disponible':
        return Colors.green;
      case 'mantenimiento':
        return Colors.orange;
      case 'inactivo':
      case 'fuera de servicio':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showMaquinaForm(BuildContext context, [Maquina? maquina]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MaquinaFormScreen(maquina: maquina),
      ),
    ).then((_) {
      // Recargar la lista después de crear/editar
      ref.read(maquinasProvider.notifier).loadMaquinas();
    });
  }

  void _showMaquinaDetail(Maquina maquina) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MaquinaDetailScreen(maquina: maquina),
      ),
    ).then((_) {
      // Recargar la lista después de cualquier cambio
      ref.read(maquinasProvider.notifier).loadMaquinas();
    });
  }

  void _handleMenuAction(String action, Maquina maquina) {
    switch (action) {
      case 'edit':
        _showMaquinaForm(context, maquina);
        break;
      case 'delete':
        _showDeleteConfirmation(maquina);
        break;
    }
  }

  void _showDeleteConfirmation(Maquina maquina) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Máquina'),
        content: Text(
            '¿Estás seguro de que quieres eliminar la máquina "${maquina.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(maquinasProvider.notifier)
                    .deleteMaquina(maquina.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Máquina eliminada exitosamente')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar máquina: $e')),
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
}
