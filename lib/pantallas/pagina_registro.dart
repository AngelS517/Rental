import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Añadido para usar Firebase Authentication
import 'login.dart'; // Añadido para la navegación

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
              onPressed: () async {
                String nombre = nombreController.text.trim();
                String correo = emailController.text.trim().toLowerCase(); // Estandarizar a minúsculas
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
                  return;
                }

                if (pass != confirmPass) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Las contraseñas no coinciden'),
                    ),
                  );
                  return;
                }

                if (!validarPassword(pass)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'La contraseña debe tener al menos 8 caracteres, incluir mayúsculas, minúsculas, números y un símbolo especial.'),
                    ),
                  );
                  return;
                }

                try {
                  print('Registrando usuario en Firebase Authentication con correo: $correo'); // Depuración
                  // Verificar si el correo ya está en uso (opcional, pero útil para depuración)
                  final signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(correo);
                  if (signInMethods.isNotEmpty) {
                    print('Correo ya registrado en Authentication: $signInMethods');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('El correo ya está en uso')),
                    );
                    return;
                  }

                  // Crear usuario en Firebase Authentication
                  UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: correo,
                    password: pass,
                  );
                  print('Usuario creado en Firebase Authentication con UID: ${userCredential.user!.uid}'); // Depuración

                  print('Guardando datos en Firestore para UID: ${userCredential.user!.uid}'); // Depuración
                  // Guardar datos en Firestore usando el UID del usuario
                  await FirebaseFirestore.instance.collection('Usuarios').doc(userCredential.user!.uid).set({
                    'nombre': nombre,
                    'correo': correo,
                    'telefono': telefono,
                    'fechaNacimiento': fechaNacimiento,
                    'direccion': direccion,
                    'password': pass, // Contraseña sin cifrar
                    'fechaRegistro': Timestamp.now(),
                  });
                  print('Datos guardados en Firestore'); // Depuración

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registro exitoso')),
                  );

                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  });
                } catch (e) {
                  print('Error al registrar: $e'); // Depuración
                  if (FirebaseAuth.instance.currentUser != null) {
                    await FirebaseAuth.instance.currentUser!.delete(); // Limpiar usuario si falla el registro
                    print('Usuario eliminado debido a error'); // Depuración
                  }
                  String errorMessage = 'Error al registrar';
                  if (e.toString().contains('email-already-in-use')) {
                    errorMessage = 'El correo ya está en uso';
                  } else if (e.toString().contains('invalid-email')) {
                    errorMessage = 'El correo no es válido';
                  } else if (e.toString().contains('weak-password')) {
                    errorMessage = 'La contraseña es demasiado débil';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$errorMessage: $e')),
                  );
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