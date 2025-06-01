import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Pantallas
import 'pantallas/login.dart';
import 'pantallas/pagina_principal.dart';
import 'pantallas/pagina_mapa.dart';
import 'pantallas/pagina_perfil.dart';
import 'pantallas/pagina_favoritos.dart';
import 'pantallas/pagina_automoviles.dart';
import 'pantallas/mapa_automovil.dart';
import 'pantallas/pagina_principal_provee.dart';
import 'pantallas/pagina_descripcion_vehiculo.dart'; // Añadida para la redirección

// Importación de Mapbox
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Configurar el token de acceso de Mapbox
  MapboxOptions.setAccessToken(
    'pk.eyJ1IjoiYW5nZWwtMDUiLCJhIjoiY21hc3JyYWUzMHJlOTJscHljd3Iyazg1bCJ9.pAS16n8E-QNtgpfOKoMfYw', // Reemplaza con tu token real
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rental App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login', // cambiar para solo cambiar la animacion
      routes: {
        '/login': (context) => const LoginPage(),
        '/principal': (context) => const PaginaPrincipal(),
        '/mapa': (context) => const PaginaMapa(),
        '/favoritos': (context) => const PaginaFavoritos(),
        '/perfil': (context) => const PaginaPerfilCliente(),
        '/vehiculos': (context) => const PaginaVehiculos(),
        '/mapa_automovil': (context) => const MapaAutomovil(),
        '/proveedor': (context) => const PaginaPrincipalProveedor(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/descripcion') {
          final args = settings.arguments as Map<String, dynamic>?;
          final placa = args?['placa']?.toString() ?? '';
          return MaterialPageRoute(
            builder: (context) => PaginaDescripcionVehiculo(placa: placa),
          );
        }
        return null; // Dejar que las rutas definidas en routes manejen las demás
      },
    );
  }
}