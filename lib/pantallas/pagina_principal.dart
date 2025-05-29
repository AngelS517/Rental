import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rental/widgets/custom_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pagina_mapa.dart';
import 'pagina_favoritos.dart';
import 'pagina_perfil.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({super.key});

  @override
  _PaginaPrincipalState createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor:
            Colors.transparent, // Hacer la barra de estado transparente para que el gradiente la cubra
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildPaginaPrincipal() {
    return Column(
      children: [
        // Parte superior con gradiente extendido hasta la barra de estado
        Container(
          width: double.infinity,
          height:
              MediaQuery.of(context).padding.top +
              80, // Ajustar para incluir la barra de estado
          padding: EdgeInsets.only(
            top:
                MediaQuery.of(context).padding.top, // Espacio para la barra de estado
            left: 16,
            right: 16,
            bottom: 20,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7b43cd), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 45,
              height: 45,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'imagenes/logorental.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        // Contenido desplazable
        Expanded(
          child: SingleChildScrollView(
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
                    categoriaItem(
                      context,
                      'imagenes/moto.png',
                      'Moto',
                      'Moto',
                    ),
                    categoriaItem(
                      context,
                      'imagenes/electricos.png',
                      'Electricos',
                      'Electrico',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                const Text(
                  'Ofertas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                StreamBuilder(
                  stream:
                      FirebaseFirestore.instance
                          .collection('Vehiculos')
                          .where('precioPorDia', isLessThan: 26000)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text('No hay vehículos en oferta');
                    }

                    final vehiculos = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vehiculos.length,
                      itemBuilder: (context, index) {
                        final v = vehiculos[index];
                        // Manejo más seguro de los campos para evitar errores
                        final modelo = v['modelo'] != null
                            ? v['modelo'].toString()
                            : 'Modelo desconocido';
                        final propietario = v['Propietario']?.toString() ?? 'Sin propietario';
                        final precio = v['precioPorDia'] != null
                            ? (v['precioPorDia'] is num
                                ? (v['precioPorDia'] as num).toDouble()
                                : 0.0)
                            : 0.0;
                        final imagenUrl = v.data().containsKey('imagen')
                            ? v['imagen'].toString()
                            : '';
                        final marca = v.data().containsKey('marca')
                            ? v['marca'].toString()
                            : 'Marca desconocida';

                        return ofertaItemFirestore(
                          propietario,
                          modelo,
                          precio,
                          imagenUrl,
                          marca,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
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
        // Usar Navigator.pushNamed y pasar la categoría como argumento
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

  Widget ofertaItemFirestore(String propietario, String modelo, double precio, String imagenUrl, String marca) {
    // Validar si el URL es potencialmente válido (comienza con http o https)
    final bool isValidUrl = imagenUrl.isNotEmpty && (imagenUrl.startsWith('http://') || imagenUrl.startsWith('https://'));

    // Quitar el año de 'modelo' (asumiendo que el año es la última palabra después de un espacio)
    final modeloSinAnio = modelo.contains(' ')
        ? modelo.substring(0, modelo.lastIndexOf(' '))
        : modelo;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: isValidUrl
            ? Image.network(
                imagenUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.directions_car, size: 50, color: Colors.blue);
                },
              )
            : const Icon(Icons.directions_car, size: 50, color: Colors.blue),
        title: Text(
          '$marca $modeloSinAnio', // Mostrar la marca y el modelo sin el año
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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