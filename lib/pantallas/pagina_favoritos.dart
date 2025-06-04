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

    // Obtener placas alquiladas desde la colección Alquilar
    final alquilarDoc =
        await FirebaseFirestore.instance
            .collection('Alquilar')
            .doc(user.uid)
            .get();

    final dataAlquilar = alquilarDoc.data();
    List<dynamic> placasAlquiladas = [];
    if (dataAlquilar != null && dataAlquilar['alquilados'] != null) {
      placasAlquiladas = dataAlquilar['alquilados'];
    }

    if (placasAlquiladas.isEmpty) {
      return [];
    }

    // Obtener los vehículos de la colección Vehiculos según las placas alquiladas
    final vehiculosQuery =
        await FirebaseFirestore.instance
            .collection('Vehiculos')
            .where('placa', whereIn: placasAlquiladas)
            .get();

    return vehiculosQuery.docs
        .map((doc) => {...doc.data(), 'id': doc.id})
        .toList();
  }

  Future<void> calificarVehiculo(String vehiculoId, int calificacion) async {
    final vehiculoRef = FirebaseFirestore.instance
        .collection('Vehiculos')
        .doc(vehiculoId);
    await vehiculoRef.update({'calificacion': calificacion});
  }

  Future<void> regresarVehiculo(String placa) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final vehiculoQuery =
        await FirebaseFirestore.instance
            .collection('Vehiculos')
            .where('placa', isEqualTo: placa)
            .get();

    if (vehiculoQuery.docs.isEmpty) return;

    final vehiculoDoc = vehiculoQuery.docs.first;

    // Actualiza el campo 'disponible' en la colección Vehiculos
    await vehiculoDoc.reference.update({'disponible': true});

    // Elimina la placa del array 'alquilados' en la colección Alquilar
    final alquilarRef = FirebaseFirestore.instance
        .collection('Alquilar')
        .doc(user.uid);
    await alquilarRef.update({
      'alquilados': FieldValue.arrayRemove([placa]),
    });

    // Refresca la vista
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vehículos Alquilados',
          style: TextStyle(
            color: Colors.white,
          ), // Aquí das color blanco al título
        ),
        backgroundColor: const Color(0xFF4B4EAB),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Opcional: íconos también en blanco
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
              final categoria = vehiculo['categoria'] ?? 'Sin categoría';
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
                      Text('Categoría: $categoria'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: RatingBar.builder(
                              initialRating: calificacion?.toDouble() ?? 0,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              itemCount: 5,
                              itemSize: 24,
                              itemBuilder:
                                  (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                              updateOnDrag: false,
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
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final confirmar = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Confirmación'),
                                    content: const Text(
                                      '¿Estás seguro que quieres regresar el vehículo?',
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('Cancelar'),
                                        onPressed:
                                            () => Navigator.of(
                                              context,
                                            ).pop(false),
                                      ),
                                      TextButton(
                                        child: const Text('Sí'),
                                        onPressed:
                                            () =>
                                                Navigator.of(context).pop(true),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmar == true) {
                                await regresarVehiculo(placa);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Vehículo $placa regresado.'),
                                  ),
                                );
                              }
                              // Si el usuario cancela, no pasa nada
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4B4EAB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: const Text('Devolver'),
                          ),
                        ],
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
