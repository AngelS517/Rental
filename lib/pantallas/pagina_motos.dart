// Importación de paquetes necesarios para Flutter, Firestore y componentes personalizados
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rental/widgets/custom_widgets.dart'; 

// Componente principal que muestra la lista de motocicletas
class PaginaMotos extends StatefulWidget {
  const PaginaMotos({super.key}); //constructor

  @override
  State<PaginaMotos> createState() => _PaginaMotosState(); // Crea el estado para el widget
}

// Estado de la página de motocicletas
class _PaginaMotosState extends State<PaginaMotos> {
  int _selectedIndex = 0; // Índice del ítem seleccionado en la barra inferior

  // Método que maneja la navegación al tocar un ítem de la barra inferior
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior
      appBar: AppBar(
        title: const Text('Lista de Motocicletas'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.blue.shade900,
        automaticallyImplyLeading: false,
      ),

      // Cuerpo principal: StreamBuilder escucha los cambios en Firestore en tiempo real
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Vehiculos')
            .where('categoria', isEqualTo: 'Moto')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay motocicletas disponibles.'));
          }

          final vehiculos = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vehiculos.length,
            itemBuilder: (context, index) {
              final data = vehiculos[index].data() as Map<String, dynamic>;
              return vehiculoItem(
                data['Marca'] ?? 'Sin marca',
                'Dueño: ${data['Dueño'] ?? 'Desconocido'}',
                data['Imagen'] ?? '',
                data['Direccion'] ?? 'Dirección no disponible',
                data['Ciudad'] ?? 'Ciudad no disponible',
              );
            },
          );
        },
      ),

      // Barra de navegación inferior personalizada
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // Widget personalizado para mostrar cada tarjeta de motocicleta con botón "Ver ubicación"
  Widget vehiculoItem(
    String titulo,
    String propietario,
    String imagenUrl,
    String direccion,
    String ciudad,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imagenUrl,
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
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(propietario),
            trailing: const Icon(Icons.local_offer, color: Colors.orange),
          ),

          // Botón "Ver ubicación"
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton.icon(
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
              icon: const Icon(Icons.location_on),
              label: const Text('Ver ubicación'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
