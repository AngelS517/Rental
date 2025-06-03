import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pagina_principal.dart';

class PaginaAlquilar extends StatefulWidget {
  final String placa;

  const PaginaAlquilar({Key? key, required this.placa}) : super(key: key);

  @override
  State<PaginaAlquilar> createState() => _PaginaAlquilarState();
}

class _PaginaAlquilarState extends State<PaginaAlquilar> {
  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final nacionalidadController = TextEditingController();
  final celularController = TextEditingController();
  final tipoDocController = TextEditingController();
  final noDocController = TextEditingController();
  final fechaRetiroController = TextEditingController();
  final fechaEntregaController = TextEditingController();
  bool proteccionTotal = false;
  bool autorizaDatos = false;

  Future<DocumentSnapshot<Map<String, dynamic>>> obtenerVehiculo() async {
    final query =
        await FirebaseFirestore.instance
            .collection('Vehiculos')
            .where('placa', isEqualTo: widget.placa)
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
                campoInfo('Placa:', widget.placa),
                campoTexto('Nombre completo:', nombreController),
                campoTexto('Correo electrónico:', correoController),
                campoTexto('Nacionalidad:', nacionalidadController),
                campoTexto('Celular:', celularController),
                campoTexto('Tipo documento:', tipoDocController),
                campoTexto('No. Documento:', noDocController),
                campoTexto('Fecha y hora del retiro:', fechaRetiroController),
                campoTexto('Fecha y hora de entrega:', fechaEntregaController),
                Row(
                  children: [
                    Checkbox(
                      value: proteccionTotal,
                      onChanged: (value) {
                        setState(() {
                          proteccionTotal = value ?? false;
                        });
                      },
                    ),
                    const Expanded(child: Text('Protección total (+\$55.000)')),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: autorizaDatos,
                      onChanged: (value) {
                        setState(() {
                          autorizaDatos = value ?? false;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Autorizo el tratamiento de datos personales',
                      ),
                    ),
                  ],
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
                    onPressed: () async {
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          throw Exception('Usuario no autenticado');
                        }

                        // Guardar en la colección 'Alquilar'
                        await FirebaseFirestore.instance
                            .collection('Alquilar')
                            .add({
                              'placa': widget.placa,
                              'vehiculo': '$marca $modelo',
                              'nombre': nombreController.text.trim(),
                              'correo': correoController.text.trim(),
                              'nacionalidad':
                                  nacionalidadController.text.trim(),
                              'celular': celularController.text.trim(),
                              'tipoDocumento': tipoDocController.text.trim(),
                              'numeroDocumento': noDocController.text.trim(),
                              'fechaRetiro': fechaRetiroController.text.trim(),
                              'fechaEntrega':
                                  fechaEntregaController.text.trim(),
                              'proteccionTotal': proteccionTotal,
                              'autorizaDatos': autorizaDatos,
                              'usuarioId': user.uid,
                              'fechaRegistro': FieldValue.serverTimestamp(),
                            });

                        // Actualizar disponibilidad del vehículo
                        final query =
                            await FirebaseFirestore.instance
                                .collection('Vehiculos')
                                .where('placa', isEqualTo: widget.placa)
                                .limit(1)
                                .get();

                        if (query.docs.isNotEmpty) {
                          final docId = query.docs.first.id;
                          await FirebaseFirestore.instance
                              .collection('Vehiculos')
                              .doc(docId)
                              .update({'disponible': false});
                        }

                        // Agregar vehículo al usuario
                        final userDocRef = FirebaseFirestore.instance
                            .collection('usuarios')
                            .doc(user.uid);

                        final userDoc = await userDocRef.get();
                        if (userDoc.exists) {
                          await userDocRef.update({
                            'alquilados': FieldValue.arrayUnion([widget.placa]),
                          });
                        } else {
                          await userDocRef.set({
                            'alquilados': [widget.placa],
                          }, SetOptions(merge: true));
                        }

                        // Mostrar éxito
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
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(
                                        'imagenes/renta.jpeg',
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
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
                                      'El vehículo que rentaste ya está disponible para ti.\n\nTen presente que los datos de tu renta y factura serán enviados a tu correo.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const PaginaPrincipal(),
                                          ),
                                        );
                                      },
                                      child: const Text('Inicio'),
                                    ),
                                  ],
                                ),
                              ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al alquilar: $e')),
                        );
                      }
                    },
                    child: const Text(
                      'Alquilar vehículo',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
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

  Widget campoTexto(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Color(0xFFEAEAEA),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}