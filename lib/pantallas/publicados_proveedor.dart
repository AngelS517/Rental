import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PublicadosProveedor extends StatelessWidget {
  const PublicadosProveedor({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return user == null
        ? const Center(child: Text('Usuario no autenticado'))
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Vehiculos')
                .where('IDPropietario', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No tienes vehículos publicados'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final vehicle = snapshot.data!.docs[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: vehicle['Imagen'] != null && vehicle['Imagen'] is String && vehicle['Imagen'].isNotEmpty
                          ? Image.network(
                              vehicle['Imagen'] as String,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.car_rental),
                            )
                          : const Icon(Icons.car_rental),
                      title: Text(vehicle['Nombre']?.toString() ?? 'Sin nombre'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Categoría: ${vehicle['Categoria']?.toString() ?? 'N/A'}'),
                          Text('Ciudad: ${vehicle['Ciudad']?.toString() ?? 'N/A'}'),
                          Text('Precio: \$${vehicle['Precio'] != null ? vehicle['Precio'].toString() : 'N/A'} por día'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          try {
                            await FirebaseFirestore.instance
                                .collection('Vehiculos')
                                .doc(vehicle.id)
                                .delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vehículo eliminado')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al eliminar: $e')),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
  }
}