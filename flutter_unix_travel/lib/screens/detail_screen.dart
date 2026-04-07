import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = "http://127.0.0.1:5000";

class DetailScreen extends StatefulWidget {
  final String nombre;
  final String precio;
  final String imagen;
  final String cedula;

  const DetailScreen({
    super.key,
    required this.nombre,
    required this.precio,
    required this.imagen,
    required this.cedula,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {

  int currentIndex = 0;
  bool esFavorito = false;

  late List<String> imagenes;

  @override
  void initState() {
    super.initState();

    imagenes = [
      widget.imagen,
      widget.imagen,
      widget.imagen,
    ];

    verificarFavorito();
  }

  Future<void> verificarFavorito() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/es_favorito"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "usuario_cedula": widget.cedula,
          "nombre": widget.nombre
        }),
      );

      final data = jsonDecode(response.body);

      setState(() {
        esFavorito = data["es_favorito"];
      });
    } catch (e) {
      print("Error verificar favorito: $e");
    }
  }

  Future<void> toggleFavorito() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/toggle_favorito"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "usuario_cedula": widget.cedula,
          "nombre": widget.nombre,
          "precio": widget.precio,
          "imagen": widget.imagen
        }),
      );

      final data = jsonDecode(response.body);

      setState(() {
        esFavorito = data["estado"] == "agregado";
      });
    } catch (e) {
      print("Error toggle favorito: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      body: Stack(
        children: [

          CustomScrollView(
            physics: const BouncingScrollPhysics(), // 🔥 SCROLL PRO
            slivers: [

              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.nombre,
                    style: const TextStyle(fontSize: 14),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [

                      // 🔥 CARRUSEL ARREGLADO
                      PageView.builder(
                        itemCount: imagenes.length,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(), // 🔥 FIX REAL
                        onPageChanged: (i) {
                          setState(() => currentIndex = i);
                        },
                        itemBuilder: (_, index) {
                          return Image.network(
                            imagenes[index],
                            fit: BoxFit.cover,
                          );
                        },
                      ),

                      // 🔥 GRADIENT PRO
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black87],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),

                      // 🔥 INDICADORES
                      Positioned(
                        bottom: 15,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(imagenes.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.all(3),
                              width: currentIndex == index ? 12 : 6,
                              height: currentIndex == index ? 12 : 6,
                              decoration: BoxDecoration(
                                color: currentIndex == index
                                    ? Colors.white
                                    : Colors.white54,
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                      )
                    ],
                  ),
                ),

                actions: [
                  IconButton(
                    icon: Icon(
                      esFavorito ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: toggleFavorito,
                  )
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.nombre,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            widget.precio,
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange),
                          Icon(Icons.star, color: Colors.orange),
                          Icon(Icons.star, color: Colors.orange),
                          Icon(Icons.star, color: Colors.orange),
                          Icon(Icons.star_half, color: Colors.orange),
                          SizedBox(width: 10),
                          Text("4.5 (120 reviews)")
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          _Feature(icon: Icons.wifi, texto: "WiFi"),
                          _Feature(icon: Icons.pool, texto: "Piscina"),
                          _Feature(icon: Icons.restaurant, texto: "Comida"),
                          _Feature(icon: Icons.flight, texto: "Vuelo"),
                        ],
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        "Descripción",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Disfruta de una experiencia única en este destino increíble. "
                        "Incluye alojamiento premium, actividades exclusivas y una vista espectacular.",
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C5364),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Reserva realizada 🛒")),
                            );
                          },
                          child: const Text("Reservar ahora"),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              )
            ],
          ),

          Positioned(
            top: 45,
            left: 15,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String texto;

  const _Feature({required this.icon, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFF2C5364),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(texto, style: const TextStyle(fontSize: 12))
      ],
    );
  }
}