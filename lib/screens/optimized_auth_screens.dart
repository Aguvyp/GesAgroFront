import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/optimized_widgets.dart';
import '../providers/optimized_auth_provider.dart';
import 'optimized_main_screen_new.dart';

/// ==================== LOGIN SCREEN OPTIMIZADA ====================

class OptimizedLoginScreen extends ConsumerStatefulWidget {
  const OptimizedLoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedLoginScreen> createState() =>
      _OptimizedLoginScreenState();
}

class _OptimizedLoginScreenState extends ConsumerState<OptimizedLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Biometría
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics =
          await auth.canCheckBiometrics && await auth.isDeviceSupported();
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      // print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Escanea tu huella para ingresar a GesAgro',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      // print(e);
      if (mounted) {
        OptimizedSnackBar.showError(context,
            message: 'Error de autenticación: ${e.message}');
      }
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }

    if (authenticated && mounted) {
      // Intentar obtener el nombre si existe una sesión previa o datos guardados
      final authState = ref.read(authProvider);
      String nombreUsuario = '';
      if (authState is AuthenticatedState) {
        nombreUsuario =
            authState.user['nombre'] ?? authState.user['username'] ?? '';
      }

      OptimizedSnackBar.showSuccess(
        context,
        message: nombreUsuario.isNotEmpty
            ? 'Bienvenido, $nombreUsuario'
            : 'Bienvenido',
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OptimizedMainScreen()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.agriculture,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'GesAgro',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const SizedBox(height: 40),
                OptimizedTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Ingresa tu email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu email';
                    }
                    if (!value.contains('@')) {
                      return 'Por favor ingresa un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                OptimizedTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  hint: 'Ingresa tu contraseña',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                OptimizedButton(
                  text: 'Iniciar Sesión',
                  onPressed:
                      authState is LoadingAuthState ? null : _handleLogin,
                  isLoading: authState is LoadingAuthState,
                  isFullWidth: true,
                ),

                // Botón de Biometría
                if (_canCheckBiometrics) ...[
                  const SizedBox(height: 24),
                  InkWell(
                    onTap: _isAuthenticating ? null : _authenticate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).primaryColor.withOpacity(0.05),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fingerprint,
                              color: Theme.of(context).primaryColor, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            'Ingresar con Huella',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                if (authState is ErrorAuthState) ...[
                  const SizedBox(height: 16),
                  Text(
                    authState.message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );

      if (mounted) {
        // Obtener nombre del usuario para el mensaje de bienvenida
        final authState = ref.read(authProvider);
        String nombreUsuario = 'Usuario';
        if (authState is AuthenticatedState) {
          nombreUsuario = authState.user['nombre'] ??
              authState.user['username'] ??
              'Usuario';
        }

        OptimizedSnackBar.showSuccess(
          context,
          message: 'Bienvenido, $nombreUsuario',
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OptimizedMainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        OptimizedSnackBar.showError(
          context,
          message: 'Error al iniciar sesión: $e',
        );
      }
    }
  }
}

/// ==================== REGISTER SCREEN OPTIMIZADA ====================

class OptimizedRegisterScreen extends ConsumerStatefulWidget {
  const OptimizedRegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedRegisterScreen> createState() =>
      _OptimizedRegisterScreenState();
}

class _OptimizedRegisterScreenState
    extends ConsumerState<OptimizedRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _dniController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _dniController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.person_add,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Crear Cuenta',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                OptimizedTextField(
                  controller: _nombreController,
                  label: 'Nombre Completo',
                  hint: 'Ingresa tu nombre completo',
                  prefixIcon: const Icon(Icons.person_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                OptimizedTextField(
                  controller: _dniController,
                  label: 'DNI',
                  hint: 'Ingresa tu DNI',
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.badge_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu DNI';
                    }
                    if (value.length < 7) {
                      return 'El DNI debe tener al menos 7 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                OptimizedTextField(
                  controller: _telefonoController,
                  label: 'Teléfono',
                  hint: 'Ingresa tu teléfono',
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu teléfono';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                OptimizedTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Ingresa tu email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu email';
                    }
                    if (!value.contains('@')) {
                      return 'Por favor ingresa un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                OptimizedTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  hint: 'Ingresa tu contraseña',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                OptimizedTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmar Contraseña',
                  hint: 'Confirma tu contraseña',
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor confirma tu contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                OptimizedButton(
                  text: 'Registrarse',
                  onPressed:
                      authState is LoadingAuthState ? null : _handleRegister,
                  isLoading: authState is LoadingAuthState,
                  isFullWidth: true,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
                if (authState is ErrorAuthState) ...[
                  const SizedBox(height: 16),
                  Text(
                    authState.message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authProvider.notifier).register(
            nombre: _nombreController.text.trim(),
            dni: _dniController.text.trim(),
            telefono: _telefonoController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OptimizedMainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        OptimizedSnackBar.showError(
          context,
          message: 'Error al registrarse: $e',
        );
      }
    }
  }
}
