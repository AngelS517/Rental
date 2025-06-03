import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox_gl;
import 'package:geolocator/geolocator.dart' as geo;
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapaAutomovil extends StatefulWidget {
  const MapaAutomovil({Key? key}) : super(key: key);

  @override
  State<MapaAutomovil> createState() => _MapaAutomovilState();
}

class _MapaAutomovilState extends State<MapaAutomovil> {
  mapbox_gl.MapboxMap? _mapboxMap;
  geo.Position? _userLocation;
  mapbox_gl.Point? _vehicleLocation;
  bool _loading = true;
  mapbox_gl.PointAnnotationManager? _annotationManager;
  String? _vehicleAddress;
  bool _routeVisible = false; // Para alternar la visibilidad de la ruta

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF5A1EFF),
      statusBarIconBrightness: Brightness.light,
    ));
  }

  Future<void> _checkAndRequestPermissions() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      await Permission.locationWhenInUse.request();
    }
    await geo.Geolocator.requestPermission();
    _getUserLocation();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _vehicleAddress = '${args['direccion']}, ${args['ciudad']}, Colombia';
      await _getVehicleLocation(_vehicleAddress!);
    }
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) return;
    }

    final position = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.medium,
    );
    setState(() {
      _userLocation = position;
    });
    if (_mapboxMap != null && _userLocation != null) {
      _centerToUserLocation();
    }
  }

  Future<void> _getVehicleLocation(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() {
          _vehicleLocation = mapbox_gl.Point(
            coordinates: mapbox_gl.Position(locations[0].longitude, locations[0].latitude),
          );
          _loading = false;
        });
        if (_mapboxMap != null && _annotationManager != null) {
          _addMarkers();
        }
      }
    } catch (e) {
      debugPrint('Error al obtener ubicación del vehículo: $e');
      setState(() => _loading = false);
    }
  }

  void _centerToUserLocation() {
    if (_userLocation != null && _mapboxMap != null) {
      _mapboxMap?.flyTo(
        mapbox_gl.CameraOptions(
          center: mapbox_gl.Point(
            coordinates: mapbox_gl.Position(_userLocation!.longitude, _userLocation!.latitude),
          ),
          zoom: 15.0, // Zoom aumentado
        ),
        mapbox_gl.MapAnimationOptions(duration: 1500),
      );
    }
  }

  void _centerToVehicleLocation() {
    if (_vehicleLocation != null && _mapboxMap != null) {
      _mapboxMap?.flyTo(
        mapbox_gl.CameraOptions(
          center: _vehicleLocation!,
          zoom: 15.0, // Zoom aumentado
        ),
        mapbox_gl.MapAnimationOptions(duration: 1500),
      );
    }
  }

  Future<void> _showRoute() async {
    if (_userLocation == null || _vehicleLocation == null || _mapboxMap == null) return;

    try {
      if (_routeVisible) {
        // Ocultar la ruta cambiando la visibilidad de la capa
        await _mapboxMap?.style.setStyleLayerProperty('route-layer', 'visibility', 'none');
        setState(() {
          _routeVisible = false;
        });
        return;
      }

      final String accessToken = 'pk.eyJ1IjoiYW5nZWwtMDUiLCJhIjoiY21hc3JyYWUzMHJlOTJscHljd3Iyazg1bCJ9.pAS16n8E-QNtgpfOKoMfYw'; // Reemplaza con tu token de Mapbox
      final String url = 'https://api.mapbox.com/directions/v5/mapbox/driving/'
          '${_userLocation!.longitude},${_userLocation!.latitude};'
          '${_vehicleLocation!.coordinates.lng},${_vehicleLocation!.coordinates.lat}'
          '?geometries=geojson&access_token=$accessToken';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] == null || data['routes'].isEmpty) {
          debugPrint('No se encontraron rutas');
          return;
        }
        final geometry = data['routes'][0]['geometry'] as Map<String, dynamic>;
        final coordinates = geometry['coordinates'] as List<dynamic>;

        // Crear un FeatureCollection con la ruta
        final geoJsonData = {
          'type': 'FeatureCollection',
          'features': [
            {
              'type': 'Feature',
              'geometry': {
                'type': 'LineString',
                'coordinates': coordinates,
              },
              'properties': {
                'line-color': '#FF0000',
                'line-width': 6.0,
                'line-opacity': 0.9,
              },
            },
          ],
        };

        // Actualizar la fuente existente con los nuevos datos (sobrescribir si existe)
        await _mapboxMap?.style.addSource(mapbox_gl.GeoJsonSource(
          id: 'route-source',
          data: jsonEncode(geoJsonData),
        ));

        // Mostrar la ruta cambiando la visibilidad de la capa
        await _mapboxMap?.style.setStyleLayerProperty('route-layer', 'visibility', 'visible');
        setState(() {
          _routeVisible = true;
        });
      } else {
        debugPrint('Error al obtener la ruta: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error al trazar la ruta: $e');
    }
  }

  Future<void> _addMarkers() async {
    if (_mapboxMap == null || _annotationManager == null) return;

    try {
      await _annotationManager?.deleteAll();

      // Marcador para tu ubicación
      if (_userLocation != null) {
        await _annotationManager?.create(
          mapbox_gl.PointAnnotationOptions(
            geometry: mapbox_gl.Point(
              coordinates: mapbox_gl.Position(_userLocation!.longitude, _userLocation!.latitude),
            ),
            iconSize: 1.0,
            textField: 'Tú',
          ),
        );
      }

      // Marcador para el vehículo con icono de carro rojo
      if (_vehicleLocation != null) {
        await _annotationManager?.create(
          mapbox_gl.PointAnnotationOptions(
            geometry: _vehicleLocation!,
            iconSize: 1.5,
            textField: 'Vehículo',
            iconImage: 'red-car-icon',
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al añadir marcadores: $e');
    }
  }

  void _onMapCreated(mapbox_gl.MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _mapboxMap?.location.updateSettings(
      mapbox_gl.LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
      ),
    );

    // Inicializar la fuente y la capa de la ruta al crear el mapa
    try {
      // Crear una fuente vacía inicialmente
      await _mapboxMap?.style.addSource(mapbox_gl.GeoJsonSource(
        id: 'route-source',
        data: jsonEncode({
          'type': 'FeatureCollection',
          'features': [],
        }),
      ));

      // Crear la capa de línea
      await _mapboxMap?.style.addLayer(mapbox_gl.LineLayer(
        id: 'route-layer',
        sourceId: 'route-source',
      ));
      // Establecer la visibilidad inicial como 'none'
      await _mapboxMap?.style.setStyleLayerProperty('route-layer', 'visibility', 'none');
    } catch (e) {
      debugPrint('Error al inicializar la fuente y capa de la ruta: $e');
    }

    _annotationManager = await mapboxMap.annotations.createPointAnnotationManager();
    await _addMarkers();

    if (_userLocation != null) {
      _centerToUserLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Image.asset(
                    'imagenes/logorental.png',
                    height: 40,
                  ),
                ),
                const Text(
                  'Ubicación del Vehículo',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            automaticallyImplyLeading: true,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 600,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: mapbox_gl.MapWidget(
                  onMapCreated: _onMapCreated,
                  cameraOptions: mapbox_gl.CameraOptions(
                    center: _vehicleLocation ?? mapbox_gl.Point(coordinates: mapbox_gl.Position(-74.0060, 40.7128)),
                    zoom: 10.0,
                  ),
                  styleUri: mapbox_gl.MapboxStyles.MAPBOX_STREETS,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _centerToUserLocation,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Centrar Tú'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2575FC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _centerToVehicleLocation,
                  icon: const Icon(Icons.location_pin),
                  label: const Text('Centrar Vehículo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2575FC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _showRoute,
                  icon: const Icon(Icons.directions),
                  label: const Text('Ruta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2575FC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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