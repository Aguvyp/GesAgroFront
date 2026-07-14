class Lote {
  final int? id;
  final int? campo;
  final String? campoNombre;
  final String nombre;
  final double hectareas;
  final Map<String, dynamic>? polygonGeoJson;
  final double? puntoAccesoLatitud;
  final double? puntoAccesoLongitud;
  final double? puntoEntradaLatitud;
  final double? puntoEntradaLongitud;
  final String? notasAcceso;
  final int? clienteId;

  Lote({
    this.id,
    this.campo,
    this.campoNombre,
    required this.nombre,
    required this.hectareas,
    this.polygonGeoJson,
    this.puntoAccesoLatitud,
    this.puntoAccesoLongitud,
    this.puntoEntradaLatitud,
    this.puntoEntradaLongitud,
    this.notasAcceso,
    this.clienteId,
  });

  factory Lote.fromJson(Map<String, dynamic> json) {
    return Lote(
      id: _toInt(json['id']),
      campo: _toInt(json['campo'] ?? json['campo_id']),
      campoNombre: json['campo_nombre']?.toString(),
      nombre: json['nombre']?.toString() ?? '',
      hectareas: _toDouble(json['hectareas']) ?? 0.0,
      polygonGeoJson: json['polygon_geojson'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['polygon_geojson'])
          : null,
      puntoAccesoLatitud: _toDouble(json['punto_acceso_latitud']),
      puntoAccesoLongitud: _toDouble(json['punto_acceso_longitud']),
      puntoEntradaLatitud: _toDouble(json['punto_entrada_latitud']),
      puntoEntradaLongitud: _toDouble(json['punto_entrada_longitud']),
      notasAcceso: json['notas_acceso']?.toString(),
      clienteId: _toInt(json['cliente_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'campo': campo,
      'nombre': nombre,
      'hectareas': hectareas,
      'polygon_geojson': polygonGeoJson,
      'punto_acceso_latitud': puntoAccesoLatitud,
      'punto_acceso_longitud': puntoAccesoLongitud,
      'punto_entrada_latitud': puntoEntradaLatitud,
      'punto_entrada_longitud': puntoEntradaLongitud,
      'notas_acceso': notasAcceso,
      'cliente_id': clienteId,
    };
  }

  bool get tieneContorno => polygonGeoJson != null;
  bool get tieneAcceso =>
      puntoAccesoLatitud != null && puntoAccesoLongitud != null;
  bool get tieneEntrada =>
      puntoEntradaLatitud != null && puntoEntradaLongitud != null;

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.trim().replaceAll(',', '.');
      if (cleaned.isEmpty) return null;
      return double.tryParse(cleaned);
    }
    return null;
  }
}
