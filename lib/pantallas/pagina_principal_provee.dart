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
  _PaginaPrincipalProveedorState createState() =>
      _PaginaPrincipalProveedorState();
}

class _PaginaPrincipalProveedorState extends State<PaginaPrincipalProveedor> {
  int _selectedIndex = 0;
  String? _uid;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF5A1EFF),
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _fetchCurrentUserUid();
  }

  Future<void> _fetchCurrentUserUid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _uid = user.uid;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final Map<int, String> titles = {
      0: 'Vehículos Rentados',
      1: 'Mis Vehículos Publicados',
      2: 'Estadísticas',
      3: 'Perfil',
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
        title: Text(
          titles[_selectedIndex]!,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _uid == null
              ? const Center(child: Text('No hay usuario autenticado.'))
              : _buildVehiculosNoDisponibles(),

          const PublicadosProveedor(),

          const Center(
            child: Text(
              'Pantalla de Estadísticas',
              style: TextStyle(fontSize: 24),
            ),
          ),

          const PaginaPerfilProveedor(),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildVehiculosNoDisponibles() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('Vehiculos')
              .where('proveedorUid', isEqualTo: _uid)
              .where('disponible', isEqualTo: false)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar los vehículos.'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final vehiculos = snapshot.data!.docs;

        if (vehiculos.isEmpty) {
          return const Center(
            child: Text('No tienes vehículos no disponibles.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: vehiculos.length,
          itemBuilder: (context, index) {
            final vehiculo = vehiculos[index];
            final data = vehiculo.data() as Map<String, dynamic>;

            final imagenUrl = data['imagen']?.toString() ?? '';
            final marca = data['marca']?.toString() ?? 'Desconocida';
            final modelo = data['modelo']?.toString() ?? 'Modelo desconocido';
            final precio =
                (data['precioPorDia'] != null)
                    ? double.tryParse(data['precioPorDia'].toString()) ?? 0.0
                    : 0.0;
            final categoria = data['categoria']?.toString() ?? 'N/A';
            final placa = data['placa']?.toString() ?? 'N/A';
            final direccion = data['direccion']?.toString() ?? 'N/A';
            final ciudad =
                data['ciudad']?.toString() ??
                'N/A'; // IMPORTANTE: Debe existir en Firestore
            final calificacion =
                double.tryParse(data['calificacion']?.toString() ?? '0.0') ??
                0.0;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8.0),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imagenUrl.isNotEmpty
                        ? imagenUrl
                        : 'https://via.placeholder.com/60',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
                title: Text(
                  '$marca $modelo',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Precio: \$${precio.toStringAsFixed(0)} COP/Día'),
                    Text('Categoría: $categoria'),
                    Text('Placa: $placa'),
                    Text('Dirección: $direccion'),
                    Row(children: _buildEstrellas(calificacion)),
                  ],
                ),
                trailing: TextButton(
                  child: const Text('Ubicación'),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/mapa_automovil',
                      arguments: {'direccion': direccion, 'ciudad': ciudad},
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Función para pintar las estrellas según la calificación (solo visualización)
  List<Widget> _buildEstrellas(double calificacion) {
    const totalEstrellas = 5;
    final estrellasLlenas = calificacion.floor();
    final medioPunto = (calificacion - estrellasLlenas) >= 0.5;

    List<Widget> estrellas = [];

    for (int i = 0; i < estrellasLlenas; i++) {
      estrellas.add(const Icon(Icons.star, color: Colors.amber, size: 20));
    }

    if (medioPunto) {
      estrellas.add(const Icon(Icons.star_half, color: Colors.amber, size: 20));
    }

    while (estrellas.length < totalEstrellas) {
      estrellas.add(
        const Icon(Icons.star_border, color: Colors.amber, size: 20),
      );
    }

    return estrellas;
  }
}