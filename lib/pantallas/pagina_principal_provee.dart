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
      3: 'Mi Perfil'
    };

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Image.asset(
              'imagenes/logorental.png',
              height: 36,
            ),
          ),
        ),
        title: Text(
          titles[_selectedIndex]!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5A1EFF),
        elevation: 0,
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