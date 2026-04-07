import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String nombreUsuario = "Invitado";
  String cedulaUsuario = ""; // 🔥 NUEVO
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    verificarSesion();
  }

  Future<void> verificarSesion() async {
    final prefs = await SharedPreferences.getInstance();

    String? nombre = prefs.getString("nombre");
    String? cedula = prefs.getString("cedula"); // 🔥 NUEVO

    setState(() {
      nombreUsuario = nombre ?? "Invitado";
      cedulaUsuario = cedula ?? ""; // 🔥 NUEVO
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (cargando) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(
        nombre: nombreUsuario,
        cedula: cedulaUsuario, // 🔥 AHORA SÍ CORRECTO
      ),
    );
  }
}