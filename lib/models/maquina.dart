class Maquina {
  final int? id;
  final String nombre;
  final String marca;
  final String modelo;
  final int ano;
  final String? detalles;
  final double? anchoTrabajo;
  final String? estado;

  Maquina({
    this.id,
    required this.nombre,
    required this.marca,
    required this.modelo,
    required this.ano,
    this.detalles,
    this.anchoTrabajo,
    this.estado,
  });

  factory Maquina.fromJson(Map<String, dynamic> json) {
    return Maquina(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      ano: json['ano'] ?? 0,
      detalles: json['detalles'],
      anchoTrabajo: json['ancho_trabajo']?.toDouble(),
      estado: json['estado'],
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
