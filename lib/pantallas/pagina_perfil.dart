import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'global.dart';
import 'login.dart'; // Asegúrate de importar la pantalla de login

class PaginaPerfil extends StatefulWidget {
  const PaginaPerfil({super.key});

  @override
  State<PaginaPerfil> createState() => _PaginaPerfilState();
}

class _PaginaPerfilState extends State<PaginaPerfil> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    obtenerDatosUsuario();
  }

  Future<void> obtenerDatosUsuario() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('Usuarios')
          .where('correo', isEqualTo: correoUsuarioGlobal)
          .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          userData = query.docs.first.data();
        });
      }
    } catch (e) {
      print('Error al obtener datos del usuario: $e');
    }
  }

  // Función para mostrar el diálogo de edición
  Future<void> _mostrarDialogoEditarDatos(BuildContext context) async {
    String? nombre = userData?['nombre'];
    String? telefono = userData?['telefono'];
    String? barrio = userData?['barrio'];
    String? ciudad = userData?['ciudad'];

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController nombreController = TextEditingController(text: nombre);
        final TextEditingController telefonoController = TextEditingController(text: telefono);
        final TextEditingController barrioController = TextEditingController(text: barrio);
        final TextEditingController ciudadController = TextEditingController(text: ciudad);

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
                  final doc = await FirebaseFirestore.instance
                      .collection('Usuarios')
                      .where('correo', isEqualTo: correoUsuarioGlobal)
                      .get();
                  if (doc.docs.isNotEmpty) {
                    await doc.docs.first.reference.update({
                      'nombre': nombreController.text,
                      'telefono': telefonoController.text,
                      'barrio': barrioController.text,
                      'ciudad': ciudadController.text,
                    });
                    setState(() {
                      userData?['nombre'] = nombreController.text;
                      userData?['telefono'] = telefonoController.text;
                      userData?['barrio'] = barrioController.text;
                      userData?['ciudad'] = ciudadController.text;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Datos actualizados correctamente')),
                    );
                  }
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

  @override
  Widget build(BuildContext context) {
    return userData == null
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
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
                ElevatedButton(
                  onPressed: () {
                    // Acción para editar
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B4EAB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Editar datos"),
                ),
                const SizedBox(height: 30),
                listTileItem(Icons.history, "Historial"),
                listTileItem(Icons.description, "Términos y condiciones"),
                // ListTile para editar datos
                ListTile(
                  leading: const Icon(
                    Icons.edit,
                    color: Color(0xFF4B4EAB),
                  ),
                  title: const Text(
                    "Editar datos",
                    style: TextStyle(color: Colors.black),
                  ),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    _mostrarDialogoEditarDatos(context);
                  },
                ),
                // Botón de cerrar sesión con texto negro
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Color(0xFF4B4EAB),
                  ),
                  title: const Text(
                    "Cerrar sesión",
                    style: TextStyle(color: Colors.black),
                  ),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (Route<dynamic> route) => false,
                    );
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