import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rental/widgets/custom_widgets.dart';
import 'pagina_principal.dart'; // Cambiado de pagina_inicio.dart

class PaginaAgregar extends StatefulWidget {
  const PaginaAgregar({super.key});

  @override
  State<PaginaAgregar> createState() => _PaginaAgregarState();
}

class _PaginaAgregarState extends State<PaginaAgregar> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'calificacion': '',
    'categoria': '',
    'ciudad': '',
    'descripcion': '',
    'direccion': '',
    'dueno': '',
    'imagen': '',
    'marca': '',
    'modelo': '',
    'placa': '',
    'precio': '',
  };

  Future<void> _guardarEnFirebase() async {
    try {
      await FirebaseFirestore.instance.collection('Vehiculos').add({
        'Calificacion': int.tryParse(_formData['calificacion']),
        'Categoria': _formData['categoria'],
        'Ciudad': _formData['ciudad'],
        'Descripcion': _formData['descripcion'],
        'Direccion': _formData['direccion'],
        'Dueño': _formData['dueno'],
        'Imagen': _formData['imagen'],
        'Marca': _formData['marca'],
        'Modelo': int.tryParse(_formData['modelo']),
        'Placa': _formData['placa'],
        'Precio': double.tryParse(_formData['precio']),
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo agregado exitosamente')),
      );

      // Redirección a PaginaPrincipal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PaginaPrincipal()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  Widget _campoTexto(String label, String clave, {TextInputType tipo = TextInputType.text}) {
    return TextFormField(
      keyboardType: tipo,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value == null || value.isEmpty ? 'Campo obligatorio' : null,
      onSaved: (value) => _formData[clave] = value ?? '',
    );
  }

  void _onItemTapped(int index) {
    Navigator.pushReplacementNamed(context, _getRouteForIndex(index));
  }

  String _getRouteForIndex(int index) {
    switch (index) {
      case 0:
        return '/inicio';
      case 1:
        return '/mapa';
      case 2:
        return '/perfil';
      case 3:
        return '/favoritos';
      default:
        return '/inicio';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Vehículo'),
        backgroundColor: Colors.blue.shade900,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _campoTexto('Calificación', 'calificacion', tipo: TextInputType.number),
              _campoTexto('Categoría', 'categoria'),
              _campoTexto('Ciudad', 'ciudad'),
              _campoTexto('Descripción', 'descripcion'),
              _campoTexto('Dirección', 'direccion'),
              _campoTexto('Dueño', 'dueno'),
              _campoTexto('Imagen (URL)', 'imagen'),
              _campoTexto('Marca', 'marca'),
              _campoTexto('Modelo', 'modelo', tipo: TextInputType.number),
              _campoTexto('Placa', 'placa'),
              _campoTexto('Precio', 'precio', tipo: TextInputType.number),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _guardarEnFirebase();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900),
                child: const Text('Guardar en Firebase'),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: -1,
        onTap: _onItemTapped,
      ),
    );
  }
}