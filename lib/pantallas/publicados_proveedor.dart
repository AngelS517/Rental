import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PublicadosProveedor extends StatefulWidget {
  final String? uid; // Parámetro para recibir el UID del proveedor

  const PublicadosProveedor({super.key, this.uid});

  @override
  _PublicadosProveedorState createState() => _PublicadosProveedorState();
}

class _PublicadosProveedorState extends State<PublicadosProveedor> {
  String? _uid; // UID del proveedor autenticado

  @override
  void initState() {
    super.initState();
    // Usar el UID pasado como parámetro o obtenerlo si no está disponible
    _uid = widget.uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (_uid == null) {
      // Mostrar error si no hay UID
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Debes iniciar sesión.')),
      );
    }
  }

  // Diálogo para agregar/editar vehículo
  Future<void> _mostrarDialogoVehiculo(BuildContext context, {DocumentSnapshot? vehiculo}) async {
    final TextEditingController marcaController = TextEditingController(text: vehiculo?.get('marca') ?? '');
    final TextEditingController modeloController = TextEditingController(text: vehiculo?.get('modelo') ?? '');
    final TextEditingController anoController = TextEditingController(text: vehiculo?.get('año')?.toString() ?? '');
    final TextEditingController colorController = TextEditingController(text: vehiculo?.get('color') ?? '');
    final TextEditingController precioController = TextEditingController(text: vehiculo?.get('precioPorDia')?.toString() ?? '');

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(vehiculo == null ? 'Agregar Vehículo' : 'Editar Vehículo'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: marcaController,
                  decoration: const InputDecoration(labelText: 'Marca'),
                ),
                TextFormField(
                  controller: modeloController,
                  decoration: const InputDecoration(labelText: 'Modelo'),
                ),
                TextFormField(
                  controller: anoController,
                  decoration: const InputDecoration(labelText: 'Año'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: colorController,
                  decoration: const InputDecoration(labelText: 'Color'),
                ),
                TextFormField(
                  controller: precioController,
                  decoration: const InputDecoration(labelText: 'Precio por Día'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Guardar'),
              onPressed: () async {
                try {
                  if (_uid == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error: Debes iniciar sesión.')),
                    );
                    return;
                  }

                  final data = {
                    'proveedorUid': _uid,
                    'marca': marcaController.text,
                    'modelo': modeloController.text,
                    'año': int.tryParse(anoController.text) ?? 0,
                    'color': colorController.text,
                    'precioPorDia': double.tryParse(precioController.text) ?? 0.0,
                  };

                  if (vehiculo == null) {
                    // Agregar nuevo vehículo
                    await FirebaseFirestore.instance.collection('Vehiculos').add(data);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vehículo agregado correctamente')),
                    );
                  } else {
                    // Actualizar vehículo existente
                    await FirebaseFirestore.instance
                        .collection('Vehiculos')
                        .doc(vehiculo.id)
                        .update(data);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vehículo actualizado correctamente')),
                    );
                  }
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al guardar vehículo: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Eliminar vehículo
  Future<void> _eliminarVehiculo(String vehiculoId) async {
    try {
      await FirebaseFirestore.instance.collection('Vehiculos').doc(vehiculoId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo eliminado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar vehículo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Center(child: Text('Error: No se pudo cargar los datos del proveedor.'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => _mostrarDialogoVehiculo(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF7b43cd), Color(0xFF2575FC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      alignment: Alignment.center,
                      child: const Text(
                        "Agregar Vehículo",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
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
                return const Center(child: Text('No tienes vehículos publicados.'));
              }

              final vehiculos = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: vehiculos.length,
                itemBuilder: (context, index) {
                  final vehiculo = vehiculos[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${vehiculo['marca']} ${vehiculo['modelo']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text('Año: ${vehiculo['año']}'),
                              Text('Color: ${vehiculo['color']}'),
                              Text('Precio por día: \$${vehiculo['precioPorDia']}'),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF4B4EAB)),
                              onPressed: () => _mostrarDialogoVehiculo(context, vehiculo: vehiculo),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _eliminarVehiculo(vehiculo.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}