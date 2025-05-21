
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final nombreController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final telefonoController = TextEditingController();
  final fechaNacimientoController = TextEditingController();
  final direccionController = TextEditingController();
  final barrioController = TextEditingController();
  final ciudadController = TextEditingController();

  String? ciudadSeleccionada;
  String? propositoSeleccionado;
  bool cargando = false;
  bool aceptaPolitica = false;

  bool validarPassword(String password) {
    final RegExp regex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
    );
    return regex.hasMatch(password);
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        fechaNacimientoController.text =
            '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
      });
    }
  }

  void mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  Future<void> registrarUsuario() async {
    final nombre = nombreController.text.trim();
    final correo = emailController.text.trim().toLowerCase();
    final telefono = telefonoController.text.trim();
    final fechaNacimiento = fechaNacimientoController.text.trim();
    final direccion = direccionController.text.trim();
    final barrio = barrioController.text.trim();
    final ciudad = ciudadController.text.trim();
    final pass = passwordController.text;
    final confirmPass = confirmPasswordController.text;

    if ([nombre, correo, telefono, fechaNacimiento, direccion, barrio, ciudad, pass, confirmPass].contains('') ||
        propositoSeleccionado == null) {
      mostrarMensaje('Por favor, completa todos los campos');
      return;
    }

    if (pass != confirmPass) {
      mostrarMensaje('Las contraseñas no coinciden');
      return;
    }

    if (!validarPassword(pass)) {
      mostrarMensaje(
          'La contraseña debe tener al menos 8 caracteres, incluir mayúsculas, minúsculas, números y un símbolo especial.');
      return;
    }

    if (!aceptaPolitica) {
      mostrarMensaje('Debes aceptar la política de privacidad para registrarte.');
      return;
    }

    setState(() => cargando = true);

    try {
      final signInMethods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(correo);
      if (signInMethods.isNotEmpty) {
        mostrarMensaje('El correo ya está registrado. Intenta iniciar sesión.');
        setState(() => cargando = false);
        return;
      }

      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: correo, password: pass);

      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(cred.user!.uid)
          .set({
        'nombre': nombre,
        'correo': correo,
        'telefono': telefono,
        'fechaNacimiento': fechaNacimiento,
        'direccion': direccion,
        'barrio': barrio,
        'ciudad': ciudad,
        'proposito': propositoSeleccionado,
        'fechaRegistro': Timestamp.now(),
        'password': pass,
      });

      mostrarMensaje('Registro exitoso');
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
    } catch (e) {
      mostrarMensaje('Error al registrar: ${e.toString()}');
    } finally {
      setState(() => cargando = false);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType tipo = TextInputType.text, bool esPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        obscureText: esPassword,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2E7F),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A2E7F), Color(0xFF1E2A6D)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Image.asset('imagenes/logorental.png', height: 60),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Registro',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A2E7F),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField('Nombre completo', nombreController),
                    _buildTextField('Correo electrónico', emailController,
                        tipo: TextInputType.emailAddress),
                    _buildTextField('Número telefónico', telefonoController,
                        tipo: TextInputType.phone),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: GestureDetector(
                        onTap: _selectDate,
                        child: AbsorbPointer(
                          child: TextField(
                            controller: fechaNacimientoController,
                            decoration: const InputDecoration(
                              labelText: 'Fecha de nacimiento',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildTextField('Dirección', direccionController),
                    _buildTextField('Barrio', barrioController),
                    _buildTextField('Ciudad', ciudadController),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Propósito'),
                      value: propositoSeleccionado,
                      items: ['Cliente', 'Proveedor']
                          .map((valor) => DropdownMenuItem(
                                value: valor,
                                child: Text(valor),
                              ))
                          .toList(),
                      onChanged: (valor) {
                        setState(() {
                          propositoSeleccionado = valor;
                        });
                      },
                    ),
                    _buildTextField('Contraseña', passwordController,
                        esPassword: true),
                    _buildTextField('Confirmar contraseña', confirmPasswordController,
                        esPassword: true),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: aceptaPolitica,
                          onChanged: (value) {
                            setState(() {
                              aceptaPolitica = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Al registrarte aceptas el uso de tus datos personales bajo la política de privacidad.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    cargando
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: aceptaPolitica ? registrarUsuario : null,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero, // Quitar padding para que el Ink controle el tamaño
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              side: const BorderSide(color: Colors.transparent),
                              elevation: 0,
                              foregroundColor: Colors.white,
                              overlayColor: Colors.white.withOpacity(0.1),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: aceptaPolitica ? null : Colors.grey,
                                gradient: aceptaPolitica
                                    ? const LinearGradient(
                                        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Registrarme',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
