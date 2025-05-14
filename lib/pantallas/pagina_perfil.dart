import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'global.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: const Color(0xFF0A0C58), // Azul oscuro
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(25),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0A0C58), // Azul oscuro
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(80),
                        bottomLeft: Radius.circular(80),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Mi Perfil',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        infoItem("Nombre", userData?['nombre']),
                        const SizedBox(height: 15),
                        infoItem("Apellido", userData?['apellido']),
                        const SizedBox(height: 15),
                        infoItem("Teléfono", userData?['telefono']),
                        const SizedBox(height: 15),
                        infoItem("Correo", userData?['correo']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget infoItem(String label, String? value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF4B4EAB), // Azul claro
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      child: Text(
        "$label: ${value ?? 'No disponible'}",
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
