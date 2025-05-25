// archivo: pagina_principal_proveedor.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rental/widgets/custom_widgets_proveedor.dart';
import 'pagina_perfil_proveedor.dart';
import 'publicados_proveedor.dart';


class PaginaPrincipalProveedor extends StatefulWidget {
  const PaginaPrincipalProveedor({super.key});

  @override
  _PaginaPrincipalProveedorState createState() => _PaginaPrincipalProveedorState();
}

class _PaginaPrincipalProveedorState extends State<PaginaPrincipalProveedor> {
  int _selectedIndex = 0;
  String? userPurpose;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF5A1EFF),
      statusBarIconBrightness: Brightness.light,
    ));
    fetchUserPurpose();
  }

  Future<void> fetchUserPurpose() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Debes iniciar sesión.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final uid = user.uid;
      final userDoc = await FirebaseFirestore.instance.collection('Usuarios').doc(uid).get();

      if (!userDoc.exists) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no encontrado.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final proposito = userData['proposito']?.toString().toLowerCase() ?? '';

      if (proposito != 'proveedor') {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Acceso denegado: No eres un proveedor.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      setState(() {
        userPurpose = proposito;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final Map<int, String> titles = {
      0: 'Página Principal - Proveedor',
      1: 'Mis Vehículos Publicados',
      2: 'Estadísticas',
      3: 'Perfil'
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF071082), Color(0xFF7B43CD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: _selectedIndex == 3
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundImage: AssetImage('images/logorental.png'),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Mi Perfil',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              )
            : Text(
                titles[_selectedIndex]!,
                style: const TextStyle(color: Colors.white),
              ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bienvenido, tu propósito es: $userPurpose',
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const PublicadosProveedor(),
          const Center(child: Text('Pantalla de Estadísticas', style: TextStyle(fontSize: 24))),
          const PaginaPerfilProveedor(),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
