import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'payment_screen.dart';

const String baseUrl = "http://127.0.0.1:5000";

class CartScreen extends StatefulWidget {
  final String cedula;
  final bool esVip;

  const CartScreen({super.key, required this.cedula, this.esVip = false});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  List carrito = [];
  bool cargando = true;

  Color get _primary => widget.esVip ? const Color(0xFFD4AF37) : const Color(0xFF2C5364);
  Color get _bg => widget.esVip ? const Color(0xFF0A0A0A) : const Color(0xFFF4F6FA);
  Color get _cardBg => widget.esVip ? const Color(0xFF1A1A1A) : Colors.white;
  Color get _textColor => widget.esVip ? Colors.white : Colors.black87;

  @override
  void initState() {
    super.initState();
    obtenerCarrito();
  }

  Future<void> obtenerCarrito() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/obtener_carrito/${widget.cedula}"));
      final data = jsonDecode(response.body);
      setState(() {
        carrito = data["carrito"];
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  Future<void> eliminarItem(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text("¿Eliminar?", style: TextStyle(color: _textColor)),
        content: Text("¿Seguro que quieres eliminar este item?", style: TextStyle(color: _textColor)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      await http.delete(Uri.parse("$baseUrl/eliminar_carrito/$id"));
      obtenerCarrito();
    }
  }

  Future<void> mostrarDialogoEditar(dynamic item) async {
    DateTime? fechaIda = item["fecha_ida"] != null ? DateTime.parse(item["fecha_ida"]) : null;
    DateTime? fechaVuelta = item["fecha_vuelta"] != null ? DateTime.parse(item["fecha_vuelta"]) : null;
    int personas = item["personas"] ?? 1;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: _cardBg,
          title: Text("Editar reserva ✏️", style: TextStyle(color: _textColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.flight_takeoff, color: _primary),
                title: Text(
                  fechaIda == null ? "Fecha de ida" : "Ida: ${fechaIda!.day}/${fechaIda!.month}/${fechaIda!.year}",
                  style: TextStyle(color: _textColor),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: fechaIda ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setStateDialog(() => fechaIda = picked);
                },
              ),
              ListTile(
                leading: Icon(Icons.flight_land, color: _primary),
                title: Text(
                  fechaVuelta == null ? "Fecha de vuelta" : "Vuelta: ${fechaVuelta!.day}/${fechaVuelta!.month}/${fechaVuelta!.year}",
                  style: TextStyle(color: _textColor),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: fechaVuelta ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setStateDialog(() => fechaVuelta = picked);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("👥 Personas:", style: TextStyle(color: _textColor)),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: _primary),
                        onPressed: () { if (personas > 1) setStateDialog(() => personas--); },
                      ),
                      Text("$personas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor)),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline, color: _primary),
                        onPressed: () => setStateDialog(() => personas++),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _primary),
              onPressed: () async {
                if (fechaIda == null || fechaVuelta == null) return;
                await http.post(
                  Uri.parse("$baseUrl/editar_carrito/${item["id"]}"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "fecha_ida": "${fechaIda!.year}-${fechaIda!.month.toString().padLeft(2, '0')}-${fechaIda!.day.toString().padLeft(2, '0')}",
                    "fecha_vuelta": "${fechaVuelta!.year}-${fechaVuelta!.month.toString().padLeft(2, '0')}-${fechaVuelta!.day.toString().padLeft(2, '0')}",
                    "personas": personas,
                  }),
                );
                Navigator.pop(context);
                obtenerCarrito();
              },
              child: Text("Guardar", style: TextStyle(color: widget.esVip ? Colors.black : Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  double calcularTotal() {
    double total = 0;
    for (var item in carrito) {
      String precio = item["precio_total"]?.toString() ??
          item["precio"].toString().replaceAll("\$", "").replaceAll(".", "");
      total += double.tryParse(precio) ?? 0;
    }
    return total;
  }

  Future<void> procederAlPago() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          cedula: widget.cedula,
          nombre: "Todo el carrito",
          precio: calcularTotal().toStringAsFixed(0),
          imagen: carrito.isNotEmpty ? carrito[0]["imagen"] ?? "" : "",
          tipo: "carrito",
          esVip: widget.esVip,
        ),
      ),
    ).then((_) => obtenerCarrito());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: widget.esVip ? const Color(0xFF0A0A0A) : const Color(0xFF0F2027),
        title: Row(
          children: [
            if (widget.esVip) const Text("👑 ", style: TextStyle(fontSize: 18)),
            Text(
              "Mi Carrito 🛒",
              style: TextStyle(color: widget.esVip ? const Color(0xFFD4AF37) : Colors.white),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: widget.esVip ? const Color(0xFFD4AF37) : Colors.white),
      ),
      body: cargando
          ? Center(child: CircularProgressIndicator(color: _primary))
          : carrito.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 80, color: _primary.withOpacity(0.3)),
                      const SizedBox(height: 15),
                      Text("Tu carrito está vacío 😢", style: TextStyle(fontSize: 18, color: _textColor)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: carrito.length,
                        itemBuilder: (context, index) {
                          final item = carrito[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _cardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: widget.esVip
                                  ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2))
                                  : null,
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    item["imagen"] ?? "",
                                    width: 75,
                                    height: 75,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 75,
                                      height: 75,
                                      color: Colors.grey[800],
                                      child: const Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item["nombre_producto"] ?? "", style: TextStyle(fontWeight: FontWeight.bold, color: _textColor)),
                                      Text(item["precio"] ?? "", style: TextStyle(color: _primary, fontWeight: FontWeight.bold)),
                                      if (item["fecha_ida"] != null)
                                        Text("✈️ ${item["fecha_ida"]} → ${item["fecha_vuelta"]}", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      if (item["personas"] != null)
                                        Text("👥 ${item["personas"]} personas", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                      if (item["precio_total"] != null)
                                        Text("💰 Total: \$${item["precio_total"]}", style: TextStyle(fontSize: 12, color: _primary, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: _primary, size: 20),
                                      onPressed: () => mostrarDialogoEditar(item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                      onPressed: () => eliminarItem(item["id"]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // 💳 FOOTER PAGO
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                        border: widget.esVip
                            ? const Border(top: BorderSide(color: Color(0xFFD4AF37), width: 1))
                            : null,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15)],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textColor)),
                              Text(
                                "\$${calcularTotal().toStringAsFixed(0)}",
                                style: TextStyle(fontSize: 22, color: _primary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              onPressed: procederAlPago,
                              child: Text(
                                widget.esVip ? "👑 Proceder al pago VIP" : "Proceder al pago",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: widget.esVip ? Colors.black : Colors.white,
                                ),
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