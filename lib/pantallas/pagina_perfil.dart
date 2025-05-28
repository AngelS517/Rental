import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar Firebase Auth
import 'package:flutter/services.dart'; // Importar para SystemChrome
import 'login.dart'; // Pantalla de login
import 'package:rental/widgets/custom_widgets.dart'; // Para CustomNavBar
import 'pagina_terminos.dart';

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
  int _selectedIndex = 3; // Índice para la página de perfil

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
      // Usar datos precargados si están disponibles
      setState(() {
        userData = widget.preloadedUserData;
        isCliente = widget.isCliente;
        isLoading = false;
      });
    } else {
      // Si no hay datos precargados, cargarlos
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
      print('UID del usuario autenticado: $uid'); // Depuración

      // Verificar si el usuario es cliente consultando la colección Usuarios
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
      print('Propósito del usuario: $proposito'); // Depuración

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

      // Si es cliente, cargar datos de la colección Usuarios
      setState(() {
        isCliente = true;
        userData = userDataFromUsuarios; // Usar datos de Usuarios directamente
        isLoading = false;
      });
      print(
        'Datos del usuario cargados desde Usuarios: $userData',
      ); // Depuración
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

  // Función para recargar datos desde Firestore
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
        });
        print(
          'Datos recargados desde Firestore (Usuarios): $userData',
        ); // Depuración
      }
    } catch (e) {
      print('Error al recargar datos desde Firestore: $e');
    }
  }

  // Función para mostrar el diálogo de edición
  Future<void> _mostrarDialogoEditarDatos(BuildContext context) async {
    String? nombre = userData?['nombre'];
    String? telefono = userData?['telefono'];
    String? barrio = userData?['barrio'];
    String? ciudad = userData?['ciudad'];
    String? correo = userData?['correo'];
    String? direccion = userData?['direccion'];
    String? fechaNacimiento = userData?['fechaNacimiento'];

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController nombreController = TextEditingController(
          text: nombre,
        );
        final TextEditingController telefonoController = TextEditingController(
          text: telefono,
        );
        final TextEditingController barrioController = TextEditingController(
          text: barrio,
        );
        final TextEditingController ciudadController = TextEditingController(
          text: ciudad,
        );
        final TextEditingController correoController = TextEditingController(
          text: correo,
        );
        final TextEditingController direccionController = TextEditingController(
          text: direccion,
        );
        final TextEditingController fechaNacimientoController =
            TextEditingController(text: fechaNacimiento);

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

                  // Guardar los datos en la colección Usuarios
                  await FirebaseFirestore.instance
                      .collection('Usuarios')
                      .doc(user.uid)
                      .set({
                        'nombre': nombreController.text,
                        'telefono': telefonoController.text,
                        'barrio': barrioController.text,
                        'ciudad': ciudadController.text,
                        'correo': correoController.text,
                        'direccion': direccionController.text,
                        'fechaNacimiento': fechaNacimientoController.text,
                      }, SetOptions(merge: true));

                  // Actualizar el estado local
                  setState(() {
                    userData?['nombre'] = nombreController.text;
                    userData?['telefono'] = telefonoController.text;
                    userData?['barrio'] = barrioController.text;
                    userData?['ciudad'] = ciudadController.text;
                    userData?['correo'] = correoController.text;
                    userData?['direccion'] = direccionController.text;
                    userData?['fechaNacimiento'] =
                        fechaNacimientoController.text;
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
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al actualizar datos: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/inicio',
        (Route<dynamic> route) => false,
      ); // Navegar a Inicio y limpiar la pila
    } else if (index == 1) {
      Navigator.pushNamed(context, '/mapa');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/favoritos');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/perfil');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Image.asset(
                        'imagenes/logorental.png', // Asegúrate de tener esta imagen
                        height: 36,
                      ),
                    ),
                  ),
                  const Text('Perfil', style: TextStyle(color: Colors.white)),
                ],
              ),
              automaticallyImplyLeading: false,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: CustomNavBar(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      );
    }

    if (!isCliente) {
      return const Center(child: Text('Acceso denegado.'));
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7b43cd), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      'imagenes/logorental.png', // Asegúrate de tener esta imagen
                      height: 36,
                    ),
                  ),
                ),
                const Text('Perfil', style: TextStyle(color: Colors.white)),
              ],
            ),
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4B4EAB), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 47,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Text(
              userData?['nombre'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),
            sectionTitle("Información Personal"),
            infoItem("Nombre", userData?['nombre']),
            infoItem("Correo", userData?['correo']),
            infoItem("Teléfono", userData?['telefono']),
            infoItem("Fecha Nac", userData?['fechaNacimiento']),
            infoItem("Dirección", userData?['direccion']),
            infoItem("Barrio", userData?['barrio']),
            infoItem("Ciudad", userData?['ciudad']),
            const SizedBox(height: 15),
            Center(
              child: SizedBox(
                width: 200, // Ancho más alargado
                child: ElevatedButton(
                  onPressed: () {
                    _mostrarDialogoEditarDatos(
                      context,
                    ); // Llamar al diálogo de edición
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.all(
                      0,
                    ), // Ajustar padding para el gradiente
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
                      ), // Ajuste de padding
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
            listTileItem(Icons.history, "Historial"),
            ListTile(
              leading: const Icon(Icons.description, color: Color(0xFF4B4EAB)),
              title: const Text("Términos y condiciones"),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaginaTerminos()),
                );
              },
            ),

            // Botón de cerrar sesión con texto negro
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF4B4EAB)),
              title: const Text(
                "Cerrar sesión",
                style: TextStyle(color: Colors.black),
              ),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
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
