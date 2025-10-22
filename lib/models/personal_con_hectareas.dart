/// Modelo para personal con hectáreas trabajadas
class PersonalConHectareas {
  final int id;
  final String nombre;
  final String dni;
  final double hectareas;

  PersonalConHectareas({
    required this.id,
    required this.nombre,
    required this.dni,
    required this.hectareas,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ha': hectareas,
    };
  }

  PersonalConHectareas copyWith({
    int? id,
    String? nombre,
    String? dni,
    double? hectareas,
  }) {
    return PersonalConHectareas(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      dni: dni ?? this.dni,
      hectareas: hectareas ?? this.hectareas,
    );
  }

  @override
  String toString() {
    return 'PersonalConHectareas(id: $id, nombre: $nombre, hectareas: $hectareas)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PersonalConHectareas && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
