import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pagina_alquilar.dart';

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

  Future<String> obtenerTelefonoProveedor(String? proveedorUid) async {
    if (proveedorUid == null || proveedorUid.isEmpty) {
      return 'No disponible';
    }
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('Usuarios')
              .doc(proveedorUid)
              .get();
      if (userDoc.exists) {
        return userDoc.data()?['telefono'] ?? 'No disponible';
      }
      return 'No disponible';
    } catch (e) {
      return 'No disponible';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7b43cd), Color(0xFF071082)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Descripción vehículo',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
        ),
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
          final categoria = data['categoria']?.toString().toLowerCase() ?? '';
          final propietarioNombre = data['Propietario'] ?? 'No disponible';
          final proveedorUid = data['proveedorUid']?.toString();

          return FutureBuilder<String>(
            future: obtenerTelefonoProveedor(proveedorUid),
            builder: (context, telefonoSnapshot) {
              if (telefonoSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final telefonoPropietario =
                  telefonoSnapshot.data ?? 'No disponible';

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              data['imagen'] ?? '',
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 180,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              'Carro ${data['marca']} ${data['modelo']}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              'Modelo: ${data['año'] ?? '2025'} – Placa: ${placa.replaceRange(0, 3, '***')}',
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Descripción:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          Text(
                            data['descripcion'] ?? 'Sin descripción disponible',
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Detalles:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          Wrap(
                            spacing: 16,
                            runSpacing: 10,
                            children: [
                              if (categoria != 'moto')
                                detalleIcono(
                                  Icons.person,
                                  '${detalles['#pasajeros'] ?? 'N/A'} Pasajeros',
                                ),
                              if (categoria != 'moto')
                                detalleIcono(
                                  Icons.ac_unit,
                                  'Aire acondicionado',
                                ),
                              detalleIcono(
                                Icons.settings,
                                detalles['transmision'] ?? 'Manual',
                              ),
                              if (categoria != 'moto')
                                detalleIcono(
                                  Icons.door_front_door,
                                  '${detalles['puertas'] ?? 4} puertas',
                                ),
                              detalleIcono(
                                Icons.speed,
                                'Kilometraje ilimitado',
                              ),
                              detalleIcono(
                                Icons.local_gas_station,
                                detalles['tipoCombustible'] ??
                                    'Combustible full',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.pink.shade600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${data['precioPorDia']} COP/Día',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Datos propietario:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('Nombre: $propietarioNombre'),
                          Text('Teléfono: $telefonoPropietario'),
                          const SizedBox(height: 16),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            PaginaAlquilar(placa: placa),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF7b43cd),
                                      Color(0xFF071082),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Alquilar vehículo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget detalleIcono(IconData icon, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 4),
        Text(texto),
      ],
    );
  }
}
