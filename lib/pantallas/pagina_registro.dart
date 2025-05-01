  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';

  class RegistroPage extends StatelessWidget {
    const RegistroPage({super.key});

    //Este codigo le da los requriminetos minimos de la contraseña
    bool validarPassword(String password) {
      final RegExp regex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
      );
      return regex.hasMatch(password);
    }

    @override
    Widget build(BuildContext context) {
      final TextEditingController nombreController = TextEditingController();
      final TextEditingController emailController = TextEditingController();
      final TextEditingController passwordController = TextEditingController();
      final TextEditingController confirmPasswordController = TextEditingController();
      final TextEditingController telefonoController = TextEditingController();
      final TextEditingController fechaNacimientoController = TextEditingController();
      final TextEditingController direccionController = TextEditingController();

      Future<void> _selectDate(BuildContext context) async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );

        if (pickedDate != null) {
          fechaNacimientoController.text = '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
        }
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Registro'),
          backgroundColor: Colors.blue.shade900,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              const Text('Nombre'),
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(hintText: 'Tu nombre'),
              ),
              const SizedBox(height: 10),
              const Text('Correo'),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(hintText: 'example@gmail.com'),
              ),
              const SizedBox(height: 10),
              const Text('Número de teléfono'),
              TextField(
                controller: telefonoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: 'Número telefónico'),
              ),
              const SizedBox(height: 10),
              const Text('Fecha de nacimiento'),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    controller: fechaNacimientoController,
                    decoration: const InputDecoration(hintText: 'dd/mm/aaaa'),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text('Dirección'),
              TextField(
                controller: direccionController,
                decoration: const InputDecoration(hintText: 'Tu dirección'),
              ),
              const SizedBox(height: 10),
              const Text('Contraseña'),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: '******'),
              ),
              const SizedBox(height: 10),
              const Text('Confirmar Contraseña'),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: '******'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String nombre = nombreController.text.trim();
                  String correo = emailController.text.trim();
                  String telefono = telefonoController.text.trim();
                  String fechaNacimiento = fechaNacimientoController.text.trim();
                  String direccion = direccionController.text.trim();
                  String pass = passwordController.text;
                  String confirmPass = confirmPasswordController.text;

                  if (nombre.isEmpty ||
                      correo.isEmpty ||
                      telefono.isEmpty ||
                      fechaNacimiento.isEmpty ||
                      direccion.isEmpty ||
                      pass.isEmpty ||
                      confirmPass.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, completa todos los campos'),
                      ),
                    );
                  } else if (pass != confirmPass) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Las contraseñas no coinciden'),
                      ),
                    );
                  } else if (!validarPassword(pass)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'La contraseña debe tener al menos 8 caracteres, incluir mayúsculas, minúsculas, números y un símbolo especial.'),
                      ),
                    );
                  } else {
                    FirebaseFirestore.instance.collection('Usuarios').add({ //funcion guardar o registrar en la base de datos
                      'nombre': nombre,
                      'correo': correo,
                      'telefono': telefono,
                      'fechaNacimiento': fechaNacimiento,
                      'direccion': direccion,
                      'password': pass, 
                      'fechaRegistro': Timestamp.now(),
                    }).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Registro exitoso')),
                      );

                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.pop(context);
                      });
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al registrar: $error')),
                      );
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Registrarse',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
