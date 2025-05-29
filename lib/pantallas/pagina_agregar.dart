import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

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
  File? _imageFile; // Para almacenar la imagen seleccionada

  final ImagePicker _picker = ImagePicker();

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

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    try {
      // Validar el tamaño de la imagen (máximo 10 MB)
      final imageSize = await imageFile.length();
      if (imageSize > 10 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La imagen es demasiado grande. Máximo 10 MB.')),
        );
        return null;
      }

      var uri = Uri.parse('https://api.cloudinary.com/v1_1/dzmcnktot/image/upload');
      var request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'Rental'
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send().timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Tiempo de espera agotado al subir la imagen.');
      });

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        print('Cloudinary Response: $responseData'); // Depuración
        var jsonResponse = jsonDecode(responseData);
        if (jsonResponse is Map && jsonResponse.containsKey('secure_url')) {
          final url = jsonResponse['secure_url'] as String?;
          if (url != null && url.isNotEmpty) {
            print('Image URL: $url'); // Depuración
            return url;
          } else {
            print('Error: secure_url is null or empty');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: No se recibió una URL válida de la imagen.')),
            );
            return null;
          }
        } else {
          print('Error: Invalid JSON response - $jsonResponse');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Respuesta inválida de Cloudinary.')),
          );
          return null;
        }
      } else {
        var responseData = await response.stream.bytesToString();
        print('Upload Error: ${response.statusCode} - $responseData');
        if (response.statusCode == 400 && responseData.contains('whitelisted')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Configura el upload preset "Rental" como Unsigned en Cloudinary.'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al subir la imagen: Código ${response.statusCode}')),
          );
        }
        return null;
      }
    } catch (e) {
      print('Upload Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir la imagen: $e')),
      );
      return null;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _registrarVehiculo() async {
    if (_formKey.currentState!.validate() && _propietario != null && _proveedorUid != null) {
      try {
        String? imageUrl;
        if (_imageFile != null) {
          imageUrl = await _uploadImageToCloudinary(_imageFile!);
          if (imageUrl == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fallo al subir la imagen. Intenta de nuevo.')),
            );
            return; // Detener el registro si la imagen no se sube
          }
        }

        final detalles = {
          if (_numPasajeros != null) '#pasajeros': int.parse(_numPasajeros!),
          if (_numPuertas != null) '#puertas': int.parse(_numPuertas!),
          if (_tipoCombustible != null) 'tipoCombustible': _tipoCombustible,
          if (_ventilacionChecked) 'ventilacion': null,
          if (_kilometrajeType != null) 'kilometraje': _kilometrajeType,
          if (_tipoTransmision != null) 'tipoDeTransmision': _tipoTransmision,
        };

        DocumentReference docRef = await FirebaseFirestore.instance.collection('Vehiculos').add({
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
          'imagen': imageUrl, // Guardar el URL de Cloudinary en Firestore
        });

        print('Vehículo registrado con ID: ${docRef.id}, Imagen URL: $imageUrl'); // Depuración

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehículo registrado correctamente')),
          );
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
                  // Campo para seleccionar imagen
                  ListTile(
                    leading: const Icon(Icons.image),
                    title: const Text('Seleccionar Imagen'),
                    subtitle: _imageFile != null
                        ? const Text('Imagen seleccionada')
                        : const Text('Sin imagen seleccionada'),
                    onTap: _pickImage,
                  ),
                  if (_imageFile != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(
                        _imageFile!,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
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