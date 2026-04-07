import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class DeleteUserScreen extends StatelessWidget {
  const DeleteUserScreen({super.key});

  @override
  Widget build(BuildContext context) {

    Future<void> eliminarUsuario() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final cedula = prefs.getString('cedula');

        print("CEDULA ELIMINAR: $cedula");

        if (cedula == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sesión no encontrada")),
          );
          return;
        }

        final response = await http.post(
          Uri.parse("http://127.0.0.1:5000/delete_user"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "cedula": cedula,
          }),
        );

        final data = jsonDecode(response.body);

        print("RESPUESTA DELETE: $data");

        if (response.statusCode == 200) {

          await prefs.clear();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => LoginScreen(), // 🔥 FIX (sin const)
            ),
            (route) => false,
          );

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data["mensaje"])),
          );
        }

      } catch (e) {
        print("ERROR DELETE: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error conexión servidor")),
        );
      }
    }

    void confirmarEliminacion() {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("¿Eliminar cuenta?"),
          content: const Text(
            "Esta acción no se puede deshacer. Se eliminarán todos tus datos.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                eliminarUsuario();
              },
              child: const Text("Eliminar"),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.redAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 60,
                      color: Colors.red,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Eliminar cuenta",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Esta acción eliminará tu cuenta permanentemente.",
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: confirmarEliminacion,
                        child: const Text(
                          "Eliminar mi cuenta",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar"),
                    )
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