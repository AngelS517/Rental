import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class PaginaHistorialUsuario extends StatefulWidget {
  const PaginaHistorialUsuario({Key? key}) : super(key: key);

  @override
  State<PaginaHistorialUsuario> createState() =>
      _PaginaHistorialUsuariosState();
}

class _PaginaHistorialUsuariosState extends State<PaginaHistorialUsuario> {
  Future<List<Map<String, dynamic>>> obtenerVehiculosAlquilados() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final userDoc =
        await FirebaseFirestore.instance
            .collection('usuariosHistorial')
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historial de Alquiler',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4B4EAB),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Para íconos de flecha hacia atrás, por ejemplo
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
                'No tienes historial de alquileres.',
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
                      Text(
                        'Categoría: $categoria',
                      ), // <-- categoría visible aquí
                      const SizedBox(height: 4),
                      RatingBarIndicator(
                        rating: calificacion?.toDouble() ?? 0,
                        itemBuilder:
                            (context, _) =>
                                const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 24,
                        direction: Axis.horizontal,
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
