class Campo {
  final int? id;
  final String nombre;
  final double superficieHa;
  final double? latitud;
  final double? longitud;
  final String? detalles;

  Campo({
    this.id,
    required this.nombre,
    required this.superficieHa,
    this.latitud,
    this.longitud,
    this.detalles,
  });

  factory Campo.fromJson(Map<String, dynamic> json) {
    return Campo(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      superficieHa: (json['hectareas'] ?? json['superficie_ha'] ?? 0.0).toDouble(),
      latitud: json['latitud']?.toDouble(),
      longitud: json['longitud']?.toDouble(),
      detalles: json['detalles'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'hectareas': superficieHa,
      'latitud': latitud,
      'longitud': longitud,
      'detalles': detalles,
    };
  }

  Campo copyWith({
    int? id,
    String? nombre,
    double? superficieHa,
    double? latitud,
    double? longitud,
    String? detalles,
  }) {
    return Campo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      superficieHa: superficieHa ?? this.superficieHa,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      detalles: detalles ?? this.detalles,
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
