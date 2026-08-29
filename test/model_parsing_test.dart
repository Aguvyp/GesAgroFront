import 'package:flutter_test/flutter_test.dart';
import 'package:ges_agro_front/models/campo.dart';
import 'package:ges_agro_front/models/trabajo.dart';
import 'package:ges_agro_front/models/factura.dart';
import 'package:ges_agro_front/models/mantenimiento.dart';

void main() {
  group('Modelos de dominio', () {
    test('Campo acepta números serializados por Django como texto', () {
      final campo = Campo.fromJson({
        'id': '12',
        'nombre': 'La Esperanza',
        'hectareas': '125,50',
        'latitud': '-33.1234',
        'longitud': -61.25,
        'propio': true,
        'cliente_id': '7',
        'lotes_count': '3',
      });

      expect(campo.id, 12);
      expect(campo.superficieHa, 125.5);
      expect(campo.latitud, -33.1234);
      expect(campo.longitud, -61.25);
      expect(campo.clienteId, 7);
      expect(campo.lotesCount, 3);
    });

    test('Trabajo interpreta relaciones y fechas del backend', () {
      final trabajo = Trabajo.fromJson({
        'id': 5,
        'id_tipo_trabajo': '2',
        'tipo_trabajo_nombre': 'Siembra',
        'cultivo': 'Soja',
        'fecha_inicio': '2026-08-29',
        'campo': {'id': 9, 'nombre': 'San Pedro'},
        'lote_id': '4',
        'id_personal': [1, 2],
        'id_maquinas': [3],
        'estado': 'Pendiente',
      });

      expect(trabajo.id, 5);
      expect(trabajo.idTipoTrabajo, 2);
      expect(trabajo.idCampo, 9);
      expect(trabajo.campoNombre, 'San Pedro');
      expect(trabajo.loteId, 4);
      expect(trabajo.idPersonal, [1, 2]);
      expect(trabajo.idMaquinas, [3]);
      expect(trabajo.fechaInicio, DateTime(2026, 8, 29));
    });

    test('Los payloads usan los nombres de relaciones de Django REST', () {
      final trabajo = Trabajo(
        cultivo: 'Soja',
        fechaInicio: DateTime(2026, 8, 29),
        idPersonal: const [],
        idMaquinas: const [],
        idCampo: 9,
      );
      final mantenimiento = Mantenimiento(
        idMaquina: 3,
        fecha: DateTime(2026, 8, 29),
        descripcion: 'Service',
        estado: 'Pendiente',
        costoTotal: 100,
      );
      final factura = Factura(
        id: 0,
        clienteId: 7,
        numero: 'A-1',
        fechaEmision: DateTime(2026, 8, 29),
        fechaVencimiento: DateTime(2026, 9, 29),
        montoTotal: 100,
        montoPagado: 0,
        estado: 'Pendiente',
        items: const [],
      );

      expect(trabajo.toJson()['campo'], 9);
      expect(trabajo.toJson().containsKey('campo_id'), isFalse);
      expect(mantenimiento.toJson()['maquina'], 3);
      expect(factura.toJson()['cliente'], 7);
    });
  });
}
