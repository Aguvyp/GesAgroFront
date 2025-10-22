import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/trabajo_detalle.dart';
import '../providers/trabajo_detalle_provider.dart';

/// Widget para mostrar los detalles completos de un trabajo
class TrabajoDetalleWidget extends ConsumerWidget {
  final int trabajoId;
  final bool showTitle;
  final EdgeInsetsGeometry? padding;

  const TrabajoDetalleWidget({
    Key? key,
    required this.trabajoId,
    this.showTitle = true,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trabajoDetalleState = ref.watch(trabajoDetalleProvider);

    return Padding(
      padding: padding ?? const EdgeInsets.all(16.0),
      child: trabajoDetalleState.when(
        data: (trabajoDetalle) {
          if (trabajoDetalle == null) {
            return const Center(child: Text('Trabajo no encontrado'));
          }
          return _buildTrabajoDetalle(context, trabajoDetalle);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(trabajoDetalleProvider.notifier).loadTrabajoDetalle(trabajoId);
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrabajoDetalle(BuildContext context, TrabajoDetalle trabajo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            'Detalles del Trabajo',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Información básica
        _buildInfoCard(
          context,
          'Información Básica',
          [
            _buildInfoRow('Tipo', trabajo.tipo),
            _buildInfoRow('Cultivo', trabajo.cultivo),
            _buildInfoRow('Estado', trabajo.estado ?? 'Pendiente'),
            _buildInfoRow('Período', trabajo.formattedDateRange),
            _buildInfoRow('Duración', '${trabajo.durationDays} días'),
            if (trabajo.observaciones?.isNotEmpty == true)
              _buildInfoRow('Observaciones', trabajo.observaciones!),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Información del campo
        _buildInfoCard(
          context,
          'Campo',
          [
            _buildInfoRow('Nombre', trabajo.campoNombre),
            _buildInfoRow('Superficie', '${trabajo.campoHectareas.toStringAsFixed(1)} ha'),
            if (trabajo.campo?.detalles?.isNotEmpty == true)
              _buildInfoRow('Detalles', trabajo.campo!.detalles!),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Información del cliente
        _buildInfoCard(
          context,
          'Cliente',
          [
            _buildInfoRow('Tipo', trabajo.aTerceros ? 'Trabajo a terceros' : 'Trabajo propio'),
            if (trabajo.clienteInfo != null) ...[
              _buildInfoRow('Nombre/Razón Social', trabajo.clienteInfo!.nombreRazonSocial),
              _buildInfoRow('CUIT', trabajo.clienteInfo!.cuit),
              _buildInfoRow('Dirección', trabajo.clienteInfo!.direccion),
              _buildInfoRow('Teléfono', trabajo.clienteInfo!.telefono),
              _buildInfoRow('Email', trabajo.clienteInfo!.email),
            ] else if (trabajo.cliente.isNotEmpty) ...[
              _buildInfoRow('Cliente', trabajo.cliente),
            ],
            if (trabajo.montoCobrado != null)
              _buildInfoRow('Monto cobrado', '\$${NumberFormat('#,##0.00').format(trabajo.montoCobrado)}'),
            _buildInfoRow('Estado de cobro', trabajo.cobrado ? 'Cobrado' : 'Pendiente'),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Personal/Operarios
        _buildInfoCard(
          context,
          'Personal/Operarios',
          [
            _buildInfoRow('Total', '${trabajo.totalPersonal} operario${trabajo.totalPersonal > 1 ? 's' : ''}'),
            _buildInfoRow('Hectáreas totales', '${trabajo.totalHectareasPersonal.toStringAsFixed(1)} ha'),
            if (trabajo.personal.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...trabajo.personal.map((per) => _buildPersonalItem(per)),
            ],
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Máquinas
        _buildInfoCard(
          context,
          'Máquinas',
          [
            _buildInfoRow('Total', '${trabajo.totalMaquinas} máquina${trabajo.totalMaquinas > 1 ? 's' : ''}'),
            if (trabajo.maquinas.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...trabajo.maquinas.map((maq) => _buildMaquinaTrabajoItem(maq)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalItem(PersonalTrabajo personal) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  personal.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'DNI: ${personal.dni}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (personal.rol != null)
                  Text(
                    'Rol: ${personal.rol}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${personal.ha.toStringAsFixed(1)} ha',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaquinaTrabajoItem(MaquinaTrabajo maquina) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.build, size: 20, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maquina.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${maquina.marca} ${maquina.modelo}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget compacto para mostrar solo información esencial del trabajo
class TrabajoDetalleCompacto extends ConsumerWidget {
  final int trabajoId;
  final bool showOperarios;
  final bool showMaquinas;

  const TrabajoDetalleCompacto({
    Key? key,
    required this.trabajoId,
    this.showOperarios = true,
    this.showMaquinas = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trabajoDetalleState = ref.watch(trabajoDetalleProvider);

    return trabajoDetalleState.when(
      data: (trabajoDetalle) {
        if (trabajoDetalle == null) {
          return const Text('Trabajo no encontrado');
        }
        return _buildCompacto(context, trabajoDetalle);
      },
      loading: () => const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stackTrace) => Text('Error: $error'),
    );
  }

  Widget _buildCompacto(BuildContext context, TrabajoDetalle trabajo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Información básica
        Text(
          '${trabajo.tipo} - ${trabajo.cultivo}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          trabajo.campoInfo,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          trabajo.trabajoInfo,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        
        if (showOperarios && trabajo.personal.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            trabajo.personalInfo,
            style: const TextStyle(fontSize: 12, color: Colors.blue),
          ),
        ],
        
        if (showMaquinas && trabajo.maquinas.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            trabajo.maquinasInfo,
            style: const TextStyle(fontSize: 12, color: Colors.green),
          ),
        ],
      ],
    );
  }
}
