import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = "http://127.0.0.1:5000";

class CartScreen extends StatefulWidget {
  final String cedula;

  const CartScreen({super.key, required this.cedula});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  List carrito = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    obtenerCarrito();
  }

  // 🔥 OBTENER DESDE MYSQL
  Future<void> obtenerCarrito() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/obtener_carrito/${widget.cedula}")
      );

      final data = jsonDecode(response.body);

      setState(() {
        carrito = data["carrito"];
        cargando = false;
      });

    } catch (e) {
      print("Error: $e");
      setState(() {
        cargando = false;
      });
    }
  }

  // ❌ ELIMINAR
  Future<void> eliminarItem(int id) async {
    await http.delete(
      Uri.parse("$baseUrl/eliminar_carrito/$id")
    );

    obtenerCarrito();
  }

  // 💳 PAGAR
  Future<void> pagar() async {
    await http.delete(
      Uri.parse("$baseUrl/pagar/${widget.cedula}")
    );

    obtenerCarrito();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Pago exitoso 🎉"),
        content: const Text("Tu compra fue realizada correctamente."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  double calcularTotal() {
    double total = 0;

    for (var item in carrito) {
      String precio = item["precio"].toString().replaceAll("\$", "");
      total += double.tryParse(precio) ?? 0;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Carrito 🛒"),
        backgroundColor: Colors.black,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : carrito.isEmpty
              ? const Center(
                  child: Text(
                    "Tu carrito está vacío 😢",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Column(
                  children: [

                    Expanded(
                      child: ListView.builder(
                        itemCount: carrito.length,
                        itemBuilder: (context, index) {
                          final item = carrito[index];

                          return Card(
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              leading: Image.network(
                                item["imagen"],
                                width: 60,
                                fit: BoxFit.cover,
                              ),
                              title: Text(item["nombre_producto"]),
                              subtitle: Text(item["precio"]),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  eliminarItem(item["id"]);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                      ),
                      child: Column(
                        children: [

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total:",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "\$${calcularTotal().toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: pagar,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                backgroundColor: Colors.green,
                              ),
                              child: const Text(
                                "Proceder al pago",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}