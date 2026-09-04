import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../models/marketplace.dart';
import '../../services/optimized_api_service.dart';

class MarketplaceMapScreen extends StatefulWidget {
  const MarketplaceMapScreen({super.key});

  @override
  State<MarketplaceMapScreen> createState() => _MarketplaceMapScreenState();
}

class _MarketplaceMapScreenState extends State<MarketplaceMapScreen> {
  static const _center = LatLng(-33.3, -61.2);
  final _api = ApiService();
  final _mapController = MapController();
  List<MarketplaceItem> _items = [];
  bool _loading = true;
  bool _locating = false;
  String _filter = 'todos';
  LatLng? _draftLocation;
  int _draftRadiusKm = 50;
  bool _requestedInitialLocation = false;

  @override
  void initState() {
    super.initState();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_requestedInitialLocation) {
        _requestedInitialLocation = true;
        _useCurrentLocation();
      }
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await _api.initialize();
      final items = await _api.getMarketplaceMap();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar la Red Agro')),
      );
    }
  }

  List<MarketplaceItem> get _visibleItems => _filter == 'todos'
      ? _items
      : _items.where((item) => item.tipo == _filter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Red Agro'),
        actions: [
          IconButton(
            tooltip: 'Mi perfil público',
            onPressed: _editProfile,
            icon: const Icon(Icons.account_circle_outlined),
          ),
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openPublishMenu,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Publicar'),
      ),
      body: Stack(children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _center,
            initialZoom: 6.2,
            onTap: (_, point) {
              setState(() => _draftLocation = point);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Ubicación ajustada. Tocá Publicar.'),
                duration: Duration(seconds: 2),
              ));
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.gesagro.app',
            ),
            CircleLayer(circles: [
              ..._visibleItems.map(_circleFor),
              if (_draftLocation != null)
                CircleMarker(
                  point: _draftLocation!,
                  radius: _draftRadiusKm * 1000,
                  useRadiusInMeter: true,
                  color: Colors.deepPurple.withValues(alpha: 0.10),
                  borderColor: Colors.deepPurple.withValues(alpha: 0.7),
                  borderStrokeWidth: 2,
                ),
            ]),
            MarkerLayer(markers: [
              ..._visibleItems.map(_markerFor),
              if (_draftLocation != null)
                Marker(
                  point: _draftLocation!,
                  width: 46,
                  height: 46,
                  child: const Icon(Icons.location_on,
                      size: 44, color: Colors.deepPurple),
                ),
            ]),
          ],
        ),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'todos', label: Text('Todos')),
                    ButtonSegment(
                        value: 'servicio',
                        label: Text('Prestadores'),
                        icon: Icon(Icons.agriculture, size: 17)),
                    ButtonSegment(
                        value: 'pedido',
                        label: Text('Pedidos'),
                        icon: Icon(Icons.campaign_outlined, size: 17)),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (value) =>
                      setState(() => _filter = value.first),
                ),
              ),
            ),
          ),
        ),
        if (_loading) const Center(child: CircularProgressIndicator()),
        Positioned(
          right: 12,
          bottom: 82,
          child: FloatingActionButton.small(
            heroTag: 'marketplace-current-location',
            tooltip: 'Usar mi ubicación actual',
            onPressed: _locating ? null : _useCurrentLocation,
            child: _locating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded),
          ),
        ),
        const Positioned(
          left: 12,
          bottom: 18,
          child: Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.circle, color: Color(0xFF2E7D32), size: 12),
                SizedBox(width: 5),
                Text('Servicio'),
                SizedBox(width: 12),
                Icon(Icons.circle, color: Color(0xFFF57C00), size: 12),
                SizedBox(width: 5),
                Text('Pedido'),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Marker _markerFor(MarketplaceItem item) => Marker(
        point: LatLng(item.latitud, item.longitud),
        width: 52,
        height: 52,
        child: GestureDetector(
          onTap: () => _showItem(item),
          child: Container(
            decoration: BoxDecoration(
              color: item.tipo == 'servicio'
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFF57C00),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(blurRadius: 5, color: Colors.black38)
              ],
            ),
            child: Icon(
              item.tipo == 'servicio'
                  ? Icons.agriculture
                  : Icons.campaign_outlined,
              color: Colors.white,
            ),
          ),
        ),
      );

  CircleMarker _circleFor(MarketplaceItem item) {
    final color = item.tipo == 'servicio'
        ? const Color(0xFF2E7D32)
        : const Color(0xFFF57C00);
    return CircleMarker(
      point: LatLng(item.latitud, item.longitud),
      radius: (item.radioCoberturaKm ?? 50) * 1000,
      useRadiusInMeter: true,
      color: color.withValues(alpha: 0.10),
      borderColor: color.withValues(alpha: 0.65),
      borderStrokeWidth: 1.5,
    );
  }

  Future<void> _useCurrentLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (!mounted) return;
        await _showLocationMessage(
          'Activá la ubicación del teléfono para poder usar tu posición.',
          actionLabel: 'Abrir configuración',
          onAction: Geolocator.openLocationSettings,
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        final accepted = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                icon: const Icon(Icons.location_on_outlined, size: 42),
                title: const Text('Usar tu ubicación'),
                content: const Text(
                  'GesAgro usará tu ubicación solamente para proponerte un '
                  'punto en el mapa. Podés moverlo antes de publicar y los '
                  'demás usuarios verán una ubicación aproximada.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Ahora no'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Continuar'),
                  ),
                ],
              ),
            ) ??
            false;
        if (!accepted) return;
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        await _showLocationMessage(
          'El permiso de ubicación está bloqueado. Podés habilitarlo desde '
          'la configuración o elegir el punto manualmente.',
          actionLabel: 'Abrir configuración',
          onAction: Geolocator.openAppSettings,
        );
        return;
      }
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        await _showLocationMessage(
          'No se otorgó el permiso. Podés mantener presionado el mapa para '
          'seleccionar la ubicación manualmente.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (!mounted) return;
      final point = LatLng(position.latitude, position.longitude);
      setState(() => _draftLocation = point);
      _mapController.move(point, 14);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Ubicación propuesta. Ajustala en el mapa si lo necesitás.',
        ),
      ));
    } catch (_) {
      if (!mounted) return;
      await _showLocationMessage(
        'No pudimos obtener tu ubicación. Podés elegirla manualmente '
        'manteniendo presionado el mapa.',
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _showLocationMessage(
    String message, {
    String? actionLabel,
    Future<bool> Function()? onAction,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubicación'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
          if (actionLabel != null && onAction != null)
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await onAction();
              },
              child: Text(actionLabel),
            ),
        ],
      ),
    );
  }

  void _showItem(MarketplaceItem item) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: item.tipo == 'servicio'
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3E0),
              child: Icon(item.tipo == 'servicio'
                  ? Icons.agriculture
                  : Icons.campaign_outlined),
            ),
            title: Text(item.titulo,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${item.nombrePublico} · ${item.categoria}'),
          ),
          if (item.descripcion.isNotEmpty)
            Align(
                alignment: Alignment.centerLeft, child: Text(item.descripcion)),
          if (item.hectareas != null)
            Align(
                alignment: Alignment.centerLeft,
                child: Text('${item.hectareas} hectáreas')),
          if (item.radioCoberturaKm != null)
            Align(
                alignment: Alignment.centerLeft,
                child: Text('Cobertura: ${item.radioCoberturaKm} km')),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: item.esPropio
                ? OutlinedButton.icon(
                    onPressed: () => _deleteItem(item, context),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar mi publicación'),
                  )
                : FilledButton.icon(
                    onPressed: () => _requestContact(item, context),
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Ver datos de contacto'),
                  ),
          ),
        ]),
      ),
    );
  }

  Future<void> _requestContact(
      MarketplaceItem item, BuildContext sheetContext) async {
    final response = await _api.getMarketplaceContact(item.tipo, item.id);
    if (!mounted || !sheetContext.mounted) return;
    Navigator.pop(sheetContext);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.workspace_premium_outlined, size: 42),
        title: const Text('Contacto protegido'),
        content: Text(response['detail']?.toString() ??
            'El desbloqueo estará disponible próximamente.'),
        actions: [
          FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido')),
        ],
      ),
    );
  }

  Future<void> _deleteItem(
      MarketplaceItem item, BuildContext sheetContext) async {
    await _api.deleteMarketplaceItem(item.tipo, item.id);
    if (!mounted || !sheetContext.mounted) return;
    Navigator.pop(sheetContext);
    await _load();
  }

  void _openPublishMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const ListTile(
            title: Text('¿Qué querés publicar?',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle:
                Text('Usamos tu GPS. Tocá el mapa para ajustar el punto.'),
          ),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.agriculture)),
            title: const Text('Ofrezco un servicio'),
            onTap: () {
              Navigator.pop(context);
              _showPublicationForm('servicio');
            },
          ),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.campaign_outlined)),
            title: const Text('Necesito un servicio'),
            onTap: () {
              Navigator.pop(context);
              _showPublicationForm('pedido');
            },
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  Future<void> _showPublicationForm(String tipo) async {
    if (_draftLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Esperá la ubicación del GPS o tocá el mapa para elegir la zona.')));
      return;
    }
    final key = GlobalKey<FormState>();
    final title = TextEditingController();
    final category = TextEditingController();
    final description = TextEditingController();
    final radius = TextEditingController(text: '50');
    final hectares = TextEditingController();
    var saving = false;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          title:
              Text(tipo == 'servicio' ? 'Ofrecer servicio' : 'Pedir servicio'),
          content: SingleChildScrollView(
            child: Form(
              key: key,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Título'),
                  validator: _required,
                ),
                TextFormField(
                  controller: category,
                  decoration: const InputDecoration(
                      labelText: 'Categoría', hintText: 'Ej. Siembra, cosecha'),
                  validator: _required,
                ),
                TextFormField(
                  controller: description,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextFormField(
                  controller: radius,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Radio de alcance (km)',
                    helperText: 'Se mostrará como un círculo en el mapa',
                  ),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed < 1 || parsed > 500) {
                      return 'Ingresá un valor entre 1 y 500 km';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed >= 1 && parsed <= 500) {
                      setState(() => _draftRadiusKm = parsed);
                    }
                  },
                ),
                if (tipo == 'pedido')
                  TextFormField(
                    controller: hectares,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'Hectáreas (opcional)'),
                  ),
              ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: saving ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (!key.currentState!.validate()) return;
                      setDialogState(() => saving = true);
                      final payload = <String, dynamic>{
                        'titulo': title.text.trim(),
                        'categoria': category.text.trim(),
                        'descripcion': description.text.trim(),
                        'latitud': _draftLocation!.latitude,
                        'longitud': _draftLocation!.longitude,
                        'radio_cobertura_km': int.parse(radius.text),
                      };
                      if (tipo == 'pedido' && hectares.text.isNotEmpty) {
                        payload['hectareas'] =
                            double.tryParse(hectares.text.replaceAll(',', '.'));
                      }
                      try {
                        await _api.createMarketplaceItem(tipo, payload);
                        if (!mounted || !dialogContext.mounted) return;
                        Navigator.pop(dialogContext);
                        setState(() => _draftLocation = null);
                        await _load();
                      } catch (error) {
                        setDialogState(() => saving = false);
                        if (!mounted || !dialogContext.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(_publicationError(error)),
                        ));
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
    title.dispose();
    category.dispose();
    description.dispose();
    radius.dispose();
    hectares.dispose();
  }

  String _publicationError(Object error) {
    final message = error.toString();
    if (message.contains('401')) {
      return 'Tu sesión venció. Cerrá sesión e ingresá nuevamente.';
    }
    if (message.contains('400')) {
      return 'Revisá los datos de la publicación e intentá nuevamente.';
    }
    return 'No se pudo publicar. Verificá tu conexión e intentá nuevamente.';
  }

  Future<void> _editProfile() async {
    final key = GlobalKey<FormState>();
    final name = TextEditingController();
    final locality = TextEditingController();
    final phone = TextEditingController();
    final description = TextEditingController();
    var type = 'Ambos';
    try {
      final profile = await _api.getMarketplaceProfile();
      if (profile != null) {
        name.text = profile['nombre_publico']?.toString() ?? '';
        locality.text = profile['localidad']?.toString() ?? '';
        phone.text = profile['telefono_contacto']?.toString() ?? '';
        description.text = profile['descripcion']?.toString() ?? '';
        type = profile['tipo']?.toString() ?? type;
      }
    } catch (_) {
      // El formulario sigue disponible aun si no se pudo leer el perfil.
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          title: const Text('Mi perfil público'),
          content: SingleChildScrollView(
            child: Form(
              key: key,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                    controller: name,
                    decoration:
                        const InputDecoration(labelText: 'Nombre público'),
                    validator: _required),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Perfil'),
                  items: const [
                    DropdownMenuItem(
                        value: 'Productor', child: Text('Productor')),
                    DropdownMenuItem(
                        value: 'Prestador', child: Text('Prestador')),
                    DropdownMenuItem(value: 'Ambos', child: Text('Ambos')),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => type = value ?? type),
                ),
                TextFormField(
                    controller: locality,
                    decoration: const InputDecoration(labelText: 'Localidad')),
                TextFormField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: 'Teléfono privado de contacto')),
                TextFormField(
                    controller: description,
                    maxLines: 2,
                    decoration:
                        const InputDecoration(labelText: 'Descripción')),
              ]),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                if (!key.currentState!.validate()) return;
                await _api.saveMarketplaceProfile({
                  'nombre_publico': name.text.trim(),
                  'tipo': type,
                  'localidad': locality.text.trim(),
                  'telefono_contacto': phone.text.trim(),
                  'descripcion': description.text.trim(),
                });
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    locality.dispose();
    phone.dispose();
    description.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Campo obligatorio' : null;
}
