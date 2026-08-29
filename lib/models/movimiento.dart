class Movimiento {
  final int id;
  final double monto;
  final DateTime? fecha;
  final String? descripcion;
  final String? categoria;
  final bool pagado;
  final String? formaPago; // heredado de Costos
  final String? metodoPago; // heredado de Pagos
  final bool esCobro; // true=Ingreso, false=Gasto
  final String? destinatario; // para gastos
  final String? cobrarA; // para ingresos pendientes
  final DateTime? fechaPagoLimite;
  final int? idTrabajo;
  final int? idFactura;
  final DateTime? fechaPago; // efectiva
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Movimiento({
    required this.id,
    required this.monto,
    this.fecha,
    this.descripcion,
    this.categoria,
    this.pagado = false,
    this.formaPago,
    this.metodoPago,
    required this.esCobro,
    this.destinatario,
    this.cobrarA,
    this.fechaPagoLimite,
    this.idTrabajo,
    this.idFactura,
    this.fechaPago,
    this.createdAt,
    this.updatedAt,
  });

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    // Función helper para convertir a double de forma segura
    double _toDouble(dynamic value, [double defaultValue = 0.0]) {
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is num) return value.toDouble();
      if (value is String) {
        if (value.isEmpty || value.trim().isEmpty) return defaultValue;
        final cleaned = value.trim().replaceAll(',', '.');
        return double.tryParse(cleaned) ?? defaultValue;
      }
      try {
        final stringValue = value.toString().trim();
        if (stringValue.isEmpty) return defaultValue;
        final cleaned = stringValue.replaceAll(',', '.');
        return double.tryParse(cleaned) ?? defaultValue;
      } catch (e) {
        return defaultValue;
      }
    }

    return Movimiento(
      id: json['id'],
      monto: _toDouble(json['monto'], 0.0),
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : null,
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      pagado: json['pagado'] ?? false,
      formaPago: json['forma_pago'],
      metodoPago: json['metodo_pago'],
      esCobro: json['es_cobro'] ?? false,
      destinatario: json['destinatario'],
      cobrarA: json['cobrar_a'],
      fechaPagoLimite: json['fecha_pago_limite'] != null
          ? DateTime.parse(json['fecha_pago_limite'])
          : null,
      idTrabajo: json['id_trabajo'],
      idFactura: json['id_factura'],
      fechaPago: json['fecha_pago'] != null
          ? DateTime.parse(json['fecha_pago'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monto': monto,
      'fecha': fecha?.toIso8601String().split('T')[0],
      'descripcion': descripcion,
      'categoria': categoria,
      'pagado': pagado,
      'forma_pago': formaPago,
      'metodo_pago': metodoPago,
      'es_cobro': esCobro,
      'destinatario': destinatario,
      'cobrar_a': cobrarA,
      'fecha_pago_limite': fechaPagoLimite?.toIso8601String().split('T')[0],
      'id_trabajo': idTrabajo,
      'id_factura': idFactura,
      'fecha_pago': fechaPago?.toIso8601String().split('T')[0],
    };
  }

  String get tipoMovimiento => esCobro ? 'Ingreso' : 'Gasto';

  Movimiento copyWith({
    int? id,
    double? monto,
    DateTime? fecha,
    String? descripcion,
    String? categoria,
    bool? pagado,
    String? formaPago,
    String? metodoPago,
    bool? esCobro,
    String? destinatario,
    String? cobrarA,
    DateTime? fechaPagoLimite,
    int? idTrabajo,
    int? idFactura,
    DateTime? fechaPago,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Movimiento(
      id: id ?? this.id,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      pagado: pagado ?? this.pagado,
      formaPago: formaPago ?? this.formaPago,
      metodoPago: metodoPago ?? this.metodoPago,
      esCobro: esCobro ?? this.esCobro,
      destinatario: destinatario ?? this.destinatario,
      cobrarA: cobrarA ?? this.cobrarA,
      fechaPagoLimite: fechaPagoLimite ?? this.fechaPagoLimite,
      idTrabajo: idTrabajo ?? this.idTrabajo,
      idFactura: idFactura ?? this.idFactura,
      fechaPago: fechaPago ?? this.fechaPago,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
