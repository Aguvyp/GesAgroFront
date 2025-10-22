class Personal {
  final int? id;
  final String nombre;
  final String dni;
  final String? telefono;
  final double? superficieTotalHa;
  final double? horasTrabajadas;
  final int? trabajosCompletados;
  final String? ultimoTrabajo;

  Personal({
    this.id,
    required this.nombre,
    required this.dni,
    this.telefono,
    this.superficieTotalHa,
    this.horasTrabajadas,
    this.trabajosCompletados,
    this.ultimoTrabajo,
  });

  factory Personal.fromJson(Map<String, dynamic> json) {
    return Personal(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      dni: json['dni'] ?? '',
      telefono: json['telefono'],
      superficieTotalHa: json['superficie_total_ha']?.toDouble(),
      horasTrabajadas: json['horas_trabajadas']?.toDouble(),
      trabajosCompletados: json['trabajos_completados'],
      ultimoTrabajo: json['ultimo_trabajo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'dni': dni,
      'telefono': telefono,
      'superficie_total_ha': superficieTotalHa,
      'horas_trabajadas': horasTrabajadas,
      'trabajos_completados': trabajosCompletados,
      'ultimo_trabajo': ultimoTrabajo,
    };
  }

  Personal copyWith({
    int? id,
    String? nombre,
    String? dni,
    String? telefono,
    double? superficieTotalHa,
    double? horasTrabajadas,
    int? trabajosCompletados,
    String? ultimoTrabajo,
  }) {
    return Personal(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      dni: dni ?? this.dni,
      telefono: telefono ?? this.telefono,
      superficieTotalHa: superficieTotalHa ?? this.superficieTotalHa,
      horasTrabajadas: horasTrabajadas ?? this.horasTrabajadas,
      trabajosCompletados: trabajosCompletados ?? this.trabajosCompletados,
      ultimoTrabajo: ultimoTrabajo ?? this.ultimoTrabajo,
    );
  }

  String get initials {
    final names = nombre.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
  }

  @override
  String toString() {
    return 'Personal(id: $id, nombre: $nombre, dni: $dni)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Personal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
