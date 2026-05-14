import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'detail_screen.dart';

const String baseUrl = "http://127.0.0.1:5000";

class FavoritesScreen extends StatefulWidget {
  final String cedula;
  final bool esVip;

  const FavoritesScreen({super.key, required this.cedula, this.esVip = false});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {

  List favoritos = [];
  bool cargando = true;

  Color get _primary => widget.esVip ? const Color(0xFFD4AF37) : const Color(0xFF2C5364);
  Color get _bg => widget.esVip ? const Color(0xFF0A0A0A) : const Color(0xFFF4F6FA);
  Color get _cardBg => widget.esVip ? const Color(0xFF1A1A1A) : Colors.white;
  Color get _textColor => widget.esVip ? Colors.white : Colors.black87;

  @override
  void initState() {
    super.initState();
    obtenerFavoritos();
  }

  Future<void> obtenerFavoritos() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/obtener_favoritos/${widget.cedula}"));
      final data = jsonDecode(response.body);
      setState(() {
        favoritos = data["favoritos"];
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  Future<void> eliminarFavorito(int id) async {
    await http.delete(Uri.parse("$baseUrl/eliminar_favorito/$id"));
    obtenerFavoritos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: widget.esVip ? const Color(0xFF0A0A0A) : const Color(0xFF0F2027),
        title: Text(
          widget.esVip ? "👑 Mis Favoritos VIP" : "Mis Favoritos ❤️",
          style: TextStyle(color: widget.esVip ? const Color(0xFFD4AF37) : Colors.white),
        ),
        iconTheme: IconThemeData(color: widget.esVip ? const Color(0xFFD4AF37) : Colors.white),
      ),
      body: cargando
          ? Center(child: CircularProgressIndicator(color: _primary))
          : favoritos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 80, color: _primary.withOpacity(0.3)),
                      const SizedBox(height: 15),
                      Text("No tienes favoritos aún", style: TextStyle(fontSize: 18, color: _textColor)),
                      Text("Agrega destinos que te gusten ❤️", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
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
                              esVip: widget.esVip,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: _cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: widget.esVip
                              ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2))
                              : null,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                              child: Image.network(
                                f["imagen"] ?? "",
                                width: 100,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 100,
                                  height: 90,
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(f["nombre_producto"] ?? "", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _textColor)),
                                    const SizedBox(height: 4),
                                    Text(f["precio"] ?? "", style: TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text("Toca para ver detalles", style: TextStyle(color: Colors.grey, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: IconButton(
                                icon: const Icon(Icons.favorite, color: Colors.red),
                                onPressed: () => eliminarFavorito(f["id"]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}