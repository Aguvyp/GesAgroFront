import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../utils/maps_config.dart';

/// Screen used to draw and edit a lote boundary polygon on a map.
class LotePolygonMapScreen extends StatefulWidget {
  /// Creates the lote polygon editor.
  const LotePolygonMapScreen({
    super.key,
    this.initialPolygon,
    this.initialLatitude,
    this.initialLongitude,
    this.title = 'Marcar contorno del lote',
  });

  /// GeoJSON polygon used to preload existing vertices.
  final Map<String, dynamic>? initialPolygon;

  /// Latitude used to center the map when there is no existing polygon.
  final double? initialLatitude;

  /// Longitude used to center the map when there is no existing polygon.
  final double? initialLongitude;

  /// Title displayed in the app bar.
  final String title;

  @override
  State<LotePolygonMapScreen> createState() => _LotePolygonMapScreenState();
}

class _LotePolygonMapScreenState extends State<LotePolygonMapScreen> {
  static const _closeDistanceMeters = 25.0;

  final List<LatLng> _points = [];
  final Distance _distance = const Distance();
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _isLocating = false;
  bool _isClosed = false;

  @override
  void initState() {
    super.initState();
    _points.addAll(_parsePolygon(widget.initialPolygon));
    _isClosed = _points.length >= 3;
    if (_points.isEmpty &&
        widget.initialLatitude == null &&
        widget.initialLongitude == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadCurrentLocation(moveMap: true);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadCurrentLocation(moveMap: false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _initialCenter();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _points.length >= 3 ? _confirmPolygon : null,
            child: const Text('Guardar'),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15,
              onTap: (_, point) => _handleMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.example.ges_agro_front',
              ),
              TileLayer(
                urlTemplate:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/Reference/World_Boundaries_and_Places/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.example.ges_agro_front',
              ),
              if (_points.length >= 3)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _points,
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.22),
                      borderColor: const Color(0xFF2E7D32),
                      borderStrokeWidth: 3,
                    ),
                  ],
                ),
              if (_points.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _polylinePoints,
                      color: const Color(0xFF2E7D32),
                      strokeWidth: 3,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (_currentLocation != null)
                    Marker(
                      point: _currentLocation!,
                      width: 28,
                      height: 28,
                      child: const _CurrentLocationMarker(),
                    ),
                  ..._points.asMap().entries.map(_buildMarker),
                ],
              ),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: _InstructionCard(
              isClosed: _isClosed,
              pointsCount: _points.length,
            ),
          ),
          Positioned(
            right: 12,
            bottom: 100,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Text(
                  'Imágenes: Esri',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 100,
            child: SafeArea(
              child: FloatingActionButton.small(
                heroTag: 'current-location',
                onPressed: _isLocating
                    ? null
                    : () => _loadCurrentLocation(moveMap: true),
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2E7D32),
                child: _isLocating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_rounded),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 16,
            child: SafeArea(
              child: _BottomActions(
                canUndo: _points.isNotEmpty,
                canSave: _points.length >= 3,
                onUndo: _undoLastPoint,
                onClear: _clearPoints,
                onSave: _confirmPolygon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  LatLng _initialCenter() {
    if (_points.isNotEmpty) {
      final lat = _points.map((p) => p.latitude).reduce((a, b) => a + b) /
          _points.length;
      final lng = _points.map((p) => p.longitude).reduce((a, b) => a + b) /
          _points.length;
      return LatLng(lat, lng);
    }

    return LatLng(
      widget.initialLatitude ??
          _currentLocation?.latitude ??
          MapsConfig.defaultLatitude,
      widget.initialLongitude ??
          _currentLocation?.longitude ??
          MapsConfig.defaultLongitude,
    );
  }

  Future<void> _loadCurrentLocation({required bool moveMap}) async {
    if (_isLocating) {
      return;
    }

    setState(() => _isLocating = true);

    try {
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final location = LatLng(position.latitude, position.longitude);

      if (!mounted) {
        return;
      }

      setState(() => _currentLocation = location);

      if (moveMap) {
        _mapController.move(location, 15);
      }
    } on Exception catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener la ubicación del teléfono.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Activá la ubicación del teléfono para centrar el mapa.'),
          ),
        );
      }
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permiso de ubicación denegado.'),
          ),
        );
      }
      return false;
    }

    return true;
  }

  List<LatLng> get _polylinePoints {
    if (!_isClosed || _points.length < 3) {
      return _points;
    }
    return [..._points, _points.first];
  }

  void _handleMapTap(LatLng point) {
    if (_isClosed) {
      return;
    }

    if (_shouldClosePolygon(point)) {
      setState(() => _isClosed = true);
      return;
    }

    setState(() => _points.add(point));
  }

  void _undoLastPoint() {
    if (_points.isEmpty) {
      return;
    }
    setState(() {
      if (_isClosed) {
        _isClosed = false;
      } else {
        _points.removeLast();
      }
    });
  }

  void _clearPoints() {
    if (_points.isEmpty) {
      return;
    }
    setState(() {
      _points.clear();
      _isClosed = false;
    });
  }

  void _confirmPolygon() {
    if (_points.length < 3) {
      return;
    }
    Navigator.pop(context, _toGeoJson(_points));
  }

  Marker _buildMarker(MapEntry<int, LatLng> entry) => Marker(
        point: entry.value,
        width: 34,
        height: 34,
        child: GestureDetector(
          onTap: entry.key == 0 && _points.length >= 3 && !_isClosed
              ? () => setState(() => _isClosed = true)
              : null,
          child: _VertexMarker(
            isStart: entry.key == 0,
            number: entry.key + 1,
          ),
        ),
      );

  bool _shouldClosePolygon(LatLng point) {
    if (_points.length < 3) {
      return false;
    }

    final meters = _distance.as(
      LengthUnit.Meter,
      _points.first,
      point,
    );
    return meters <= _closeDistanceMeters;
  }

  Map<String, dynamic> _toGeoJson(List<LatLng> points) {
    final coordinates = points
        .map((point) => [point.longitude, point.latitude])
        .toList(growable: true);

    final first = coordinates.first;
    final last = coordinates.last;
    if (first[0] != last[0] || first[1] != last[1]) {
      coordinates.add([first[0], first[1]]);
    }

    return {
      'type': 'Polygon',
      'coordinates': [coordinates],
    };
  }

  List<LatLng> _parsePolygon(Map<String, dynamic>? geoJson) {
    if (geoJson == null) {
      return [];
    }

    final geometry = geoJson['type'] == 'Feature' && geoJson['geometry'] is Map
        ? Map<String, dynamic>.from(geoJson['geometry'])
        : geoJson;

    if (geometry['type'] != 'Polygon') {
      return [];
    }
    final coordinates = geometry['coordinates'];
    if (coordinates is! List ||
        coordinates.isEmpty ||
        coordinates.first is! List) {
      return [];
    }

    final ring = coordinates.first as List;
    final points = <LatLng>[];
    for (final coordinate in ring) {
      if (coordinate is List && coordinate.length >= 2) {
        final lng = _toDouble(coordinate[0]);
        final lat = _toDouble(coordinate[1]);
        if (lat != null && lng != null) {
          points.add(LatLng(lat, lng));
        }
      }
    }

    if (points.length > 1 &&
        points.first.latitude == points.last.latitude &&
        points.first.longitude == points.last.longitude) {
      points.removeLast();
    }

    return points;
  }

  double? _toDouble(value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({
    required this.isClosed,
    required this.pointsCount,
  });

  final bool isClosed;
  final int pointsCount;

  @override
  // Kept as a block because the UI tree is easier to scan this way.
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Icon(Icons.touch_app_rounded, color: Color(0xFF2E7D32)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isClosed
                    ? 'Contorno cerrado. Guardá o deshacé para ajustar.'
                    : pointsCount < 3
                        ? 'Tocá el mapa para marcar al menos 3 puntos del contorno.'
                        : 'Tocá el primer punto para cerrar el contorno.',
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$pointsCount pts',
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.canUndo,
    required this.canSave,
    required this.onUndo,
    required this.onClear,
    required this.onSave,
  });

  final bool canUndo;
  final bool canSave;
  final VoidCallback onUndo;
  final VoidCallback onClear;
  final VoidCallback onSave;

  @override
  // Kept as a block because the UI tree is easier to scan this way.
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            IconButton.filledTonal(
              onPressed: canUndo ? onUndo : null,
              icon: const Icon(Icons.undo_rounded),
              tooltip: 'Deshacer punto',
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: canUndo ? onClear : null,
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Limpiar',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: canSave ? onSave : null,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Guardar contorno'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VertexMarker extends StatelessWidget {
  const _VertexMarker({
    required this.isStart,
    required this.number,
  });

  final bool isStart;
  final int number;

  @override
  // Kept as a block because the UI tree is easier to scan this way.
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isStart ? const Color(0xFFE53935) : const Color(0xFF2E7D32),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$number',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _CurrentLocationMarker extends StatelessWidget {
  const _CurrentLocationMarker();

  @override
  // Kept as a block because the UI tree is easier to scan this way.
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2).withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
