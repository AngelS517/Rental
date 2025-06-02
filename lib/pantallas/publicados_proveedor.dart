import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pagina_agregar.dart';

class PublicadosProveedor extends StatefulWidget {
  final String? uid;

  const PublicadosProveedor({super.key, this.uid});

  @override
  _PublicadosProveedorState createState() => _PublicadosProveedorState();
}

class _PublicadosProveedorState extends State<PublicadosProveedor> {
  String? _uid;
  String? _propietario;

  @override
  void initState() {
    super.initState();
    _uid = widget.uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (_uid == null) {
      FirebaseAuth.instance.authStateChanges().first.then((user) {
        if (user != null) {
          setState(() {
            _uid = user.uid;
            _cargarNombrePropietario();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Debes iniciar sesión.')),
          );
        }
      });
    } else {
      _cargarNombrePropietario();
    }
  }

  Future<void> _cargarNombrePropietario() async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('Usuarios')
              .doc(_uid)
              .get();
      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          _propietario = userDoc.data()?['nombre'] ?? 'Proveedor desconocido';
        });
      } else {
        setState(() {
          _propietario = 'Proveedor desconocido';
        });
      }
    } catch (e) {
      setState(() {
        _propietario = 'Proveedor desconocido';
      });
    }
  }

  Future<void> _mostrarDialogoEditarVehiculo(
    BuildContext context,
    DocumentSnapshot vehiculo,
  ) async {
    if (_propietario == null) {
      await _cargarNombrePropietario();
    }

    final TextEditingController ciudadController = TextEditingController(
      text: vehiculo['ciudad']?.toString() ?? '',
    );
    String? _categoria = vehiculo['categoria']?.toString() ?? null;
    final TextEditingController descripcionController = TextEditingController(
      text: vehiculo['descripcion']?.toString() ?? '',
    );
    final TextEditingController direccionController = TextEditingController(
      text: vehiculo['direccion']?.toString() ?? '',
    );
    final TextEditingController marcaController = TextEditingController(
      text: vehiculo['marca']?.toString() ?? '',
    );
    final TextEditingController modeloController = TextEditingController(
      text: vehiculo['modelo']?.toString() ?? '',
    );
    final TextEditingController placaController = TextEditingController(
      text: vehiculo['placa']?.toString() ?? '',
    );
    final TextEditingController precioController = TextEditingController(
      text: vehiculo['precioPorDia']?.toString() ?? '',
    );
    String? _numPasajeros = vehiculo['detalles']?['#pasajeros']?.toString();
    String? _numPuertas = vehiculo['detalles']?['#puertas']?.toString();
    String? _tipoCombustible =
        vehiculo['detalles']?['tipoCombustible']?.toString();
    String? _tipoTransmision =
        vehiculo['detalles']?['tipoDeTransmision']?.toString();
    bool _ventilacionChecked = vehiculo['detalles']?['ventilacion'] != null;
    String? _kilometrajeType = vehiculo['detalles']?['kilometraje']?.toString();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Editar Vehículo'),
                  const SizedBox(height: 8),
                  Text(
                    'Propietario: $_propietario',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: ciudadController,
                      decoration: const InputDecoration(labelText: 'Ciudad'),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Campo requerido'
                                  : null,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      value: _categoria,
                      items:
                          ['Automovil', 'Moto', 'Electrico', 'Minivan'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _categoria = value;
                        });
                      },
                      validator:
                          (value) =>
                              value == null ? 'Seleccione una categoría' : null,
                    ),
                    TextFormField(
                      controller: descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Campo requerido'
                                  : null,
                    ),
                    TextFormField(
                      controller: direccionController,
                      decoration: const InputDecoration(labelText: 'Dirección'),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Campo requerido'
                                  : null,
                    ),
                    TextFormField(
                      controller: marcaController,
                      decoration: const InputDecoration(labelText: 'Marca'),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Campo requerido'
                                  : null,
                    ),
                    TextFormField(
                      controller: modeloController,
                      decoration: const InputDecoration(labelText: 'Modelo'),
                      keyboardType: TextInputType.number,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Campo requerido'
                                  : null,
                    ),
                    TextFormField(
                      controller: placaController,
                      decoration: const InputDecoration(labelText: 'Placa'),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Campo requerido'
                                  : null,
                    ),
                    TextFormField(
                      controller: precioController,
                      decoration: const InputDecoration(
                        labelText: 'Precio por Día',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Campo requerido'
                                  : null,
                    ),
                    const Text('Detalles:'),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Número de Pasajeros',
                      ),
                      value: _numPasajeros,
                      items:
                          ['1', '2', '3', '4', '5', '6', '7', '8'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _numPasajeros = value;
                        });
                      },
                      validator:
                          (value) =>
                              value == null ? 'Seleccione un valor' : null,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Número de Puertas',
                      ),
                      value: _numPuertas,
                      items:
                          ['2', '3', '4', '5'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _numPuertas = value;
                        });
                      },
                      validator:
                          (value) =>
                              value == null ? 'Seleccione un valor' : null,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Combustible',
                      ),
                      value: _tipoCombustible,
                      items:
                          _categoria == 'Electrico'
                              ? []
                              : ['Corriente', 'ACP', 'Gas'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                      onChanged:
                          _categoria == 'Electrico'
                              ? null
                              : (value) {
                                setState(() {
                                  _tipoCombustible = value;
                                });
                              },
                      validator:
                          _categoria == 'Electrico'
                              ? null
                              : (value) =>
                                  value == null ? 'Seleccione un valor' : null,
                    ),
                    CheckboxListTile(
                      title: const Text(
                        'Ventilación (Aire Acondicionado/Ventilador)',
                      ),
                      value: _ventilacionChecked,
                      onChanged:
                          (value) =>
                              setState(() => _ventilacionChecked = value!),
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Kilometraje',
                      ),
                      value: _kilometrajeType,
                      items:
                          ['Limitado', 'Ilimitado', 'No aplica'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _kilometrajeType = value;
                        });
                      },
                      validator:
                          (value) =>
                              value == null ? 'Seleccione un valor' : null,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Transmisión',
                      ),
                      value: _tipoTransmision,
                      items:
                          ['Automático', 'Semiautomático', 'Mecánico'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _tipoTransmision = value;
                        });
                      },
                      validator:
                          (value) =>
                              value == null ? 'Seleccione un valor' : null,
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
                          const SnackBar(
                            content: Text('Error: Debes iniciar sesión.'),
                          ),
                        );
                        return;
                      }

                      final detalles = {
                        if (_numPasajeros != null)
                          '#pasajeros': int.parse(_numPasajeros!),
                        if (_numPuertas != null)
                          '#puertas': int.parse(_numPuertas!),
                        if (_tipoCombustible != null)
                          'tipoCombustible': _tipoCombustible,
                        if (_ventilacionChecked) 'ventilacion': null,
                        if (_kilometrajeType != null)
                          'kilometraje': _kilometrajeType,
                        if (_tipoTransmision != null)
                          'tipoDeTransmision': _tipoTransmision,
                      };

                      final data = {
                        'proveedorUid': _uid,
                        'Propietario': _propietario ?? 'Proveedor desconocido',
                        'ciudad': ciudadController.text,
                        'categoria': _categoria,
                        'descripcion': descripcionController.text,
                        'direccion': direccionController.text,
                        'marca': marcaController.text,
                        'modelo': int.tryParse(modeloController.text) ?? 0,
                        'placa': placaController.text,
                        'precioPorDia':
                            double.tryParse(precioController.text) ?? 0.0,
                        'detalles': detalles.isNotEmpty ? detalles : null,
                      };

                      await FirebaseFirestore.instance
                          .collection('Vehiculos')
                          .doc(vehiculo.id)
                          .update(data);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vehículo actualizado correctamente'),
                        ),
                      );
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al guardar vehículo: $e'),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _eliminarVehiculo(String vehiculoId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Vehiculos')
          .doc(vehiculoId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo eliminado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar vehículo: $e')));
    }
  }

  Widget vehiculoItem(
    String marca,
    String imagenUrl,
    String direccion,
    String ciudad,
    String vehiculoId,
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
                    : 'https://via.placeholder.com/60', // Placeholder si no hay imagen
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed:
                      () => _mostrarDialogoEditarVehiculo(context, vehiculo),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B4EAB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Editar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _eliminarVehiculo(vehiculoId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Eliminar'),
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
                    return vehiculoItem(
                      data['marca']?.toString() ?? 'Sin marca',
                      imagenUrl,
                      data['direccion']?.toString() ??
                          'Dirección no disponible',
                      data['ciudad']?.toString() ?? 'Ciudad no disponible',
                      vehiculo.id,
                      vehiculo,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final uid = FirebaseAuth.instance.currentUser?.uid;

          if (uid == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Debes iniciar sesión')),
            );
            return;
          }

          final snapshot =
              await FirebaseFirestore.instance
                  .collection('Vehiculos')
                  .where('proveedorUid', isEqualTo: uid)
                  .get();

          if (snapshot.docs.length >= 5) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Cantidad de vehículos superada. Solo puedes tener 5 vehículos.',
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PaginaAgregar()),
            );
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFF7B1FA2),
      ),
    );
  }
}
