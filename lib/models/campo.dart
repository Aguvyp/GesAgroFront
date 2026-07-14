class Campo {
  final int? id;
  final String nombre;
  final double superficieHa;
  final double? latitud;
  final double? longitud;
  final Map<String, dynamic>? polygonGeoJson;
  final String? detalles;
  final bool esPropio;
  final int? clienteId;
  final int lotesCount;

  Campo({
    this.id,
    required this.nombre,
    required this.superficieHa,
    this.latitud,
    this.longitud,
    this.polygonGeoJson,
    this.detalles,
    this.esPropio = true,
    this.clienteId,
    this.lotesCount = 0,
  });

  factory Campo.fromJson(Map<String, dynamic> json) {
    // Función helper para convertir a double de forma segura
    // Maneja String, int, double, y otros tipos
    double? _toDouble(dynamic value) {
      if (value == null) return null;

      // Si ya es double, retornarlo directamente
      if (value is double) return value;

      // Si es int, convertir a double
      if (value is int) return value.toDouble();

      // Si es String, parsearlo
      if (value is String) {
        if (value.isEmpty || value.trim().isEmpty) return null;
        // Limpiar el string (remover espacios, comas, etc.)
        final cleaned = value.trim().replaceAll(',', '.');
        final parsed = double.tryParse(cleaned);
        return parsed;
      }

      // Para cualquier otro tipo, intentar convertir a String y luego parsear
      try {
        final stringValue = value.toString().trim();
        if (stringValue.isEmpty) return null;
        final cleaned = stringValue.replaceAll(',', '.');
        return double.tryParse(cleaned);
      } catch (e) {
        return null;
      }
    }

    try {
      // Obtener el valor de hectáreas de diferentes posibles campos
      final hectareasValue = json['hectareas'] ??
          json['superficie_ha'] ??
          json['superficieHa'] ??
          json['superficie'];

      return Campo(
        id: json['id'] is int
            ? json['id']
            : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
        nombre: json['nombre']?.toString() ?? '',
        superficieHa: _toDouble(hectareasValue) ?? 0.0,
        latitud: _toDouble(json['latitud']),
        longitud: _toDouble(json['longitud']),
        polygonGeoJson: json['polygon_geojson'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['polygon_geojson'])
            : null,
        detalles: json['detalles']?.toString(),
        esPropio: json['propio'] == 1 || json['propio'] == true,
        clienteId: json['cliente_id'] is int
            ? json['cliente_id']
            : (json['cliente_id'] != null
                ? int.tryParse(json['cliente_id'].toString())
                : (json['id_cliente'] is int
                    ? json['id_cliente']
                    : (json['id_cliente'] != null
                        ? int.tryParse(json['id_cliente'].toString())
                        : null))),
        lotesCount: json['lotes_count'] is int
            ? json['lotes_count']
            : (json['lotes_count'] != null
                ? int.tryParse(json['lotes_count'].toString()) ?? 0
                : 0),
      );
    } catch (e) {
      // Si hay un error al crear el Campo, lanzar una excepción más descriptiva
      throw Exception('Error parsing Campo from JSON: $json. Error: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'hectareas': superficieHa,
      'latitud': latitud,
      'longitud': longitud,
      'polygon_geojson': polygonGeoJson,
      'detalles': detalles,
      'propio': esPropio ? 1 : 0,
      'cliente_id': clienteId,
      'id_cliente': clienteId, // Fallback key
      'lotes_count': lotesCount,
    };
  }

  Campo copyWith({
    int? id,
    String? nombre,
    double? superficieHa,
    double? latitud,
    double? longitud,
    Map<String, dynamic>? polygonGeoJson,
    String? detalles,
    bool? esPropio,
    int? clienteId,
    int? lotesCount,
  }) {
    return Campo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      superficieHa: superficieHa ?? this.superficieHa,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      polygonGeoJson: polygonGeoJson ?? this.polygonGeoJson,
      detalles: detalles ?? this.detalles,
      esPropio: esPropio ?? this.esPropio,
      clienteId: clienteId ?? this.clienteId,
      lotesCount: lotesCount ?? this.lotesCount,
    );
  }

  @override
  String toString() {
    return 'Campo(id: $id, nombre: $nombre, superficieHa: $superficieHa)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Campo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
