import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/personal.dart';
import '../../providers/optimized_providers.dart';
import '../../widgets/optimized_widgets.dart';
import 'personal_form_dialog.dart';
import 'personal_detail_screen.dart';

class PersonalListScreen extends ConsumerStatefulWidget {
  const PersonalListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PersonalListScreen> createState() => _PersonalListScreenState();
}

class _PersonalListScreenState extends ConsumerState<PersonalListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(personalProvider.notifier).loadPersonal();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final personalState = ref.watch(personalProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(personalProvider.notifier).loadPersonal();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar personal...',
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
          
          // Lista de personal
          Expanded(
            child: _buildPersonalList(personalState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPersonalDialog(),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPersonalList(BaseState personalState) {
    if (personalState is LoadingState) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando personal...'),
          ],
        ),
      );
    }

    if (personalState is ErrorState) {
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
              'Error al cargar personal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              personalState.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(personalProvider.notifier).loadPersonal();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (personalState is LoadedState<List<Personal>>) {
      final personalList = personalState.data;
      final filteredList = _searchQuery.isEmpty
          ? personalList
          : personalList.where((personal) {
              return personal.nombre.toLowerCase().contains(_searchQuery) ||
                     personal.dni.toLowerCase().contains(_searchQuery) ||
                     (personal.telefono?.toLowerCase().contains(_searchQuery) ?? false);
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
                    ? 'No hay personal registrado'
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
                    ? 'Toca el botón + para agregar personal'
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
          await ref.read(personalProvider.notifier).loadPersonal();
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final personal = filteredList[index];
            return _buildPersonalCard(personal);
          },
        ),
      );
    }

    return const Center(
      child: Text('Estado desconocido'),
    );
  }

  Widget _buildPersonalCard(Personal personal) {
    return OptimizedCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            personal.initials,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          personal.nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('DNI: ${personal.dni}'),
            if (personal.telefono != null && personal.telefono!.isNotEmpty)
              Text('Tel: ${personal.telefono}'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, personal),
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
        onTap: () => _navigateToDetail(personal),
      ),
    );
  }

  void _handleMenuAction(String action, Personal personal) {
    switch (action) {
      case 'view':
        _navigateToDetail(personal);
        break;
      case 'edit':
        _showEditPersonalDialog(personal);
        break;
      case 'delete':
        _showDeleteConfirmation(personal);
        break;
    }
  }

  void _navigateToDetail(Personal personal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalDetailScreen(personal: personal),
      ),
    );
  }

  void _showAddPersonalDialog() {
    showDialog(
      context: context,
      builder: (context) => PersonalFormDialog(
        onSaved: () {
          ref.read(personalProvider.notifier).loadPersonal();
          OptimizedSnackBar.showSuccess(
            context,
            message: 'Personal agregado exitosamente',
          );
        },
      ),
    );
  }

  void _showEditPersonalDialog(Personal personal) {
    showDialog(
      context: context,
      builder: (context) => PersonalFormDialog(
        personal: personal,
        onSaved: () {
          ref.read(personalProvider.notifier).loadPersonal();
          OptimizedSnackBar.showSuccess(
            context,
            message: 'Personal actualizado exitosamente',
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(Personal personal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar a ${personal.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deletePersonal(personal);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePersonal(Personal personal) async {
    try {
      await ref.read(personalProvider.notifier).deletePersonal(personal.id!);
      OptimizedSnackBar.showSuccess(
        context,
        message: 'Personal eliminado exitosamente',
      );
    } catch (e) {
      OptimizedSnackBar.showError(
        context,
        message: 'Error al eliminar personal: $e',
      );
    }
  }
}
