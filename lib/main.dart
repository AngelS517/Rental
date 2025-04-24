import 'package:flutter/material.dart';
import 'pantallas/login.dart';
import 'pantallas/pagina_principal.dart';
import 'pantallas/pagina_mapa.dart';
import 'pantallas/pagina_perfil.dart';
import 'pantallas/pagina_favoritos.dart';
import 'pantallas/pagina_automoviles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pantallas/mapa_automovil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/inicio': (context) => const PaginaPrincipal(),
        '/mapa': (context) => const PaginaMapa(),
        '/perfil': (context) => const PaginaPerfil(),
        '/favoritos': (context) => const PaginaFavoritos(),
        '/vehiculos': (context) => const PaginaVehiculos(),
        '/mapa_automovil': (context) => const MapaAutomovil(),
      },
    );
  }
}