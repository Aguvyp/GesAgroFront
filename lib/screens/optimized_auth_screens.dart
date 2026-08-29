import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/optimized_widgets.dart';
import '../providers/optimized_auth_provider.dart';
import '../themes/app_theme.dart';
import 'optimized_main_screen_new.dart';

/// ==================== LOGIN SCREEN ====================

class OptimizedLoginScreen extends ConsumerStatefulWidget {
  const OptimizedLoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OptimizedLoginScreen> createState() =>
      _OptimizedLoginScreenState();
}

class _OptimizedLoginScreenState extends ConsumerState<OptimizedLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _isAuthenticating = false;

  late AnimationController _bgAnimController;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics =
          await auth.canCheckBiometrics && await auth.isDeviceSupported();
    } on PlatformException {
      canCheckBiometrics = false;
    }
    if (!mounted) return;
    setState(() => _canCheckBiometrics = canCheckBiometrics);
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() => _isAuthenticating = true);
      authenticated = await auth.authenticate(
        localizedReason: 'Escanea tu huella para ingresar',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      if (mounted) {
        OptimizedSnackBar.showError(context, message: 'Error: ${e.message}');
      }
      return;
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }

    if (authenticated && mounted) {
      final authState = ref.read(authProvider);
      String nombre = '';
      if (authState is AuthenticatedState) {
        nombre = authState.user['nombre'] ?? authState.user['username'] ?? '';
      }
      OptimizedSnackBar.showSuccess(context,
          message: nombre.isNotEmpty ? 'Bienvenido, $nombre' : 'Bienvenido');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OptimizedMainScreen()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bgAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            // ─── Fondo con gradiente animado ───
            AnimatedBuilder(
              animation: _bgAnimController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: const [
                        Color(0xFF0D3B0F),
                        Color(0xFF1B5E20),
                        Color(0xFF2E7D32),
                        Color(0xFF1B5E20),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment(
                        0.5 + _bgAnimController.value * 0.5,
                        1.0 + _bgAnimController.value * 0.3,
                      ),
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                );
              },
            ),

            // ─── Patrón decorativo ───
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.3,
              left: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),

            // ─── Contenido principal ───
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        // ─── Logo animado ───
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.eco_rounded,
                            size: 52,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(duration: 600.ms).scale(
                              begin: const Offset(0.5, 0.5),
                              end: const Offset(1.0, 1.0),
                              curve: Curves.easeOutBack,
                              duration: 800.ms,
                            ),

                        const SizedBox(height: 24),

                        Text(
                          'GesAgro',
                          style: GoogleFonts.inter(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1.5,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 500.ms)
                            .slideY(begin: 0.3, end: 0, duration: 500.ms),

                        const SizedBox(height: 6),
                        Text(
                          'Gestión agrícola inteligente',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.7),
                            letterSpacing: 0.3,
                          ),
                        ).animate().fadeIn(delay: 350.ms, duration: 500.ms),

                        const SizedBox(height: 48),

                        // ─── Card de login con glassmorphism ───
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Email
                                  _buildGlassTextField(
                                    controller: _emailController,
                                    hint: 'Email',
                                    icon: Icons.mail_outline_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Ingresa tu email';
                                      if (!value.contains('@'))
                                        return 'Email no válido';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Password
                                  _buildGlassTextField(
                                    controller: _passwordController,
                                    hint: 'Contraseña',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 20,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscurePassword = !_obscurePassword),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Ingresa tu contraseña';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 28),

                                  // Login button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: authState is LoadingAuthState
                                          ? null
                                          : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppTheme.primary,
                                        disabledBackgroundColor:
                                            Colors.white.withOpacity(0.5),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: authState is LoadingAuthState
                                          ? SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: AppTheme.primary,
                                              ),
                                            )
                                          : Text(
                                              'Iniciar sesión',
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 450.ms, duration: 600.ms)
                            .slideY(
                                begin: 0.2,
                                end: 0,
                                curve: Curves.easeOutCubic,
                                duration: 600.ms),

                        // Biometrics
                        if (_canCheckBiometrics) ...[
                          const SizedBox(height: 24),
                          _buildBiometricButton()
                              .animate()
                              .fadeIn(delay: 650.ms, duration: 400.ms),
                        ],

                        // Error
                        if (authState is ErrorAuthState) ...[
                          const SizedBox(height: 20),
                          _buildErrorBanner(authState.message)
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .shake(hz: 2, rotation: 0.01),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          color: Colors.white.withOpacity(0.4),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(icon, size: 20, color: Colors.white.withOpacity(0.5)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.4), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF8A80), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF8A80), width: 2),
        ),
        errorStyle: GoogleFonts.inter(
          color: const Color(0xFFFF8A80),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return GestureDetector(
      onTap: _isAuthenticating ? null : _authenticate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
          color: Colors.white.withOpacity(0.08),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fingerprint_rounded,
                size: 24, color: Colors.white.withOpacity(0.8)),
            const SizedBox(width: 10),
            Text(
              'Ingresar con huella',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFF5252).withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFFF5252).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 20, color: Color(0xFFFF8A80)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFFFCDD2),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
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
        final authState = ref.read(authProvider);
        String nombre = 'Usuario';
        if (authState is AuthenticatedState) {
          nombre = authState.user['nombre'] ??
              authState.user['username'] ??
              'Usuario';
        }
        OptimizedSnackBar.showSuccess(context, message: 'Bienvenido, $nombre');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OptimizedMainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        OptimizedSnackBar.showError(context,
            message: 'Error al iniciar sesión');
      }
    }
  }
}

/// ==================== REGISTER SCREEN ====================

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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildField(
                  controller: _nombreController,
                  hint: 'Nombre completo',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _dniController,
                  hint: 'DNI',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (v.length < 7) return 'Mínimo 7 dígitos';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _telefonoController,
                  hint: 'Teléfono',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _emailController,
                  hint: 'Email',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (!v.contains('@')) return 'Email no válido';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _passwordController,
                  hint: 'Contraseña',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppTheme.textTertiary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _confirmPasswordController,
                  hint: 'Confirmar contraseña',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppTheme.textTertiary,
                    ),
                    onPressed: () => setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (v != _passwordController.text) return 'No coinciden';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed:
                        authState is LoadingAuthState ? null : _handleRegister,
                    child: authState is LoadingAuthState
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white)),
                          )
                        : Text('Registrarse',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            )),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '¿Ya tienes cuenta? Iniciar sesión',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (authState is ErrorAuthState) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.errorSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            size: 18, color: AppTheme.error),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            authState.message,
                            style: GoogleFonts.inter(
                              color: AppTheme.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffixIcon,
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
          MaterialPageRoute(builder: (_) => const OptimizedMainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        OptimizedSnackBar.showError(context, message: 'Error al registrarse');
      }
    }
  }
}
