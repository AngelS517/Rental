import 'package:flutter/material.dart';

class RegistroPage extends StatelessWidget {
  const RegistroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final TextEditingController telefonoController = TextEditingController();
    final TextEditingController fechaNacimientoController =
        TextEditingController();
    final TextEditingController direccionController = TextEditingController();

    // Función para seleccionar la fecha
    Future<void> _selectDate(BuildContext context) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );

      if (pickedDate != null) {
        // Formatear la fecha como dd/mm/yyyy
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
              decoration: const InputDecoration(hintText: 'numero telefonico'),
            ),
            const SizedBox(height: 10),
            const Text('Fecha de nacimiento'),
            GestureDetector(
              onTap: () => _selectDate(context), // Abre el DatePicker
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
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registro exitoso')),
                  );

                  // Esperar un momento para mostrar el mensaje, luego regresar
                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.pop(context); // volver al login
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


