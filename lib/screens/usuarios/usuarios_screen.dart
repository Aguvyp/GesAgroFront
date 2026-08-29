import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/usuario.dart';
import '../../providers/optimized_providers.dart';
import '../../themes/app_theme.dart';

class UsuariosScreen extends ConsumerStatefulWidget {
  const UsuariosScreen({super.key});

  @override
  ConsumerState<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends ConsumerState<UsuariosScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(usuariosProvider.notifier).loadUsuarios());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usuariosProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Usuarios')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Nuevo usuario'),
      ),
      body: RefreshIndicator(
        onRefresh: ref.read(usuariosProvider.notifier).loadUsuarios,
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(BaseState state) {
    if (state is LoadingState || state is InitialState) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is ErrorState) {
      return ListView(children: [
        const SizedBox(height: 120),
        const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(state.message, textAlign: TextAlign.center),
        ),
      ]);
    }
    final usuarios = (state as LoadedState<List<Usuario>>).data;
    if (usuarios.isEmpty) {
      return ListView(children: const [
        SizedBox(height: 140),
        Icon(Icons.people_outline, size: 56, color: Colors.grey),
        SizedBox(height: 12),
        Center(child: Text('No hay usuarios cargados')),
      ]);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: usuarios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final usuario = usuarios[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                  (usuario.nombre.isNotEmpty ? usuario.nombre : usuario.email)
                      .substring(0, 1)
                      .toUpperCase()),
            ),
            title:
                Text(usuario.nombre.isEmpty ? usuario.email : usuario.nombre),
            subtitle: Text('${usuario.email}\n${usuario.rol}'),
            isThreeLine: true,
            trailing: Icon(
              usuario.activo ? Icons.check_circle : Icons.cancel,
              color: usuario.activo ? AppTheme.success : AppTheme.error,
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCreateDialog() async {
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    var rol = 'Empleado';
    var saving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nuevo usuario'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) => value != null && value.contains('@')
                      ? null
                      : 'Ingresá un email válido',
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  validator: (value) => (value?.length ?? 0) >= 8
                      ? null
                      : 'Debe tener al menos 8 caracteres',
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: rol,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: const [
                    DropdownMenuItem(value: 'Dueño', child: Text('Dueño')),
                    DropdownMenuItem(
                        value: 'Empleado', child: Text('Empleado')),
                  ],
                  onChanged: (value) => rol = value ?? rol,
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => saving = true);
                      await ref.read(usuariosProvider.notifier).createUsuario({
                        'nombre': nombreController.text.trim(),
                        'email': emailController.text.trim().toLowerCase(),
                        'password': passwordController.text,
                        'rol': rol,
                        'activo': true,
                      });
                      if (!mounted) return;
                      if (!dialogContext.mounted) return;
                      final result = ref.read(usuariosProvider);
                      if (result is ErrorState) {
                        setDialogState(() => saving = false);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text(result.message)),
                        );
                        return;
                      }
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                            content: Text('Usuario creado correctamente')),
                      );
                    },
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Crear'),
            ),
          ],
        ),
      ),
    );
    nombreController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
}
