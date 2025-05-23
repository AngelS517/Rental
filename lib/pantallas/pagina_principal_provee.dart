import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rental/widgets/custom_widgets_proveedor.dart';
import 'global.dart';
import 'pagina_perfil.dart';
import 'publicados_proveedor.dart';

class PaginaPrincipalProveedor extends StatefulWidget {
  const PaginaPrincipalProveedor({super.key});

  @override
  _PaginaPrincipalProveedorState createState() => _PaginaPrincipalProveedorState();
}

class _PaginaPrincipalProveedorState extends State<PaginaPrincipalProveedor> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF5A1EFF),
      statusBarIconBrightness: Brightness.light,
    ));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Inicio (mantener la pantalla actual)
    } else if (index == 1) {
      // Publicados (ya se muestra en el IndexedStack)
    } else if (index == 2) {
      Navigator.pushNamed(context, '/estadisticas');
    } else if (index == 3) {
      // Perfil (ya se muestra en el IndexedStack)
    }
  }

  @override
  Widget build(BuildContext context) {
    // Títulos dinámicos para los índices que no son "Perfil"
    final Map<int, String> titles = {
      0: 'Página Principal - Proveedor',
      1: 'Mis Vehículos Publicados',
      2: 'Estadísticas',
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
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: const AssetImage('imagenes/logorental.png'),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: const Text(
                        'Mi Perfil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Espacio para balancear el diseño
                ],
              )
            : Text(
                titles[_selectedIndex] ?? 'Página Principal - Proveedor',
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
                  'Bienvenido, tu propósito es: $propositoUsuarioGlobal',
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const PublicadosProveedor(),
          const Center(child: Text('Pantalla de Estadísticas', style: TextStyle(fontSize: 24))),
          const PaginaPerfil(),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}