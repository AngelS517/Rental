import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistorialProveedor extends StatefulWidget {
  const HistorialProveedor({super.key});

  @override
  State<HistorialProveedor> createState() => _HistorialProveedorState();
}

class _HistorialProveedorState extends State<HistorialProveedor> {
  String? _uid;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _uid = user.uid;
      });
    }
  }

  Widget vehiculoItem(
    String marca,
    String imagenUrl,
    String direccion,
    String ciudad,
    String categoria,
    double calificacion,
    DocumentSnapshot vehiculo,
  ) {
    final data = vehiculo.data() as Map<String, dynamic>;
    final modelo = data['modelo']?.toString() ?? '';
    final precio = data['precioPorDia']?.toDouble() ?? 0.0;
    final numPasajeros = data['detalles']?['#pasajeros']?.toString() ?? 'N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imagenUrl.isNotEmpty
                    ? imagenUrl
                    : 'https://via.placeholder.com/60',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  );
                },
              ),
            ),
            title: Text(
              modelo.isNotEmpty ? '$marca $modelo' : marca,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Precio: \$${precio.toStringAsFixed(0)} COP/Día',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Pasajeros: $numPasajeros',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Dirección: $direccion',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Categoría: $categoria',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                // Calificación en estrellas
                Row(
                  children: List.generate(5, (i) {
                    if (i < calificacion.floor()) {
                      return const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      );
                    } else if (i < calificacion) {
                      return const Icon(
                        Icons.star_half,
                        color: Colors.amber,
                        size: 20,
                      );
                    } else {
                      return const Icon(
                        Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Center(
        child: Text('Error: No se pudo cargar los datos del proveedor.'),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // ENCABEZADO con degradado y texto
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7B1FA2), Color(0xFF4B4EAB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text(
                'Historial de Vehículos Publicados',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('Vehiculos')
                      .where('proveedorUid', isEqualTo: _uid)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No tienes vehículos publicados.'),
                  );
                }

                final vehiculos = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vehiculos.length,
                  itemBuilder: (context, index) {
                    final vehiculo = vehiculos[index];
                    final data = vehiculo.data() as Map<String, dynamic>;
                    final imagenUrl = data['imagen']?.toString() ?? '';
                    final marca = data['marca']?.toString() ?? 'Sin marca';
                    final direccion =
                        data['direccion']?.toString() ??
                        'Dirección no disponible';
                    final ciudad =
                        data['ciudad']?.toString() ?? 'Ciudad no disponible';
                    final categoria =
                        data['categoria']?.toString() ?? 'No disponible';
                    final calificacion =
                        (data['calificacion']?.toDouble() ?? 0.0).clamp(0, 5);

                    return vehiculoItem(
                      marca,
                      imagenUrl,
                      direccion,
                      ciudad,
                      categoria,
                      calificacion,
                      vehiculo,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
