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
  List<File?> _imageFiles = [null, null, null]; // Array for up to 3 images

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
      final userDoc =
          await FirebaseFirestore.instance.collection('Usuarios').doc(_proveedorUid).get();
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
          const SnackBar(
            content: Text('La imagen es demasiado grande. Máximo 10 MB.'),
          ),
        );
        return null;
      }

      var uri = Uri.parse('https://api.cloudinary.com/v1_1/dzmcnktot/image/upload');
      var request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'Rental'
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Tiempo de espera agotado al subir la imagen.');
        },
      );

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
              const SnackBar(
                content: Text('Error: No se recibió una URL válida de la imagen.'),
              ),
            );
            return null;
          }
        } else {
          print('Error: Invalid JSON response - $jsonResponse');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Respuesta inválida de Cloudinary.'),
            ),
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
            SnackBar(
              content: Text('Error al subir la imagen: Código ${response.statusCode}'),
            ),
          );
        }
        return null;
      }
    } catch (e) {
      print('Upload Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir la imagen: $e')));
      return null;
    }
  }

  Future<void> _pickImage(int index) async {
    if (index >= 0 && index < 3) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFiles[index] = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _registrarVehiculo() async {
    if (_formKey.currentState!.validate() && _propietario != null && _proveedorUid != null) {
      try {
        // Verificar si la placa ya está registrada
        final placaExistente = await FirebaseFirestore.instance
            .collection('Vehiculos')
            .where('placa', isEqualTo: _placaController.text)
            .get();

        if (placaExistente.docs.isNotEmpty) {
          // Mostrar mensaje si la placa ya está registrada
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La placa ya está registrada en otro vehículo.'),
            ),
          );
          return; // Detener el registro
        }

        List<String?> imageUrls = [];
        for (var imageFile in _imageFiles) {
          if (imageFile != null) {
            final url = await _uploadImageToCloudinary(imageFile);
            if (url != null) {
              imageUrls.add(url);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fallo al subir una de las imágenes. Intenta de nuevo.'),
                ),
              );
              return;
            }
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

        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('Vehiculos')
            .add({
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
              'imagen': imageUrls.isNotEmpty ? imageUrls : null, // Store as array
              'disponible': true,
            });

        print('Vehículo registrado con ID: ${docRef.id}, Imagen URLs: $imageUrls');

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehículo registrado correctamente')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al registrar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050272), // Blue background as requested
      body: Center(
        child: AlertDialog(
          backgroundColor: const Color(0xFFF5F5F5), // Light gray background like the image, kept as white-like
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Agregar Vehículo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B4EAB), // Dark blue from the image
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Propietario: ${_propietario ?? 'Cargando...'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16), // Added spacing to match layout
                  TextFormField(
                    controller: _ciudadController,
                    decoration: const InputDecoration(
                      labelText: 'Ciudad',
                      filled: true,
                      fillColor: Color(0xFFF0F0F0), // Light gray fill
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      filled: true,
                      fillColor: Color(0xFFF0F0F0), // Light gray fill
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      filled: true,
                      fillColor: Color(0xFFF0F0F0), // Light gray fill
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _direccionController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección',
                      filled: true,
                      fillColor: Color(0xFFF0F0F0), // Light gray fill
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _marcaController,
                    decoration: const InputDecoration(
                      labelText: 'Marca',
                      filled: true,
                      fillColor: Color(0xFFF0F0F0), // Light gray fill
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _modeloController,
                    decoration: const InputDecoration(
                      labelText: 'Modelo',
                      filled: true,
                      fillColor: Color(0xFFF0F0F0), // Light gray fill
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _placaController,
                    decoration: const InputDecoration(
                      labelText: 'Placa',
                      filled: true,
                      fillColor: Color(0xFFF0F0F0), // Light gray fill
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (value) {
                      final newValue = value.toUpperCase();
                      if (newValue != value) {
                        _placaController.value = _placaController.value.copyWith(
                          text: newValue,
                          selection: TextSelection.collapsed(offset: newValue.length),
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Campo requerido';

                      if (value.length > 6) return 'La placa debe tener máximo 6 caracteres';

                      final validChars = RegExp(r'^[A-Z0-9]+$');
                      if (!validChars.hasMatch(value)) {
                        return 'La placa solo puede contener letras mayúsculas y números, sin espacios';
                      }

                      final hasLetter = value.contains(RegExp(r'[A-Z]'));
                      final hasNumber = value.contains(RegExp(r'[0-9]'));
                      if (!hasLetter || !hasNumber) {
                        return 'La placa debe contener al menos una letra y un número';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _precioController,
                    decoration: const InputDecoration(
                      labelText: 'Precio por Día',
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Detalles:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B4EAB),
                    ),
                  ),
                  if (_selectedCategory != 'Moto')
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Número de Pasajeros',
                        filled: true,
                        fillColor: Color(0xFFF0F0F0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      value: _numPasajeros,
                      items: (_selectedCategory == 'Minivan' ? ['1', '2', '3', '4', '5', '6', '7', '8'] : ['1', '2', '3', '4'])
                          .map((String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _numPasajeros = value;
                        });
                      },
                      validator: (value) => value == null ? 'Seleccione un valor' : null,
                    ),
                  const SizedBox(height: 16),
                  if (_selectedCategory != 'Moto')
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Número de Puertas',
                        filled: true,
                        fillColor: Color(0xFFF0F0F0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Combustible',
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    value: _tipoCombustible,
                    items: _selectedCategory == 'Electrico'
                        ? []
                        : ['Corriente', 'ACP', 'Gas'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                    onChanged: _selectedCategory == 'Electrico' ? null : (value) {
                      setState(() {
                        _tipoCombustible = value;
                      });
                    },
                    validator: _selectedCategory == 'Electrico' ? null : (value) => value == null ? 'Seleccione un valor' : null,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text(
                      'Ventilación (Aire Acondicionado/Ventilador)',
                      style: TextStyle(color: Colors.black87),
                    ),
                    value: _ventilacionChecked,
                    onChanged: (value) => setState(() => _ventilacionChecked = value!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Kilometraje',
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Transmisión',
                      filled: true,
                      fillColor: Color(0xFFF0F0F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
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
                  const SizedBox(height: 16),
                  // Campos para seleccionar hasta 3 imágenes
                  ListTile(
                    leading: const Icon(Icons.image, color: Color(0xFF4B4EAB)),
                    title: const Text('Seleccionar Imagen 1', style: TextStyle(color: Color(0xFF4B4EAB))),
                    subtitle: _imageFiles[0] != null ? const Text('Imagen seleccionada', style: TextStyle(color: Colors.black87)) : const Text('Sin imagen seleccionada', style: TextStyle(color: Colors.black87)),
                    onTap: () => _pickImage(0),
                  ),
                  if (_imageFiles[0] != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(
                        _imageFiles[0]!,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ListTile(
                    leading: const Icon(Icons.image, color: Color(0xFF4B4EAB)),
                    title: const Text('Seleccionar Imagen 2', style: TextStyle(color: Color(0xFF4B4EAB))),
                    subtitle: _imageFiles[1] != null ? const Text('Imagen seleccionada', style: TextStyle(color: Colors.black87)) : const Text('Sin imagen seleccionada', style: TextStyle(color: Colors.black87)),
                    onTap: () => _pickImage(1),
                  ),
                  if (_imageFiles[1] != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(
                        _imageFiles[1]!,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ListTile(
                    leading: const Icon(Icons.image, color: Color(0xFF4B4EAB)),
                    title: const Text('Seleccionar Imagen 3', style: TextStyle(color: Color(0xFF4B4EAB))),
                    subtitle: _imageFiles[2] != null ? const Text('Imagen seleccionada', style: TextStyle(color: Colors.black87)) : const Text('Sin imagen seleccionada', style: TextStyle(color: Colors.black87)),
                    onTap: () => _pickImage(2),
                  ),
                  if (_imageFiles[2] != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(
                        _imageFiles[2]!,
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
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFF4B4EAB))),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4B4EAB)),
              child: const Text('Registrar', style: TextStyle(color: Colors.white)),
              onPressed: _registrarVehiculo,
            ),
          ],
        ),
      ),
    );
  }
}