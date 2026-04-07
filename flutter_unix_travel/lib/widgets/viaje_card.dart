import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/detail_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = "http://127.0.0.1:5000";

class ViajeCard extends StatelessWidget {
  final String nombre;
  final String precio;
  final String imagen;
  final bool esInvitado;
  final String cedula;

  const ViajeCard({
    super.key,
    required this.nombre,
    required this.precio,
    required this.imagen,
    required this.esInvitado,
    required this.cedula,
  });

  Future<void> agregarCarrito(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/agregar_carrito"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "usuario_cedula": cedula,
          "nombre": nombre,
          "precio": precio,
          "imagen": imagen
        }),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.statusCode == 200
                ? "Agregado al carrito 🛒"
                : "Error al agregar ❌",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error conexión API ❌")),
      );
    }
  }

  Future<void> agregarFavorito(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/agregar_favorito"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "usuario_cedula": cedula,
          "nombre": nombre,
          "precio": precio,
          "imagen": imagen
        }),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.statusCode == 200
                ? "Agregado a favoritos ❤️"
                : "Error al agregar ❌",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error conexión API ❌")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(
              nombre: nombre,
              precio: precio,
              imagen: imagen,
              cedula: cedula,
            ),
          ),
        );
      },
      child: Card(
        elevation: 8, // 🔥 más profundidad
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        margin: const EdgeInsets.all(10),
        child: SizedBox(
          height: 230,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔥 IMAGEN CON OVERLAY PRO
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Stack(
                  children: [
                    Image.network(
                      imagen,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),

                    // 🔥 DEGRADADO OSCURO
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),

                    // ❤️ FAVORITO PRO
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.favorite_border, color: Colors.red),
                          onPressed: () {
                            if (esInvitado) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            } else {
                              agregarFavorito(context);
                            }
                          },
                        ),
                      ),
                    ),

                    // 🔥 BADGE TOP MEJORADO
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "TOP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              // 🔥 CONTENIDO
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombre,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            precio,
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C5364),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () {
                            if (esInvitado) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            } else {
                              agregarCarrito(context);
                            }
                          },
                          child: const Text(
                            "Agregar",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}