import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateUserScreen extends StatefulWidget {
  const UpdateUserScreen({super.key});

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {

  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final emailController = TextEditingController();
  final telefonoController = TextEditingController();

  bool usuarioCargado = false;
  String? cedula;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  Future<void> cargarUsuario() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      cedula = prefs.getString("cedula");

      if (cedula == null) return;

      final response = await http.get(
        Uri.parse("http://127.0.0.1:5000/user/$cedula"),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final usuario = data["usuario"];

        setState(() {
          nombreController.text = usuario["nombre"];
          apellidosController.text = usuario["apellidos"];
          emailController.text = usuario["email"];
          telefonoController.text = usuario["telefono"];
          usuarioCargado = true;
        });
      }

    } catch (e) {
      print("ERROR LOAD: $e");
    }
  }

  Future<void> actualizarUsuario() async {
    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/update_user"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "cedula": cedula,
          "nombre": nombreController.text,
          "apellidos": apellidosController.text,
          "email": emailController.text,
          "telefono": telefonoController.text,
        }),
      );

      final data = jsonDecode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["mensaje"])),
      );

    } catch (e) {
      print("ERROR UPDATE: $e");
    }
  }

  Widget input(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
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

        child: usuarioCargado
            ? Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Card(
                      elevation: 15,
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
                              child: const Icon(Icons.edit, size: 35, color: Colors.white),
                            ),

                            const SizedBox(height: 15),

                            const Text(
                              "Actualizar perfil",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              "Edita tu información personal",
                              style: TextStyle(color: Colors.grey),
                            ),

                            const SizedBox(height: 25),

                            input("Nombre", nombreController, Icons.person),
                            const SizedBox(height: 15),

                            input("Apellidos", apellidosController, Icons.person_outline),
                            const SizedBox(height: 15),

                            input("Correo", emailController, Icons.email),
                            const SizedBox(height: 15),

                            input("Teléfono", telefonoController, Icons.phone),

                            const SizedBox(height: 25),

                            // 🔥 BOTÓN PRO
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                icon: const Icon(Icons.save),
                                label: const Text(
                                  "Actualizar",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: actualizarUsuario,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
      ),
    );
  }
}