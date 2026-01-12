import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/personal.dart';
import '../../providers/optimized_providers.dart';
import '../../providers/optimized_auth_provider.dart';
import '../../widgets/optimized_widgets.dart';
import '../forms/forms_screens.dart';
import '../optimized_main_screen_new.dart';
import '../optimized_screens.dart';
import '../maquinas/maquinas_list_screen.dart';
import '../mantenimientos/optimized_mantenimientos_screen.dart';
import '../finanzas/optimized_finanzas_screens.dart';
import '../reportes/optimized_reportes_screen.dart';
import 'personal_detail_screen.dart';

class PersonalListScreen extends ConsumerStatefulWidget {
  const PersonalListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PersonalListScreen> createState() => _PersonalListScreenState();
}

class _PersonalListScreenState extends ConsumerState<PersonalListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final personalState = ref.watch(personalProvider);
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Personal',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, size: 20),
          color: const Color(0xFF1C1C1E),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            color: const Color(0xFF1C1C1E),
            onPressed: () {
              ref.read(personalProvider.notifier).loadPersonal();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalFormScreen(),
      ),
    ).then((_) {
      ref.read(personalProvider.notifier).loadPersonal();
      OptimizedSnackBar.showSuccess(
        context,
        message: 'Personal agregado exitosamente',
      );
    });
  }

  void _showEditPersonalDialog(Personal personal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalFormScreen(personal: personal),
      ),
    ).then((_) {
      ref.read(personalProvider.notifier).loadPersonal();
      OptimizedSnackBar.showSuccess(
        context,
        message: 'Personal actualizado exitosamente',
      );
    });
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      width: 320,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          backgroundBlendMode: BlendMode.overlay,
        ),
        child: Column(
          children: [
            // Header con efecto blur y sombra
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.agriculture,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'GesAgro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Sistema de Gestión Agrícola',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Contenido del drawer con padding y scroll
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildModernDrawerItem(
                        context,
                        'Inicio',
                        Icons.home_rounded,
                        0,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const OptimizedMainScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Campos',
                        Icons.landscape_rounded,
                        1,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OptimizedCamposListScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Trabajos',
                        Icons.work_rounded,
                        2,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OptimizedTrabajosListScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Máquinas',
                        Icons.local_shipping_rounded,
                        -1,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OptimizedMaquinasListScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Mantenimientos',
                        Icons.build_rounded,
                        -1,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OptimizedMantenimientosScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Personal',
                        Icons.people_rounded,
                        -1,
                        isSelected: true,
                      ),
                      const SizedBox(height: 16),
                      
                      // Separador simple
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.grey[300],
                      ),
                      
                      _buildModernDrawerItem(
                        context,
                        'Finanzas',
                        Icons.account_balance_wallet_rounded,
                        -1,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OptimizedFinanzasMainScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Reportes',
                        Icons.analytics_rounded,
                        -1,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OptimizedReportesScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Separador simple
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.grey[300],
                      ),
                      
                      _buildModernDrawerItem(
                        context,
                        'Perfil',
                        Icons.person_rounded,
                        4,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OptimizedProfileScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Configuración',
                        Icons.settings_rounded,
                        -1,
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Implementar pantalla de configuración
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildModernDrawerItem(
                        context,
                        'Cerrar Sesión',
                        Icons.logout_rounded,
                        -1,
                        isDestructive: true,
                        onTap: () async {
                          Navigator.pop(context);
                          await _handleLogout(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    int index, {
    VoidCallback? onTap,
    bool isDestructive = false,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected 
                ? Theme.of(context).primaryColor.withOpacity(0.08)
                : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: isSelected 
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isDestructive 
                    ? Colors.red.shade600
                    : (isSelected 
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isDestructive 
                        ? Colors.red.shade600
                        : (isSelected 
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade700),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
