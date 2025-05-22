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
      final query =
          await FirebaseFirestore.instance
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
          userData == null
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
                                backgroundImage: AssetImage(
                                  "assets/avatar.png",
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
                    infoItem("Fecha Nac", userData?['fecha_nacimiento']),
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

                    /// 🔻🔻🔻 CIERRE DE SESIÓN AQUÍ 🔻🔻🔻
                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Color(0xFF4B4EAB),
                      ),
                      title: const Text("Cerrar sesión"),
                      trailing: const Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        // Aquí navegas al login, conservando los datos del usuario en memoria
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),

                    /// 🔺🔺🔺 FIN CIERRE DE SESIÓN 🔺🔺🔺
                    const SizedBox(height: 30),
                  ],
                ),
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
