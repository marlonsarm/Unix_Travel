import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'admin_screen.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final cedulaController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool cargando = false;
  bool verPassword = false;

  Future<void> iniciarSesion() async {
    // 🔥 VALIDAR CAMPOS VACÍOS
    if (cedulaController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos ⚠️")),
      );
      return;
    }

    setState(() => cargando = true);

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
        await prefs.setString("tipo_usuario", data["usuario"]["tipo_usuario"]);

        print("SESION GUARDADA - Rol: ${data["usuario"]["tipo_usuario"]}");

        // 🔐 SEPARAR ROL ADMIN Y CLIENTE
        if (data["usuario"]["tipo_usuario"] == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminScreen(
                nombre: data["usuario"]["nombre"],
                cedula: cedulaController.text,
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                nombre: data["usuario"]["nombre"],
                cedula: cedulaController.text,
              ),
            ),
          );
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["mensaje"] ?? "Datos incorrectos ❌")),
        );
      }

    } catch (e) {
      print("ERROR LOGIN: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error de conexión con el servidor ❌")),
      );
    }

    setState(() => cargando = false);
  }

  @override
  Widget build(BuildContext context) {
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

                      // ✈️ ICONO + TITULO
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
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
                        keyboardType: TextInputType.number,
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
                        keyboardType: TextInputType.emailAddress,
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

                      // 🔥 PASSWORD CON OJO
                      TextField(
                        controller: passwordController,
                        obscureText: !verPassword,
                        decoration: InputDecoration(
                          labelText: "Contraseña",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              verPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => verPassword = !verPassword);
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // 🔥 BOTON INGRESAR
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: cargando ? null : iniciarSesion,
                          child: Ink(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blueAccent, Colors.cyan],
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Center(
                              child: cargando
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Ingresar",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

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
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "¿No tienes cuenta? Crear cuenta",
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                        ),
                      ),
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