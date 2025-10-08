import '../models/factura.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class FacturaService {
  static Future<List<Factura>> getFacturas({int? skip, int? limit, String? estado}) async {
    try {
      String endpoint = '${AppConstants.facturasEndpoint}';
      final params = <String>[];
      if (skip != null) params.add('skip=$skip');
      if (limit != null) params.add('limit=$limit');
      if (estado != null) params.add('estado=$estado');
      
      if (params.isNotEmpty) {
        endpoint += '?${params.join('&')}';
      }
      
      final response = await ApiService.get(endpoint);
      final List<dynamic> facturasData = response is List ? response : (response['data'] ?? []);
      return facturasData.map((json) => Factura.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener facturas: $e');
    }
  }

  static Future<Factura> getFactura(int id) async {
    try {
      final response = await ApiService.get('${AppConstants.facturasEndpoint}/$id');
      return Factura.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener factura: $e');
    }
  }

  static Future<Factura> createFactura(Factura factura) async {
    try {
      final response = await ApiService.post(AppConstants.facturasEndpoint, factura.toJson());
      if (response is Map<String, dynamic>) {
        return Factura.fromJson(response);
      }
      throw Exception('Respuesta inesperada al crear factura');
    } catch (e) {
      throw Exception('Error al crear factura: $e');
    }
  }

  static Future<Factura> updateFactura(Factura factura) async {
    try {
      final response = await ApiService.put('${AppConstants.facturasEndpoint}/${factura.id}', factura.toJson());
      return Factura.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar factura: $e');
    }
  }

  static Future<void> deleteFactura(int id) async {
    try {
      await ApiService.delete('${AppConstants.facturasEndpoint}/$id');
    } catch (e) {
      throw Exception('Error al eliminar factura: $e');
    }
  }

  static Future<List<Factura>> getFacturasByCliente(int clienteId) async {
    try {
      final response = await ApiService.get('${AppConstants.facturasEndpoint}/cliente/$clienteId');
      final List<dynamic> facturasData = response['data'] ?? response;
      return facturasData.map((json) => Factura.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener facturas del cliente: $e');
    }
  }

  static Future<List<Factura>> getFacturasPendientes() async {
    try {
      final response = await ApiService.get('${AppConstants.facturasEndpoint}/pendientes');
      final List<dynamic> facturasData = response['data'] ?? response;
      return facturasData.map((json) => Factura.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener facturas pendientes: $e');
    }
  }

  static Future<List<Factura>> getFacturasVencidas() async {
    try {
      final response = await ApiService.get('${AppConstants.facturasEndpoint}/vencidas');
      final List<dynamic> facturasData = response['data'] ?? response;
      return facturasData.map((json) => Factura.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener facturas vencidas: $e');
    }
  }

  static Future<Map<String, dynamic>> getResumenFacturacion() async {
    try {
      final response = await ApiService.get('${AppConstants.facturasEndpoint}/resumen');
      return response;
    } catch (e) {
      throw Exception('Error al obtener resumen de facturación: $e');
    }
  }
}
