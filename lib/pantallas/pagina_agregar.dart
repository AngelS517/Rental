import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pagina_principal.dart';

class PaginaAgregar extends StatefulWidget {
  const PaginaAgregar({super.key});

  @override
  State<PaginaAgregar> createState() => _PaginaAgregarState();
}

class _PaginaAgregarState extends State<PaginaAgregar> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _calificacionController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _duenoController = TextEditingController();
  final TextEditingController _imagenController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();

  String? _categoriaSeleccionada;

  Future<void> _registrarVehiculo() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('Vehiculos').add({
          'Calificacion': _calificacionController.text,
          'Categoria': _categoriaSeleccionada,
          'Ciudad': _ciudadController.text,
          'Descripcion': _descripcionController.text,
          'Direccion': _direccionController.text,
          'Dueño': _duenoController.text,
          'Imagen': _imagenController.text,
          'Marca': _marcaController.text,
          'Modelo': _modeloController.text,
          'Placa': _placaController.text,
          'Precio': _precioController.text,
        });

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PaginaPrincipal()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Vehículo'),
        backgroundColor: const Color(0xFF071082),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              campoTexto('Calificación', _calificacionController),
              dropdownCategoria(),
              campoTexto('Ciudad', _ciudadController),
              campoTexto('Descripción', _descripcionController),
              campoTexto('Dirección', _direccionController),
              campoTexto('Dueño', _duenoController),
              campoTexto('Imagen (URL)', _imagenController),
              campoTexto('Marca', _marcaController),
              campoTexto('Modelo', _modeloController),
              campoTexto('Placa', _placaController),
              campoTexto('Precio', _precioController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registrarVehiculo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF050272),
                ),
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
      // Agregamos el FloatingActionButton aquí
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context); // Regresa a la pantalla anterior
        },
        child: const Icon(Icons.arrow_back),
        backgroundColor: const Color(0xFF6A11CB),
      ),
    );
  }

  Widget campoTexto(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Campo requerido' : null,
      ),
    );
  }

  Widget dropdownCategoria() {
    final categorias = ['Automoviles', 'Minivan', 'Motocicletas', 'Electricos'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Categoría',
          border: OutlineInputBorder(),
        ),
        value: _categoriaSeleccionada,
        onChanged: (value) {
          setState(() {
            _categoriaSeleccionada = value;
          });
        },
        items: categorias.map((categoria) {
          return DropdownMenuItem(
            value: categoria,
            child: Text(categoria),
          );
        }).toList(),
        validator: (value) =>
            value == null || value.isEmpty ? 'Seleccione una categoría' : null,
      ),
    );
  }
}