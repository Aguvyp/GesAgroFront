import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/cliente.dart';

class ClienteDetailScreen extends StatelessWidget {
  final Cliente cliente;

  const ClienteDetailScreen({
    Key? key,
    required this.cliente,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Detalle del Cliente',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C1C1E),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          color: const Color(0xFF1C1C1E),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con avatar y nombre
            _buildHeader(context),
            const SizedBox(height: 24),

            // Información de contacto
            _buildSection(
              context,
              'Información de Contacto',
              Icons.contact_mail,
              [
                if (cliente.email != null && cliente.email!.isNotEmpty)
                  _buildInfoRow(Icons.email, 'Email', cliente.email!),
                if (cliente.telefono != null && cliente.telefono!.isNotEmpty)
                  _buildInfoRow(Icons.phone, 'Teléfono', cliente.telefono!),
                if (cliente.direccion != null && cliente.direccion!.isNotEmpty)
                  _buildInfoRow(
                      Icons.location_on, 'Dirección', cliente.direccion!),
              ],
            ),
            const SizedBox(height: 16),

            // Información fiscal
            if (cliente.cuit != null && cliente.cuit!.isNotEmpty) ...[
              _buildSection(
                context,
                'Información Fiscal',
                Icons.account_balance,
                [
                  _buildInfoRow(Icons.badge, 'CUIT', cliente.cuit!),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Observaciones
            if (cliente.observaciones != null &&
                cliente.observaciones!.isNotEmpty) ...[
              _buildSection(
                context,
                'Observaciones',
                Icons.notes,
                [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      cliente.observaciones!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Información del sistema
            _buildSection(
              context,
              'Información del Sistema',
              Icons.info_outline,
              [
                if (cliente.fechaCreacion != null)
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Fecha de Creación',
                    DateFormat('dd/MM/yyyy HH:mm')
                        .format(cliente.fechaCreacion!),
                  ),
                if (cliente.fechaModificacion != null)
                  _buildInfoRow(
                    Icons.update,
                    'Última Modificación',
                    DateFormat('dd/MM/yyyy HH:mm')
                        .format(cliente.fechaModificacion!),
                  ),
                if (cliente.id != null)
                  _buildInfoRow(Icons.tag, 'ID', cliente.id.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Text(
                cliente.initials,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cliente.nombre ?? 'Sin nombre',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cliente',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
