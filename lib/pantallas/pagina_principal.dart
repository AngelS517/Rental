import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rental/widgets/custom_widgets.dart';
import 'pagina_automoviles.dart';
import 'pagina_motos.dart';

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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF5A1EFF),
      statusBarIconBrightness: Brightness.light,
    ));
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      // Inicio
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Parte superior con gradiente y solo el logo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5A1EFF), Color(0xFF9445F3)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
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
                        return const Icon(Icons.person, size: 40, color: Colors.grey);
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
                        categoriaItem(context, 'imagenes/auto.png', 'Automóvil', true),
                        categoriaItem(context, 'imagenes/minivan.png', 'Minivan', false),
                        categoriaItem(context, 'imagenes/moto.png', 'Moto', false),
                        categoriaItem(context, 'imagenes/electricos.png', 'Electricos', false),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ofertas',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ofertaItem('Chevrolet Kia', 'Dueño: Juan Sebastián', 'assets/carro1.png'),
                    ofertaItem('Camioneta', 'Dueño: Ángel Santiago', 'assets/carro2.png'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget categoriaItem(BuildContext context, String imagenPath, String titulo, bool esAutomovil) {
    return GestureDetector(
      onTap: () {
        if (esAutomovil) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PaginaVehiculos()),
          );
        } else if (titulo == 'Moto') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PaginaMotos()),
          );
        }
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

  Widget ofertaItem(String titulo, String propietario, String imagen) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Image.asset(
          imagen,
          width: 50,
          height: 50,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
          },
        ),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(propietario),
        trailing: const Icon(Icons.local_offer, color: Colors.orange),
      ),
    );
  }
}
