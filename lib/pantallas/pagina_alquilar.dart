import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pagina_principal.dart';
import 'package:intl/intl.dart';

class PaginaAlquilar extends StatefulWidget {
  final String placa;

  const PaginaAlquilar({Key? key, required this.placa}) : super(key: key);

  @override
  State<PaginaAlquilar> createState() => _PaginaAlquilarState();
}

class _PaginaAlquilarState extends State<PaginaAlquilar> {
  final fechaRetiroController = TextEditingController();
  final fechaEntregaController = TextEditingController();
  bool proteccionTotal = false;

  String nombreUsuario = '';
  String correoUsuario = '';
  String celularUsuario = '';
  String documentoUsuario = '';
  File? licenciaImagen;
  late int precioPorDia;

  int precioVehiculo = 0;
  int precioProteccion = 0;
  int precioTotal = 0;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    obtenerDatosUsuario();
  }

  Future<void> obtenerDatosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('Usuarios')
              .doc(user.uid)
              .get();

      final data = userDoc.data();
      if (data != null) {
        setState(() {
          nombreUsuario = data['nombre'] ?? '';
          correoUsuario = data['correo'] ?? '';
          celularUsuario = data['telefono'] ?? '';
          documentoUsuario = 'CC ${data['cedula'] ?? ''}';
        });
      }
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> obtenerVehiculo() async {
    final query =
        await FirebaseFirestore.instance
            .collection('Vehiculos')
            .where('placa', isEqualTo: widget.placa)
            .limit(1)
            .get();

    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      precioPorDia = 30000; // Cambiado fijo a 30000 según tu pedido
      return query.docs.first;
    } else {
      throw Exception('Vehículo no encontrado');
    }
  }

  Future<void> seleccionarFechaYHora(TextEditingController controller) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (fecha != null) {
      final hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (hora != null) {
        final fechaHora = DateTime(
          fecha.year,
          fecha.month,
          fecha.day,
          hora.hour,
          hora.minute,
        );
        final formato = DateFormat('yyyy-MM-dd HH:mm');
        controller.text = formato.format(fechaHora);
        _calcularPrecios(); // Recalcular precios al cambiar fecha
      }
    }
  }

  void _calcularPrecios() {
    if (fechaRetiroController.text.isEmpty ||
        fechaEntregaController.text.isEmpty) {
      setState(() {
        precioVehiculo = 0;
        precioProteccion = 0;
        precioTotal = 0;
      });
      return;
    }

    try {
      final fechaRetiro = DateFormat(
        'yyyy-MM-dd HH:mm',
      ).parse(fechaRetiroController.text);
      final fechaEntrega = DateFormat(
        'yyyy-MM-dd HH:mm',
      ).parse(fechaEntregaController.text);

      // Diferencia en horas y convertir a días (al menos 1 día)
      final diferenciaHoras = fechaEntrega.difference(fechaRetiro).inHours;
      final diferenciaDias = (diferenciaHoras / 24).ceil();

      if (diferenciaDias < 1) {
        // No cumple mínimo 1 día
        setState(() {
          precioVehiculo = 0;
          precioProteccion = 0;
          precioTotal = 0;
        });
        return;
      }

      int vehiculoPrice = diferenciaDias * precioPorDia;
      int proteccionPrice = proteccionTotal ? 30000 : 0;
      int total = vehiculoPrice + proteccionPrice;

      setState(() {
        precioVehiculo = vehiculoPrice;
        precioProteccion = proteccionPrice;
        precioTotal = total;
      });
    } catch (e) {
      setState(() {
        precioVehiculo = 0;
        precioProteccion = 0;
        precioTotal = 0;
      });
    }
  }

  Future<void> seleccionarImagenLicencia() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        licenciaImagen = File(pickedFile.path);
      });
    }
  }

  Future<String> subirImagenACloudinary(File imagen) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/dzmcnktot/image/upload',
    );
    final request =
        http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = 'Rental'
          ..files.add(await http.MultipartFile.fromPath('file', imagen.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await http.Response.fromStream(response);
      final jsonData = json.decode(responseData.body);
      return jsonData['secure_url'];
    } else {
      throw Exception('Error al subir la imagen');
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
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información del vehículo
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información del vehículo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      campoInfo('Vehículo a alquilar:', '$marca $modelo'),
                      campoInfo('Placa:', widget.placa),
                      campoInfo(
                        'Precio por día:',
                        '\$${precioPorDia.toString()}',
                      ),
                    ],
                  ),
                ),

                // Información del usuario
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información del usuario',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      campoInfo('Nombre completo:', nombreUsuario),
                      campoInfo('Correo electrónico:', correoUsuario),
                      campoInfo('Celular:', celularUsuario),
                      campoInfo('Número de documento:', documentoUsuario),
                    ],
                  ),
                ),

                // Información de alquiler
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información de alquiler',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      campoFecha(
                        'Fecha y hora de retiro:',
                        fechaRetiroController,
                      ),
                      campoFecha(
                        'Fecha y hora de entrega:',
                        fechaEntregaController,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: seleccionarImagenLicencia,
                        child: const Text(
                          'Seleccionar foto de licencia de conducir',
                        ),
                      ),
                      if (licenciaImagen != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Image.file(licenciaImagen!, height: 150),
                        ),
                      Row(
                        children: [
                          Checkbox(
                            value: proteccionTotal,
                            onChanged: (value) {
                              setState(() {
                                proteccionTotal = value ?? false;
                                _calcularPrecios();
                              });
                            },
                          ),
                          const Expanded(
                            child: Text('Protección total (+\$30.000)'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Valor (precios)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Valor',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      campoInfo('Precio del vehículo:', '\$$precioVehiculo'),
                      campoInfo(
                        'Precio protección total:',
                        '\$$precioProteccion',
                      ),
                      const Divider(),
                      campoInfo(
                        'Precio total:',
                        '\$$precioTotal',
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),

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
                      if (licenciaImagen == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Debes seleccionar una foto de la licencia.',
                            ),
                          ),
                        );
                        return;
                      }

                      final confirmacion = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Confirmar renta'),
                              content: const Text(
                                '¿Estás seguro de que quieres alquilar este vehículo?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4B4EAB),
                                  ),
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Confirmar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (confirmacion != true) {
                        return; // Cancelado por el usuario
                      }

                      try {
                        final fechaRetiro = DateFormat(
                          'yyyy-MM-dd HH:mm',
                        ).parse(fechaRetiroController.text.trim());
                        final fechaEntrega = DateFormat(
                          'yyyy-MM-dd HH:mm',
                        ).parse(fechaEntregaController.text.trim());

                        if (fechaRetiro.isAfter(fechaEntrega)) {
                          throw Exception(
                            'La fecha y hora de retiro debe ser menor a la de entrega',
                          );
                        }

                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          throw Exception('Usuario no autenticado');
                        }

                        final urlLicencia = await subirImagenACloudinary(
                          licenciaImagen!,
                        );
                        final total =
                            proteccionTotal
                                ? precioPorDia + 55000
                                : precioPorDia;

                        final alquilarRef = FirebaseFirestore.instance
                            .collection('Alquilar')
                            .doc(user.uid);

                        await alquilarRef.set({
                          'alquilados': FieldValue.arrayUnion([widget.placa]),
                          'nombre': nombreUsuario,
                          'usuarioUid': user.uid,
                          'fechaRetiro': fechaRetiroController.text.trim(),
                          'fechaEntrega': fechaEntregaController.text.trim(),
                          'proteccionTotal': proteccionTotal,
                          'urlLicencia': urlLicencia,
                          'precioTotal': precioProteccion,
                          'fechaRegistro': FieldValue.serverTimestamp(),
                        }, SetOptions(merge: true));

                        final vehiculoQuery =
                            await FirebaseFirestore.instance
                                .collection('Vehiculos')
                                .where('placa', isEqualTo: widget.placa)
                                .limit(1)
                                .get();

                        if (vehiculoQuery.docs.isNotEmpty) {
                          final docId = vehiculoQuery.docs.first.id;
                          await FirebaseFirestore.instance
                              .collection('Vehiculos')
                              .doc(docId)
                              .update({'disponible': false});
                        }

                        final historialRef = FirebaseFirestore.instance
                            .collection('usuariosHistorial')
                            .doc(user.uid);

                        await historialRef.set({
                          'alquilados': FieldValue.arrayUnion([widget.placa]),
                          'nombre': nombreUsuario,
                          'usuarioUid': user.uid,
                        }, SetOptions(merge: true));

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
                                    Text(
                                      'Precio total: \$${precioTotal.toString()}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
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
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    child: const Text(
                      'Alquilar vehículo',
                      style: TextStyle(fontSize: 16, color: Colors.white),
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

  Widget campoInfo(
    String etiqueta,
    String valor, {
    Color? color,
    FontWeight? fontWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: '$etiqueta ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 16,
          ),
          children: [
            TextSpan(
              text: valor,
              style: TextStyle(
                fontWeight: fontWeight ?? FontWeight.normal,
                color: color ?? Colors.black87,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget campoFecha(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () => seleccionarFechaYHora(controller),
      ),
    );
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }
}
