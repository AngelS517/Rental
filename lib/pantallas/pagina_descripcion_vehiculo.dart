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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B4EAB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Descripción vehículo'),
        centerTitle: true,
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
                          data['imagen'] ??
                              'https://via.placeholder.com/400x200.png?text=Sin+Imagen',
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
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
                      Text(data['descripcion'] ?? 'Sin descripción disponible'),

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
                          detalleIcono(
                            Icons.person,
                            '${detalles['#pasajeros'] ?? 'N/A'} Pasajeros',
                          ),
                          detalleIcono(Icons.ac_unit, 'Aire acondicionado'),
                          detalleIcono(
                            Icons.settings,
                            detalles['transmision'] ?? 'Manual',
                          ),
                          detalleIcono(
                            Icons.door_front_door,
                            '${detalles['puertas'] ?? 4} puertas',
                          ),
                          detalleIcono(Icons.speed, 'Kilometraje ilimitado'),
                          detalleIcono(
                            Icons.local_gas_station,
                            detalles['tipoCombustible'] ?? 'Combustible full',
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.location_on),
                        label: const Text('Ver ubicación'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade100,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.pink.shade600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${data['precioPorDia']} COP/Día',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => PaginaAlquilar(placa: placa),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4B4EAB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Alquilar vehículo'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Text(
                        'Datos propietario:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Nombre: ${data['Propietario'] ?? 'No disponible'}'),
                      Text('Cel: ${data['telefono'] ?? 'No disponible'}'),
                    ],
                  ),
                ),
              ),
            ),
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
