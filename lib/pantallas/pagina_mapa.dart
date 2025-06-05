import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lat_lng;
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaginaMapa extends StatefulWidget {
  const PaginaMapa({Key? key}) : super(key: key);

  @override
  State<PaginaMapa> createState() => _PaginaMapaState();
}

class _PaginaMapaState extends State<PaginaMapa> {
  geo.Position? _userPosition;
  List<Marker> _vehicleMarkers = [];
  MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _requestLocationPermissionAndGetPosition();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF5A1EFF),
      statusBarIconBrightness: Brightness.light,
    ));
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      print("Firebase inicializado correctamente");
      await _loadVehicles();
    } catch (e, stackTrace) {
      print("Error al iniciar Firebase: $e");
      print("StackTrace: $stackTrace");
      _showErrorDialog('Error al inicializar Firebase.');
    }
  }

  Future<void> _requestLocationPermissionAndGetPosition() async {
    try {
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print("Los servicios de ubicación están deshabilitados");
        _showLocationDisabledDialog();
        return;
      }

      geo.LocationPermission permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }

      if (permission == geo.LocationPermission.denied) {
        print("Permiso de ubicación denegado por el usuario");
        _showPermissionDeniedDialog();
        return;
      }

      if (permission == geo.LocationPermission.deniedForever) {
        print("Permiso de ubicación denegado permanentemente");
        _showPermissionDeniedForeverDialog();
        return;
      }

      geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high,
      );
      setState(() {
        _userPosition = position;
      });
      print("Posición del usuario: lat=${position.latitude}, lon=${position.longitude}");

      // Centrar el mapa en la posición del usuario al inicio
      if (_userPosition != null) {
        _mapController.move(
          lat_lng.LatLng(_userPosition!.latitude, _userPosition!.longitude),
          14.0,
        );
      }
    } catch (e, stackTrace) {
      print("Error al obtener la ubicación: $e");
      print("StackTrace: $stackTrace");
      _showErrorDialog('No se pudo obtener la ubicación. Por favor, intenta de nuevo.');
    }
  }

  void _showLocationDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Servicios de ubicación desactivados'),
        content: Text('Por favor, activa los servicios de ubicación en tu dispositivo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permiso de ubicación denegado'),
        content: Text('Por favor, otorga el permiso de ubicación en la configuración de la app.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Abrir configuración'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permiso de ubicación denegado permanentemente'),
        content: Text('Por favor, habilita el permiso de ubicación en la configuración del dispositivo.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Abrir configuración'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadVehicles() async {
    print("Iniciando _loadVehicles");
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("Usuario no autenticado");
        _showErrorDialog('Debes iniciar sesión para ver los vehículos.');
        return;
      }
      print("Usuario autenticado: ${user.uid}");

      final snapshot = await FirebaseFirestore.instance.collection('Vehiculos').get();
      print("Documentos obtenidos: ${snapshot.docs.length}");

      List<Marker> markers = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print("Procesando vehículo ${doc.id}: $data");

        String? vehicleType = data['tipo']?.toString();
        double? lat = double.tryParse(data['latitude']?.toString() ?? '');
        double? lon = double.tryParse(data['longitude']?.toString() ?? '');
        bool? alquilado = data['alquilado'] as bool?;

        // Filtrar vehículos alquilados
        if (alquilado == true) {
          print("Vehículo ${doc.id} omitido: está alquilado");
          continue;
        }

        if (vehicleType == null || !['Automovil', 'Moto', 'Minivan', 'Electrico'].contains(vehicleType)) {
          print("Vehículo ${doc.id} omitido: tipo inválido ($vehicleType)");
          continue;
        }

        if (lat == null || lon == null) {
          print("Vehículo ${doc.id} omitido: no tiene coordenadas válidas (lat=$lat, lon=$lon)");
          continue;
        }

        markers.add(
          Marker(
            point: lat_lng.LatLng(lat, lon),
            width: 40,
            height: 40,
            child: Icon(
              _getVehicleIcon(vehicleType),
              color: _getVehicleColor(vehicleType),
              size: 30,
            ),
          ),
        );
        print("Marcador '$vehicleType' añadido en lat=$lat, lon=$lon");
      }

      setState(() {
        _vehicleMarkers = markers;
      });
      print("Total de marcadores añadidos: ${markers.length}");
      if (markers.isEmpty) {
        print("No se encontraron vehículos disponibles");
        _showErrorDialog('No hay vehículos disponibles en este momento.');
      }
    } catch (e, stackTrace) {
      print("Error en _loadVehicles: $e");
      print("StackTrace: $stackTrace");
      _showErrorDialog('Error al cargar los vehículos.');
    }
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType) {
      case 'Automovil':
        return Icons.directions_car;
      case 'Moto':
        return Icons.motorcycle;
      case 'Minivan':
        return Icons.airport_shuttle;
      case 'Electrico':
        return Icons.electric_car;
      default:
        return Icons.directions_car;
    }
  }

  Color _getVehicleColor(String vehicleType) {
    switch (vehicleType) {
      case 'Automovil':
        return Colors.blue;
      case 'Moto':
        return Colors.red;
      case 'Minivan':
        return Colors.green;
      case 'Electrico':
        return Colors.yellow;
      default:
        return Colors.black;
    }
  }

  void _centerOnUserLocation() async {
    if (_userPosition != null) {
      _mapController.move(
        lat_lng.LatLng(_userPosition!.latitude, _userPosition!.longitude),
        14.0,
      );
      print("Mapa centrado en la ubicación del usuario: lat=${_userPosition!.latitude}, lon=${_userPosition!.longitude}");
    } else {
      print("No se ha obtenido la ubicación del usuario");
      await _requestLocationPermissionAndGetPosition();
      if (_userPosition != null) {
        _mapController.move(
          lat_lng.LatLng(_userPosition!.latitude, _userPosition!.longitude),
          14.0,
        );
        print("Mapa centrado en la ubicación del usuario tras reintento: lat=${_userPosition!.latitude}, lon=${_userPosition!.longitude}");
      } else {
        _showErrorDialog('No se pudo obtener tu ubicación. Verifica los permisos y los servicios de ubicación.');
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 32,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: lat_lng.LatLng(7.1250, -73.1198), // Bucaramanga como fallback
                initialZoom: 11.0, // Zoom amplio para ver todos los vehículos
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: _vehicleMarkers),
                if (_userPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: lat_lng.LatLng(_userPosition!.latitude, _userPosition!.longitude),
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.my_location,
                          color: Colors.blueAccent,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnUserLocation,
        child: Icon(Icons.my_location),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}