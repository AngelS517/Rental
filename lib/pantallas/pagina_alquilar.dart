import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'mapa_automovil.dart';

class PaginaAlquilar extends StatelessWidget {
  final String placa;

  const PaginaAlquilar({Key? key, required this.placa}) : super(key: key);

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
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: obtenerVehiculo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final data = snapshot.data!.data()!;
        final marca = data['marca'] ?? 'Desconocida';
        final modelo = data['modelo'] ?? 'Desconocido';

        return Scaffold(
          backgroundColor: const Color(0xFFF2F3FC),
          appBar: AppBar(
            title: const Text('Formulario de Alquiler'),
            backgroundColor: const Color(0xFF4B4EAB),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Formulario de Alquiler',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B4EAB),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                campoInfo('Vehículo a alquilar:', '$marca $modelo'),
                campoInfo('Placa:', placa),
                // ... lo demás sin cambios ...
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9008C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Total: \$0000',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4B4EAB),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '¡Renta Exitosa!',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4B4EAB),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'El vehículo que rentaste, ya está disponible para ti.\n\nTen presente que los datos de tu renta y factura serán enviados de forma electrónica a tu correo registrado.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const MapaAutomovil(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.location_on),
                                    label: const Text('Ver ubicación'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Color(0xFF4B4EAB),
                                      side: const BorderSide(
                                        color: Color(0xFF4B4EAB),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      'assets/images/mapa_carro.png',
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      );
                    },
                    child: const Text(
                      'Alquilar vehículo',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget campoInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(top: 4, bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEAEAEA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value),
        ),
      ],
    );
  }
}
