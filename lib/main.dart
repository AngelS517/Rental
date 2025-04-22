import 'package:flutter/material.dart';
import 'pantallas/login.dart';
import 'pantallas/pagina_principal.dart';
import 'pantallas/pagina_mapa.dart';
import 'pantallas/pagina_perfil.dart';
import 'pantallas/pagina_favoritos.dart';
import 'pantallas/pagina_automoviles.dart';

void main() {
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
      },
    );
  }
}
