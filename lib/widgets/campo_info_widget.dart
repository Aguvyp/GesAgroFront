import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/campo.dart';
import '../providers/optimized_providers.dart';

/// Widget que muestra información de un campo cargándolo por ID
class CampoInfoWidget extends ConsumerStatefulWidget {
  final int campoId;
  final Widget Function(Campo? campo) builder;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const CampoInfoWidget({
    Key? key,
    required this.campoId,
    required this.builder,
    this.loadingWidget,
    this.errorWidget,
  }) : super(key: key);

  @override
  ConsumerState<CampoInfoWidget> createState() => _CampoInfoWidgetState();
}

class _CampoInfoWidgetState extends ConsumerState<CampoInfoWidget> {
  @override
  void initState() {
    super.initState();
    // Cargar el campo por ID al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(campoByIdProvider.notifier).loadCampoById(widget.campoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final campoState = ref.watch(campoByIdProvider);
    
    if (campoState is LoadingState) {
      return widget.loadingWidget ?? const SizedBox.shrink();
    }
    
    if (campoState is ErrorState) {
      return widget.errorWidget ?? Text('Error: ${campoState.message}');
    }
    
    if (campoState is LoadedState<dynamic>) {
      final campo = campoState.data as Campo?;
      return widget.builder(campo);
    }
    
    return const SizedBox.shrink();
  }
}

/// Widget específico para mostrar información de campo en trabajos
class TrabajoCampoInfo extends StatelessWidget {
  final int campoId;
  final TextStyle? textStyle;

  const TrabajoCampoInfo({
    Key? key,
    required this.campoId,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CampoInfoWidget(
      campoId: campoId,
      builder: (campo) {
        if (campo != null) {
          return Text(
            '${campo.nombre} - ${campo.superficieHa.toStringAsFixed(1)}ha',
            style: textStyle ?? const TextStyle(fontSize: 12, color: Colors.grey),
          );
        } else {
          return Text(
            'Campo ID: $campoId',
            style: textStyle ?? const TextStyle(fontSize: 12, color: Colors.grey),
          );
        }
      },
      loadingWidget: Text(
        'Cargando campo...',
        style: textStyle ?? const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      errorWidget: Text(
        'Error cargando campo',
        style: textStyle ?? const TextStyle(fontSize: 12, color: Colors.red),
      ),
    );
  }
}
