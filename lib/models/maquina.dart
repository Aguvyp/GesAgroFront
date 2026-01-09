class Maquina {
  final int? id;
  final String nombre;
  final String marca;
  final String modelo;
  final int ano;
  final String? detalles;
  final double? anchoTrabajo;
  final String? estado;
  final double? superficieTotalHa;
  final double? horasTrabajadas;
  final String? ultimoTrabajo;

  Maquina({
    this.id,
    required this.nombre,
    required this.marca,
    required this.modelo,
    required this.ano,
    this.detalles,
    this.anchoTrabajo,
    this.estado,
    this.superficieTotalHa,
    this.horasTrabajadas,
    this.ultimoTrabajo,
  });

  factory Maquina.fromJson(Map<String, dynamic> json) {
    // Función helper para convertir a double de forma segura
    double? _toDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        if (value.isEmpty || value.trim().isEmpty) return null;
        final cleaned = value.trim().replaceAll(',', '.');
        return double.tryParse(cleaned);
      }
      try {
        final stringValue = value.toString().trim();
        if (stringValue.isEmpty) return null;
        final cleaned = stringValue.replaceAll(',', '.');
        return double.tryParse(cleaned);
      } catch (e) {
        return null;
      }
    }

    return Maquina(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      ano: json['ano'] ?? 0,
      detalles: json['detalles'],
      anchoTrabajo: _toDouble(json['ancho_trabajo']),
      estado: json['estado'],
      superficieTotalHa: _toDouble(json['superficie_total_ha']),
      horasTrabajadas: _toDouble(json['horas_trabajadas']),
      ultimoTrabajo: json['ultimo_trabajo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'marca': marca,
      'modelo': modelo,
      'ano': ano,
      'detalles': detalles,
      'ancho_trabajo': anchoTrabajo,
      'estado': estado,
      'superficie_total_ha': superficieTotalHa,
      'horas_trabajadas': horasTrabajadas,
      'ultimo_trabajo': ultimoTrabajo,
    };
  }

  Maquina copyWith({
    int? id,
    String? nombre,
    String? marca,
    String? modelo,
    int? ano,
    String? detalles,
    double? anchoTrabajo,
    String? estado,
    double? superficieTotalHa,
    double? horasTrabajadas,
    String? ultimoTrabajo,
  }) {
    return Maquina(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      ano: ano ?? this.ano,
      detalles: detalles ?? this.detalles,
      anchoTrabajo: anchoTrabajo ?? this.anchoTrabajo,
      estado: estado ?? this.estado,
      superficieTotalHa: superficieTotalHa ?? this.superficieTotalHa,
      horasTrabajadas: horasTrabajadas ?? this.horasTrabajadas,
      ultimoTrabajo: ultimoTrabajo ?? this.ultimoTrabajo,
    );
  }

  String get displayName => '$marca $modelo ($ano)';

  @override
  String toString() {
    return 'Maquina(id: $id, nombre: $nombre, marca: $marca, modelo: $modelo, ano: $ano)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Maquina && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
