import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class PaginaFavoritos extends StatefulWidget {
  const PaginaFavoritos({Key? key}) : super(key: key);

  @override
  State<PaginaFavoritos> createState() => _PaginaFavoritosState();
}

class _PaginaFavoritosState extends State<PaginaFavoritos> {
  Future<List<Map<String, dynamic>>> obtenerVehiculosAlquilados() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final userDoc =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

    final data = userDoc.data();
    if (data == null || data['alquilados'] == null) {
      return [];
    }

    final List<dynamic> placasAlquiladas = data['alquilados'];
    if (placasAlquiladas.isEmpty) {
      return [];
    }

    final query =
        await FirebaseFirestore.instance
            .collection('Vehiculos')
            .where('placa', whereIn: placasAlquiladas)
            .get();

    return query.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<void> calificarVehiculo(String vehiculoId, int calificacion) async {
    final vehiculoRef = FirebaseFirestore.instance
        .collection('Vehiculos')
        .doc(vehiculoId);

    await vehiculoRef.update({'calificacion': calificacion});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículos Alquilados'),
        backgroundColor: const Color(0xFF4B4EAB),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: obtenerVehiculosAlquilados(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final vehiculos = snapshot.data ?? [];

          if (vehiculos.isEmpty) {
            return const Center(
              child: Text(
                'Aún no has alquilado ningún vehículo.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: vehiculos.length,
            itemBuilder: (context, index) {
              final vehiculo = vehiculos[index];
              final marca = vehiculo['marca'] ?? 'Desconocida';
              final modelo = vehiculo['modelo'] ?? 'Desconocido';
              final placa = vehiculo['placa'] ?? 'N/A';
              final imagen =
                  vehiculo['imagen'] ?? 'https://via.placeholder.com/150';

              final int? calificacion =
                  (vehiculo['calificacion'] as num?)?.toInt();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Image.network(
                    imagen,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text('$marca $modelo'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Placa: $placa'),
                      const SizedBox(height: 4),
                      RatingBar.builder(
                        initialRating: calificacion?.toDouble() ?? 0,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemSize: 24,
                        itemBuilder:
                            (context, _) =>
                                const Icon(Icons.star, color: Colors.amber),
                        updateOnDrag: false,
                        // Quitamos ignoreGestures para que el usuario pueda cambiar siempre
                        onRatingUpdate: (rating) async {
                          await calificarVehiculo(
                            vehiculo['id'],
                            rating.toInt(),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('¡Calificación guardada!'),
                            ),
                          );
                          setState(
                            () {},
                          ); // Para refrescar y mostrar la nueva calificación
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}