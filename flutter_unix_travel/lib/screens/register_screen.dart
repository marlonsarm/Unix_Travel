import 'package:flutter/material.dart';
import 'home_screen.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cedulaController = TextEditingController();
    final nombreController = TextEditingController();
    final apellidosController = TextEditingController();
    final emailController = TextEditingController();
    final telefonoController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 15,
                shadowColor: Colors.black54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // 👤 ICONO PRO
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Colors.blueAccent, Colors.cyan],
                          ),
                        ),
                        child: const Icon(Icons.person_add, size: 35, color: Colors.white),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Crear cuenta",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        "Regístrate para comenzar tu viaje ✈️",
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 25),

                      // 🔥 CAMPOS PRO
                      TextField(
                        controller: cedulaController,
                        decoration: InputDecoration(
                          labelText: "Cédula",
                          prefixIcon: const Icon(Icons.badge),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: nombreController,
                        decoration: InputDecoration(
                          labelText: "Nombre",
                          prefixIcon: const Icon(Icons.person),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: apellidosController,
                        decoration: InputDecoration(
                          labelText: "Apellidos",
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Correo",
                          prefixIcon: const Icon(Icons.email),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: telefonoController,
                        decoration: InputDecoration(
                          labelText: "Teléfono",
                          prefixIcon: const Icon(Icons.phone),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Contraseña",
                          prefixIcon: const Icon(Icons.lock),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // 🔥 BOTÓN PRO
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () async {
                            try {
                              final response = await http.post(
                                Uri.parse("http://127.0.0.1:5000/register"),
                                headers: {"Content-Type": "application/json"},
                                body: jsonEncode({
                                  "cedula": cedulaController.text,
                                  "nombre": nombreController.text,
                                  "apellidos": apellidosController.text,
                                  "email": emailController.text,
                                  "password": passwordController.text,
                                  "telefono": telefonoController.text,
                                }),
                              );

                              final data = jsonDecode(response.body);

                              if (response.statusCode == 200) {

                                final prefs = await SharedPreferences.getInstance();

                                await prefs.setString("nombre", nombreController.text);
                                await prefs.setString("cedula", cedulaController.text);

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HomeScreen(
                                      nombre: nombreController.text,
                                      cedula: cedulaController.text,
                                    ),
                                  ),
                                  (route) => false,
                                );

                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(data["mensaje"])),
                                );
                              }

                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Error conexión servidor"),
                                ),
                              );
                            }
                          },
                          child: Ink(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blueAccent, Colors.cyan],
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            child: const Center(
                              child: Text(
                                "Registrarse",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "¿Ya tienes cuenta? Inicia sesión",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}