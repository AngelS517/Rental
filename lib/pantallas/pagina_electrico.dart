import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rental/widgets/custom_widgets.dart';
import 'pagina_descripcion_vehiculo.dart';

class PaginaElectrico extends StatefulWidget {
  const PaginaElectrico({super.key});

  @override
  State<PaginaElectrico> createState() => _PaginaElectricoState();
}

class _PaginaElectricoState extends State<PaginaElectrico> {
  int _selectedIndex = 0;
  String _sortOrder = 'default';

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushNamed(context, '/inicio');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/mapa');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/favoritos');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/perfil');
    }
  }

  void _onSortSelected(String value) {
    setState(() {
      _sortOrder = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('Vehiculos')
        .where('categoria', isEqualTo: 'Electrico');

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF7B1FA2)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('imagenes/logorental.png', height: 40),
                ),
                const Text(
                  'Lista de Vehículos Eléctricos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, right: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                icon: Image.asset('imagenes/categoria.png', height: 32),
                onSelected: _onSortSelected,
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'asc',
                        child: Text('Más barato a caro'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'desc',
                        child: Text('Más caro a barato'),
                      ),
                    ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No hay vehículos eléctricos disponibles.'),
                  );
                }

                List<QueryDocumentSnapshot> vehiculos =
                    snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data.containsKey('precioPorDia') &&
                          (data['precioPorDia'] is num);
                    }).toList();

                if (_sortOrder != 'default') {
                  vehiculos.sort((a, b) {
                    final dataA = a.data() as Map<String, dynamic>;
                    final dataB = b.data() as Map<String, dynamic>;
                    final precioA = dataA['precioPorDia'].toDouble();
                    final precioB = dataB['precioPorDia'].toDouble();
                    return _sortOrder == 'asc'
                        ? precioA.compareTo(precioB)
                        : precioB.compareTo(precioA);
                  });
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vehiculos.length,
                  itemBuilder: (context, index) {
                    final data =
                        vehiculos[index].data() as Map<String, dynamic>;
                    final calificacion =
                        data['calificacion'] is double
                            ? data['calificacion'] as double
                            : (data['calificacion'] as num?)?.toDouble() ?? 0.0;
                    final placa = data['placa']?.toString() ?? '';
                    return vehiculoItem(
                      data['marca']?.toString() ?? 'Sin marca',
                      data['modelo']?.toString() ?? '',
                      data['precioPorDia']?.toDouble() ?? 0.0,
                      data['Propietario']?.toString() ?? 'Desconocido',
                      data['imagen']?.toString() ?? '',
                      data['direccion']?.toString() ??
                          'Dirección no disponible',
                      data['ciudad']?.toString() ?? 'Ciudad no disponible',
                      data['detalles']?['tipoCombustible']?.toString() ??
                          'No especificado',
                      data['detalles']?['#pasajeros']?.toString() ?? 'N/A',
                      data['detalles']?['kilometraje']?.toString() ??
                          'No especificado',
                      calificacion,
                      placa,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget vehiculoItem(
    String marca,
    String modelo,
    double precioPorDia,
    String propietario,
    String imagenUrl,
    String direccion,
    String ciudad,
    String tipoCombustible,
    String numPasajeros,
    String kilometraje,
    double calificacion,
    String placa,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imagenUrl.isNotEmpty
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imagenUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
                : Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.directions_car, size: 80),
                  ),
                ),
            const SizedBox(height: 12),
            Text(
              '$marca $modelo',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Propietario: $propietario'),
            Text('Ciudad: $ciudad'),
            Text('Dirección: $direccion'),
            Text('Tipo: $tipoCombustible | Pasajeros: $numPasajeros'),
            Text('Kilometraje: $kilometraje'),
            Text('Precio por día: \$${precioPorDia.toStringAsFixed(2)}'),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < calificacion.round() ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
