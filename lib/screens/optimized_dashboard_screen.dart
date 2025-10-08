import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'optimized_finanzas_screens.dart';
import 'test_connection_screen.dart';
import 'personal/personal_list_screen.dart';

class OptimizedDashboardScreen extends ConsumerWidget {
  final Function(int)? onNavigateToIndex;
  
  const OptimizedDashboardScreen({
    Key? key,
    this.onNavigateToIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // AppBar removido - ahora está en OptimizedMainScreen
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenido a GesAgro',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tu sistema de gestión agrícola optimizado',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildQuickAccessCard(
                    context,
                    'Finanzas',
                    Icons.account_balance_wallet,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OptimizedFinanzasMainScreen()),
                    ),
                  ),
                  _buildQuickAccessCard(
                    context,
                    'Campos',
                    Icons.landscape,
                    Colors.brown,
                    () => onNavigateToIndex?.call(1), // Navegar a Campos (índice 1)
                  ),
                  _buildQuickAccessCard(
                    context,
                    'Trabajos',
                    Icons.work,
                    Colors.blue,
                    () => onNavigateToIndex?.call(2), // Navegar a Trabajos (índice 2)
                  ),
                  _buildQuickAccessCard(
                    context,
                    'Costos',
                    Icons.attach_money,
                    Colors.orange,
                    () => onNavigateToIndex?.call(3), // Navegar a Costos (índice 3)
                  ),
                  _buildQuickAccessCard(
                    context,
                    'Personal',
                    Icons.people,
                    Colors.purple,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PersonalListScreen()),
                    ),
                  ),
                  _buildQuickAccessCard(
                    context,
                    'Prueba Conexión',
                    Icons.wifi_find,
                    Colors.teal,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TestConnectionScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildQuickAccessCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}