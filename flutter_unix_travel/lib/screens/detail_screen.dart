import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'payment_screen.dart';
import 'login_screen.dart';

const String baseUrl = "http://127.0.0.1:5000";

// 🔥 IMÁGENES REALES POR DESTINO — UNSPLASH ALTA CALIDAD (FALLBACK GARANTIZADO)
const Map<String, List<String>> _imagenesRealesPorDestino = {
  "san andres": [
    "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1200&q=90",
    "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200&q=90",
    "https://images.unsplash.com/photo-1559494007-9f5847c49d94?w=1200&q=90",
    "https://images.unsplash.com/photo-1580541631950-7282082b53ce?w=1200&q=90",
    "https://images.unsplash.com/photo-1519046904884-53103b34b206?w=1200&q=90",
    "https://images.unsplash.com/photo-1530053969600-caed2596d242?w=1200&q=90",
    "https://images.unsplash.com/photo-1475924156734-496f6cac6ec1?w=1200&q=90",
    "https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=1200&q=90",
    "https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=1200&q=90",
    "https://images.unsplash.com/photo-1433086966358-54859d0ed716?w=1200&q=90",
  ],
  "san andrés": [
    "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1200&q=90",
    "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200&q=90",
    "https://images.unsplash.com/photo-1559494007-9f5847c49d94?w=1200&q=90",
    "https://images.unsplash.com/photo-1580541631950-7282082b53ce?w=1200&q=90",
    "https://images.unsplash.com/photo-1519046904884-53103b34b206?w=1200&q=90",
    "https://images.unsplash.com/photo-1530053969600-caed2596d242?w=1200&q=90",
    "https://images.unsplash.com/photo-1475924156734-496f6cac6ec1?w=1200&q=90",
    "https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=1200&q=90",
    "https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=1200&q=90",
    "https://images.unsplash.com/photo-1433086966358-54859d0ed716?w=1200&q=90",
  ],
  "cartagena": [
    "https://images.unsplash.com/photo-1583997052103-b4a1cb974ce5?w=1200&q=90",
    "https://images.unsplash.com/photo-1601465552814-5b8e5f3c26d0?w=1200&q=90",
    "https://images.unsplash.com/photo-1570168007204-dfb528c6958f?w=1200&q=90",
    "https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?w=1200&q=90",
    "https://images.unsplash.com/photo-1504512485720-7d83a16ee930?w=1200&q=90",
    "https://images.unsplash.com/photo-1555400038-63f5ba517a47?w=1200&q=90",
    "https://images.unsplash.com/photo-1596422846543-75c6fc197f07?w=1200&q=90",
    "https://images.unsplash.com/photo-1534430480872-3498386e7856?w=1200&q=90",
    "https://images.unsplash.com/photo-1519451241324-20b4ea2c4220?w=1200&q=90",
  ],
  "medellín": [
    "https://images.unsplash.com/photo-1598256989800-fe5f95da9787?w=1200&q=90",
    "https://images.unsplash.com/photo-1562883676-8c7feb83f09b?w=1200&q=90",
    "https://images.unsplash.com/photo-1559827291-72ee739d0d9a?w=1200&q=90",
    "https://images.unsplash.com/photo-1520341280432-4749d4d7bcf9?w=1200&q=90",
    "https://images.unsplash.com/photo-1518183214770-9cffbec72538?w=1200&q=90",
    "https://images.unsplash.com/photo-1567448400815-0b7bec7a7748?w=1200&q=90",
    "https://images.unsplash.com/photo-1531572753322-ad063cecc140?w=1200&q=90",
    "https://images.unsplash.com/photo-1501854140801-50d01698950b?w=1200&q=90",
  ],
  "medellin": [
    "https://images.unsplash.com/photo-1598256989800-fe5f95da9787?w=1200&q=90",
    "https://images.unsplash.com/photo-1562883676-8c7feb83f09b?w=1200&q=90",
    "https://images.unsplash.com/photo-1559827291-72ee739d0d9a?w=1200&q=90",
    "https://images.unsplash.com/photo-1520341280432-4749d4d7bcf9?w=1200&q=90",
    "https://images.unsplash.com/photo-1501854140801-50d01698950b?w=1200&q=90",
  ],
  "santa marta": [
    "https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?w=1200&q=90",
    "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200&q=90",
    "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1200&q=90",
    "https://images.unsplash.com/photo-1559494007-9f5847c49d94?w=1200&q=90",
    "https://images.unsplash.com/photo-1580541631950-7282082b53ce?w=1200&q=90",
    "https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=1200&q=90",
  ],
  "punta cana": [
    "https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=1200&q=90",
    "https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?w=1200&q=90",
    "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200&q=90",
    "https://images.unsplash.com/photo-1564530497978-8c53f51e9cbc?w=1200&q=90",
    "https://images.unsplash.com/photo-1596422846543-75c6fc197f07?w=1200&q=90",
    "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1200&q=90",
    "https://images.unsplash.com/photo-1530053969600-caed2596d242?w=1200&q=90",
    "https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=1200&q=90",
  ],
  "bogotá": [
    "https://images.unsplash.com/photo-1588546642610-e9ee6b8bece5?w=1200&q=90",
    "https://images.unsplash.com/photo-1534430480872-3498386e7856?w=1200&q=90",
    "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200&q=90",
    "https://images.unsplash.com/photo-1501854140801-50d01698950b?w=1200&q=90",
    "https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=1200&q=90",
  ],
  "bogota": [
    "https://images.unsplash.com/photo-1588546642610-e9ee6b8bece5?w=1200&q=90",
    "https://images.unsplash.com/photo-1534430480872-3498386e7856?w=1200&q=90",
    "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200&q=90",
    "https://images.unsplash.com/photo-1501854140801-50d01698950b?w=1200&q=90",
  ],
  "cancun": [
    "https://images.unsplash.com/photo-1552074284-5e88ef1aef18?w=1200&q=90",
    "https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=1200&q=90",
    "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200&q=90",
    "https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?w=1200&q=90",
    "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1200&q=90",
    "https://images.unsplash.com/photo-1530053969600-caed2596d242?w=1200&q=90",
  ],
  "cancún": [
    "https://images.unsplash.com/photo-1552074284-5e88ef1aef18?w=1200&q=90",
    "https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=1200&q=90",
    "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200&q=90",
  ],
  "miami": [
    "https://images.unsplash.com/photo-1533106497176-45ae19e68ba2?w=1200&q=90",
    "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200&q=90",
    "https://images.unsplash.com/photo-1535498730771-e735b998cd64?w=1200&q=90",
    "https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=1200&q=90",
    "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200&q=90",
  ],
  "paris": [
    "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=1200&q=90",
    "https://images.unsplash.com/photo-1499856374655-b3e7a24e87b0?w=1200&q=90",
    "https://images.unsplash.com/photo-1543349689-9a4d426bee8e?w=1200&q=90",
    "https://images.unsplash.com/photo-1520939817895-060bdaf4fe1b?w=1200&q=90",
    "https://images.unsplash.com/photo-1431274172761-fca41d930114?w=1200&q=90",
  ],
  "madrid": [
    "https://images.unsplash.com/photo-1539037116277-4db20889f2d4?w=1200&q=90",
    "https://images.unsplash.com/photo-1543783207-ec64e4d95325?w=1200&q=90",
    "https://images.unsplash.com/photo-1576492831081-4ab2d88e6e96?w=1200&q=90",
    "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=1200&q=90",
  ],
};

const List<String> _imagenesGenericas = [
  "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200&q=90",
  "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=1200&q=90",
  "https://images.unsplash.com/photo-1501426026826-31c667bdf23d?w=1200&q=90",
  "https://images.unsplash.com/photo-1488085061387-422e29b40080?w=1200&q=90",
  "https://images.unsplash.com/photo-1530521954074-e64f6810b32d?w=1200&q=90",
  "https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=1200&q=90",
  "https://images.unsplash.com/photo-1452421822248-d4c2b47f0c81?w=1200&q=90",
  "https://images.unsplash.com/photo-1504609813442-a8924e83f76e?w=1200&q=90",
];

List<String> _obtenerImagenesLocales(String nombreDestino) {
  final key = nombreDestino.toLowerCase().trim();
  return _imagenesRealesPorDestino[key] ?? _imagenesGenericas;
}

class DetailScreen extends StatefulWidget {
  final String nombre;
  final String precio;
  final String imagen;
  final String cedula;
  final String tipo;
  final bool esVip;
  final String? codigoIata;

  const DetailScreen({
    super.key,
    required this.nombre,
    required this.precio,
    required this.imagen,
    required this.cedula,
    this.tipo = "destino",
    this.esVip = false,
    this.codigoIata,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  bool esFavorito = false;
  late TabController _tabController;
  late PageController _pageController;

  List hoteles = [];
  List vuelos = [];
  List tours = [];
  bool cargando = false;
  bool cargandoReales = false;

  Map? vueloSeleccionado;
  Map? hotelSeleccionado;
  Map? tourSeleccionado;

  late List<String> imagenes;

  // 🔥 ESTADO DE FECHAS — primero fechas, luego vuelos
  DateTime? fechaIda;
  DateTime? fechaVuelta;
  bool fechasConfirmadas = false;

  // 🔥 INFO DE ACCESO (para destinos sin aeropuerto)
  Map? infoAcceso;
  bool tieneAeropuerto = true;

  // 🎨 COLORES ACTUALIZADOS — sistema unificado con home y profile
  Color get _primary => widget.esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7);
  Color get _bg => widget.esVip ? const Color(0xFF0A0A0A) : const Color(0xFFF0F2F8);
  Color get _cardBg => widget.esVip ? const Color(0xFF1A1A1A) : Colors.white;
  Color get _textColor => widget.esVip ? Colors.white : const Color(0xFF1A1A2E);
  Color get _subTextColor => widget.esVip ? const Color(0xFFD4AF37) : Colors.grey[500]!;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();
    imagenes = [widget.imagen, ..._obtenerImagenesLocales(widget.nombre)];
    verificarFavorito();
    _cargarImagenesDestino();
    if (widget.tipo == "destino") {
      _verificarAeropuerto();
      _cargarTours();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // 🔥 VERIFICA SI EL DESTINO TIENE AEROPUERTO ANTES DE MOSTRAR NADA
  Future<void> _verificarAeropuerto() async {
    try {
      final resp = await http.get(
        Uri.parse("$baseUrl/info_acceso_destino?destino=${Uri.encodeComponent(widget.nombre.toLowerCase())}"),
      ).timeout(const Duration(seconds: 8));
      final data = jsonDecode(resp.body);
      if (mounted) {
        setState(() {
          infoAcceso = data;
          tieneAeropuerto = data["tiene_aeropuerto_directo"] == true;
        });
      }
    } catch (e) {
      print("⚠️ Error verificando aeropuerto: $e");
      if (mounted) setState(() => tieneAeropuerto = true);
    }
  }

  // 🔥 CARGA SOLO TOURS (no necesitan fecha)
  Future<void> _cargarTours() async {
    try {
      final resTours = await http.get(Uri.parse("$baseUrl/obtener_tours"));
      final tData = jsonDecode(resTours.body);
      final toursLocales = (tData["tours"] as List).where((t) =>
        t["destino"]?.toString().toLowerCase() == widget.nombre.toLowerCase()
      ).toList();
      if (mounted) setState(() => tours = toursLocales);
    } catch (e) {
      print("⚠️ Error cargando tours: $e");
    }
  }

  Future<void> _cargarImagenesDestino() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/imagenes_destino?ciudad=${Uri.encodeComponent(widget.nombre)}&imagen_admin=${Uri.encodeComponent(widget.imagen)}"),
      ).timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);
      final imgs = List<String>.from(data["imagenes"] ?? []);
      if (imgs.isNotEmpty && mounted) {
        final Set<String> seen = {};
        final combinadas = [...imgs, ..._obtenerImagenesLocales(widget.nombre)]
            .where((img) => seen.add(img)).toList();
        setState(() => imagenes = combinadas);
      } else {
        if (mounted) setState(() => imagenes = [widget.imagen, ..._obtenerImagenesLocales(widget.nombre)]);
      }
    } catch (e) {
      if (mounted) setState(() => imagenes = [widget.imagen, ..._obtenerImagenesLocales(widget.nombre)]);
    }
  }

  // 🔥 CARGAR VUELOS Y HOTELES CON LA FECHA SELECCIONADA
  Future<void> cargarContenidoConFechas() async {
    if (fechaIda == null) return;
    setState(() { cargando = true; vuelos = []; hoteles = []; });

    final fechaStr = _formatearFecha(fechaIda!);
    final checkIn = fechaStr;
    final checkOut = _formatearFecha(fechaVuelta ?? fechaIda!.add(const Duration(days: 3)));

    try {
      // Vuelos con la fecha seleccionada
      if (tieneAeropuerto) {
        try {
          final iata = widget.codigoIata ?? _obtenerCodigoIata(widget.nombre);
          final resVuelos = await http.post(
            Uri.parse("$baseUrl/buscar_vuelos_reales"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "origen": "BOG",
              "destino": iata,
              "destino_nombre": widget.nombre,
              "fecha": fechaStr,
              "tipo": "one-way"
            }),
          ).timeout(const Duration(seconds: 15));
          final vData = jsonDecode(resVuelos.body);
          final vuelosApi = vData["vuelos"] ?? [];
          if (vuelosApi.isNotEmpty) {
            if (mounted) setState(() => vuelos = vuelosApi);
            print("✅ Vuelos para fecha $fechaStr: ${vuelosApi.length}");
          } else {
            // Fallback a locales si no hay para esa fecha
            final resLocal = await http.get(Uri.parse("$baseUrl/obtener_vuelos"));
            final vLocal = jsonDecode(resLocal.body);
            final locales = (vLocal["vuelos"] as List).where((v) =>
              v["destino"]?.toString().toLowerCase() == widget.nombre.toLowerCase()
            ).toList();
            if (mounted) setState(() => vuelos = locales);
          }
        } catch (e) {
          print("⚠️ Error vuelos: $e");
          final resLocal = await http.get(Uri.parse("$baseUrl/obtener_vuelos"));
          final vLocal = jsonDecode(resLocal.body);
          final locales = (vLocal["vuelos"] as List).where((v) =>
            v["destino"]?.toString().toLowerCase() == widget.nombre.toLowerCase()
          ).toList();
          if (mounted) setState(() => vuelos = locales);
        }
      }

      // Hoteles con las fechas seleccionadas
      try {
        final resHoteles = await http.post(
          Uri.parse("$baseUrl/buscar_hoteles_reales"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "ciudad": widget.nombre,
            "check_in": checkIn,
            "check_out": checkOut,
            "personas": 2
          }),
        ).timeout(const Duration(seconds: 15));
        final hData = jsonDecode(resHoteles.body);
        final hotelesApi = hData["hoteles"] ?? [];
        if (mounted) setState(() => hoteles = hotelesApi.isNotEmpty ? hotelesApi : []);
        print("✅ Hoteles para fechas: ${hotelesApi.length}");
      } catch (e) {
        print("⚠️ Error hoteles: $e");
        final resLocal = await http.get(Uri.parse("$baseUrl/obtener_hoteles"));
        final hLocal = jsonDecode(resLocal.body);
        final locales = (hLocal["hoteles"] as List).where((h) =>
          h["destino"]?.toString().toLowerCase() == widget.nombre.toLowerCase()
        ).toList();
        if (mounted) setState(() => hoteles = locales);
      }

      if (mounted) setState(() { cargando = false; fechasConfirmadas = true; });
    } catch (e) {
      print("❌ Error general: $e");
      if (mounted) setState(() => cargando = false);
    }
  }

  String _obtenerCodigoIata(String destino) {
    final codigos = {
      "cartagena": "CTG", "san andrés": "ADZ", "san andres": "ADZ",
      "medellín": "MDE", "medellin": "MDE", "santa marta": "SMR",
      "bogotá": "BOG", "bogota": "BOG", "cali": "CLO", "leticia": "LET",
      "manizales": "MZL", "pereira": "PEI", "bucaramanga": "BGA",
      "barranquilla": "BAQ", "pasto": "PSO", "cucuta": "CUC", "cúcuta": "CUC",
      "armenia": "AXM", "neiva": "NVA", "villavicencio": "VVC",
      "punta cana": "PUJ", "cancun": "CUN", "cancún": "CUN",
      "miami": "MIA", "paris": "CDG", "madrid": "MAD",
    };
    return codigos[destino.toLowerCase()] ?? "BOG";
  }

  String _formatearFecha(DateTime fecha) {
    return "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
  }

  String _fechaLegible(DateTime fecha) {
    const meses = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"];
    return "${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}";
  }

  Future<void> verificarFavorito() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/es_favorito"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"usuario_cedula": widget.cedula, "nombre": widget.nombre}),
      );
      final data = jsonDecode(response.body);
      setState(() => esFavorito = data["es_favorito"]);
    } catch (e) {}
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
          "imagen": widget.imagen,
        }),
      );
      final data = jsonDecode(response.body);
      setState(() => esFavorito = data["estado"] == "agregado");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(esFavorito ? "Agregado a favoritos" : "Eliminado de favoritos")),
      );
    } catch (e) {}
  }

  void _mostrarFlujoReserva() {
    if (!fechasConfirmadas) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Primero selecciona tus fechas de viaje"), backgroundColor: Colors.orange),
      );
      return;
    }
    if (vuelos.isEmpty && tieneAeropuerto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No hay vuelos disponibles hacia ${widget.nombre}"), backgroundColor: Colors.red),
      );
      return;
    }
    if (!tieneAeropuerto) {
      // Destino sin aeropuerto → ir directo al pago sin vuelo
      _mostrarSeleccionHotel();
      return;
    }
    _mostrarSeleccionVuelo();
  }

  void _mostrarSeleccionVuelo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlanSheet(
        titulo: "Selecciona tu vuelo",
        subtitulo: "Obligatorio para continuar",
        items: vuelos,
        tipo: "vuelo",
        esVip: widget.esVip,
        esOpcional: false,
        itemSeleccionado: vueloSeleccionado,
        onSeleccionar: (item) {
          setState(() => vueloSeleccionado = item);
          Navigator.pop(context);
          _mostrarSeleccionHotel();
        },
      ),
    );
  }

  void _mostrarSeleccionHotel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlanSheet(
        titulo: "Selecciona tu hotel",
        subtitulo: "Opcional — puedes omitir este paso",
        items: hoteles,
        tipo: "hotel",
        esVip: widget.esVip,
        esOpcional: true,
        itemSeleccionado: hotelSeleccionado,
        onSeleccionar: (item) {
          setState(() => hotelSeleccionado = item);
          Navigator.pop(context);
          _mostrarSeleccionTour();
        },
        onOmitir: () {
          setState(() => hotelSeleccionado = null);
          Navigator.pop(context);
          _mostrarSeleccionTour();
        },
      ),
    );
  }

  void _mostrarSeleccionTour() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlanSheet(
        titulo: "Agrega un tour",
        subtitulo: "Opcional — enriquece tu experiencia",
        items: tours,
        tipo: "tour",
        esVip: widget.esVip,
        esOpcional: true,
        itemSeleccionado: tourSeleccionado,
        onSeleccionar: (item) {
          setState(() => tourSeleccionado = item);
          Navigator.pop(context);
          _mostrarResumenPlan();
        },
        onOmitir: () {
          setState(() => tourSeleccionado = null);
          Navigator.pop(context);
          _mostrarResumenPlan();
        },
      ),
    );
  }

  void _mostrarResumenPlan() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ResumenPlanSheet(
        destino: widget.nombre,
        imagenDestino: widget.imagen,
        vuelo: vueloSeleccionado,
        hotel: hotelSeleccionado,
        tour: tourSeleccionado,
        esVip: widget.esVip,
        cedula: widget.cedula,
        onConfirmar: () {
          Navigator.pop(context);
          _irAlPago();
        },
      ),
    );
  }

  void _irAlPago() {
    double total = 0;
    if (vueloSeleccionado != null) {
      final vPrecio = vueloSeleccionado?["precio"]?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? "0";
      total += double.tryParse(vPrecio) ?? 0;
    }
    if (hotelSeleccionado != null) {
      final hPrecio = hotelSeleccionado?["precio_noche"]?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? "0";
      total += double.tryParse(hPrecio) ?? 0;
    }
    if (tourSeleccionado != null) {
      final tPrecio = tourSeleccionado?["precio"]?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? "0";
      total += double.tryParse(tPrecio) ?? 0;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          cedula: widget.cedula,
          nombre: widget.nombre,
          precio: total.toStringAsFixed(0),
          imagen: widget.imagen,
          tipo: "destino",
          esVip: widget.esVip,
          vueloSeleccionado: vueloSeleccionado,
          hotelSeleccionado: hotelSeleccionado,
          tourSeleccionado: tourSeleccionado,
          // 🔥 FIX: pasar las fechas ya seleccionadas para no pedirlas de nuevo
          fechaIdaPreseleccionada: fechaIda,
          fechaVueltaPreseleccionada: fechaVuelta,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ============ APP BAR CON CARRUSEL ============
              SliverAppBar(
                expandedHeight: 420,
                pinned: true,
                backgroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: imagenes.length,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (i) => setState(() => currentIndex = i),
                        itemBuilder: (_, index) => Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              imagenes[index],
                              fit: BoxFit.cover,
                              loadingBuilder: (ctx, child, prog) => prog == null ? child
                                  : Container(color: Colors.black, child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white38))),
                              errorBuilder: (_, __, ___) {
                                final fallbackIdx = index % _imagenesGenericas.length;
                                return Image.network(_imagenesGenericas[fallbackIdx], fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: Colors.grey[900]));
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.9)],
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                      if (widget.esVip)
                        Positioned(
                          top: 100, right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFFFD700), Color(0xFFD4AF37)]),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.5), blurRadius: 12)],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.workspace_premium, color: Colors.black, size: 14),
                                SizedBox(width: 5),
                                Text("VIP MEMBER", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      Positioned(
                        top: 100, left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                          child: Row(children: [
                            const Icon(Icons.photo_library_outlined, color: Colors.white70, size: 13),
                            const SizedBox(width: 5),
                            Text("${currentIndex + 1} / ${imagenes.length}", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ),
                      Positioned(
                        bottom: 48, left: 20, right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.nombre, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 0.5, shadows: [Shadow(color: Colors.black87, blurRadius: 10)])),
                            const SizedBox(height: 6),
                            Row(children: [
                              Icon(Icons.attach_money, color: widget.esVip ? const Color(0xFFD4AF37) : Colors.greenAccent, size: 20),
                              Text(widget.precio, style: TextStyle(color: widget.esVip ? const Color(0xFFD4AF37) : Colors.greenAccent, fontSize: 22, fontWeight: FontWeight.bold)),
                            ]),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 18, left: 0, right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(imagenes.length > 12 ? 12 : imagenes.length, (index) =>
                            GestureDetector(
                              onTap: () => _pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: currentIndex == index ? 20 : 6, height: 6,
                                decoration: BoxDecoration(
                                  color: currentIndex == index ? (widget.esVip ? const Color(0xFFD4AF37) : Colors.white) : Colors.white38,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (currentIndex > 0)
                        Positioned(left: 12, top: 0, bottom: 0, child: Center(
                          child: GestureDetector(
                            onTap: () => _pageController.previousPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut),
                            child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle), child: const Icon(Icons.chevron_left, color: Colors.white, size: 22)),
                          ),
                        )),
                      if (currentIndex < imagenes.length - 1)
                        Positioned(right: 12, top: 0, bottom: 0, child: Center(
                          child: GestureDetector(
                            onTap: () => _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut),
                            child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle), child: const Icon(Icons.chevron_right, color: Colors.white, size: 22)),
                          ),
                        )),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(esFavorito ? Icons.favorite : Icons.favorite_border, key: ValueKey(esFavorito), color: Colors.red, size: 26),
                    ),
                    onPressed: toggleFavorito,
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating
                      Row(children: [
                        ...List.generate(4, (_) => Icon(Icons.star_rounded, color: widget.esVip ? const Color(0xFFD4AF37) : Colors.amber, size: 20)),
                        Icon(Icons.star_half_rounded, color: widget.esVip ? const Color(0xFFD4AF37) : Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text("4.5", style: TextStyle(color: _textColor, fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        Text("(120 reseñas)", style: TextStyle(color: _subTextColor, fontSize: 13)),
                      ]),

                      const SizedBox(height: 20),

                      // Features
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                        decoration: BoxDecoration(
                          color: _cardBg, borderRadius: BorderRadius.circular(20),
                          border: widget.esVip ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.35)) : Border.all(color: Colors.grey.withOpacity(0.08)),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(widget.esVip ? 0.3 : 0.06), blurRadius: 16, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _Feature(icon: Icons.wifi_rounded, texto: "WiFi", esVip: widget.esVip),
                            _Feature(icon: Icons.pool_rounded, texto: "Piscina", esVip: widget.esVip),
                            _Feature(icon: Icons.restaurant_rounded, texto: "Comida", esVip: widget.esVip),
                            _Feature(icon: Icons.flight_rounded, texto: "Vuelo", esVip: widget.esVip),
                            _Feature(icon: Icons.spa_rounded, texto: "Spa", esVip: widget.esVip),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Descripción
                      Text("Descripción", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: _textColor)),
                      const SizedBox(height: 10),
                      Text(
                        "Disfruta de una experiencia única en ${widget.nombre}. Incluye alojamiento premium, actividades exclusivas y una vista espectacular. Perfecta para quienes buscan lo mejor en cada detalle de su viaje.",
                        style: TextStyle(color: _subTextColor, height: 1.7, fontSize: 14),
                      ),

                      // Galería thumbnails
                      if (imagenes.length > 1) ...[
                        const SizedBox(height: 24),
                        Text("Galería", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: _textColor)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 85,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: imagenes.length,
                            itemBuilder: (context, index) {
                              final isSelected = currentIndex == index;
                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(index, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                                  setState(() => currentIndex = index);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: EdgeInsets.only(right: 10, bottom: isSelected ? 0 : 6, top: isSelected ? 0 : 6),
                                  width: isSelected ? 90 : 78,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected ? Border.all(color: _primary, width: 2.5) : Border.all(color: Colors.transparent),
                                    boxShadow: isSelected ? [BoxShadow(color: _primary.withOpacity(0.4), blurRadius: 8)] : [],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(imagenes[index], fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(color: Colors.grey[800])),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 25),

                      if (widget.tipo == "destino") ...[

                        // 🔥 INFO DE DESTINO SIN AEROPUERTO
                        if (!tieneAeropuerto && infoAcceso != null)
                          _buildInfoSinAeropuerto(),

                        // 🔥 SELECTOR DE FECHAS — SIEMPRE VISIBLE PRIMERO
                        _buildSelectorFechas(),

                        const SizedBox(height: 16),

                        // 🔥 CONTENIDO (vuelos/hoteles) solo si fechas confirmadas
                        if (fechasConfirmadas) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Disponible en ${widget.nombre}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _textColor)),
                              if (!cargando)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: vuelos.isNotEmpty && vuelos.first["fuente"] == "real"
                                        ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    vuelos.isNotEmpty && vuelos.first["fuente"] == "real" ? "Precios en tiempo real" : "Precios estimados",
                                    style: TextStyle(color: vuelos.isNotEmpty && vuelos.first["fuente"] == "real" ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: _cardBg, borderRadius: BorderRadius.circular(12),
                              border: widget.esVip ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)) : Border.all(color: Colors.grey.withOpacity(0.08)),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              labelColor: _primary,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: _primary,
                              tabs: const [Tab(text: "Hoteles"), Tab(text: "Vuelos"), Tab(text: "Tours")],
                            ),
                          ),
                          const SizedBox(height: 10),
                          cargando
                              ? Center(child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(children: [
                                    CircularProgressIndicator(color: _primary),
                                    const SizedBox(height: 10),
                                    Text("Buscando disponibilidad para ${_fechaLegible(fechaIda!)}...", style: TextStyle(color: _subTextColor, fontSize: 12)),
                                  ]),
                                ))
                              : SizedBox(
                                  height: 250,
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      _listaItems(hoteles, "hotel"),
                                      // Si no tiene aeropuerto, muestra info de transporte en tab vuelos
                                      !tieneAeropuerto ? _buildTabSinAeropuerto() : _listaItems(vuelos, "vuelo"),
                                      _listaItems(tours, "tour"),
                                    ],
                                  ),
                                ),
                          const SizedBox(height: 20),

                          if (vueloSeleccionado != null) _buildResumenPlanParcial(),
                          const SizedBox(height: 20),
                        ],

                        // 🔥 BOTÓN ARMAR PLAN
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: fechasConfirmadas ? _mostrarFlujoReserva : null,
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: widget.esVip
                                    ? const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFFFD700), Color(0xFFD4AF37)])
                                    : (fechasConfirmadas
                                        ? const LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF4F8EF7)])
                                        : const LinearGradient(colors: [Color(0xFF666666), Color(0xFF444444)])),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: fechasConfirmadas ? [BoxShadow(color: _primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))] : [],
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      fechasConfirmadas ? (widget.esVip ? Icons.workspace_premium : Icons.add_circle_outline) : Icons.calendar_today_rounded,
                                      color: widget.esVip ? Colors.black : Colors.white,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      fechasConfirmadas
                                          ? (widget.esVip ? "Armar mi plan VIP" : "Armar mi plan de viaje")
                                          : "Selecciona tus fechas primero",
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: widget.esVip ? Colors.black : Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                      ] else ...[
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => PaymentScreen(cedula: widget.cedula, nombre: widget.nombre, precio: widget.precio, imagen: widget.imagen, tipo: widget.tipo, esVip: widget.esVip),
                            )),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: widget.esVip
                                    ? const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFFFD700)])
                                    : const LinearGradient(colors: [Color(0xFF1A1A2E), Color(0xFF4F8EF7)]),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(widget.esVip ? "Reservar — Acceso VIP" : "Reservar ahora",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: widget.esVip ? Colors.black : Colors.white)),
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Botón back
          Positioned(
            top: 45, left: 15,
            child: Container(
              decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)]),
              child: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔥 SELECTOR DE FECHAS — el corazón de la nueva lógica
  // ============================================================
  Widget _buildSelectorFechas() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: fechasConfirmadas
              ? _primary.withOpacity(0.5)
              : (widget.esVip ? const Color(0xFFD4AF37).withOpacity(0.4) : const Color(0xFF4F8EF7).withOpacity(0.3)),
          width: fechasConfirmadas ? 2 : 1,
        ),
        boxShadow: [BoxShadow(color: _primary.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, color: _primary, size: 20),
              const SizedBox(width: 8),
              Text(
                fechasConfirmadas ? "Fechas seleccionadas ✓" : "¿Cuándo quieres viajar?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _textColor),
              ),
              if (fechasConfirmadas) ...[
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() { fechasConfirmadas = false; vuelos = []; hoteles = []; vueloSeleccionado = null; hotelSeleccionado = null; tourSeleccionado = null; }),
                  child: Text("Cambiar", style: TextStyle(color: _primary, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            fechasConfirmadas
                ? "Se muestran vuelos y hoteles disponibles para tus fechas"
                : "Selecciona las fechas para ver vuelos y hoteles disponibles",
            style: TextStyle(color: _subTextColor, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Fecha ida
              Expanded(child: GestureDetector(
                onTap: () async {
                  final p = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                    helpText: "Fecha de ida",
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: ColorScheme.light(primary: _primary),
                      ),
                      child: child!,
                    ),
                  );
                  if (p != null) setState(() { fechaIda = p; if (fechaVuelta != null && fechaVuelta!.isBefore(p)) fechaVuelta = null; fechasConfirmadas = false; });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: fechaIda != null ? _primary.withOpacity(0.1) : (widget.esVip ? const Color(0xFF0A0A0A) : Colors.grey[50]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: fechaIda != null ? _primary.withOpacity(0.5) : Colors.grey.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.flight_takeoff_rounded, size: 13, color: _primary),
                        const SizedBox(width: 4),
                        Text("IDA", style: TextStyle(color: _primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ]),
                      const SizedBox(height: 4),
                      Text(
                        fechaIda != null ? _fechaLegible(fechaIda!) : "Seleccionar",
                        style: TextStyle(fontWeight: FontWeight.bold, color: _textColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )),
              const SizedBox(width: 10),
              // Fecha vuelta
              Expanded(child: GestureDetector(
                onTap: () async {
                  if (fechaIda == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Primero selecciona la fecha de ida")));
                    return;
                  }
                  final p = await showDatePicker(
                    context: context,
                    initialDate: fechaIda!.add(const Duration(days: 1)),
                    firstDate: fechaIda!.add(const Duration(days: 1)),
                    lastDate: DateTime(2030),
                    helpText: "Fecha de vuelta",
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.light(primary: _primary)),
                      child: child!,
                    ),
                  );
                  if (p != null) setState(() { fechaVuelta = p; fechasConfirmadas = false; });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: fechaVuelta != null ? _primary.withOpacity(0.1) : (widget.esVip ? const Color(0xFF0A0A0A) : Colors.grey[50]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: fechaVuelta != null ? _primary.withOpacity(0.5) : Colors.grey.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.flight_land_rounded, size: 13, color: _primary),
                        const SizedBox(width: 4),
                        Text("VUELTA", style: TextStyle(color: _primary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ]),
                      const SizedBox(height: 4),
                      Text(
                        fechaVuelta != null ? _fechaLegible(fechaVuelta!) : "Seleccionar",
                        style: TextStyle(fontWeight: FontWeight.bold, color: _textColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
          if (fechaIda != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: cargando ? null : cargarContenidoConFechas,
                child: cargando
                    ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: widget.esVip ? Colors.black : Colors.white)),
                        const SizedBox(width: 10),
                        Text("Buscando...", style: TextStyle(color: widget.esVip ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                      ])
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.search_rounded, color: widget.esVip ? Colors.black : Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          "Ver vuelos y hoteles disponibles",
                          style: TextStyle(color: widget.esVip ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 🔥 BANNER DE DESTINO SIN AEROPUERTO
  Widget _buildInfoSinAeropuerto() {
    final aeropuertoCercano = infoAcceso?["aeropuerto_cercano"] ?? "";
    final instrucciones = infoAcceso?["instrucciones"] ?? "";
    final tiempo = infoAcceso?["tiempo_terrestre"] ?? "";
    final nota = infoAcceso?["nota"] ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.esVip ? const Color(0xFF1A1200) : Colors.orange.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 20)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Este destino no tiene aeropuerto directo", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 14)),
              if (aeropuertoCercano.isNotEmpty)
                Text("Aeropuerto más cercano: $aeropuertoCercano", style: TextStyle(color: Colors.orange.withOpacity(0.7), fontSize: 12)),
            ])),
          ]),
          if (instrucciones.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(instrucciones, style: TextStyle(color: _textColor, fontSize: 13, height: 1.5)),
          ],
          if (tiempo.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.directions_bus_rounded, size: 14, color: Colors.orange.withOpacity(0.7)),
              const SizedBox(width: 5),
              Text("Tiempo de viaje terrestre: $tiempo", style: TextStyle(color: Colors.orange.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ],
          if (nota.isNotEmpty && nota != instrucciones) ...[
            const SizedBox(height: 6),
            Text(nota, style: TextStyle(color: _subTextColor, fontSize: 11, fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  // 🔥 TAB DE VUELOS PARA DESTINOS SIN AEROPUERTO
  Widget _buildTabSinAeropuerto() {
    final transporte = infoAcceso?["transporte"] as List? ?? [];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.withOpacity(0.3))),
            child: Row(children: [
              const Icon(Icons.airplanemode_off_rounded, color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text("${widget.nombre} no tiene vuelos directos. Vuela al aeropuerto más cercano.", style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.w500))),
            ]),
          ),
          if (transporte.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...transporte.map((t) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.withOpacity(0.2))),
              child: Row(children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: _primary.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(t["tipo"]?.toString().toLowerCase() == "bus" ? Icons.directions_bus_rounded : Icons.local_taxi_rounded, color: _primary, size: 16)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t["tipo"] ?? "", style: TextStyle(fontWeight: FontWeight.bold, color: _textColor, fontSize: 13)),
                  Text(t["descripcion"] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                  if ((t["precio_aprox"] ?? "").isNotEmpty)
                    Text("💰 ${t["precio_aprox"]}", style: TextStyle(color: _primary, fontSize: 11, fontWeight: FontWeight.bold)),
                  if ((t["duracion"] ?? "").isNotEmpty)
                    Text("⏱ ${t["duracion"]}", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ])),
              ]),
            )).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildResumenPlanParcial() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _primary.withOpacity(0.4))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.check_circle, color: _primary, size: 16), const SizedBox(width: 8), Text("Tu plan actual", style: TextStyle(fontWeight: FontWeight.bold, color: _textColor, fontSize: 14))]),
          const SizedBox(height: 10),
          if (vueloSeleccionado != null)
            _filaPlan("Vuelo", "${vueloSeleccionado!["origen"]} → ${vueloSeleccionado!["destino"]}", vueloSeleccionado!["precio"] ?? ""),
          if (hotelSeleccionado != null)
            _filaPlan("Hotel", hotelSeleccionado!["nombre"] ?? "", hotelSeleccionado!["precio_noche"] ?? ""),
          if (tourSeleccionado != null)
            _filaPlan("Tour", tourSeleccionado!["nombre"] ?? "", tourSeleccionado!["precio"] ?? ""),
          const Divider(height: 15),
          GestureDetector(onTap: _mostrarFlujoReserva, child: Text("Modificar plan", style: TextStyle(color: _primary, fontSize: 12, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _filaPlan(String tipo, String nombre, String precio) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: _primary.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: Text(tipo, style: TextStyle(color: _primary, fontSize: 10, fontWeight: FontWeight.bold))),
        const SizedBox(width: 8),
        Expanded(child: Text(nombre, style: TextStyle(color: _textColor, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
        Text(precio, style: TextStyle(color: _primary, fontSize: 12, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _listaItems(List items, String tipo) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 40, color: _primary.withOpacity(0.3)),
              const SizedBox(height: 10),
              Text("No hay ${tipo}s disponibles para ${widget.nombre}", style: TextStyle(color: _subTextColor), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final nombre = tipo == "vuelo" ? "${item["origen"]} → ${item["destino"]}" : item["nombre"] ?? "";
        final precio = tipo == "hotel" ? item["precio_noche"] ?? "" : item["precio"] ?? "";
        final imagen = item["imagen"] ?? "";
        final esReal = item["fuente"] == "real";
        final subtitulo = tipo == "hotel"
            ? "${item["estrellas"]} estrellas • ${item["tipo_habitacion"] ?? "Doble"}"
            : tipo == "vuelo"
                ? "${item["aerolinea"] ?? ""} • ${item["duracion"] ?? ""} • ${item["hora_salida"] != null ? item["hora_salida"].toString().substring(0, 16) : ""}"
                : "${item["duracion"]} • Max ${item["cupo_maximo"]} personas";

        return Card(
          color: _cardBg,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: widget.esVip ? BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.2)) : BorderSide.none),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(imagen, width: 55, height: 55, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 55, height: 55, color: Colors.grey[800],
                  child: Icon(tipo == "vuelo" ? Icons.flight : tipo == "hotel" ? Icons.hotel : Icons.tour, color: Colors.white54))),
            ),
            title: Row(children: [
              Expanded(child: Text(nombre, style: TextStyle(fontWeight: FontWeight.bold, color: _textColor, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (esReal) Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(4)), child: const Text("REAL", style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold))),
            ]),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(subtitulo, style: TextStyle(color: _subTextColor, fontSize: 11)),
              Text(precio, style: TextStyle(color: _primary, fontWeight: FontWeight.bold)),
            ]),
          ),
        );
      },
    );
  }
}

// =========================
// SHEET SELECCIÓN DE ITEM
// =========================
class _PlanSheet extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final List items;
  final String tipo;
  final bool esVip;
  final bool esOpcional;
  final Map? itemSeleccionado;
  final Function(Map) onSeleccionar;
  final VoidCallback? onOmitir;

  const _PlanSheet({
    required this.titulo, required this.subtitulo, required this.items,
    required this.tipo, required this.esVip, required this.esOpcional,
    required this.itemSeleccionado, required this.onSeleccionar, this.onOmitir,
  });

  // 🎨 COLORES ACTUALIZADOS
  Color get _primary => esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7);
  Color get _bg => esVip ? const Color(0xFF0A0A0A) : Colors.white;
  Color get _cardBg => esVip ? const Color(0xFF1A1A1A) : const Color(0xFFF0F2F8);
  Color get _textColor => esVip ? Colors.white : const Color(0xFF1A1A2E);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(color: _bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(25)), border: esVip ? const Border(top: BorderSide(color: Color(0xFFD4AF37), width: 1)) : null),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: esVip ? const Color(0xFFD4AF37) : Colors.grey[300], borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _textColor)),
                Text(subtitulo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
              if (esOpcional && onOmitir != null)
                TextButton(onPressed: onOmitir, child: Text("Omitir", style: TextStyle(color: _primary))),
            ],
          ),
        ),
        if (items.isEmpty)
          Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.search_off, size: 50, color: _primary.withOpacity(0.3)),
            const SizedBox(height: 10),
            Text("No hay ${tipo}s disponibles", style: const TextStyle(color: Colors.grey)),
            if (esOpcional && onOmitir != null) ...[
              const SizedBox(height: 15),
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _primary), onPressed: onOmitir, child: Text("Continuar sin $tipo", style: TextStyle(color: esVip ? Colors.black : Colors.white))),
            ],
          ])))
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final nombre = tipo == "vuelo" ? "${item["origen"]} → ${item["destino"]}" : item["nombre"] ?? "";
                final precio = tipo == "hotel" ? item["precio_noche"] ?? "" : item["precio"] ?? "";
                final imagen = item["imagen"] ?? "";
                final seleccionado = itemSeleccionado == item;
                final esReal = item["fuente"] == "real";
                final subtituloItem = tipo == "hotel"
                    ? "${item["estrellas"]} estrellas • ${item["tipo_habitacion"] ?? "Doble"}"
                    : tipo == "vuelo"
                        ? "${item["aerolinea"] ?? ""} • ${item["duracion"] ?? ""} • ${item["hora_salida"] != null ? item["hora_salida"].toString().substring(0, 16) : ""} → ${item["hora_llegada"] != null ? item["hora_llegada"].toString().substring(0, 16) : ""}"
                        : "${item["duracion"]} • Max ${item["cupo_maximo"]} personas";

                return GestureDetector(
                  onTap: () => onSeleccionar(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: seleccionado ? _primary.withOpacity(0.1) : _cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: seleccionado ? _primary : Colors.grey.withOpacity(0.2), width: seleccionado ? 2 : 1),
                    ),
                    child: Row(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(imagen, width: 65, height: 65, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 65, height: 65, color: Colors.grey[800], child: Icon(tipo == "vuelo" ? Icons.flight : tipo == "hotel" ? Icons.hotel : Icons.tour, color: Colors.white54)))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(nombre, style: TextStyle(fontWeight: FontWeight.bold, color: _textColor, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          if (esReal) Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(4)), child: const Text("REAL", style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold))),
                        ]),
                        const SizedBox(height: 3),
                        Text(subtituloItem, style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 2),
                        const SizedBox(height: 3),
                        Text(precio, style: TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 14)),
                      ])),
                      if (seleccionado) Icon(Icons.check_circle, color: _primary)
                      else Icon(Icons.radio_button_unchecked, color: Colors.grey.withOpacity(0.5)),
                    ]),
                  ),
                );
              },
            ),
          ),
      ]),
    );
  }
}

// =========================
// SHEET RESUMEN DEL PLAN
// =========================
class _ResumenPlanSheet extends StatelessWidget {
  final String destino;
  final String imagenDestino;
  final Map? vuelo;
  final Map? hotel;
  final Map? tour;
  final bool esVip;
  final String cedula;
  final VoidCallback onConfirmar;

  const _ResumenPlanSheet({
    required this.destino, required this.imagenDestino,
    this.vuelo, this.hotel, this.tour,
    required this.esVip, required this.cedula, required this.onConfirmar,
  });

  // 🎨 COLORES ACTUALIZADOS
  Color get _primary => esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7);
  Color get _bg => esVip ? const Color(0xFF0A0A0A) : Colors.white;
  Color get _cardBg => esVip ? const Color(0xFF1A1A1A) : const Color(0xFFF0F2F8);
  Color get _textColor => esVip ? Colors.white : const Color(0xFF1A1A2E);

  double get _totalPlan {
    double total = 0;
    if (vuelo != null) {
      final vPrecio = vuelo!["precio"]?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? "0";
      total += double.tryParse(vPrecio) ?? 0;
    }
    if (hotel != null) {
      final hPrecio = hotel!["precio_noche"]?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? "0";
      total += double.tryParse(hPrecio) ?? 0;
    }
    if (tour != null) {
      final tPrecio = tour!["precio"]?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? "0";
      total += double.tryParse(tPrecio) ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(color: _bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(25)), border: esVip ? const Border(top: BorderSide(color: Color(0xFFD4AF37), width: 1)) : null),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: esVip ? const Color(0xFFD4AF37) : Colors.grey[300], borderRadius: BorderRadius.circular(2))),
        Padding(padding: const EdgeInsets.all(20), child: Text(esVip ? "Tu Plan VIP" : "Resumen de tu plan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: _textColor))),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            _buildItemPlan(icono: "Destino", nombre: destino, detalle: "Tu destino principal", precio: "", imagen: imagenDestino, obligatorio: true),
            if (vuelo != null) ...[
              const SizedBox(height: 10),
              _buildItemPlan(icono: "Vuelo", nombre: "${vuelo!["origen"]} → ${vuelo!["destino"]}", detalle: "${vuelo!["aerolinea"] ?? ""} • ${vuelo!["duracion"] ?? ""}", precio: vuelo!["precio"] ?? "", imagen: vuelo!["imagen"] ?? "", obligatorio: true),
            ],
            if (hotel != null) ...[
              const SizedBox(height: 10),
              _buildItemPlan(icono: "Hotel", nombre: hotel!["nombre"] ?? "", detalle: "${hotel!["estrellas"]} estrellas", precio: hotel!["precio_noche"] ?? "", imagen: hotel!["imagen"] ?? "", obligatorio: false),
            ],
            if (tour != null) ...[
              const SizedBox(height: 10),
              _buildItemPlan(icono: "Tour", nombre: tour!["nombre"] ?? "", detalle: tour!["duracion"] ?? "", precio: tour!["precio"] ?? "", imagen: tour!["imagen"] ?? "", obligatorio: false),
            ],
            const Divider(height: 25),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Total del plan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textColor)),
              Text("\$${_totalPlan.toStringAsFixed(0)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: _primary)),
            ]),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0),
                onPressed: onConfirmar,
                child: Text(esVip ? "Proceder al pago VIP" : "Proceder al pago", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: esVip ? Colors.black : Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ]),
        )),
      ]),
    );
  }

  Widget _buildItemPlan({required String icono, required String nombre, required String detalle, required String precio, required String imagen, required bool obligatorio}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: obligatorio ? _primary.withOpacity(0.4) : Colors.grey.withOpacity(0.2))),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(imagen, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[800]))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: _primary.withOpacity(0.15), borderRadius: BorderRadius.circular(6)), child: Text(icono, style: TextStyle(color: _primary, fontSize: 10, fontWeight: FontWeight.bold))),
            if (obligatorio) ...[
              const SizedBox(width: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: const Text("Obligatorio", style: TextStyle(color: Colors.red, fontSize: 9))),
            ],
          ]),
          const SizedBox(height: 4),
          Text(nombre, style: TextStyle(fontWeight: FontWeight.bold, color: _textColor, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(detalle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ])),
        if (precio.isNotEmpty) Text(precio, style: TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 13)),
      ]),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String texto;
  final bool esVip;

  const _Feature({required this.icon, required this.texto, this.esVip = false});

  @override
  Widget build(BuildContext context) {
    // 🎨 COLOR ACTUALIZADO — círculo plano en lugar de gradiente
    final color = esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7);
    return Column(children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(height: 6),
      Text(texto, style: TextStyle(fontSize: 11, color: esVip ? Colors.white70 : Colors.grey[600], fontWeight: FontWeight.w500)),
    ]);
  }
}