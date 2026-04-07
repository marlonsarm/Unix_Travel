import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'home_screen.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cedulaController = TextEditingController();
    final emailController = TextEditingController();
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

                      // ✈️ ICONO + TITULO PRO
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Colors.blueAccent, Colors.cyan],
                          ),
                        ),
                        child: const Icon(Icons.flight, size: 35, color: Colors.white),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Unix Travel",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        "Bienvenido de nuevo",
                        style: TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 25),

                      // 🔥 CEDULA
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

                      // 🔥 EMAIL
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

                      // 🔥 PASSWORD
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

                      // 🔥 BOTON PRO
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
                              print("BOTON LOGIN PRESIONADO");

                              final response = await http.post(
                                Uri.parse("http://127.0.0.1:5000/login"),
                                headers: {"Content-Type": "application/json"},
                                body: jsonEncode({
                                  "cedula": cedulaController.text,
                                  "email": emailController.text,
                                  "password": passwordController.text
                                }),
                              );

                              final data = jsonDecode(response.body);

                              print("RESPUESTA: $data");

                              if (response.statusCode == 200) {

                                final prefs = await SharedPreferences.getInstance();

                                await prefs.setString("nombre", data["usuario"]["nombre"]);
                                await prefs.setString("cedula", cedulaController.text);

                                print("SESION GUARDADA");

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HomeScreen(
                                      nombre: data["usuario"]["nombre"],
                                      cedula: cedulaController.text,
                                    ),
                                  ),
                                );

                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(data["mensaje"])),
                                );
                              }

                            } catch (e) {
                              print("ERROR LOGIN: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Error servidor")),
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
                                "Ingresar",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // 🔗 REGISTRO
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "¿No tienes cuenta? Crear cuenta",
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