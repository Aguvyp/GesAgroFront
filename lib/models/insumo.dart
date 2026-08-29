class Insumo {
  final int id;
  final String nombre;
  final String categoria;
  final String unidad; // 'kg', 'litros', 'unidades', etc.
  final double stockActual;
  final double stockMinimo;
  final double precioUnitario;
  final String? proveedor;
  final DateTime? fechaVencimiento;
  final String? observaciones;
  final bool activo;

  Insumo({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.unidad,
    required this.stockActual,
    required this.stockMinimo,
    required this.precioUnitario,
    this.proveedor,
    this.fechaVencimiento,
    this.observaciones,
    this.activo = true,
  });

  factory Insumo.fromJson(Map<String, dynamic> json) {
    return Insumo(
      id: json['id'],
      nombre: json['nombre'],
      categoria: json['categoria'],
      unidad: json['unidad'],
      stockActual: json['stock_actual'].toDouble(),
      stockMinimo: json['stock_minimo'].toDouble(),
      precioUnitario: json['precio_unitario'].toDouble(),
      proveedor: json['proveedor'],
      fechaVencimiento: json['fecha_vencimiento'] != null
          ? DateTime.parse(json['fecha_vencimiento'])
          : null,
      observaciones: json['observaciones'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'unidad': unidad,
      'stock_actual': stockActual,
      'stock_minimo': stockMinimo,
      'precio_unitario': precioUnitario,
      'proveedor': proveedor,
      'fecha_vencimiento': fechaVencimiento?.toIso8601String(),
      'observaciones': observaciones,
      'activo': activo,
    };
  }

  bool get bajoStock => stockActual <= stockMinimo;
  bool get sinStock => stockActual <= 0;
  bool get proximoVencimiento {
    if (fechaVencimiento == null) return false;
    final diasRestantes = fechaVencimiento!.difference(DateTime.now()).inDays;
    return diasRestantes <= 30 && diasRestantes >= 0;
  }

  bool get vencido {
    if (fechaVencimiento == null) return false;
    return DateTime.now().isAfter(fechaVencimiento!);
  }

  Insumo copyWith({
    int? id,
    String? nombre,
    String? categoria,
    String? unidad,
    double? stockActual,
    double? stockMinimo,
    double? precioUnitario,
    String? proveedor,
    DateTime? fechaVencimiento,
    String? observaciones,
    bool? activo,
  }) {
    return Insumo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      unidad: unidad ?? this.unidad,
      stockActual: stockActual ?? this.stockActual,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      proveedor: proveedor ?? this.proveedor,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      observaciones: observaciones ?? this.observaciones,
      activo: activo ?? this.activo,
    );
  }
}
