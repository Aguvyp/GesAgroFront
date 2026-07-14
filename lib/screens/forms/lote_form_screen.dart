import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/campo.dart';
import '../../models/lote.dart';
import '../../providers/optimized_providers.dart';
import '../../widgets/optimized_widgets.dart';
import '../campos/lote_polygon_map_screen.dart';
import '../campos/map_location_screen.dart';

/// Form used to create or edit a lote for a campo.
class LoteFormScreen extends ConsumerStatefulWidget {
  /// Creates the lote form.
  const LoteFormScreen({
    super.key,
    required this.campo,
    this.lote,
  });

  /// Campo that owns the lote being created or edited.
  final Campo campo;

  /// Existing lote when editing, or null when creating.
  final Lote? lote;

  @override
  ConsumerState<LoteFormScreen> createState() => _LoteFormScreenState();
}

class _LoteFormScreenState extends ConsumerState<LoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _hectareasController;
  late final TextEditingController _accesoLatController;
  late final TextEditingController _accesoLngController;
  late final TextEditingController _entradaLatController;
  late final TextEditingController _entradaLngController;
  late final TextEditingController _notasAccesoController;
  Map<String, dynamic>? _polygonGeoJson;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final lote = widget.lote;
    _nombreController = TextEditingController(text: lote?.nombre ?? '');
    _hectareasController = TextEditingController(
      text: lote?.hectareas.toString() ?? '',
    );
    _accesoLatController = TextEditingController(
      text: lote?.puntoAccesoLatitud?.toString() ?? '',
    );
    _accesoLngController = TextEditingController(
      text: lote?.puntoAccesoLongitud?.toString() ?? '',
    );
    _entradaLatController = TextEditingController(
      text: lote?.puntoEntradaLatitud?.toString() ?? '',
    );
    _entradaLngController = TextEditingController(
      text: lote?.puntoEntradaLongitud?.toString() ?? '',
    );
    _notasAccesoController =
        TextEditingController(text: lote?.notasAcceso ?? '');
    _polygonGeoJson = lote?.polygonGeoJson;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _hectareasController.dispose();
    _accesoLatController.dispose();
    _accesoLngController.dispose();
    _entradaLatController.dispose();
    _entradaLngController.dispose();
    _notasAccesoController.dispose();
    super.dispose();
  }

  @override
  // Kept as a block because the UI tree is easier to scan this way.
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.lote == null ? 'Nuevo Lote' : 'Editar Lote'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1C1C1E),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _submit,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            OptimizedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.campo.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Campo base · ${widget.campo.superficieHa.toStringAsFixed(1)} ha',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OptimizedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Datos del lote',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  OptimizedTextField(
                    controller: _nombreController,
                    label: 'Nombre del lote',
                    hint: 'Ej: Lote 3, Bajo norte',
                    prefixIcon: const Icon(Icons.crop_square_rounded),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'El nombre es requerido'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  OptimizedTextField(
                    controller: _hectareasController,
                    label: 'Superficie (ha)',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: const Icon(Icons.straighten_rounded),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La superficie es requerida';
                      }
                      return double.tryParse(value.replaceAll(',', '.')) == null
                          ? 'Ingrese un número válido'
                          : null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildPointCard(
              title: 'Punto de acceso al campo',
              subtitle:
                  'Tranquera o punto donde conviene llegar desde el camino.',
              latController: _accesoLatController,
              lngController: _accesoLngController,
            ),
            const SizedBox(height: 16),
            _buildPointCard(
              title: 'Punto de entrada al lote',
              subtitle:
                  'Lugar recomendado para empezar el trabajo dentro del campo.',
              latController: _entradaLatController,
              lngController: _entradaLngController,
            ),
            const SizedBox(height: 16),
            OptimizedCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Indicaciones de acceso',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  OptimizedTextField(
                    controller: _notasAccesoController,
                    label: 'Notas de acceso',
                    hint:
                        'Ej: Entrar por tranquera norte, evitar bajo del este...',
                    prefixIcon: const Icon(Icons.notes_rounded),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),
                  _buildPolygonSection(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OptimizedButton(
              text: widget.lote == null ? 'Crear lote' : 'Actualizar lote',
              onPressed: _isSaving ? null : _submit,
              isLoading: _isSaving,
              isFullWidth: true,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPolygonSection() {
    final pointsCount = _polygonPointsCount(_polygonGeoJson);
    final hasPolygon = pointsCount >= 3;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8EAD9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.polyline_rounded,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contorno del lote',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasPolygon
                          ? '$pointsCount puntos marcados'
                          : 'Sin contorno marcado',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Marcá el perímetro tocando el mapa. El sistema guardará el contorno en formato GeoJSON para mostrarlo en las indicaciones del trabajo.',
            style:
                TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.35),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openPolygonEditor,
                  icon: const Icon(Icons.map_rounded),
                  label: Text(hasPolygon ? 'Editar en mapa' : 'Marcar en mapa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E7D32),
                    side: const BorderSide(color: Color(0xFF2E7D32)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (hasPolygon) ...[
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  onPressed: () => setState(() => _polygonGeoJson = null),
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: 'Quitar contorno',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointCard({
    required String title,
    required String subtitle,
    required TextEditingController latController,
    required TextEditingController lngController,
  }) =>
      OptimizedCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OptimizedTextField(
                    controller: latController,
                    label: 'Latitud',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OptimizedTextField(
                    controller: lngController,
                    label: 'Longitud',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _pickPoint(latController, lngController),
              icon: const Icon(Icons.map_rounded),
              label: const Text('Seleccionar en mapa'),
            ),
          ],
        ),
      );

  Future<void> _pickPoint(
    TextEditingController latController,
    TextEditingController lngController,
  ) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => MapLocationScreen(
          initialLatitude:
              _toDouble(latController.text) ?? widget.campo.latitud,
          initialLongitude:
              _toDouble(lngController.text) ?? widget.campo.longitud,
        ),
      ),
    );

    if (result == null) {
      return;
    }
    setState(() {
      latController.text = result['latitude']?.toString() ?? '';
      lngController.text = result['longitude']?.toString() ?? '';
    });
  }

  Future<void> _openPolygonEditor() async {
    final entradaLat = _toDouble(_entradaLatController.text);
    final entradaLng = _toDouble(_entradaLngController.text);
    final accesoLat = _toDouble(_accesoLatController.text);
    final accesoLng = _toDouble(_accesoLngController.text);

    double? initialLatitude;
    double? initialLongitude;
    if (entradaLat != null && entradaLng != null) {
      initialLatitude = entradaLat;
      initialLongitude = entradaLng;
    } else if (accesoLat != null && accesoLng != null) {
      initialLatitude = accesoLat;
      initialLongitude = accesoLng;
    } else {
      initialLatitude = widget.campo.latitud;
      initialLongitude = widget.campo.longitud;
    }

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => LotePolygonMapScreen(
          initialPolygon: _polygonGeoJson,
          initialLatitude: initialLatitude,
          initialLongitude: initialLongitude,
        ),
      ),
    );

    if (result == null) {
      return;
    }
    setState(() => _polygonGeoJson = result);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    final data = {
      'campo': widget.campo.id,
      'nombre': _nombreController.text.trim(),
      'hectareas': _toDouble(_hectareasController.text) ?? 0.0,
      'polygon_geojson': _polygonGeoJson,
      'punto_acceso_latitud': _toDouble(_accesoLatController.text),
      'punto_acceso_longitud': _toDouble(_accesoLngController.text),
      'punto_entrada_latitud': _toDouble(_entradaLatController.text),
      'punto_entrada_longitud': _toDouble(_entradaLngController.text),
      'notas_acceso': _notasAccesoController.text.trim().isEmpty
          ? null
          : _notasAccesoController.text.trim(),
      'cliente_id': widget.campo.clienteId,
    };

    try {
      final notifier = ref.read(lotesProvider.notifier);
      final result = widget.lote == null
          ? await notifier.createLote(data, campoId: widget.campo.id)
          : await notifier.updateLote(
              widget.lote!.id!,
              data,
              campoId: widget.campo.id,
            );

      if (!mounted) {
        return;
      }
      if (result != null) {
        Navigator.pop(context, result);
        OptimizedSnackBar.showSuccess(context, message: 'Lote guardado');
      }
    } on Exception catch (e) {
      if (mounted) {
        _showError('Error guardando lote: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showError(String message) {
    OptimizedSnackBar.showError(context, message: message);
  }

  double? _toDouble(String value) {
    if (value.trim().isEmpty) {
      return null;
    }
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  int _polygonPointsCount(Map<String, dynamic>? geoJson) {
    if (geoJson == null) {
      return 0;
    }

    final geometry = geoJson['type'] == 'Feature' && geoJson['geometry'] is Map
        ? Map<String, dynamic>.from(geoJson['geometry'])
        : geoJson;

    final coordinates = geometry['coordinates'];
    if (geometry['type'] != 'Polygon' ||
        coordinates is! List ||
        coordinates.isEmpty ||
        coordinates.first is! List) {
      return 0;
    }

    final ring = coordinates.first as List;
    if (ring.length > 1 &&
        ring.first is List &&
        ring.last is List &&
        (ring.first as List).length >= 2 &&
        (ring.last as List).length >= 2 &&
        (ring.first as List)[0] == (ring.last as List)[0] &&
        (ring.first as List)[1] == (ring.last as List)[1]) {
      return ring.length - 1;
    }

    return ring.length;
  }
}
