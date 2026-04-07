import 'package:flutter/material.dart';
import '../widgets/viaje_card.dart';
import '../data/viajes_data.dart';
import '../data/hoteles_data.dart';
import '../data/vuelos_data.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'favorites_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatelessWidget {
  final String nombre;
  final String cedula;

  const HomeScreen({
    super.key,
    required this.nombre,
    required this.cedula,
  });

  @override
  Widget build(BuildContext context) {

    bool esInvitado = nombre == "Invitado";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 75,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Unix Travel ✈️",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Hola, $nombre",
              style: const TextStyle(fontSize: 13),
            )
          ],
        ),
        actions: [

          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CartScreen(cedula: cedula),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FavoritesScreen(cedula: cedula),
                ),
              );
            },
          ),

          if (!esInvitado)
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      nombre: nombre,
                      cedula: cedula,
                    ),
                  ),
                );
              },
            ),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
            child: Text(
              esInvitado ? "Login" : "Cuenta",
              style: const TextStyle(color: Colors.white),
            ),
          )
        ],
      ),

      body: ListView(
        children: [

          // 🔥 HERO + BUSCADOR (NIVEL BOOKING)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "¿A dónde quieres viajar?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search),
                      hintText: "Buscar destinos, hoteles, vuelos...",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _Filtro(icon: Icons.flight, texto: "Vuelos"),
                    _Filtro(icon: Icons.hotel, texto: "Hoteles"),
                    _Filtro(icon: Icons.map, texto: "Viajes"),
                    _Filtro(icon: Icons.local_offer, texto: "Ofertas"),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🔥 VIAJES
          _seccion("Viajes", viajes, esInvitado, cedula),

          // 🔥 HOTELES
          _seccion("Hoteles", hoteles, esInvitado, cedula),

          // 🔥 VUELOS
          _seccion("Vuelos", vuelos, esInvitado, cedula),

          // 🔥 FOOTER PRO
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: const [
                Divider(),
                SizedBox(height: 10),
                Text("📧 unixtravel@gmail.com"),
                Text("📞 +57 300 123 4567"),
                Text("📍 Colombia"),
                SizedBox(height: 10),
                Text(
                  "© 2026 Unix Travel",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // 🔥 SECCIONES REUTILIZABLES
  Widget _seccion(String titulo, List<Map<String, String>> data, bool esInvitado, String cedula) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text("Ver todo", style: TextStyle(color: Colors.blue))
            ],
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              return SizedBox(
                width: 190,
                child: ViajeCard(
                  nombre: item["nombre"]!,
                  precio: item["precio"]!,
                  imagen: item["imagen"]!,
                  esInvitado: esInvitado,
                  cedula: cedula,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

// 🔥 FILTROS
class _Filtro extends StatelessWidget {
  final IconData icon;
  final String texto;

  const _Filtro({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(icon, color: Colors.black),
        ),
        const SizedBox(height: 5),
        Text(texto, style: const TextStyle(color: Colors.white))
      ],
    );
  }
}