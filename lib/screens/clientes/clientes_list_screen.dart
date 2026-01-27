import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/cliente.dart';
import '../../providers/optimized_providers.dart';
import '../../widgets/optimized_widgets.dart';
import '../forms/cliente_form_screen.dart';
import 'cliente_detail_screen.dart';

class ClientesListScreen extends ConsumerStatefulWidget {
  const ClientesListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ClientesListScreen> createState() => _ClientesListScreenState();
}

class _ClientesListScreenState extends ConsumerState<ClientesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(clientesProvider.notifier).loadClientes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientesState = ref.watch(clientesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Clientes',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            color: const Color(0xFF1C1C1E),
            onPressed: () {
              ref.read(clientesProvider.notifier).loadClientes();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          // Barra de búsqueda y botón de nuevo cliente
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar clientes...',
                      hintStyle:
                          TextStyle(color: Colors.grey[500], fontSize: 15),
                      prefixIcon:
                          Icon(Icons.search_rounded, color: Colors.grey[400]),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              color: Colors.grey[400],
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                    style: const TextStyle(fontSize: 15),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => _showAddClienteDialog(),
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    tooltip: 'Agregar Cliente',
                  ),
                ),
              ],
            ),
          ),

          // Lista de clientes
          Expanded(
            child: _buildClientesList(clientesState),
          ),
        ],
      ),
    );
  }

  Widget _buildClientesList(BaseState clientesState) {
    if (clientesState is LoadingState) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando clientes...'),
          ],
        ),
      );
    }

    if (clientesState is ErrorState) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar clientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              clientesState.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(clientesProvider.notifier).loadClientes();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (clientesState is LoadedState<List<Cliente>>) {
      final clientesList = clientesState.data;
      final filteredList = _searchQuery.isEmpty
          ? clientesList
          : clientesList.where((cliente) {
              return (cliente.nombre?.toLowerCase().contains(_searchQuery) ??
                      false) ||
                  (cliente.email?.toLowerCase().contains(_searchQuery) ??
                      false) ||
                  (cliente.telefono?.toLowerCase().contains(_searchQuery) ??
                      false) ||
                  (cliente.cuit?.toLowerCase().contains(_searchQuery) ?? false);
            }).toList();

      if (filteredList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty
                    ? 'No hay clientes guardados'
                    : 'No se encontraron resultados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isEmpty
                    ? 'Toca el botón + para agregar un cliente'
                    : 'Intenta con otros términos de búsqueda',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          await ref.read(clientesProvider.notifier).loadClientes();
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final cliente = filteredList[index];
            return _buildClienteCard(cliente);
          },
        ),
      );
    }

    return const Center(
      child: Text('Estado desconocido'),
    );
  }

  Widget _buildClienteCard(Cliente cliente) {
    return OptimizedCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 4,
            ),
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Text(
              cliente.initials,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            cliente.nombre ?? 'Sin nombre',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              if (cliente.email != null && cliente.email!.isNotEmpty)
                Text('Email: ${cliente.email}'),
              if (cliente.telefono != null && cliente.telefono!.isNotEmpty)
                Text('Tel: ${cliente.telefono}'),
              if (cliente.cuit != null && cliente.cuit!.isNotEmpty)
                Text('CUIT: ${cliente.cuit}'),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: Colors.grey[500]),
            onSelected: (value) => _handleMenuAction(value, cliente),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility),
                    SizedBox(width: 8),
                    Text('Ver detalles'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          onTap: () => _navigateToDetail(cliente),
        ),
      ),
    );
  }

  void _handleMenuAction(String action, Cliente cliente) {
    switch (action) {
      case 'view':
        _navigateToDetail(cliente);
        break;
      case 'edit':
        _showEditClienteDialog(cliente);
        break;
      case 'delete':
        _showDeleteConfirmation(cliente);
        break;
    }
  }

  void _navigateToDetail(Cliente cliente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClienteDetailScreen(cliente: cliente),
      ),
    );
  }

  void _showAddClienteDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ClienteFormScreen(),
      ),
    ).then((_) {
      ref.read(clientesProvider.notifier).loadClientes();
      OptimizedSnackBar.showSuccess(
        context,
        message: 'Cliente agregado exitosamente',
      );
    });
  }

  void _showEditClienteDialog(Cliente cliente) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClienteFormScreen(cliente: cliente),
      ),
    ).then((_) {
      ref.read(clientesProvider.notifier).loadClientes();
      OptimizedSnackBar.showSuccess(
        context,
        message: 'Cliente actualizado exitosamente',
      );
    });
  }

  void _showDeleteConfirmation(Cliente cliente) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
            '¿Estás seguro de que deseas eliminar a ${cliente.nombre ?? "este cliente"}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteCliente(cliente);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCliente(Cliente cliente) async {
    try {
      await ref.read(clientesProvider.notifier).deleteCliente(cliente.id!);
      OptimizedSnackBar.showSuccess(
        context,
        message: 'Cliente eliminado exitosamente',
      );
    } catch (e) {
      OptimizedSnackBar.showError(
        context,
        message: 'Error al eliminar cliente: $e',
      );
    }
  }
}
