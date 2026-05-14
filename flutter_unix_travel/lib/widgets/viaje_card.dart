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
  final String tipo;

  const ViajeCard({
    super.key,
    required this.nombre,
    required this.precio,
    required this.imagen,
    required this.esInvitado,
    required this.cedula,
    this.tipo = "destino",
  });

  // 🛒 AGREGAR AL CARRITO CON FECHAS
  Future<void> mostrarDialogoFechas(BuildContext context) async {
    DateTime? fechaIda;
    DateTime? fechaVuelta;
    int personas = 1;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text("Reservar $nombre ✈️"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // 📅 FECHA IDA
                  ListTile(
                    leading: const Icon(Icons.flight_takeoff, color: Color(0xFF2C5364)),
                    title: Text(
                      fechaIda == null
                          ? "Seleccionar fecha de ida"
                          : "Ida: ${fechaIda!.day}/${fechaIda!.month}/${fechaIda!.year}",
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setStateDialog(() => fechaIda = picked);
                      }
                    },
                  ),

                  // 📅 FECHA VUELTA
                  ListTile(
                    leading: const Icon(Icons.flight_land, color: Color(0xFF2C5364)),
                    title: Text(
                      fechaVuelta == null
                          ? "Seleccionar fecha de vuelta"
                          : "Vuelta: ${fechaVuelta!.day}/${fechaVuelta!.month}/${fechaVuelta!.year}",
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setStateDialog(() => fechaVuelta = picked);
                      }
                    },
                  ),

                  const SizedBox(height: 10),

                  // 👥 PERSONAS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Personas:", style: TextStyle(fontSize: 16)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (personas > 1) {
                                setStateDialog(() => personas--);
                              }
                            },
                          ),
                          Text(
                            "$personas",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setStateDialog(() => personas++);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C5364),
                  ),
                  onPressed: () async {
                    if (fechaIda == null || fechaVuelta == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Selecciona las fechas ⚠️")),
                      );
                      return;
                    }

                    if (fechaVuelta!.isBefore(fechaIda!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("La fecha de vuelta no puede ser antes de la ida ⚠️")),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    await agregarCarrito(context, fechaIda!, fechaVuelta!, personas);
                  },
                  child: const Text("Agregar al carrito"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> agregarCarrito(BuildContext context, DateTime fechaIda, DateTime fechaVuelta, int personas) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/agregar_carrito"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "usuario_cedula": cedula,
          "nombre": nombre,
          "precio": precio,
          "imagen": imagen,
          "fecha_ida": "${fechaIda.year}-${fechaIda.month.toString().padLeft(2, '0')}-${fechaIda.day.toString().padLeft(2, '0')}",
          "fecha_vuelta": "${fechaVuelta.year}-${fechaVuelta.month.toString().padLeft(2, '0')}-${fechaVuelta.day.toString().padLeft(2, '0')}",
          "personas": personas,
          "tipo": tipo,
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

  // ❤️ FAVORITO
  Future<void> toggleFavorito(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/toggle_favorito"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "usuario_cedula": cedula,
          "nombre": nombre,
          "precio": precio,
          "imagen": imagen,
        }),
      );

      final data = jsonDecode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data["estado"] == "agregado"
                ? "Agregado a favoritos ❤️"
                : "Eliminado de favoritos 💔",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error conexión API ❌")),
      );
    }
  }

  // 🏷️ COLOR DEL BADGE SEGÚN TIPO
  Color _colorBadge() {
    switch (tipo) {
      case "hotel":
        return Colors.purple;
      case "vuelo":
        return Colors.blue;
      case "tour":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  // 🏷️ TEXTO DEL BADGE SEGÚN TIPO
  String _textoBadge() {
    switch (tipo) {
      case "hotel":
        return "HOTEL";
      case "vuelo":
        return "VUELO";
      case "tour":
        return "TOUR";
      default:
        return "TOP";
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
        elevation: 8,
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

              // 🔥 IMAGEN CON OVERLAY
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Stack(
                  children: [
                    Image.network(
                      imagen,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, size: 40),
                      ),
                    ),

                    // 🔥 DEGRADADO
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

                    // ❤️ FAVORITO
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
                              toggleFavorito(context);
                            }
                          },
                        ),
                      ),
                    ),

                    // 🏷️ BADGE DINÁMICO POR TIPO
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _colorBadge(),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _textoBadge(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
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
                              mostrarDialogoFechas(context);
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