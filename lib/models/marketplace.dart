class MarketplaceItem {
  final int id;
  final String tipo;
  final String titulo;
  final String categoria;
  final String descripcion;
  final String nombrePublico;
  final double latitud;
  final double longitud;
  final bool esPropio;
  final double? hectareas;
  final int? radioCoberturaKm;

  const MarketplaceItem({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.categoria,
    required this.descripcion,
    required this.nombrePublico,
    required this.latitud,
    required this.longitud,
    required this.esPropio,
    this.hectareas,
    this.radioCoberturaKm,
  });

  factory MarketplaceItem.fromJson(String tipo, Map<String, dynamic> json) {
    double? number(dynamic value) => value == null
        ? null
        : value is num
            ? value.toDouble()
            : double.tryParse(value.toString());

    return MarketplaceItem(
      id: json['id'] as int,
      tipo: tipo,
      titulo: json['titulo']?.toString() ?? '',
      categoria: json['categoria']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      nombrePublico: json['nombre_publico']?.toString() ?? 'Usuario GesAgro',
      latitud: number(json['latitud']) ?? 0,
      longitud: number(json['longitud']) ?? 0,
      esPropio: json['es_propio'] == true,
      hectareas: number(json['hectareas']),
      radioCoberturaKm: number(json['radio_cobertura_km'])?.round(),
    );
  }
}
