import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaginaDescripcionVehiculo extends StatelessWidget {
  final String placa;

  const PaginaDescripcionVehiculo({Key? key, required this.placa})
    : super(key: key);

  Future<DocumentSnapshot<Map<String, dynamic>>> obtenerVehiculo() async {
    final query =
        await FirebaseFirestore.instance
            .collection('Vehiculos')
            .where('placa', isEqualTo: placa)
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first;
    } else {
      throw Exception('Vehículo no encontrado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Descripción del Vehículo'),
        backgroundColor: const Color(0xFF4B4EAB),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: obtenerVehiculo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Vehículo no encontrado.'));
          }

          final data = snapshot.data!.data()!;
          final detalles = data['detalles'] ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                data['imagen'] != null
                    ? Image.network(
                      data['imagen'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                    : const SizedBox(),
                const SizedBox(height: 16),
                Text(
                  '${data['marca']} ${data['modelo']}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Placa: $placa'),
                const SizedBox(height: 8),
                Text('Precio por día: \$${data['precioPorDia']} COP'),
                const SizedBox(height: 8),
                Text('Propietario: ${data['Propietario'] ?? 'Desconocido'}'),
                const SizedBox(height: 8),
                Text('Dirección: ${data['direccion'] ?? 'No disponible'}'),
                const SizedBox(height: 8),
                Text('Ciudad: ${data['ciudad'] ?? 'No especificada'}'),
                const SizedBox(height: 8),
                Text(
                  'Combustible: ${detalles['tipoCombustible'] ?? 'No especificado'}',
                ),
                const SizedBox(height: 8),
                Text('Pasajeros: ${detalles['#pasajeros'] ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text(
                  'Kilometraje: ${detalles['kilometraje'] ?? 'No especificado'}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Calificación: ${data['calificacion'] ?? 'No disponible'} ⭐',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
