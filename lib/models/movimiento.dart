class Movimiento {
  final int id;
  final int insumoId;
  final String tipo; // 'Entrada', 'Salida'
  final double cantidad;
  final double precioUnitario;
  final DateTime fecha;
  final String motivo;
  final String? observaciones;
  final String? referencia; // Número de factura, orden de trabajo, etc.

  Movimiento({
    required this.id,
    required this.insumoId,
    required this.tipo,
    required this.cantidad,
    required this.precioUnitario,
    required this.fecha,
    required this.motivo,
    this.observaciones,
    this.referencia,
  });

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    return Movimiento(
      id: json['id'],
      insumoId: json['insumo_id'],
      tipo: json['tipo'],
      cantidad: json['cantidad'].toDouble(),
      precioUnitario: json['precio_unitario'].toDouble(),
      fecha: DateTime.parse(json['fecha']),
      motivo: json['motivo'],
      observaciones: json['observaciones'],
      referencia: json['referencia'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'insumo_id': insumoId,
      'tipo': tipo,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'fecha': fecha.toIso8601String(),
      'motivo': motivo,
      'observaciones': observaciones,
      'referencia': referencia,
    };
  }

  bool get esEntrada => tipo == 'Entrada';
  bool get esSalida => tipo == 'Salida';
  double get valorTotal => cantidad * precioUnitario;

  Movimiento copyWith({
    int? id,
    int? insumoId,
    String? tipo,
    double? cantidad,
    double? precioUnitario,
    DateTime? fecha,
    String? motivo,
    String? observaciones,
    String? referencia,
  }) {
    return Movimiento(
      id: id ?? this.id,
      insumoId: insumoId ?? this.insumoId,
      tipo: tipo ?? this.tipo,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      fecha: fecha ?? this.fecha,
      motivo: motivo ?? this.motivo,
      observaciones: observaciones ?? this.observaciones,
      referencia: referencia ?? this.referencia,
    );
  }
}
