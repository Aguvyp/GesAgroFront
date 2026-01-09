import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/optimized_providers.dart';
import '../../models/maquina.dart';
import '../forms/maquina_form_screen.dart';
import '../optimized_main_screen_new.dart';
import '../optimized_screens.dart';
import '../personal/personal_list_screen.dart';
import '../finanzas/optimized_finanzas_screens.dart';
import '../reportes/optimized_reportes_screen.dart';
import '../mantenimientos/optimized_mantenimientos_screen.dart';
import 'maquina_detail_screen.dart';

/// Pantalla de lista de máquinas
class OptimizedMaquinasListScreen extends ConsumerStatefulWidget {
  const OptimizedMaquinasListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedMaquinasListScreen> createState() => _OptimizedMaquinasListScreenState();
}

class _OptimizedMaquinasListScreenState extends ConsumerState<OptimizedMaquinasListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Máquinas'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(maquinasProvider.notifier).loadMaquinas();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
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
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
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

    final maquinas = state is LoadedState<List<Maquina>> ? state.data : <Maquina>[];
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
              _searchQuery.isNotEmpty ? 'No se encontraron máquinas' : 'No hay máquinas registradas',
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showMaquinaDetail(maquina),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.build,
                      color: Theme.of(context).primaryColor,
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${maquina.marca} ${maquina.modelo}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                            Text('Eliminar', style: TextStyle(color: Colors.red)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        content: Text('¿Estás seguro de que quieres eliminar la máquina "${maquina.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(maquinasProvider.notifier).deleteMaquina(maquina.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Máquina eliminada exitosamente')),
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      width: 320, // Ancho más amplio para elementos flotantes
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
                        isSelected: true,
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
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PersonalListScreen()),
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
                        Icons.assessment_rounded,
                        -1,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OptimizedReportesScreen()),
                          );
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
    bool isSelected = false,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {
            Navigator.pop(context);
            // Navegación por índice si es necesario
          },
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
