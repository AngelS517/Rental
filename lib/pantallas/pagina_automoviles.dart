import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pagina_principal.dart';

class PaginaVehiculos extends StatefulWidget {
  final String? categoria;

  const PaginaVehiculos({super.key, this.categoria});

  @override
  State<PaginaVehiculos> createState() => _PaginaVehiculosState();
}

class _PaginaVehiculosState extends State<PaginaVehiculos> {
  String _sortOrder = 'default';

  void _onSortSelected(String value) {
    setState(() {
      _sortOrder = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String categoria =
        routeArgs != null && routeArgs.containsKey('categoria')
            ? routeArgs['categoria'] as String
            : widget.categoria ?? 'Automovil';

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('Vehiculos')
        .where('disponible', isEqualTo: true)
        .where('categoria', isEqualTo: categoria);

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
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset('imagenes/logorental.png', height: 40),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Lista de $categoria',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
                  return Center(
                    child: Text(
                      'No hay ${categoria.toLowerCase()} disponibles.',
                    ),
                  );
                }

                List<QueryDocumentSnapshot> vehiculos =
                    snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data.containsKey('precioPorDia') &&
                          data['precioPorDia'] is num &&
                          data.containsKey('placa') &&
                          data['placa'] is String;
                    }).toList();

                if (vehiculos.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay ${categoria.toLowerCase()} válidos disponibles.',
                    ),
                  );
                }

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
                    final placa = data['placa'] as String;

                    return vehiculoItem(
                      data['marca']?.toString() ?? 'Sin marca',
                      data['modelo']?.toString() ?? '',
                      data['precioPorDia']?.toDouble() ?? 0.0,
                      data['Propietario']?.toString() ?? 'Desconocido',
                      data['imagen'], // Pasamos el campo imagen directamente
                      data['direccion']?.toString() ?? 'No disponible',
                      data['ciudad']?.toString() ?? 'Ciudad desconocida',
                      data['detalles']?['tipoCombustible']?.toString() ??
                          'No especificado',
                      data['detalles']?['#pasajeros']?.toString() ?? 'N/A',
                      data['detalles']?['kilometraje']?.toString() ??
                          'No especificado',
                      calificacion,
                      placa,
                      null,
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF7B1FA2)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaginaPrincipal(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.arrow_back, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Volver',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget vehiculoItem(
    String marca,
    String modelo,
    double precioPorDia,
    String propietario,
    dynamic imagen, // Cambiado a dynamic para manejar String o List
    String direccion,
    String ciudad,
    String tipoCombustible,
    String numPasajeros,
    String kilometraje,
    double calificacion,
    String placa,
    Function(double)? onRatingSelected,
  ) {
    // Manejar imagen como String o List<dynamic>
    String imagenUrl;
    if (imagen is String) {
      imagenUrl = imagen;
    } else if (imagen is List<dynamic>) {
      imagenUrl = imagen.isNotEmpty ? imagen[0]?.toString() ?? '' : '';
    } else {
      imagenUrl = '';
    }

    final bool isValidUrl = imagenUrl.isNotEmpty &&
        (imagenUrl.startsWith('http://') || imagenUrl.startsWith('https://'));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: isValidUrl
                      ? Image.network(
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
                        )
                      : Container(
                          width: 90,
                          height: 90,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        modelo.isNotEmpty ? '$marca $modelo' : marca,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Propietario: $propietario',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_city,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              ciudad,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.local_gas_station,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              tipoCombustible,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.person, size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '$numPasajeros pasajeros',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.speed, size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              kilometraje,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '\$${precioPorDia.toStringAsFixed(0)} COP/Día',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return Icon(
                  starValue <= calificacion ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 24,
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/descripcion',
                      arguments: {'placa': placa},
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Ver Más'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}