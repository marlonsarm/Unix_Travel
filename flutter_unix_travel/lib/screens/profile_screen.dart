import 'package:flutter/material.dart';
import 'update_user_screen.dart';
import 'delete_user_screen.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'cart_screen.dart';
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
  int carritoCount = 0;
  int totalCompras = 0;
  List compras = [];
  List solicitudes = [];
  bool cargandoCompras = true;
  bool esVip = false;
  String? fotoBase64;

  Color get _primary => esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7);
  Color get _bg => esVip ? const Color(0xFF0A0A0A) : const Color(0xFFF0F2F8);
  Color get _cardBg => esVip ? const Color(0xFF141414) : Colors.white;
  Color get _textColor => esVip ? Colors.white : const Color(0xFF1A1A2E);
  List<Color> get _headerGradient => esVip
      ? [const Color(0xFF0A0A0A), const Color(0xFF1A1200), const Color(0xFF0A0A0A)]
      : [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)];

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final favRes = await http.get(Uri.parse("$baseUrl/obtener_favoritos/${widget.cedula}"));
      final carRes = await http.get(Uri.parse("$baseUrl/obtener_carrito/${widget.cedula}"));
      final comprasRes = await http.get(Uri.parse("$baseUrl/mis_compras/${widget.cedula}"));
      final solicRes = await http.get(Uri.parse("$baseUrl/mis_solicitudes/${widget.cedula}"));
      final userRes = await http.get(Uri.parse("$baseUrl/user/${widget.cedula}"));

      final favData = jsonDecode(favRes.body);
      final carData = jsonDecode(carRes.body);
      final comprasData = jsonDecode(comprasRes.body);
      final solicData = jsonDecode(solicRes.body);
      final userData = jsonDecode(userRes.body);

      setState(() {
        favoritos = favData["favoritos"].length;
        carritoCount = carData["carrito"].length;
        compras = comprasData["compras"] ?? [];
        totalCompras = compras.length;
        solicitudes = solicData["solicitudes"] ?? [];
        esVip = totalCompras > 0;
        fotoBase64 = userData["usuario"]?["foto_perfil"];
        cargandoCompras = false;
      });
    } catch (e) {
      setState(() => cargandoCompras = false);
    }
  }

  Future<void> solicitarEdicion(Map compra) async {
    DateTime? fechaNueva;
    DateTime? fechaVueltaNueva;
    int personasNueva = compra["personas"] ?? 1;
    final motivoCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: _cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Solicitar cambio", style: TextStyle(color: _textColor, fontWeight: FontWeight.w800, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Los cambios requieren aprobación del admin", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                const SizedBox(height: 15),
                ListTile(
                  leading: Icon(Icons.flight_takeoff_rounded, color: _primary),
                  title: Text(
                    fechaNueva == null ? "Nueva fecha de ida" : "Ida: ${fechaNueva!.day}/${fechaNueva!.month}/${fechaNueva!.year}",
                    style: TextStyle(color: _textColor, fontSize: 13),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setStateDialog(() => fechaNueva = picked);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.flight_land_rounded, color: _primary),
                  title: Text(
                    fechaVueltaNueva == null ? "Nueva fecha de vuelta" : "Vuelta: ${fechaVueltaNueva!.day}/${fechaVueltaNueva!.month}/${fechaVueltaNueva!.year}",
                    style: TextStyle(color: _textColor, fontSize: 13),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setStateDialog(() => fechaVueltaNueva = picked);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Personas:", style: TextStyle(color: _textColor, fontSize: 13)),
                    Row(
                      children: [
                        _CounterBtn(icon: Icons.remove_rounded, color: _primary, onTap: () { if (personasNueva > 1) setStateDialog(() => personasNueva--); }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text("$personasNueva", style: TextStyle(fontWeight: FontWeight.w800, color: _textColor, fontSize: 16)),
                        ),
                        _CounterBtn(icon: Icons.add_rounded, color: _primary, onTap: () => setStateDialog(() => personasNueva++)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: motivoCtrl,
                  style: TextStyle(color: _textColor, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: "Motivo del cambio",
                    labelStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
                    filled: true,
                    fillColor: _primary.withOpacity(0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primary.withOpacity(0.2))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primary)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancelar", style: TextStyle(color: Colors.grey[500])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
              onPressed: () async {
                if (fechaNueva == null || fechaVueltaNueva == null) return;
                await http.post(
                  Uri.parse("$baseUrl/solicitar_edicion"),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    "compra_id": compra["id"],
                    "usuario_cedula": widget.cedula,
                    "fecha_ida_nueva": "${fechaNueva!.year}-${fechaNueva!.month.toString().padLeft(2, '0')}-${fechaNueva!.day.toString().padLeft(2, '0')}",
                    "fecha_vuelta_nueva": "${fechaVueltaNueva!.year}-${fechaVueltaNueva!.month.toString().padLeft(2, '0')}-${fechaVueltaNueva!.day.toString().padLeft(2, '0')}",
                    "personas_nueva": personasNueva,
                    "motivo": motivoCtrl.text,
                  }),
                );
                Navigator.pop(context);
                cargarDatos();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Solicitud enviada al admin ✅")),
                );
              },
              child: Text("Enviar", style: TextStyle(color: esVip ? Colors.black : Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ===== HEADER =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _headerGradient,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                border: esVip ? const Border(bottom: BorderSide(color: Color(0xFFD4AF37), width: 0.8)) : null,
              ),
              child: Column(
                children: [
                  // VIP badge
                  if (esVip)
                    Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFFFD700)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("👑", style: TextStyle(fontSize: 13)),
                          SizedBox(width: 6),
                          Text("MIEMBRO VIP", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.5)),
                        ],
                      ),
                    ),

                  // App name
                  Text(
                    "Unix Travel",
                    style: TextStyle(
                      color: esVip ? const Color(0xFFD4AF37) : Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    esVip ? "✈️ Experiencia VIP" : "Explora el mundo sin límites ✈️",
                    style: TextStyle(
                      color: esVip ? const Color(0xFFD4AF37).withOpacity(0.6) : Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: esVip ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.4),
                        width: 2.5,
                      ),
                      boxShadow: esVip
                          ? [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.35), blurRadius: 20, spreadRadius: 2)]
                          : [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 16)],
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: esVip ? const Color(0xFF1A1200) : const Color(0xFF16213E),
                      child: fotoBase64 != null
                          ? ClipOval(
                              child: Image.memory(
                                base64Decode(fotoBase64!),
                                width: 84, height: 84,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Text(
                              widget.nombre[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 28,
                                color: esVip ? const Color(0xFFD4AF37) : Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    widget.nombre,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    esVip ? "✨ Viajero VIP" : "Viajero Premium",
                    style: TextStyle(
                      color: esVip ? const Color(0xFFD4AF37) : Colors.amber[300],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ===== STATS =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tus reservas están abajo 👇"))),
                      child: _StatCard(icon: Icons.receipt_long_rounded, titulo: "Reservas", valor: "$totalCompras", primary: _primary, cardBg: _cardBg, textColor: _textColor, esVip: esVip),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FavoritesScreen(cedula: widget.cedula, esVip: esVip))),
                      child: _StatCard(icon: Icons.favorite_rounded, titulo: "Favoritos", valor: "$favoritos", primary: _primary, cardBg: _cardBg, textColor: _textColor, esVip: esVip),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen(cedula: widget.cedula, esVip: esVip))),
                      child: _StatCard(icon: Icons.shopping_bag_rounded, titulo: "Carrito", valor: "$carritoCount", primary: _primary, cardBg: _cardBg, textColor: _textColor, esVip: esVip),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== BENEFICIOS =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: esVip
                        ? [const Color(0xFF1A1200), const Color(0xFF2E2000)]
                        : [const Color(0xFF1A1A2E), const Color(0xFF0F3460)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: esVip ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(esVip ? "👑" : "⭐", style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          esVip ? "Beneficios VIP Exclusivos" : "Beneficios Premium",
                          style: TextStyle(
                            color: esVip ? const Color(0xFFD4AF37) : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...(esVip ? [
                      "✨ Acceso prioritario a ofertas exclusivas",
                      "🥂 Upgrades de habitación gratuitos",
                      "🚀 Check-in exprés sin filas",
                      "🎁 Regalos de bienvenida en el destino",
                      "📞 Línea VIP de atención 24/7",
                    ] : [
                      "✔ Descuentos exclusivos",
                      "✔ Acceso anticipado a viajes",
                      "✔ Soporte prioritario",
                    ]).map((b) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        b,
                        style: TextStyle(
                          color: esVip ? const Color(0xFFD4AF37).withOpacity(0.75) : Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===== MIS RESERVAS =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                    titulo: esVip ? "Mis Reservas VIP" : "Mis Reservas",
                    icono: esVip ? "👑" : "📦",
                    textColor: _textColor,
                  ),
                  const SizedBox(height: 12),
                  cargandoCompras
                      ? Center(child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: _primary, strokeWidth: 2.5),
                        ))
                      : compras.isEmpty
                          ? _EmptyState(primary: _primary, cardBg: _cardBg, esVip: esVip)
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: compras.length,
                              itemBuilder: (context, index) => _CompraCard(
                                compra: compras[index],
                                esVip: esVip,
                                primary: _primary,
                                cardBg: _cardBg,
                                textColor: _textColor,
                                onSolicitarEdicion: () => solicitarEdicion(compras[index]),
                              ),
                            ),
                ],
              ),
            ),

            // ===== SOLICITUDES =====
            if (solicitudes.isNotEmpty) ...[
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(titulo: "Mis Solicitudes de Cambio", icono: "📝", textColor: _textColor),
                    const SizedBox(height: 12),
                    ...solicitudes.map((s) {
                      final Color estadoColor = s["estado"] == "aprobada"
                          ? Colors.green
                          : s["estado"] == "rechazada"
                              ? Colors.red
                              : Colors.orange;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: _cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: estadoColor.withOpacity(0.25)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s["nombre_producto"] ?? "", style: TextStyle(fontWeight: FontWeight.w700, color: _textColor, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  if (s["respuesta_admin"] != null)
                                    Text("Admin: ${s["respuesta_admin"]}", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: estadoColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: estadoColor.withOpacity(0.3)),
                              ),
                              child: Text(s["estado"] ?? "", style: TextStyle(color: estadoColor, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ===== MENÚ =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.edit_rounded,
                    texto: "Editar perfil",
                    primary: _primary,
                    cardBg: _cardBg,
                    textColor: _textColor,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdateUserScreen())),
                  ),
                  _MenuTile(
                    icon: Icons.delete_outline_rounded,
                    texto: "Eliminar cuenta",
                    primary: Colors.red,
                    cardBg: _cardBg,
                    textColor: _textColor,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DeleteUserScreen())),
                  ),
                  _MenuTile(
                    icon: Icons.logout_rounded,
                    texto: "Cerrar sesión",
                    primary: _primary,
                    cardBg: _cardBg,
                    textColor: _textColor,
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove("cedula");
                      await prefs.remove("nombre");
                      await prefs.remove("tipo_usuario");
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomeScreen(nombre: "Invitado", cedula: "")),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

// =========================
// WIDGETS AUXILIARES
// =========================

class _SectionTitle extends StatelessWidget {
  final String titulo;
  final String icono;
  final Color textColor;
  const _SectionTitle({required this.titulo, required this.icono, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icono, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 7),
        Text(
          titulo,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Color primary;
  final Color cardBg;
  final bool esVip;
  const _EmptyState({required this.primary, required this.cardBg, required this.esVip});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: esVip ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.15)) : null,
      ),
      child: Column(
        children: [
          Icon(Icons.luggage_rounded, size: 44, color: primary.withOpacity(0.25)),
          const SizedBox(height: 10),
          Text("Aún no tienes reservas", style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          const SizedBox(height: 3),
          Text("¡Explora y reserva tu primer viaje!", style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CounterBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

// =========================
// 📦 COMPRA CARD
// =========================
class _CompraCard extends StatelessWidget {
  final Map compra;
  final bool esVip;
  final Color primary;
  final Color cardBg;
  final Color textColor;
  final VoidCallback onSolicitarEdicion;

  const _CompraCard({
    required this.compra,
    required this.esVip,
    required this.primary,
    required this.cardBg,
    required this.textColor,
    required this.onSolicitarEdicion,
  });

  Color _colorTipo() {
    switch (compra["tipo"]) {
      case "hotel": return const Color(0xFF9B59B6);
      case "vuelo": return const Color(0xFF4F8EF7);
      case "tour":  return const Color(0xFFE67E22);
      default:      return const Color(0xFF27AE60);
    }
  }

  IconData _iconoTipo() {
    switch (compra["tipo"]) {
      case "hotel": return Icons.hotel_rounded;
      case "vuelo": return Icons.flight_rounded;
      case "tour":  return Icons.tour_rounded;
      default:      return Icons.explore_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipoColor = _colorTipo();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: esVip
            ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.18))
            : Border.all(color: Colors.grey.withOpacity(0.07)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(esVip ? 0.25 : 0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    compra["imagen"] ?? "",
                    width: 68,
                    height: 68,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 68, height: 68,
                      decoration: BoxDecoration(
                        color: tipoColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_iconoTipo(), color: tipoColor, size: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              compra["nombre_producto"] ?? "",
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: textColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Tipo badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: tipoColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_iconoTipo(), size: 10, color: tipoColor),
                                const SizedBox(width: 3),
                                Text(
                                  (compra["tipo"] ?? "").toString().toUpperCase(),
                                  style: TextStyle(fontSize: 9, color: tipoColor, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        compra["precio"] ?? "",
                        style: TextStyle(color: primary, fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      if (compra["precio_total"] != null)
                        Text("Total: \$${compra["precio_total"]}", style: TextStyle(color: primary, fontSize: 11)),
                      if (compra["fecha_ida"] != null) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.flight_takeoff_rounded, size: 11, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text("${compra["fecha_ida"]} → ${compra["fecha_vuelta"]}", style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                          ],
                        ),
                      ],
                      if (compra["personas"] != null)
                        Row(
                          children: [
                            Icon(Icons.people_rounded, size: 11, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text("${compra["personas"]} personas", style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                          ],
                        ),
                      if (compra["fecha_compra"] != null)
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 10, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(compra["fecha_compra"].toString().substring(0, 10), style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Botón solicitar cambio — compacto
            GestureDetector(
              onTap: onSolicitarEdicion,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: primary.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_calendar_rounded, color: primary, size: 14),
                    const SizedBox(width: 7),
                    Text("Solicitar cambio de fechas", style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// STAT CARD
// =========================
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;
  final Color primary;
  final Color cardBg;
  final Color textColor;
  final bool esVip;

  const _StatCard({
    required this.icon,
    required this.titulo,
    required this.valor,
    required this.primary,
    required this.cardBg,
    required this.textColor,
    required this.esVip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: esVip
            ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2))
            : Border.all(color: Colors.grey.withOpacity(0.07)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(esVip ? 0.2 : 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primary, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: textColor, letterSpacing: -0.5),
          ),
          const SizedBox(height: 2),
          Text(titulo, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          const SizedBox(height: 5),
          Text(
            "Ver →",
            style: TextStyle(fontSize: 9, color: primary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// =========================
// MENU TILE
// =========================
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String texto;
  final VoidCallback onTap;
  final Color primary;
  final Color cardBg;
  final Color textColor;

  const _MenuTile({
    required this.icon,
    required this.texto,
    required this.onTap,
    required this.primary,
    required this.cardBg,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.07)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: primary, size: 17),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}