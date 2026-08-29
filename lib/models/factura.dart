class Factura {
  final int id;
  final int clienteId;
  final String numero;
  final DateTime fechaEmision;
  final DateTime fechaVencimiento;
  final double montoTotal;
  final double montoPagado;
  final String estado; // 'Pendiente', 'Pagada', 'Vencida', 'Cancelada'
  final String? observaciones;
  final List<FacturaItem> items;

  Factura({
    required this.id,
    required this.clienteId,
    required this.numero,
    required this.fechaEmision,
    required this.fechaVencimiento,
    required this.montoTotal,
    this.montoPagado = 0.0,
    this.estado = 'Pendiente',
    this.observaciones,
    this.items = const [],
  });

  factory Factura.fromJson(Map<String, dynamic> json) {
    return Factura(
      id: json['id'],
      clienteId: json['cliente_id'] ?? json['cliente'],
      numero: json['numero'],
      fechaEmision: DateTime.parse(json['fecha_emision']),
      fechaVencimiento: DateTime.parse(json['fecha_vencimiento']),
      montoTotal: json['monto_total'].toDouble(),
      montoPagado: json['monto_pagado']?.toDouble() ?? 0.0,
      estado: json['estado'],
      observaciones: json['observaciones'],
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => FacturaItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente': clienteId,
      'numero': numero,
      'fecha_emision': fechaEmision.toIso8601String(),
      'fecha_vencimiento': fechaVencimiento.toIso8601String(),
      'monto_total': montoTotal,
      'monto_pagado': montoPagado,
      'estado': estado,
      'observaciones': observaciones,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  double get montoPendiente => montoTotal - montoPagado;
  bool get estaPagada => estado == 'Pagada';
  bool get estaVencida =>
      estado == 'Vencida' ||
      (DateTime.now().isAfter(fechaVencimiento) && estado == 'Pendiente');
  bool get estaPendiente => estado == 'Pendiente' && !estaVencida;

  Factura copyWith({
    int? id,
    int? clienteId,
    String? numero,
    DateTime? fechaEmision,
    DateTime? fechaVencimiento,
    double? montoTotal,
    double? montoPagado,
    String? estado,
    String? observaciones,
    List<FacturaItem>? items,
  }) {
    return Factura(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      numero: numero ?? this.numero,
      fechaEmision: fechaEmision ?? this.fechaEmision,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      montoTotal: montoTotal ?? this.montoTotal,
      montoPagado: montoPagado ?? this.montoPagado,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      items: items ?? this.items,
    );
  }
}

class FacturaItem {
  final int id;
  final String descripcion;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  FacturaItem({
    required this.id,
    required this.descripcion,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory FacturaItem.fromJson(Map<String, dynamic> json) {
    return FacturaItem(
      id: json['id'],
      descripcion: json['descripcion'],
      cantidad: json['cantidad'],
      precioUnitario: json['precio_unitario'].toDouble(),
      subtotal: json['subtotal'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': descripcion,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'subtotal': subtotal,
    };
  }
}
