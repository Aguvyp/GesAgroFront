import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'themes/app_theme.dart';
import 'screens/optimized_main_screen_new.dart';
import 'screens/optimized_auth_screens.dart';
import 'screens/optimized_screens.dart';
import 'screens/optimized_dashboard_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/config/app_config.dart';
import 'core/logger/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar todos los gestores de manera optimizada
    await _initializeApp();

    runApp(
      const ProviderScope(
        child: OptimizedGesAgroApp(),
      ),
    );
  } catch (e) {
    // Manejar errores de inicialización
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error de inicialización: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Reiniciar la aplicación
                    main();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _initializeApp() async {
  final logger = AppLogger.instance;
  logger.initialize();

  logger.info('🚀 Iniciando GesAgro Ultra Optimizado...');

  // Inicializar configuración de la aplicación
  await AppConfig.instance.initialize();

  // Inicializar localización
  await initializeDateFormatting('es', null);

  logger.info('✅ Inicialización completada exitosamente');
}

class OptimizedGesAgroApp extends ConsumerWidget {
  const OptimizedGesAgroApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'GesAgro Ultra Optimizado',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,

      // Configuraciones de rendimiento
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.textScalerOf(context).clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.2,
            ),
          ),
          child: child!,
        );
      },

      // Pantalla inicial - Login
      home: const OptimizedLoginScreen(),

      // Rutas optimizadas
      routes: {
        '/main': (context) => const OptimizedMainScreen(),
        '/login': (context) => const OptimizedLoginScreen(),
        '/dashboard': (context) => const OptimizedDashboardScreen(),
        '/campos': (context) => const OptimizedCamposListScreen(),
      },

      // Configuración de navegación
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/main':
            return MaterialPageRoute(
              builder: (context) => const OptimizedMainScreen(),
              settings: settings,
            );
          case '/login':
            return MaterialPageRoute(
              builder: (context) => const OptimizedLoginScreen(),
              settings: settings,
            );
          default:
            return MaterialPageRoute(
              builder: (context) => const OptimizedMainScreen(),
              settings: settings,
            );
        }
      },
    );
  }
}
