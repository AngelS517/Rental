// Importación de paquetes necesarios para la interfaz, el mapa y la ubicación
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

// Widget con estado que mostrará un mapa con la ubicación actual del usuario
class PaginaMapa extends StatefulWidget {
  const PaginaMapa({Key? key}) : super(key: key);

  @override
  _PaginaMapaState createState() => _PaginaMapaState();
}

// Estado de la clase PaginaMapa
class _PaginaMapaState extends State<PaginaMapa> {
  final MapController _mapController = MapController(); // Controlador para el mapa
  LatLng? _currentLocation; // Variable para guardar la ubicación actual del usuario
  bool _loading = true; // Bandera para mostrar cargando mientras se obtiene la ubicación

  @override
  void initState() {
    super.initState();
    _getUserLocation(); // Llamamos a la función para obtener la ubicación al iniciar
  }

  // Función asincrónica para obtener la ubicación del usuario
  Future<void> _getUserLocation() async {
    Location location = Location(); // Instancia del paquete Location

    try {
      // Verifica si el servicio de ubicación está habilitado
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService(); // Pide al usuario que lo habilite
        if (!serviceEnabled) return; // Si no lo habilita, salimos de la función
      }

      // Verifica permisos de ubicación
      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission(); // Pide permiso si está denegado
        if (permissionGranted != PermissionStatus.granted) return;
      }

      // Obtiene los datos de la ubicación actual
      final locationData = await location.getLocation();
      setState(() {
        _currentLocation = LatLng(locationData.latitude!, locationData.longitude!); // Guarda la ubicación
        _loading = false; // Ya no está cargando
      });

      _mapController.move(_currentLocation!, 14.0); // Mueve el mapa a la ubicación del usuario con zoom 14
    } catch (e) {
      print("Error al obtener la ubicación: $e"); // Captura errores y los imprime en consola
      setState(() => _loading = false); // Detiene el indicador de carga
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapa de ubicación usuario"),
        automaticallyImplyLeading: false, // Oculta el botón de retroceso del AppBar
      ),
      // Si está cargando, muestra un spinner, si no, muestra el mapa
      body: _loading
          ? const Center(child: CircularProgressIndicator()) // Indicador de carga
          : FlutterMap(
              mapController: _mapController, // Controlador del mapa
              options: MapOptions(
                initialCenter: _currentLocation!, // Centra el mapa en la ubicación del usuario
                initialZoom: 14.0, // Nivel de zoom inicial
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all, // Permite todas las interacciones (zoom, mover, etc.)
                ),
              ),
              children: [
                // Capa que carga los tiles (imágenes) de OpenStreetMap
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", // URL base 
                  subdomains: const ['a', 'b', 'c'], // Subdominios 
                  userAgentPackageName: 'com.example.rental', 
                ),
                // Capa de marcadoresx
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _currentLocation!, // Posición del marcador (ubicación actual)
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red, // Icono rojo para marcar la ubicación
                        size: 40.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
