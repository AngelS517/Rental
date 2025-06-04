import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar Firebase Auth
import 'package:flutter/services.dart'; // Importar para SystemChrome
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart'; // Pantalla de login
import 'pagina_terminos.dart';
import 'pagina_historial_Usuario.dart';

class PaginaPerfilCliente extends StatefulWidget {
  final Map<String, dynamic>? preloadedUserData; // Datos precargados
  final bool isCliente; // Estado precargado

  const PaginaPerfilCliente({
    super.key,
    this.preloadedUserData,
    this.isCliente = false,
  });

  @override
  State<PaginaPerfilCliente> createState() => _PaginaPerfilClienteState();
}

class _PaginaPerfilClienteState extends State<PaginaPerfilCliente> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isCliente = false;
  String? _imageUrl; // URL de la imagen de perfil
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF5A1EFF),
        statusBarIconBrightness: Brightness.light,
      ),
    );
    if (widget.preloadedUserData != null) {
      setState(() {
        userData = widget.preloadedUserData;
        isCliente = widget.isCliente;
        _imageUrl = userData?['imagen'];
        isLoading = false;
      });
    } else {
      verificarUsuarioYObtenerDatos();
    }
  }

  Future<void> verificarUsuarioYObtenerDatos() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('Error: No hay usuario autenticado');
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Debes iniciar sesión.')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
        return;
      }

      final uid = user.uid;
      print('UID del usuario autenticado: $uid');

      final userDoc =
          await FirebaseFirestore.instance
              .collection('Usuarios')
              .doc(uid)
              .get();

      if (!userDoc.exists) {
        print('Usuario no encontrado en la colección Usuarios');
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Usuario no encontrado.')));
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
        return;
      }

      final userDataFromUsuarios = userDoc.data() as Map<String, dynamic>;
      final proposito =
          userDataFromUsuarios['proposito']?.toString().toLowerCase() ?? '';
      print('Propósito del usuario: $proposito');

      if (proposito == 'proveedor') {
        print('El usuario no es cliente');
        setState(() {
          isLoading = false;
          isCliente = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Acceso denegado: No eres un cliente.')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
        return;
      }

      setState(() {
        isCliente = true;
        userData = userDataFromUsuarios;
        _imageUrl = userData?['imagen'];
        isLoading = false;
      });
      print('Datos del usuario cargados desde Usuarios: $userData');
    } catch (e) {
      print('Error al obtener datos: $e');
      setState(() {
        userData = {};
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
    }
  }

  Future<void> _recargarDatosDesdeFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc =
          await FirebaseFirestore.instance
              .collection('Usuarios')
              .doc(user.uid)
              .get();

      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data();
          _imageUrl = userData?['imagen'];
        });
        print('Datos recargados desde Firestore (Usuarios): $userData');
      }
    } catch (e) {
      print('Error al recargar datos desde Firestore: $e');
    }
  }

  Future<void> _subirImagen() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Subir imagen a Cloudinary
        final url = Uri.parse(
          'https://api.cloudinary.com/v1_1/dzmcnktot/image/upload?api_key=YOUR_API_KEY',
        );
        final request =
            http.MultipartRequest('POST', url)
              ..fields['upload_preset'] = 'Rental'
              ..files.add(
                await http.MultipartFile.fromPath('file', pickedFile.path),
              );

        final response = await request.send();
        if (response.statusCode == 200) {
          final responseData = await http.Response.fromStream(response);
          final jsonData = json.decode(responseData.body);
          final imageUrl = jsonData['secure_url'];

          // Guardar URL en Firestore
          await FirebaseFirestore.instance
              .collection('Usuarios')
              .doc(user.uid)
              .update({'imagen': imageUrl});

          setState(() {
            _imageUrl = imageUrl;
            userData?['imagen'] = _imageUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imagen subida correctamente')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al subir la imagen')),
          );
        }
      }
    }
  }

  Future<void> _mostrarDialogoEditarDatos(BuildContext context) async {
    String? nombre = userData?['nombre'];
    String? cedula = userData?['cedula'];
    String? telefono = userData?['telefono'];
    String? barrio = userData?['barrio'];
    String? ciudad = userData?['ciudad'];
    String? correo = userData?['correo'];
    String? direccion = userData?['direccion'];
    String? fechaNacimiento = userData?['fechaNacimiento'];
    bool showPasswordFields = false; // Estado para mostrar campos de contraseña

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            final TextEditingController nombreController =
                TextEditingController(text: nombre ?? '');
            final TextEditingController cedulaController =
                TextEditingController(text: cedula ?? '');
            final TextEditingController telefonoController =
                TextEditingController(text: telefono ?? '');
            final TextEditingController barrioController =
                TextEditingController(text: barrio ?? '');
            final TextEditingController ciudadController =
                TextEditingController(text: ciudad ?? '');
            final TextEditingController correoController =
                TextEditingController(
                  text:
                      correo ?? FirebaseAuth.instance.currentUser?.email ?? '',
                );
            final TextEditingController direccionController =
                TextEditingController(text: direccion ?? '');
            final TextEditingController fechaNacimientoController =
                TextEditingController(text: fechaNacimiento ?? '');

            final TextEditingController currentPasswordController =
                TextEditingController();
            final TextEditingController newPasswordController =
                TextEditingController();

            return AlertDialog(
              title: const Text('Editar Datos'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    TextFormField(
                      controller: cedulaController,
                      decoration: const InputDecoration(labelText: 'Cedula'),
                    ),
                    TextFormField(
                      controller: telefonoController,
                      decoration: const InputDecoration(labelText: 'Teléfono'),
                    ),
                    TextFormField(
                      controller: barrioController,
                      decoration: const InputDecoration(labelText: 'Barrio'),
                    ),
                    TextFormField(
                      controller: ciudadController,
                      decoration: const InputDecoration(labelText: 'Ciudad'),
                    ),
                    TextFormField(
                      controller: correoController,
                      decoration: const InputDecoration(labelText: 'Correo'),
                      enabled: false, // Deshabilitar edición
                    ),
                    TextFormField(
                      controller: direccionController,
                      decoration: const InputDecoration(labelText: 'Dirección'),
                    ),
                    TextFormField(
                      controller: fechaNacimientoController,
                      decoration: const InputDecoration(
                        labelText: 'Fecha Nacimiento',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        setDialogState(() {
                          showPasswordFields = !showPasswordFields;
                        });
                      },
                      child: Text(
                        showPasswordFields
                            ? 'Ocultar Cambio de Contraseña'
                            : 'Cambiar Contraseña',
                      ),
                    ),
                    if (showPasswordFields) ...[
                      TextFormField(
                        controller: currentPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña Actual',
                        ),
                        obscureText: true,
                      ),
                      TextFormField(
                        controller: newPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Nueva Contraseña',
                        ),
                        obscureText: true,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Guardar'),
                  onPressed: () async {
                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error: Debes iniciar sesión.'),
                          ),
                        );
                        return;
                      }

                      String? newPasswordToSave;

                      // Verificar si la contraseña cambió (solo si los campos están visibles)
                      final currentPassword =
                          currentPasswordController.text.trim();
                      final newPassword = newPasswordController.text.trim();
                      if (showPasswordFields && newPassword.isNotEmpty) {
                        if (currentPassword.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Por favor, ingresa la contraseña actual.',
                              ),
                            ),
                          );
                          return;
                        }
                        // Validar la nueva contraseña (mínimo 6 caracteres, requerido por Firebase)
                        if (newPassword.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'La nueva contraseña debe tener al menos 6 caracteres.',
                              ),
                            ),
                          );
                          return;
                        }
                        // Actualizar la contraseña en FirebaseAuth
                        await user.updatePassword(newPassword);
                        newPasswordToSave =
                            newPassword; // Guardar para Firestore
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Contraseña actualizada correctamente.',
                            ),
                          ),
                        );
                      }

                      // Guardar los datos en la colección Usuarios
                      final updatedData = {
                        'nombre': nombreController.text,
                        'cedula': cedulaController.text,
                        'telefono': telefonoController.text,
                        'barrio': barrioController.text,
                        'ciudad': ciudadController.text,
                        'correo':
                            user.email, // Usar el correo actual del usuario
                        'direccion': direccionController.text,
                        'fechaNacimiento': fechaNacimientoController.text,
                        'imagen': _imageUrl,
                      };

                      // Solo agregar el campo password si se cambió la contraseña
                      if (newPasswordToSave != null) {
                        updatedData['password'] = newPasswordToSave;
                      }

                      await FirebaseFirestore.instance
                          .collection('Usuarios')
                          .doc(user.uid)
                          .set(updatedData, SetOptions(merge: true));

                      // Actualizar el estado local
                      setState(() {
                        userData?['nombre'] = nombreController.text;
                        userData?['cedula'] = cedulaController.text;
                        userData?['telefono'] = telefonoController.text;
                        userData?['barrio'] = barrioController.text;
                        userData?['ciudad'] = ciudadController.text;
                        userData?['correo'] =
                            user.email; // Usar el correo actual
                        userData?['direccion'] = direccionController.text;
                        userData?['fechaNacimiento'] =
                            fechaNacimientoController.text;
                        userData?['imagen'] = _imageUrl;
                        if (newPasswordToSave != null) {
                          userData?['password'] = newPasswordToSave;
                        }
                      });

                      // Depuración: Verificar que userData se actualizó
                      print('userData actualizado localmente: $userData');

                      // Recargar datos desde Firestore para confirmar
                      await _recargarDatosDesdeFirestore();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Datos actualizados correctamente'),
                        ),
                      );
                      Navigator.of(context).pop();
                    } on FirebaseException catch (e) {
                      print(
                        'Error al interactuar con Firestore: ${e.code} - ${e.message}',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error al actualizar datos en Firestore: ${e.message}',
                          ),
                        ),
                      );
                    } catch (e) {
                      print('Error inesperado al actualizar datos: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error inesperado al actualizar datos: $e',
                          ),
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

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : !isCliente
        ? const Center(child: Text('Acceso denegado.'))
        : SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height:
                        MediaQuery.of(context).size.height * 0.25 +
                        kToolbarHeight,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://sdmntprwestus.oaiusercontent.com/files/00000000-f37c-6230-b61d-5e0671390ff8/raw?se=2025-06-01T01%3A48%3A13Z&sp=r&sv=2024-08-04&sr=b&scid=3f75e862-f7fa-5734-b72b-683ed88eefd3&skoid=add8ee7d-5fc7-451e-b06e-a82b2276cf62&sktid=a48cca56-e6da-484e-a814-9c849652bcb3&skt=2025-05-31T21%3A47%3A52Z&ske=2025-06-01T21%3A47%3A52Z&sks=b&skv=2024-08-04&sig=dHaEgfJ/%2BBe6rAvdtwNgmeITbrqW9mlwIDXLfa1jAG0%3D',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.125,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: _subirImagen,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 47,
                                backgroundImage:
                                    _imageUrl != null
                                        ? NetworkImage(_imageUrl!)
                                        : null,
                                child:
                                    _imageUrl == null
                                        ? Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.grey[700],
                                        )
                                        : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                userData?['nombre'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              sectionTitle("Información Personal"),
              infoItem("Nombre", userData?['nombre']),
              infoItem("Cedula", userData?['cedula']),
              infoItem("Correo", userData?['correo']),
              infoItem("Teléfono", userData?['telefono']),
              infoItem("Fecha Nac", userData?['fechaNacimiento']),
              infoItem("Dirección", userData?['direccion']),
              infoItem("Barrio", userData?['barrio']),
              infoItem("Ciudad", userData?['ciudad']),
              const SizedBox(height: 15),
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      _mostrarDialogoEditarDatos(context);
                    },
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
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Editar datos",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ListTile(
                leading: const Icon(
                  Icons.history,
                  color: Color(0xFF4B4EAB), // Color como el segundo ListTile
                ),
                title: const Text("Historial"),
                trailing: const Icon(
                  Icons.keyboard_arrow_right,
                  color: Color(
                    0xFF4B4EAB,
                  ), // Color de la flechita también igual
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaginaHistorialUsuario(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.description,
                  color: Color(0xFF4B4EAB),
                ),
                title: const Text("Términos y condiciones"),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PaginaTerminos()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFF4B4EAB)),
                title: const Text(
                  "Cerrar sesión",
                  style: TextStyle(color: Colors.black),
                ),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Center(
                            child: Text(
                              'Confirmar',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          content: const Text(
                            '¿Estás seguro de cerrar sesión?',
                          ),
                          actionsAlignment:
                              MainAxisAlignment.center, // 🔴 Centra los botones
                          actions: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFF4B4EAB), // Color morado
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextButton(
                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ), // Texto blanco
                                ),
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFF4B4EAB), // Color morado
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextButton(
                                child: const Text(
                                  'Sí',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ), // Texto blanco
                                ),
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                              ),
                            ),
                          ],
                        ),
                  );
                  if (confirm == true) {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        children: [
          const SizedBox(width: 20),
          const Icon(Icons.person, color: Color(0xFF4B4EAB)),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4B4EAB),
            ),
          ),
        ],
      ),
    );
  }

  Widget infoItem(String label, String? value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      child: Text(
        "$label: ${value ?? 'No disponible'}",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget listTileItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4B4EAB)),
      title: Text(title),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        // Aquí puedes agregar acciones personalizadas si es necesario
      },
    );
  }
}
