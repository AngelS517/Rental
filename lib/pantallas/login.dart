import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pagina_principal.dart';
import 'pagina_principal_provee.dart';
import 'pagina_registro.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true; // Estado para mostrar/ocultar contraseña

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Center(child: Image.asset('imagenes/logorental.png', height: 120)),
            const SizedBox(height: 20),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0A0C58),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(80),
                  bottomLeft: Radius.circular(80),
                ),
              ),
              padding: const EdgeInsets.only(
                left: 30,
                right: 30,
                top: 40,
                bottom: 80,
              ),
              child: Column(
                children: [
                  const Text(
                    'Rental',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Bienvenido',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Correo:',
                      labelStyle: const TextStyle(color: Colors.white),
                      hintText: 'Juanchito@gmail.com',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF4B4EAB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20), // Espacio consistente
                      floatingLabelBehavior: FloatingLabelBehavior.auto, // Animación natural
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    obscureText: _obscureText, // Controlar si se muestra u oculta
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Contraseña:',
                      labelStyle: const TextStyle(color: Colors.white),
                      hintText: '******',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF4B4EAB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20), // Espacio consistente, ajustado para el icono
                      floatingLabelBehavior: FloatingLabelBehavior.auto, // Animación natural
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility, // Mantenido como está
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText; // Alternar entre mostrar y ocultar
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF071082), Color(0xFF7B43CD)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          String email = emailController.text.trim().toLowerCase();
                          String password = passwordController.text.trim();

                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Por favor, ingresa tu correo y contraseña',
                                ),
                              ),
                            );
                            return;
                          }

                          try {
                            print(
                              'Intentando iniciar sesión con email: $email y password: $password',
                            );

                            UserCredential userCredential = await FirebaseAuth
                                .instance
                                .signInWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                );
                            print(
                              'Usuario autenticado con UID: ${userCredential.user!.uid}',
                            );

                            DocumentSnapshot doc = await FirebaseFirestore.instance
                                .collection('Usuarios')
                                .doc(userCredential.user!.uid)
                                .get();

                            if (doc.exists) {
                              print(
                                'Usuario encontrado en Firestore: ${doc.data()}',
                              );

                              Map<String, dynamic> datos = doc.data() as Map<String, dynamic>;
                              String proposito = datos['proposito']?.toLowerCase() ?? '';

                              // Redirigir según el propósito
                              if (proposito == 'proveedor') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PaginaPrincipalProveedor(),
                                  ),
                                );
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PaginaPrincipal(),
                                  ),
                                );
                              }
                            } else {
                              print('Usuario no encontrado en Firestore');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Usuario no encontrado en Firestore',
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            print('Error al iniciar sesión: $e');
                            String errorMessage = 'Error al iniciar sesión';
                            if (e.toString().contains('invalid-credential') ||
                                e.toString().contains('user-not-found')) {
                              errorMessage = 'Correo no registrado';
                            } else if (e.toString().contains('wrong-password')) {
                              errorMessage = 'Contraseña incorrecta';
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errorMessage)),
                            );
                          }
                        },
                        child: const Text(
                          'Iniciar Sesión',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistroPage(),
                        ),
                      );
                    },
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: '¿Olvidaste tu contraseña?\n',
                            style: TextStyle(color: Colors.white70),
                          ),
                          TextSpan(
                            text: 'Regístrate',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}