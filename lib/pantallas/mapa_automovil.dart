import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class MapaAutomovil extends StatefulWidget {
  const MapaAutomovil({Key? key}) : super(key: key);

  @override
  State<MapaAutomovil> createState() => _MapaAutomovilState();
}

class _MapaAutomovilState extends State<MapaAutomovil> {
  final MapController _mapController = MapController();
  LatLng? _location;
  String? _direccion;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _direccion = '${args['direccion']}, ${args['ciudad']}, Colombia';

    _buscarUbicacion(_direccion!);
  }

  Future<void> _buscarUbicacion(String direccionCompleta) async {
    try {
      List<Location> locations = await locationFromAddress(direccionCompleta);
      if (locations.isNotEmpty) {
        setState(() {
          _location = LatLng(locations[0].latitude, locations[0].longitude);
          _loading = false;
        });

        _mapController.move(_location!, 16.0);
      }
    } catch (e) {
      debugPrint('Error al buscar la ubicación: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación del Vehículo'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: _loading || _location == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _location!,
                initialZoom: 16.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.rental',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _location!,
                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.blue,
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
