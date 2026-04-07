import 'package:flutter/material.dart';
import 'update_user_screen.dart';
import 'delete_user_screen.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = "http://127.0.0.1:5000";

class ProfileScreen extends StatefulWidget {
  final String nombre;
  final String cedula;

  const ProfileScreen({super.key, required this.nombre, required this.cedula});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  int favoritos = 0;
  int carrito = 0;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final favRes = await http.get(
        Uri.parse("$baseUrl/obtener_favoritos/${widget.cedula}")
      );

      final carRes = await http.get(
        Uri.parse("$baseUrl/obtener_carrito/${widget.cedula}")
      );

      final favData = jsonDecode(favRes.body);
      final carData = jsonDecode(carRes.body);

      setState(() {
        favoritos = favData["favoritos"].length;
        carrito = carData["carrito"].length;
      });

    } catch (e) {
      print("Error cargando perfil: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      body: SingleChildScrollView(
        child: Column(
          children: [

            // 🔥 HEADER PREMIUM
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 70, bottom: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF141E30), Color(0xFF243B55)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [

                  const Text(
                    "Unix Travel",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Explora el mundo sin límites ✈️",
                    style: TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 20),

                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: const Color(0xFF243B55),
                      child: Text(
                        widget.nombre[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    widget.nombre,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Usuario Premium",
                    style: TextStyle(color: Colors.amber, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 🔥 STATS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatCard(icon: Icons.flight_takeoff, titulo: "Viajes", valor: "0"),
                  _StatCard(icon: Icons.favorite, titulo: "Favoritos", valor: "$favoritos"),
                  _StatCard(icon: Icons.shopping_bag, titulo: "Carrito", valor: "$carrito"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 🔥 BENEFICIOS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Beneficios Premium",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text("✔ Descuentos exclusivos", style: TextStyle(color: Colors.white70)),
                    Text("✔ Acceso anticipado a viajes", style: TextStyle(color: Colors.white70)),
                    Text("✔ Soporte prioritario", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 🔥 MENÚ PRO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [

                  _MenuTile(
                    icon: Icons.edit,
                    texto: "Editar perfil",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UpdateUserScreen(),
                        ),
                      );
                    },
                  ),

                  _MenuTile(
                    icon: Icons.delete,
                    texto: "Eliminar cuenta",
                    color: Colors.red,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeleteUserScreen(),
                        ),
                      );
                    },
                  ),

                  _MenuTile(
                    icon: Icons.logout,
                    texto: "Cerrar sesión",
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();

                      await prefs.remove("cedula");
                      await prefs.remove("nombre");

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(
                            nombre: "Invitado",
                            cedula: "",
                          ),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// 🔥 STATS CARD
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;

  const _StatCard({
    required this.icon,
    required this.titulo,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,3))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xFF243B55)),
          const SizedBox(height: 6),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(titulo, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// 🔥 MENÚ TILE
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String texto;
  final VoidCallback onTap;
  final Color? color;

  const _MenuTile({
    required this.icon,
    required this.texto,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.black87),
        title: Text(texto),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}