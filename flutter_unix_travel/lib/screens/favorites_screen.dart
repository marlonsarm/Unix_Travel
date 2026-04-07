import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'detail_screen.dart';

const String baseUrl = "http://127.0.0.1:5000";

class FavoritesScreen extends StatefulWidget {
  final String cedula;

  const FavoritesScreen({super.key, required this.cedula});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {

  List favoritos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    obtenerFavoritos();
  }

  Future<void> obtenerFavoritos() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/obtener_favoritos/${widget.cedula}")
      );

      final data = jsonDecode(response.body);

      setState(() {
        favoritos = data["favoritos"];
        cargando = false;
      });

    } catch (e) {
      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> eliminarFavorito(int id) async {
    await http.delete(
      Uri.parse("$baseUrl/eliminar_favorito/$id")
    );

    obtenerFavoritos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favoritos ❤️")),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : favoritos.isEmpty
              ? const Center(child: Text("No tienes favoritos"))
              : ListView.builder(
                  itemCount: favoritos.length,
                  itemBuilder: (context, index) {
                    final f = favoritos[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                              nombre: f["nombre_producto"],
                              precio: f["precio"],
                              imagen: f["imagen"],
                              cedula: widget.cedula,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: Image.network(
                            f["imagen"],
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(f["nombre_producto"]),
                          subtitle: Text(f["precio"]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              eliminarFavorito(f["id"]);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}