// Importaciones necesarias
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox_gl;
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter/services.dart';
import 'package:rental/widgets/custom_widgets.dart';

class PaginaMapa extends StatefulWidget {
  const PaginaMapa({Key? key}) : super(key: key);

  @override
  State<PaginaMapa> createState() => _PaginaMapaState();
}

class _PaginaMapaState extends State<PaginaMapa> {
  mapbox_gl.MapboxMap? _mapboxMap;
  int _selectedIndex = 1; // Índice inicial para la página del mapa (ícono de mapa)

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF5A1EFF),
      statusBarIconBrightness: Brightness.light,
    ));
  }

  // Función para solicitar permisos de ubicación
  Future<void> _checkAndRequestPermissions() async {
    await Permission.locationWhenInUse.request();
    await geo.Geolocator.requestPermission();
  }

  // Función para centrar el mapa en la ubicación actual
  Future<void> _centerToUserLocation() async {
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Los servicios de ubicación están deshabilitados.");
      return;
    }

    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        print("Permiso de ubicación denegado.");
        return;
      }
    }

    final position = await geo.Geolocator.getCurrentPosition(
      desiredAccuracy: geo.LocationAccuracy.high,
    );

    _mapboxMap?.flyTo(
      mapbox_gl.CameraOptions(
        center: mapbox_gl.Point(
          coordinates: mapbox_gl.Position(position.longitude, position.latitude),
        ),
        zoom: 15.0,
      ),
      mapbox_gl.MapAnimationOptions(duration: 1500),
    );
  }

  // Cuando se crea el mapa
  void _onMapCreated(mapbox_gl.MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    await mapboxMap.location.updateSettings(
      mapbox_gl.LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
      ),
    );

    _centerToUserLocation(); // Centrar automáticamente en la ubicación actual
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushNamed(context, '/inicio');
    } else if (index == 1) {
      // Ya estamos en la página del mapa
    } else if (index == 2) {
      Navigator.pushNamed(context, '/favoritos');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/perfil');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con degradado y logo
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
                    'imagenes/logorental.png', // asegúrate de tener esta imagen
                    height: 40,
                  ),
                ),
                const Text(
                  'Cercanos a ti',
                  style: TextStyle(color: Colors.white), // Texto blanco
                ),
              ],
            ),
            automaticallyImplyLeading: false,
          ),
        ),
      ),

      body: Stack(
        children: [
          // Mapa con bordes redondeados y tamaño reducido
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 400, // Tamaño más pequeño
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: mapbox_gl.MapWidget(
                  onMapCreated: _onMapCreated,
                  cameraOptions: mapbox_gl.CameraOptions(
                    center: mapbox_gl.Point(
                      coordinates: mapbox_gl.Position(-74.0060, 40.7128),
                    ),
                    zoom: 10.0,
                  ),
                  styleUri: mapbox_gl.MapboxStyles.MAPBOX_STREETS,
                ),
              ),
            ),
          ),

          // Botón "Centrar"
          Positioned(
            bottom: 30,
            right: 30,
            child: ElevatedButton.icon(
              onPressed: _centerToUserLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Centrar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2575FC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
