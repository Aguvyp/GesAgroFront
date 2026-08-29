import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../utils/constants.dart';
import '../../utils/maps_config.dart';

class MapLocationScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const MapLocationScreen({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
  }) : super(key: key);

  @override
  State<MapLocationScreen> createState() => _MapLocationScreenState();
}

class _MapLocationScreenState extends State<MapLocationScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  MapType _mapType = MapType.terrain;

  @override
  void initState() {
    super.initState();

    // Establecer ubicación inicial
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation =
          LatLng(widget.initialLatitude!, widget.initialLongitude!);
    } else {
      // Ubicación por defecto desde configuración
      _selectedLocation =
          const LatLng(MapsConfig.defaultLatitude, MapsConfig.defaultLongitude);
    }

    // Simular carga inicial con manejo de errores
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Verificar si la API key está configurada correctamente
          if (!MapsConfig.isApiKeyConfigured) {
            _hasError = true;
            _errorMessage = MapsConfig.apiKeyError;
          }
        });
      }
    });
  }

  void _onMapTapped(LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Limpiar errores si el mapa se carga correctamente
    if (_hasError) {
      setState(() {
        _hasError = false;
        _errorMessage = '';
      });
    }
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Navigator.of(context).pop({
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
      });
    }
  }

  void _useCurrentLocation() async {
    // Aquí podrías implementar la geolocalización actual
    // Por ahora, mostraremos un mensaje informativo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            const Text('Función de ubicación actual próximamente disponible'),
        backgroundColor: const Color(AppConstants.infoColor),
      ),
    );
  }

  void _changeMapType() {
    setState(() {
      switch (_mapType) {
        case MapType.terrain:
          _mapType = MapType.satellite;
          break;
        case MapType.satellite:
          _mapType = MapType.hybrid;
          break;
        case MapType.hybrid:
          _mapType = MapType.terrain;
          break;
        default:
          _mapType = MapType.terrain;
      }
    });

    // Centrar el mapa en la ubicación seleccionada
    if (_mapController != null && _selectedLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_selectedLocation!),
      );
    }
  }

  String _getMapTypeLabel() {
    switch (_mapType) {
      case MapType.terrain:
        return 'Relieve';
      case MapType.satellite:
        return 'Satelital';
      case MapType.hybrid:
        return 'Híbrido';
      default:
        return 'Relieve';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Seleccionar Ubicación',
        actions: [
          TextButton(
            onPressed: _changeMapType,
            child: Text(
              _getMapTypeLabel(),
              style: const TextStyle(
                color: Color(AppConstants.primaryColor),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: _useCurrentLocation,
            child: const Text(
              'Mi Ubicación',
              style: TextStyle(
                color: Color(AppConstants.primaryColor),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Maps
          if (!_isLoading)
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _selectedLocation!,
                zoom: MapsConfig.defaultZoom,
              ),
              mapType: _mapType,
              onTap: _onMapTapped,
              markers: _selectedLocation != null
                  ? {
                      Marker(
                        markerId: const MarkerId('selected_location'),
                        position: _selectedLocation!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed),
                      ),
                    }
                  : {},
            ),

          // Indicador de carga o error
          if (_isLoading || _hasError)
            Container(
              color: Colors.grey[100],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading) ...[
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text(
                        'Cargando mapa...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(AppConstants.textColor),
                        ),
                      ),
                    ] else if (_hasError) ...[
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Color(AppConstants.errorColor),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(AppConstants.errorColor),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _hasError = false;
                            _errorMessage = '';
                          });
                          // Reintentar carga
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          });
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Información de coordenadas
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Coordenadas Seleccionadas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(AppConstants.textColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_selectedLocation != null) ...[
                    Text(
                      'Latitud: ${_selectedLocation!.latitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(AppConstants.textColor),
                      ),
                    ),
                    Text(
                      'Longitud: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(AppConstants.textColor),
                      ),
                    ),
                  ] else
                    const Text(
                      'Toca el mapa para seleccionar una ubicación',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(AppConstants.textColor),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Instrucciones
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(AppConstants.primaryColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.touch_app,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Toca el mapa para seleccionar la ubicación del campo.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botones de acción
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancelar',
                    isOutlined: true,
                    backgroundColor: const Color(AppConstants.cancelColor),
                    textColor: const Color(AppConstants.textColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Confirmar',
                    onPressed:
                        _selectedLocation != null ? _confirmLocation : null,
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
