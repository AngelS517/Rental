import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pagina_mapa.dart';
import 'pagina_favoritos.dart';
import 'pagina_perfil.dart';
import 'dart:async';
import 'package:rental/widgets/custom_widgets.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  _PaginaPrincipalState createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  int _selectedIndex = 0;

  late Stream<QuerySnapshot<Map<String, dynamic>>> _ofertasStream;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      _ofertasSubscription;
  bool _mostrarBotonRecargar = false;
  bool _isLoading = true; // Track initial loading state
  bool _hasInitialized = false; // Prevent multiple initializations

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Ensure initialization happens only once
    if (!_hasInitialized) {
      // Add a delay to allow Firestore and session to stabilize
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasInitialized = true;
          });
        }
      });

      // Initialize stream with error handling
      _ofertasStream = _crearStreamOfertas().handleError((error, stackTrace) {
        print('Error en el stream de ofertas: $error');
        if (mounted) {
          setState(() {
            _mostrarBotonRecargar = true;
            _isLoading = false; // Ensure loading stops on error
          });
        }
      });

      _ofertasSubscription = FirebaseFirestore.instance
          .collection('Vehiculos')
          .snapshots()
          .debounceTime(const Duration(seconds: 1))
          .handleError((error, stackTrace) {
            print('Error en la suscripción: $error');
            if (mounted) {
              setState(() {
                _mostrarBotonRecargar = true;
                _isLoading = false; // Ensure loading stops on error
              });
            }
          })
          .listen((_) {
            if (mounted) {
              setState(() {
                _mostrarBotonRecargar = true;
              });
            }
          });

      _hasInitialized = true;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _crearStreamOfertas() {
    return FirebaseFirestore.instance
        .collection('Vehiculos')
        .where('precioPorDia', isLessThan: 26000)
        .where('disponible', isEqualTo: true)
        .snapshots()
        .debounceTime(const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _ofertasSubscription.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildPaginaPrincipal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Categorías',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.2,
            children: [
              categoriaItem(
                context,
                'imagenes/auto.png',
                'Automóvil',
                'Automovil',
              ),
              categoriaItem(
                context,
                'imagenes/minivan.png',
                'Minivan',
                'Minivan',
              ),
              categoriaItem(context, 'imagenes/moto.png', 'Moto', 'Moto'),
              categoriaItem(
                context,
                'imagenes/electricos.png',
                'Eléctricos',
                'Electrico',
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Ofertas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            StreamBuilder(
              stream: _ofertasStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar las ofertas'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay vehículos en oferta'));
                }

                final vehiculos = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vehiculos.length,
                  itemBuilder: (context, index) {
                    final v = vehiculos[index];
                    final modelo =
                        v['modelo']?.toString() ?? 'Modelo desconocido';
                    final propietario =
                        v['Propietario']?.toString() ?? 'Sin propietario';
                    final precio =
                        v['precioPorDia'] != null
                            ? (v['precioPorDia'] is num
                                ? (v['precioPorDia'] as num).toDouble()
                                : 0.0)
                            : 0.0;
                    // Handle imagen as either a String or List<dynamic>
                    dynamic imagen = v['imagen'];
                    String imagenUrl;
                    if (imagen is String) {
                      imagenUrl = imagen;
                    } else if (imagen is List<dynamic>) {
                      imagenUrl = imagen.isNotEmpty ? imagen[0]?.toString() ?? '' : '';
                    } else {
                      imagenUrl = '';
                    }
                    final marca =
                        v.data().containsKey('marca')
                            ? v['marca'].toString()
                            : 'Marca desconocida';
                    final placa =
                        v.data().containsKey('placa')
                            ? v['placa'].toString()
                            : 'Sin placa';

                    return ofertaItemFirestore(
                      propietario,
                      modelo,
                      precio,
                      imagenUrl,
                      marca,
                      placa,
                    );
                  },
                );
              },
            ),
          const SizedBox(height: 20),

          // Botón de recargar ofertas (solo visible cuando corresponde)
          if (_mostrarBotonRecargar)
            Center(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7b43cd), Color(0xFF071082)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _ofertasStream = _crearStreamOfertas();
                      _mostrarBotonRecargar = false;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Cargar Ofertas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // Hacer transparente
                    foregroundColor: Colors.white,
                    shadowColor:
                        Colors
                            .transparent, // Quitar sombra para unificar visualmente
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget categoriaItem(
    BuildContext context,
    String imagenPath,
    String titulo,
    String categoria,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/vehiculos',
          arguments: {'categoria': categoria},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF050272),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagenPath, height: 50),
            const SizedBox(height: 10),
            Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ofertaItemFirestore(
    String propietario,
    String modelo,
    double precio,
    String imagenUrl,
    String marca,
    String placa,
  ) {
    final bool isValidUrl =
        imagenUrl.isNotEmpty &&
        (imagenUrl.startsWith('http://') || imagenUrl.startsWith('https://'));
    final modeloSinAnio =
        modelo.contains(' ')
            ? modelo.substring(0, modelo.lastIndexOf(' '))
            : modelo;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          ListTile(
            leading:
                isValidUrl
                    ? Image.network(
                      imagenUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.directions_car,
                          size: 50,
                          color: Colors.blue,
                        );
                      },
                    )
                    : const Icon(
                      Icons.directions_car,
                      size: 50,
                      color: Colors.blue,
                    ),
            title: Text(
              '$marca $modeloSinAnio',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Propietario: $propietario'),
            trailing: Text(
              '\$${precio.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/descripcion',
                  arguments: {'placa': placa},
                );
              },
              child: const Text('Ver más'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<int, String> titles = {
      0: 'Página Principal ',
      1: 'Mapa',
      2: 'Vehiculos Alquilados',
      3: 'Mi Perfil',
    };

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Image.asset('imagenes/logorental.png', height: 36),
          ),
        ),
        title: Text(
          titles[_selectedIndex]!,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF071082), Color(0xFF7b43cd)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildPaginaPrincipal(),
          const PaginaMapa(),
          const PaginaFavoritos(),
          const PaginaPerfilCliente(),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}