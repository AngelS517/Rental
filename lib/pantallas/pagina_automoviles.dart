import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rental/widgets/custom_widgets.dart';

class PaginaVehiculos extends StatefulWidget {
  const PaginaVehiculos({super.key});

  @override
  State<PaginaVehiculos> createState() => _PaginaVehiculosState();
}

class _PaginaVehiculosState extends State<PaginaVehiculos> {
  int _selectedIndex = 0;
  String _sortOrder = 'default'; // 'default', 'asc', 'desc'

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
    // Consulta base sin orderBy para evitar el índice compuesto
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('Vehiculos')
        .where('categoria', isEqualTo: 'Automovil');

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
                  child: Image.asset(
                    'imagenes/logorental.png',
                    height: 40,
                  ),
                ),
                const Text(
                  'Lista de Automóviles',
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
                icon: Image.asset(
                  'imagenes/categoria.png',
                  height: 32,
                ),
                onSelected: _onSortSelected,
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
                  return const Center(child: Text('No hay automóviles disponibles.'));
                }

                // Filtrar documentos válidos (asegurarse de que precioPorDia exista y sea numérico)
                List<QueryDocumentSnapshot> vehiculos = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data.containsKey('precioPorDia') && (data['precioPorDia'] is num);
                }).toList();

                if (vehiculos.isEmpty) {
                  return const Center(child: Text('No hay automóviles con precios válidos.'));
                }

                // Ordenar los vehículos en el cliente según el precioPorDia
                if (_sortOrder != 'default') {
                  vehiculos.sort((a, b) {
                    final dataA = a.data() as Map<String, dynamic>;
                    final dataB = b.data() as Map<String, dynamic>;
                    final precioA = dataA['precioPorDia'].toDouble();
                    final precioB = dataB['precioPorDia'].toDouble();
                    return _sortOrder == 'asc'
                        ? precioA.compareTo(precioB) // Menor a mayor
                        : precioB.compareTo(precioA); // Mayor a menor
                  });
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vehiculos.length,
                  itemBuilder: (context, index) {
                    final data = vehiculos[index].data() as Map<String, dynamic>;
                    final calificacion = data['calificacion'] is double
                        ? data['calificacion'] as double
                        : (data['calificacion'] as num?)?.toDouble() ?? 0.0;
                    return vehiculoItem(
                      data['marca']?.toString() ?? 'Sin marca',
                      data['modelo']?.toString() ?? '',
                      data['precioPorDia']?.toDouble() ?? 0.0,
                      data['Propietario']?.toString() ?? 'Desconocido',
                      data['imagen']?.toString() ?? '',
                      data['direccion']?.toString() ?? 'Dirección no disponible',
                      data['ciudad']?.toString() ?? 'Ciudad no disponible',
                      data['detalles']?['tipoCombustible']?.toString() ?? 'No especificado',
                      data['detalles']?['#pasajeros']?.toString() ?? 'N/A',
                      data['detalles']?['kilometraje']?.toString() ?? 'No especificado',
                      calificacion,
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
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del vehículo
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imagenUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 90,
                        height: 90,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Detalles del vehículo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título (Marca y Modelo)
                      Text(
                        modelo.isNotEmpty ? '$marca $modelo' : marca,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Propietario
                      Text(
                        'Propietario: $propietario',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Ciudad
                      Row(
                        children: [
                          Icon(Icons.location_city, size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              ciudad,
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Tipo de Combustible y Pasajeros
                      Row(
                        children: [
                          Icon(Icons.local_gas_station, size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              tipoCombustible,
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.person, size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '$numPasajeros pasajeros',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Kilometraje
                      Row(
                        children: [
                          Icon(Icons.speed, size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              kilometraje,
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Precio y Calificación
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '\$${precioPorDia.toStringAsFixed(0)} COP/Día',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    if (index < calificacion.floor()) {
                      return const Icon(Icons.star, color: Colors.amber, size: 16);
                    } else if (index < calificacion && index >= calificacion.floor()) {
                      return const Icon(Icons.star_half, color: Colors.amber, size: 16);
                    } else {
                      return const Icon(Icons.star_border, color: Colors.grey, size: 16);
                    }
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/mapa_automovil',
                      arguments: {
                        'direccion': direccion,
                        'ciudad': ciudad,
                        'pais': 'Colombia',
                      },
                    );
                  },
                  icon: const Icon(Icons.location_on, size: 16),
                  label: const Text('Ubicación'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implementar navegación o lógica para ver detalles
                  },
                  child: const Text('Ver Detalles'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}