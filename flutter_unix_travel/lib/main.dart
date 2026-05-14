import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String nombreUsuario = "Invitado";
  String cedulaUsuario = "";
  String tipoUsuario = "cliente";
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    verificarSesion();
  }

  Future<void> verificarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nombreUsuario = prefs.getString("nombre") ?? "Invitado";
      cedulaUsuario = prefs.getString("cedula") ?? "";
      tipoUsuario = prefs.getString("tipo_usuario") ?? "cliente";
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "UNIX TRAVEL",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget pantallaInicial;
    if (cedulaUsuario.isEmpty) {
      pantallaInicial = const HomeScreen(nombre: "Invitado", cedula: "");
    } else if (tipoUsuario == "admin") {
      pantallaInicial = AdminScreen(nombre: nombreUsuario, cedula: cedulaUsuario);
    } else {
      pantallaInicial = HomeScreen(nombre: nombreUsuario, cedula: cedulaUsuario);
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
      ),
      home: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          // No hace nada — sesión protegida
        },
        child: pantallaInicial,
      ),
    );
  }
}