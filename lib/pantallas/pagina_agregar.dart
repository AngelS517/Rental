import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pagina_inicio.dart';

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
        'calificacion': int.tryParse(_formData['calificacion']),
        'categoria': _formData['categoria'],
        'ciudad': _formData['ciudad'],
        'descripcion': _formData['descripcion'],
        'direccion': _formData['direccion'],
        'dueno': _formData['dueno'],
        'imagen': _formData['imagen'],
        'marca': _formData['marca'],
        'modelo': int.tryParse(_formData['modelo']),
        'placa': _formData['placa'],
        'precio': double.tryParse(_formData['precio']),
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo agregado exiitosamente')),
      );

      // ✅ Redirección después de guardar exitosamente
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PaginaInicio()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Vehículo'),
        backgroundColor: Colors.blue.shade900,
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
                    _guardarEnFirebase(); // Guarda primero, y luego redirige
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade900),
                child: const Text('Guardar en Firebase'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
