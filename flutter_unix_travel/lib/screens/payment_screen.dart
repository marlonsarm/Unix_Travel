import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
 
const String baseUrl = "http://127.0.0.1:5000";
 
class PaymentScreen extends StatefulWidget {
  final String cedula;
  final String nombre;
  final String precio;
  final String imagen;
  final String tipo;
  final bool esVip;
  final Map? vueloSeleccionado;
  final Map? hotelSeleccionado;
  final Map? tourSeleccionado;
  // 🔥 NUEVO: fechas ya seleccionadas desde detail_screen
  final DateTime? fechaIdaPreseleccionada;
  final DateTime? fechaVueltaPreseleccionada;
 
  const PaymentScreen({
    super.key,
    required this.cedula,
    required this.nombre,
    required this.precio,
    required this.imagen,
    required this.tipo,
    this.esVip = false,
    this.vueloSeleccionado,
    this.hotelSeleccionado,
    this.tourSeleccionado,
    this.fechaIdaPreseleccionada,
    this.fechaVueltaPreseleccionada,
  });
 
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}
 
class _PaymentScreenState extends State<PaymentScreen> with TickerProviderStateMixin {
 
  int paso = 0;
  late DateTime? fechaIda;
  late DateTime? fechaVuelta;
  int personas = 1;
  String metodoPago = "";
  bool procesando = false;
  bool mostrarFrente = true;
 
  final _numCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
 
  late AnimationController _flipController;
  late AnimationController _procesandoController;
  late Animation<double> _flipAnimation;
 
  Color get _primary => widget.esVip ? const Color(0xFFD4AF37) : const Color(0xFF2C5364);
  Color get _bg => widget.esVip ? const Color(0xFF0A0A0A) : const Color(0xFFF4F6FA);
  Color get _cardBg => widget.esVip ? const Color(0xFF1A1A1A) : Colors.white;
  Color get _textColor => widget.esVip ? Colors.white : Colors.black87;
 
  bool get _esPlanCompleto => widget.vueloSeleccionado != null;
  // 🔥 Si vienen fechas preseleccionadas, empezar en paso 1 directamente
  bool get _tienenFechasPreseleccionadas => widget.fechaIdaPreseleccionada != null;
 
  double _parsearPrecio(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 0;
    final limpio = raw.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(limpio) ?? 0;
  }
 
  double calcularTotal() {
    if (_esPlanCompleto) {
      double total = 0;
      total += _parsearPrecio(widget.vueloSeleccionado?["precio"]?.toString()) * personas;
      if (widget.hotelSeleccionado != null) {
        total += _parsearPrecio(widget.hotelSeleccionado!["precio_noche"]?.toString()) * personas;
      }
      if (widget.tourSeleccionado != null) {
        total += _parsearPrecio(widget.tourSeleccionado!["precio"]?.toString()) * personas;
      }
      return total;
    }
    return _parsearPrecio(widget.precio) * personas;
  }
 
  @override
  void initState() {
    super.initState();
    // 🔥 Pre-cargar fechas si vienen del detail_screen
    fechaIda = widget.fechaIdaPreseleccionada;
    fechaVuelta = widget.fechaVueltaPreseleccionada;
    // 🔥 Si ya tienen fechas, saltar directamente al paso de método de pago
    if (_tienenFechasPreseleccionadas) paso = 1;
 
    _flipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _procesandoController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _flipController, curve: Curves.easeInOut));
  }
 
  @override
  void dispose() {
    _flipController.dispose();
    _procesandoController.dispose();
    _numCtrl.dispose();
    _nombreCtrl.dispose();
    _fechaCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }
 
  void _flipTarjeta(bool alFrente) {
    if (alFrente && !mostrarFrente) {
      _flipController.reverse();
      setState(() => mostrarFrente = true);
    } else if (!alFrente && mostrarFrente) {
      _flipController.forward();
      setState(() => mostrarFrente = false);
    }
  }
 
  Future<void> _procesarPago() async {
    setState(() => procesando = true);
    await Future.delayed(const Duration(seconds: 3));
    try {
      if (_esPlanCompleto) {
        await _agregarItem(nombre: "${widget.vueloSeleccionado!["origen"]} → ${widget.vueloSeleccionado!["destino"]}", precio: widget.vueloSeleccionado!["precio"] ?? "", imagen: widget.vueloSeleccionado!["imagen"] ?? "", tipo: "vuelo");
        if (widget.hotelSeleccionado != null) {
          await _agregarItem(nombre: widget.hotelSeleccionado!["nombre"] ?? "", precio: widget.hotelSeleccionado!["precio_noche"] ?? "", imagen: widget.hotelSeleccionado!["imagen"] ?? "", tipo: "hotel");
        }
        if (widget.tourSeleccionado != null) {
          await _agregarItem(nombre: widget.tourSeleccionado!["nombre"] ?? "", precio: widget.tourSeleccionado!["precio"] ?? "", imagen: widget.tourSeleccionado!["imagen"] ?? "", tipo: "tour");
        }
      } else {
        await _agregarItem(nombre: widget.nombre, precio: widget.precio, imagen: widget.imagen, tipo: widget.tipo);
      }
      await http.post(Uri.parse("$baseUrl/pagar/${widget.cedula}"), headers: {"Content-Type": "application/json"});
      setState(() { procesando = false; paso = 4; });
    } catch (e) {
      setState(() => procesando = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al procesar el pago")));
    }
  }
 
  Future<void> _agregarItem({required String nombre, required String precio, required String imagen, required String tipo}) async {
    await http.post(
      Uri.parse("$baseUrl/agregar_carrito"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "usuario_cedula": widget.cedula,
        "nombre": nombre,
        "precio": precio,
        "imagen": imagen,
        "fecha_ida": fechaIda != null ? "${fechaIda!.year}-${fechaIda!.month.toString().padLeft(2, '0')}-${fechaIda!.day.toString().padLeft(2, '0')}" : null,
        "fecha_vuelta": fechaVuelta != null ? "${fechaVuelta!.year}-${fechaVuelta!.month.toString().padLeft(2, '0')}-${fechaVuelta!.day.toString().padLeft(2, '0')}" : null,
        "personas": personas,
        "tipo": tipo,
        "precio_total": calcularTotal().toStringAsFixed(0),
      }),
    );
  }
 
  String _fechaLegible(DateTime? f) {
    if (f == null) return "Sin fecha";
    const m = ["Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic"];
    return "${f.day} ${m[f.month-1]} ${f.year}";
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: paso == 4 ? null : AppBar(
        backgroundColor: widget.esVip ? const Color(0xFF0A0A0A) : const Color(0xFF0F2027),
        elevation: 0,
        title: Text(
          _tienenFechasPreseleccionadas
              ? ["Método de pago", "Datos de tarjeta", "Confirmación"][paso.clamp(1, 3) - 1]
              : ["Fechas y viajeros", "Método de pago", "Datos de tarjeta", "Confirmación"][paso.clamp(0, 3)],
          style: TextStyle(color: widget.esVip ? const Color(0xFFD4AF37) : Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: widget.esVip ? const Color(0xFFD4AF37) : Colors.white),
      ),
      body: paso == 4 ? _pantallaExito() : Column(
        children: [
          // Barra de progreso
          Container(
            color: widget.esVip ? const Color(0xFF0A0A0A) : const Color(0xFF0F2027),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
            child: Row(
              children: List.generate(_tienenFechasPreseleccionadas ? 3 : 4, (i) => Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: (_tienenFechasPreseleccionadas ? i + 1 <= paso : i <= paso) ? _primary : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              )),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildResumenPlan(),
                  const SizedBox(height: 20),
                  if (paso == 0 && !_tienenFechasPreseleccionadas) _buildPaso0(),
                  if (paso == 1) _buildPaso1(),
                  if (paso == 2) _buildPaso2(),
                  if (paso == 3) _buildPaso3(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  Widget _buildResumenPlan() {
    if (_esPlanCompleto) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: widget.esVip ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.35)) : Border.all(color: Colors.grey.withOpacity(0.15)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(widget.esVip ? 0.3 : 0.06), blurRadius: 15, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _primary.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.luggage_rounded, color: _primary, size: 18)),
              const SizedBox(width: 10),
              Text("Tu plan de viaje", style: TextStyle(fontWeight: FontWeight.bold, color: _textColor, fontSize: 15)),
              const Spacer(),
              // 🔥 Muestra fechas preseleccionadas
              if (_tienenFechasPreseleccionadas)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    "${_fechaLegible(fechaIda)} → ${_fechaLegible(fechaVuelta)}",
                    style: TextStyle(color: _primary, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ]),
            const SizedBox(height: 14),
            _filaPlanMejorada("Destino", widget.nombre, "", Icons.location_on_rounded, obligatorio: true),
            _filaPlanMejorada("Vuelo", "${widget.vueloSeleccionado!["origen"]} → ${widget.vueloSeleccionado!["destino"]}", widget.vueloSeleccionado!["precio"] ?? "", Icons.flight_rounded, obligatorio: true),
            if (widget.hotelSeleccionado != null)
              _filaPlanMejorada("Hotel", widget.hotelSeleccionado!["nombre"] ?? "", widget.hotelSeleccionado!["precio_noche"] ?? "", Icons.hotel_rounded),
            if (widget.tourSeleccionado != null)
              _filaPlanMejorada("Tour", widget.tourSeleccionado!["nombre"] ?? "", widget.tourSeleccionado!["precio"] ?? "", Icons.tour_rounded),
            const SizedBox(height: 10),
            Container(height: 1, color: _primary.withOpacity(0.2)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total base", style: TextStyle(color: _subTextColor, fontSize: 12)),
                RichText(text: TextSpan(children: [
                  TextSpan(text: "\$${calcularTotal().toStringAsFixed(0)}", style: TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 15)),
                  TextSpan(text: " × $personas persona${personas > 1 ? 's' : ''}", style: TextStyle(color: _subTextColor, fontSize: 11)),
                ])),
              ],
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: widget.esVip ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)) : null),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(widget.imagen, width: 65, height: 65, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 65, height: 65, color: Colors.grey[800]))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.nombre, style: TextStyle(fontWeight: FontWeight.bold, color: _textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(widget.precio, style: TextStyle(color: _primary, fontWeight: FontWeight.bold)),
          Text(widget.tipo.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ])),
        Text("\$${calcularTotal().toStringAsFixed(0)}", style: TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 16)),
      ]),
    );
  }
 
  Color get _subTextColor => widget.esVip ? const Color(0xFFD4AF37).withOpacity(0.6) : Colors.grey;
 
  Widget _filaPlanMejorada(String tipo, String nombre, String precio, IconData icono, {bool obligatorio = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _primary.withOpacity(obligatorio ? 0.07 : 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _primary.withOpacity(obligatorio ? 0.2 : 0.08)),
      ),
      child: Row(children: [
        Icon(icono, color: _primary, size: 15),
        const SizedBox(width: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: _primary.withOpacity(0.15), borderRadius: BorderRadius.circular(5)), child: Text(tipo, style: TextStyle(color: _primary, fontSize: 9, fontWeight: FontWeight.bold))),
        const SizedBox(width: 8),
        Expanded(child: Text(nombre, style: TextStyle(color: _textColor, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
        if (precio.isNotEmpty) Text(precio, style: TextStyle(color: _primary, fontSize: 12, fontWeight: FontWeight.bold)),
      ]),
    );
  }
 
  Widget _buildPaso0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Planifica tu viaje", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textColor)),
        const SizedBox(height: 5),
        Text("Selecciona fechas y número de viajeros", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: _buildFechaTile(Icons.flight_takeoff, "Ida", fechaIda == null ? "Seleccionar" : _fechaLegible(fechaIda), () async {
            final p = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
            if (p != null) setState(() => fechaIda = p);
          })),
          const SizedBox(width: 10),
          Expanded(child: _buildFechaTile(Icons.flight_land, "Vuelta", fechaVuelta == null ? "Seleccionar" : _fechaLegible(fechaVuelta), () async {
            final p = await showDatePicker(context: context, initialDate: fechaIda ?? DateTime.now(), firstDate: fechaIda ?? DateTime.now(), lastDate: DateTime(2030));
            if (p != null) setState(() => fechaVuelta = p);
          })),
        ]),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(14), border: widget.esVip ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)) : null),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Viajeros", style: TextStyle(fontWeight: FontWeight.bold, color: _textColor)),
                Text("Número de personas", style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ]),
              Row(children: [
                _buildBotonCantidad(Icons.remove, () { if (personas > 1) setState(() => personas--); }),
                Container(margin: const EdgeInsets.symmetric(horizontal: 15), child: Text("$personas", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textColor))),
                _buildBotonCantidad(Icons.add, () => setState(() => personas++)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [_primary.withOpacity(0.1), _primary.withOpacity(0.05)]), borderRadius: BorderRadius.circular(14), border: Border.all(color: _primary.withOpacity(0.3))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text("Total estimado", style: TextStyle(fontWeight: FontWeight.bold, color: _textColor)),
            Text("\$${calcularTotal().toStringAsFixed(0)}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _primary)),
          ]),
        ),
        const SizedBox(height: 25),
        _buildBotonPrincipal("Continuar", () {
          if (fechaIda == null || fechaVuelta == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecciona las fechas")));
            return;
          }
          if (fechaVuelta!.isBefore(fechaIda!)) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("La fecha de vuelta no puede ser antes de la ida")));
            return;
          }
          setState(() => paso = 1);
        }),
      ],
    );
  }
 
  Widget _buildPaso1() {
    // 🔥 Si vienen fechas preseleccionadas, muestra resumen de fechas + viajeros primero
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔥 Resumen de fechas si vienen preseleccionadas
        if (_tienenFechasPreseleccionadas) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _primary.withOpacity(0.25))),
            child: Column(children: [
              Row(children: [
                Icon(Icons.calendar_month_rounded, color: _primary, size: 16),
                const SizedBox(width: 8),
                Text("Fechas de viaje", style: TextStyle(fontWeight: FontWeight.bold, color: _textColor, fontSize: 13)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _buildFechaTile(Icons.flight_takeoff_rounded, "Ida", _fechaLegible(fechaIda), () async {
                  final p = await showDatePicker(context: context, initialDate: fechaIda ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                  if (p != null) setState(() => fechaIda = p);
                })),
                const SizedBox(width: 10),
                Expanded(child: _buildFechaTile(Icons.flight_land_rounded, "Vuelta", _fechaLegible(fechaVuelta), () async {
                  final p = await showDatePicker(context: context, initialDate: fechaVuelta ?? DateTime.now(), firstDate: fechaIda ?? DateTime.now(), lastDate: DateTime(2030));
                  if (p != null) setState(() => fechaVuelta = p);
                })),
              ]),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Viajeros", style: TextStyle(fontWeight: FontWeight.bold, color: _textColor, fontSize: 13)),
                  Text("Número de personas", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ]),
                Row(children: [
                  _buildBotonCantidad(Icons.remove, () { if (personas > 1) setState(() => personas--); }),
                  Container(margin: const EdgeInsets.symmetric(horizontal: 15), child: Text("$personas", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textColor))),
                  _buildBotonCantidad(Icons.add, () => setState(() => personas++)),
                ]),
              ]),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(gradient: LinearGradient(colors: [_primary.withOpacity(0.12), _primary.withOpacity(0.05)]), borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("Total estimado", style: TextStyle(fontWeight: FontWeight.bold, color: _textColor, fontSize: 13)),
                  Text("\$${calcularTotal().toStringAsFixed(0)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primary)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 20),
        ],
 
        Text("Método de pago", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textColor)),
        const SizedBox(height: 5),
        Text("Elige cómo quieres pagar", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 20),
        ...[
          {"id": "tarjeta", "nombre": "Tarjeta Crédito / Débito", "icon": Icons.credit_card, "desc": "Visa, Mastercard, Amex, Diners"},
          {"id": "pse", "nombre": "PSE", "icon": Icons.account_balance, "desc": "Transferencia bancaria en línea"},
          {"id": "nequi", "nombre": "Nequi", "icon": Icons.phone_android, "desc": "Pago desde tu app Nequi"},
          {"id": "daviplata", "nombre": "Daviplata", "icon": Icons.phone_android, "desc": "Pago desde tu app Daviplata"},
          {"id": "efecty", "nombre": "Efecty", "icon": Icons.store, "desc": "Pago en puntos Efecty"},
        ].map((m) {
          final sel = metodoPago == m["id"];
          return GestureDetector(
            onTap: () => setState(() => metodoPago = m["id"] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: sel ? _primary.withOpacity(0.1) : _cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: sel ? _primary : Colors.grey.withOpacity(0.2), width: sel ? 2 : 1),
              ),
              child: Row(children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: sel ? _primary.withOpacity(0.15) : Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(m["icon"] as IconData, color: sel ? _primary : Colors.grey, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(m["nombre"] as String, style: TextStyle(fontWeight: FontWeight.bold, color: _textColor)),
                  Text(m["desc"] as String, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ])),
                if (sel) Icon(Icons.check_circle, color: _primary),
              ]),
            ),
          );
        }).toList(),
        const SizedBox(height: 20),
        _buildBotonesNavegacion(
          onAtras: () => setState(() => paso = _tienenFechasPreseleccionadas ? 1 : 0),
          onContinuar: () {
            if (metodoPago.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecciona un método de pago"))); return; }
            setState(() => paso = metodoPago == "tarjeta" ? 2 : 3);
          },
        ),
      ],
    );
  }
 
  Widget _buildPaso2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Datos de tu tarjeta", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textColor)),
        const SizedBox(height: 20),
        Center(
          child: AnimatedBuilder(
            animation: _flipAnimation,
            builder: (_, __) {
              final angulo = _flipAnimation.value * pi;
              final mostrarFront = angulo < pi / 2;
              return Transform(alignment: Alignment.center, transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angulo),
                child: mostrarFront ? _buildTarjetaFrente() : Transform(alignment: Alignment.center, transform: Matrix4.identity()..rotateY(pi), child: _buildTarjetaDorso()));
            },
          ),
        ),
        const SizedBox(height: 25),
        _buildCampoTarjeta(label: "Número de tarjeta", controller: _numCtrl, hint: "0000 0000 0000 0000", icon: Icons.credit_card, tipo: TextInputType.number, onTap: () => _flipTarjeta(true), formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)], onChanged: (v) => setState(() {})),
        const SizedBox(height: 12),
        _buildCampoTarjeta(label: "Nombre en la tarjeta", controller: _nombreCtrl, hint: "NOMBRE APELLIDO", icon: Icons.person_outline, onTap: () => _flipTarjeta(true), onChanged: (v) => setState(() {})),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _buildCampoTarjeta(label: "Vencimiento", controller: _fechaCtrl, hint: "MM/AA", icon: Icons.calendar_today, tipo: TextInputType.number, onTap: () => _flipTarjeta(true), formatters: [LengthLimitingTextInputFormatter(5)], onChanged: (v) => setState(() {}))),
          const SizedBox(width: 12),
          Expanded(child: _buildCampoTarjeta(label: "CVV", controller: _cvvCtrl, hint: "•••", icon: Icons.lock_outline, tipo: TextInputType.number, onTap: () => _flipTarjeta(false), formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)], onChanged: (v) => setState(() {}))),
        ]),
        const SizedBox(height: 20),
        _buildBotonesNavegacion(
          onAtras: () => setState(() => paso = 1),
          onContinuar: () {
            if (_numCtrl.text.length < 16 || _nombreCtrl.text.isEmpty || _fechaCtrl.text.length < 5 || _cvvCtrl.text.length < 3) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Completa todos los datos de la tarjeta")));
              return;
            }
            setState(() => paso = 3);
          },
        ),
      ],
    );
  }
 
  Widget _buildTarjetaFrente() {
    return Container(
      width: double.infinity, height: 190,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: widget.esVip ? [const Color(0xFF1A1200), const Color(0xFF3D2B00), const Color(0xFFD4AF37)] : [const Color(0xFF0F2027), const Color(0xFF2C5364)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: (widget.esVip ? const Color(0xFFD4AF37) : const Color(0xFF2C5364)).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("UNIX TRAVEL", style: TextStyle(color: widget.esVip ? const Color(0xFFD4AF37) : Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12)),
          if (widget.esVip) const Text("👑", style: TextStyle(fontSize: 20)),
        ]),
        const SizedBox(height: 20),
        Text(_numCtrl.text.isEmpty ? "•••• •••• •••• ••••" : _formatearNumero(_numCtrl.text), style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 3, fontWeight: FontWeight.bold)),
        const Spacer(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("TITULAR", style: TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1)),
            Text(_nombreCtrl.text.isEmpty ? "NOMBRE APELLIDO" : _nombreCtrl.text.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("VENCE", style: TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1)),
            Text(_fechaCtrl.text.isEmpty ? "MM/AA" : _fechaCtrl.text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          ]),
        ]),
      ]),
    );
  }
 
  Widget _buildTarjetaDorso() {
    return Container(
      width: double.infinity, height: 190,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: widget.esVip ? [const Color(0xFF3D2B00), const Color(0xFF1A1200)] : [const Color(0xFF2C5364), const Color(0xFF0F2027)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(height: 45, color: Colors.black54),
        const SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(margin: const EdgeInsets.only(right: 20), padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: Text(_cvvCtrl.text.isEmpty ? "•••" : _cvvCtrl.text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 3))),
        ]),
      ]),
    );
  }
 
  String _formatearNumero(String num) {
    final limpio = num.replaceAll(" ", "");
    final partes = <String>[];
    for (int i = 0; i < limpio.length; i += 4) { partes.add(limpio.substring(i, min(i + 4, limpio.length))); }
    return partes.join(" ");
  }
 
  Widget _buildPaso3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Confirma tu reserva", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textColor)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: widget.esVip ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)) : null),
          child: Column(children: [
            if (_esPlanCompleto) ...[
              _filaResumen("Destino", widget.nombre),
              _filaResumen("Vuelo", "${widget.vueloSeleccionado!["origen"]} → ${widget.vueloSeleccionado!["destino"]}"),
              if (widget.hotelSeleccionado != null) _filaResumen("Hotel", widget.hotelSeleccionado!["nombre"] ?? ""),
              if (widget.tourSeleccionado != null) _filaResumen("Tour", widget.tourSeleccionado!["nombre"] ?? ""),
            ] else _filaResumen("Reserva", widget.nombre),
            _filaResumen("Fechas", fechaIda != null ? "${_fechaLegible(fechaIda)} → ${_fechaLegible(fechaVuelta)}" : "Sin fechas"),
            _filaResumen("Viajeros", "$personas persona${personas > 1 ? 's' : ''}"),
            _filaResumen("Pago", metodoPago.toUpperCase()),
            if (metodoPago == "tarjeta" && _numCtrl.text.length >= 4)
              _filaResumen("Tarjeta", "•••• •••• •••• ${_numCtrl.text.substring(_numCtrl.text.length - 4)}"),
            const Divider(height: 25),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("TOTAL A PAGAR", style: TextStyle(fontWeight: FontWeight.bold, color: _textColor, fontSize: 15)),
              Text("\$${calcularTotal().toStringAsFixed(0)}", style: TextStyle(fontWeight: FontWeight.bold, color: _primary, fontSize: 24)),
            ]),
          ]),
        ),
        const SizedBox(height: 20),
        if (procesando) _buildProcesando()
        else _buildBotonesNavegacion(
          onAtras: () => setState(() => paso = metodoPago == "tarjeta" ? 2 : 1),
          onContinuar: _procesarPago,
          textoContinuar: "Confirmar y pagar",
        ),
      ],
    );
  }
 
  Widget _buildProcesando() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: widget.esVip ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)) : null),
      child: Column(children: [
        AnimatedBuilder(animation: _procesandoController, builder: (_, __) => Transform.rotate(angle: _procesandoController.value * 2 * pi, child: Icon(Icons.autorenew, color: _primary, size: 40))),
        const SizedBox(height: 15),
        Text("Procesando tu pago...", style: TextStyle(fontWeight: FontWeight.bold, color: _textColor, fontSize: 16)),
        const SizedBox(height: 8),
        Text("Por favor no cierres esta pantalla", style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 15),
        LinearProgressIndicator(backgroundColor: Colors.grey.withOpacity(0.2), valueColor: AlwaysStoppedAnimation(_primary)),
      ]),
    );
  }
 
  Widget _pantallaExito() {
    return Container(
      width: double.infinity, height: double.infinity,
      decoration: BoxDecoration(gradient: widget.esVip
          ? const LinearGradient(colors: [Color(0xFF0A0A0A), Color(0xFF1A1200), Color(0xFF0A0A0A)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
          : const LinearGradient(colors: [Color(0xFF0F2027), Color(0xFF2C5364)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: SafeArea(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (widget.esVip) ...[
          const Text("👑", style: TextStyle(fontSize: 90)),
          const SizedBox(height: 20),
          const Text("BIENVENIDO AL CLUB VIP", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 10),
          Container(margin: const EdgeInsets.symmetric(horizontal: 40), padding: const EdgeInsets.all(15), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)), borderRadius: BorderRadius.circular(15)),
            child: const Text("Tu experiencia de viaje nunca será la misma. Accedes a beneficios exclusivos, upgrades y atención personalizada.", style: TextStyle(color: Color(0xFFD4AF37), fontSize: 13, height: 1.6), textAlign: TextAlign.center)),
        ] else ...[
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: Colors.greenAccent, width: 2)),
            child: const Icon(Icons.check, color: Colors.greenAccent, size: 60)),
          const SizedBox(height: 20),
          const Text("Reserva Confirmada", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text("Tu plan de viaje a ${widget.nombre} fue procesado exitosamente.", style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6), textAlign: TextAlign.center)),
        ],
        const SizedBox(height: 40),
        // 🔥 FIX: Se usa Navigator.pop() para cerrar solo el PaymentScreen
        // y regresar a la pantalla anterior SIN cerrar sesión.
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: widget.esVip ? const Color(0xFFD4AF37) : Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.esVip ? "Gracias por elegir unix travel" : "Iniciar Sesion para mayor seguridad ", style: TextStyle(color: widget.esVip ? Colors.black : const Color(0xFF0F2027), fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ])),
    );
  }
 
  Widget _buildFechaTile(IconData icon, String label, String valor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: valor == "Seleccionar" ? Colors.grey.withOpacity(0.3) : _primary.withOpacity(0.5))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, size: 14, color: _primary), const SizedBox(width: 5), Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 5),
          Text(valor, style: TextStyle(fontWeight: FontWeight.bold, color: _textColor, fontSize: 13)),
        ]),
      ),
    );
  }
 
  Widget _buildBotonCantidad(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: _primary.withOpacity(0.3))), child: Icon(icon, color: _primary, size: 18)),
    );
  }
 
  Widget _buildCampoTarjeta({required String label, required TextEditingController controller, required String hint, required IconData icon, TextInputType tipo = TextInputType.text, required VoidCallback onTap, List<TextInputFormatter>? formatters, required Function(String) onChanged}) {
    return Container(
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: _primary.withOpacity(0.2))),
      child: TextField(
        controller: controller, keyboardType: tipo, inputFormatters: formatters,
        style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
        onTap: onTap, onChanged: onChanged,
        decoration: InputDecoration(prefixIcon: Icon(icon, color: _primary, size: 18), labelText: label, labelStyle: const TextStyle(color: Colors.grey, fontSize: 12), hintText: hint, hintStyle: const TextStyle(color: Colors.grey), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16)),
      ),
    );
  }
 
  Widget _buildBotonPrincipal(String texto, VoidCallback onTap) {
    return SizedBox(width: double.infinity, height: 55,
      child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0), onPressed: onTap, child: Text(texto, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.esVip ? Colors.black : Colors.white))));
  }
 
  Widget _buildBotonesNavegacion({required VoidCallback onAtras, required VoidCallback onContinuar, String textoContinuar = "Continuar"}) {
    return Row(children: [
      Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(side: BorderSide(color: _primary), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), onPressed: onAtras, child: Text("Atrás", style: TextStyle(color: _primary)))),
      const SizedBox(width: 10),
      Expanded(flex: 2, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _primary, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0), onPressed: onContinuar, child: Text(textoContinuar, style: TextStyle(fontWeight: FontWeight.bold, color: widget.esVip ? Colors.black : Colors.white)))),
    ]);
  }
 
  Widget _filaResumen(String label, String valor) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      Flexible(child: Text(valor, style: TextStyle(fontWeight: FontWeight.bold, color: _textColor, fontSize: 13), textAlign: TextAlign.end)),
    ]));
  }
}