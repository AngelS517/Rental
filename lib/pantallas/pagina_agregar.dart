import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaginaAgregar extends StatefulWidget {
  const PaginaAgregar({super.key});

  @override
  State<PaginaAgregar> createState() => _PaginaAgregarState();
}

class _PaginaAgregarState extends State<PaginaAgregar> {
  final _formKey = GlobalKey<FormState>();
  String? _propietario; // Nombre del propietario dinámico
  final TextEditingController _ciudadController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  String? _selectedCategory; // Una sola categoría
  String? _numPasajeros;
  String? _numPuertas;
  String? _tipoCombustible;
  String? _tipoTransmision;
  bool _ventilacionChecked = false;
  String? _kilometrajeType;
  String? _proveedorUid;

  @override
  void initState() {
    super.initState();
    _proveedorUid = FirebaseAuth.instance.currentUser?.uid;
    if (_proveedorUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Debes iniciar sesión.')),
      );
    } else {
      _cargarNombrePropietario();
    }
  }

  Future<void> _cargarNombrePropietario() async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('Usuarios').doc(_proveedorUid).get();
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

  Future<void> _registrarVehiculo() async {
    if (_formKey.currentState!.validate() && _propietario != null && _proveedorUid != null) {
      try {
        final detalles = {
          if (_numPasajeros != null) '#pasajeros': int.parse(_numPasajeros!),
          if (_numPuertas != null) '#puertas': int.parse(_numPuertas!),
          if (_tipoCombustible != null) 'tipoCombustible': _tipoCombustible,
          if (_ventilacionChecked) 'ventilacion': null,
          if (_kilometrajeType != null) 'kilometraje': _kilometrajeType,
          if (_tipoTransmision != null) 'tipoDeTransmision': _tipoTransmision,
        };

        await FirebaseFirestore.instance.collection('Vehiculos').add({
          'Propietario': _propietario,
          'categoria': _selectedCategory,
          'ciudad': _ciudadController.text,
          'descripcion': _descripcionController.text,
          'detalles': detalles.isNotEmpty ? detalles : null,
          'direccion': _direccionController.text,
          'marca': _marcaController.text,
          'modelo': int.tryParse(_modeloController.text) ?? 0,
          'placa': _placaController.text,
          'precioPorDia': double.tryParse(_precioController.text) ?? 0.0,
          'proveedorUid': _proveedorUid,
        });

        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Registrar Vehículo'),
              const SizedBox(height: 8),
              Text(
                'Propietario: ${_propietario ?? 'Cargando...'}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _ciudadController,
                    decoration: const InputDecoration(labelText: 'Ciudad'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo requerido' : null,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    value: _selectedCategory,
                    items: ['Automovil', 'Moto', 'Electrico', 'Minivan'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) => value == null ? 'Seleccione una categoría' : null,
                  ),
                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    controller: _direccionController,
                    decoration: const InputDecoration(labelText: 'Dirección'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    controller: _marcaController,
                    decoration: const InputDecoration(labelText: 'Marca'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    controller: _modeloController,
                    decoration: const InputDecoration(labelText: 'Modelo'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    controller: _placaController,
                    decoration: const InputDecoration(labelText: 'Placa'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo requerido' : null,
                  ),
                  TextFormField(
                    controller: _precioController,
                    decoration: const InputDecoration(labelText: 'Precio por Día'),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Campo requerido' : null,
                  ),
                  const Text('Detalles:'),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Número de Pasajeros'),
                    value: _numPasajeros,
                    items: ['1', '2', '3', '4', '5', '6', '7', '8'].map((String value) {
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
                    validator: (value) => value == null ? 'Seleccione un valor' : null,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Número de Puertas'),
                    value: _numPuertas,
                    items: ['2', '3', '4', '5'].map((String value) {
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
                    validator: (value) => value == null ? 'Seleccione un valor' : null,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Tipo de Combustible'),
                    value: _tipoCombustible,
                    items: _selectedCategory == 'Electrico'
                        ? []
                        : ['Corriente', 'ACP', 'Gas'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                    onChanged: _selectedCategory == 'Electrico'
                        ? null
                        : (value) {
                            setState(() {
                              _tipoCombustible = value;
                            });
                          },
                    validator: _selectedCategory == 'Electrico'
                        ? null
                        : (value) => value == null ? 'Seleccione un valor' : null,
                  ),
                  CheckboxListTile(
                    title: const Text('Ventilación (Aire Acondicionado/Ventilador)'),
                    value: _ventilacionChecked,
                    onChanged: (value) => setState(() => _ventilacionChecked = value!),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Kilometraje'),
                    value: _kilometrajeType,
                    items: ['Limitado', 'Ilimitado', 'No aplica'].map((String value) {
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
                    validator: (value) => value == null ? 'Seleccione un valor' : null,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Tipo de Transmisión'),
                    value: _tipoTransmision,
                    items: ['Automático', 'Semiautomático', 'Mecánico'].map((String value) {
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
                    validator: (value) => value == null ? 'Seleccione un valor' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Registrar'),
              onPressed: _registrarVehiculo,
            ),
          ],
        ),
      ),
    );
  }
}