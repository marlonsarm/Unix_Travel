import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'login_screen.dart';
import 'profile_screen.dart';
import 'favorites_screen.dart';
import 'cart_screen.dart';
import 'detail_screen.dart';

const String baseUrl = "http://127.0.0.1:5000";

// 🔥 IMÁGENES REALES POR DESTINO
const Map<String, String> _imagenRealPorDestino = {
  "cartagena":    "https://images.unsplash.com/photo-1583997052103-b4a1cb974ce5?w=800&q=90",
  "san andres":   "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&q=90",
  "san andrés":   "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&q=90",
  "medellín":     "https://images.unsplash.com/photo-1598256989800-fe5f95da9787?w=800&q=90",
  "medellin":     "https://images.unsplash.com/photo-1598256989800-fe5f95da9787?w=800&q=90",
  "santa marta":  "https://images.unsplash.com/photo-1518548419970-58e3b4079ab2?w=800&q=90",
  "bogotá":       "https://images.unsplash.com/photo-1588546642610-e9ee6b8bece5?w=800&q=90",
  "bogota":       "https://images.unsplash.com/photo-1588546642610-e9ee6b8bece5?w=800&q=90",
  "punta cana":   "https://images.unsplash.com/photo-1510414842594-a61c69b5ae57?w=800&q=90",
  "cancun":       "https://images.unsplash.com/photo-1552074284-5e88ef1aef18?w=800&q=90",
  "cancún":       "https://images.unsplash.com/photo-1552074284-5e88ef1aef18?w=800&q=90",
  "miami":        "https://images.unsplash.com/photo-1533106497176-45ae19e68ba2?w=800&q=90",
  "paris":        "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800&q=90",
  "madrid":       "https://images.unsplash.com/photo-1539037116277-4db20889f2d4?w=800&q=90",
  "cali":         "https://images.unsplash.com/photo-1501854140801-50d01698950b?w=800&q=90",
  "barranquilla": "https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800&q=90",
  "bucaramanga":  "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=90",
  "pereira":      "https://images.unsplash.com/photo-1501426026826-31c667bdf23d?w=800&q=90",
};

// 🔥 10 FOTOS REALES POR AEROLÍNEA
const Map<String, List<String>> _imagenesAerolinea = {
  "avianca": [
    "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=900&q=90",
    "https://images.unsplash.com/photo-1556388158-158ea5ccacbd?w=900&q=90",
    "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=900&q=90",
    "https://images.unsplash.com/photo-1569154941061-e231b4725ef1?w=900&q=90",
    "https://images.unsplash.com/photo-1583290173879-e3da85f72a0c?w=900&q=90",
    "https://images.unsplash.com/photo-1540339832862-474599807836?w=900&q=90",
    "https://images.unsplash.com/photo-1517479149777-5f3b1511d5ad?w=900&q=90",
    "https://images.unsplash.com/photo-1610556074082-af6b71b4d2c6?w=900&q=90",
    "https://images.unsplash.com/photo-1529074963764-98f45c47344b?w=900&q=90",
    "https://images.unsplash.com/photo-1464037866556-6812c9d1c72e?w=900&q=90",
  ],
  "latam": [
    "https://images.unsplash.com/photo-1555400038-63f5ba517a47?w=900&q=90",
    "https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=900&q=90",
    "https://images.unsplash.com/photo-1607472587735-3e35dbb65a52?w=900&q=90",
    "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=900&q=90",
    "https://images.unsplash.com/photo-1519677100203-a0e668c92439?w=900&q=90",
    "https://images.unsplash.com/photo-1542296332-2e4473faf563?w=900&q=90",
    "https://images.unsplash.com/photo-1504150558240-0b4fd8946624?w=900&q=90",
    "https://images.unsplash.com/photo-1559797103-47715b8f0620?w=900&q=90",
    "https://images.unsplash.com/photo-1583296581396-f18b9f7b5f52?w=900&q=90",
    "https://images.unsplash.com/photo-1521322800607-8b1d94d9b979?w=900&q=90",
  ],
  "copa": [
    "https://images.unsplash.com/photo-1583990246141-6a69d5d9c6b4?w=900&q=90",
    "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=900&q=90",
    "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=900&q=90",
    "https://images.unsplash.com/photo-1569154941061-e231b4725ef1?w=900&q=90",
    "https://images.unsplash.com/photo-1540339832862-474599807836?w=900&q=90",
    "https://images.unsplash.com/photo-1556388158-158ea5ccacbd?w=900&q=90",
    "https://images.unsplash.com/photo-1529074963764-98f45c47344b?w=900&q=90",
    "https://images.unsplash.com/photo-1610556074082-af6b71b4d2c6?w=900&q=90",
    "https://images.unsplash.com/photo-1517479149777-5f3b1511d5ad?w=900&q=90",
    "https://images.unsplash.com/photo-1583296581396-f18b9f7b5f52?w=900&q=90",
  ],
  "wingo": [
    "https://images.unsplash.com/photo-1464037866556-6812c9d1c72e?w=900&q=90",
    "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=900&q=90",
    "https://images.unsplash.com/photo-1607472587735-3e35dbb65a52?w=900&q=90",
    "https://images.unsplash.com/photo-1555400038-63f5ba517a47?w=900&q=90",
    "https://images.unsplash.com/photo-1519677100203-a0e668c92439?w=900&q=90",
    "https://images.unsplash.com/photo-1521322800607-8b1d94d9b979?w=900&q=90",
    "https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=900&q=90",
    "https://images.unsplash.com/photo-1504150558240-0b4fd8946624?w=900&q=90",
    "https://images.unsplash.com/photo-1542296332-2e4473faf563?w=900&q=90",
    "https://images.unsplash.com/photo-1583990246141-6a69d5d9c6b4?w=900&q=90",
  ],
  "american": [
    "https://images.unsplash.com/photo-1529074963764-98f45c47344b?w=900&q=90",
    "https://images.unsplash.com/photo-1556388158-158ea5ccacbd?w=900&q=90",
    "https://images.unsplash.com/photo-1583296581396-f18b9f7b5f52?w=900&q=90",
    "https://images.unsplash.com/photo-1610556074082-af6b71b4d2c6?w=900&q=90",
    "https://images.unsplash.com/photo-1517479149777-5f3b1511d5ad?w=900&q=90",
    "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=900&q=90",
    "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=900&q=90",
    "https://images.unsplash.com/photo-1569154941061-e231b4725ef1?w=900&q=90",
    "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=900&q=90",
    "https://images.unsplash.com/photo-1540339832862-474599807836?w=900&q=90",
  ],
};

const List<String> _imagenesAvionGenerico = [
  "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=900&q=90",
  "https://images.unsplash.com/photo-1556388158-158ea5ccacbd?w=900&q=90",
  "https://images.unsplash.com/photo-1474302770737-173ee21bab63?w=900&q=90",
  "https://images.unsplash.com/photo-1569154941061-e231b4725ef1?w=900&q=90",
  "https://images.unsplash.com/photo-1540339832862-474599807836?w=900&q=90",
  "https://images.unsplash.com/photo-1529074963764-98f45c47344b?w=900&q=90",
  "https://images.unsplash.com/photo-1517479149777-5f3b1511d5ad?w=900&q=90",
  "https://images.unsplash.com/photo-1610556074082-af6b71b4d2c6?w=900&q=90",
  "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=900&q=90",
  "https://images.unsplash.com/photo-1583296581396-f18b9f7b5f52?w=900&q=90",
];

List<String> _getImagenesAerolinea(String aerolinea) {
  final key = aerolinea.toLowerCase().trim();
  for (final entry in _imagenesAerolinea.entries) {
    if (key.contains(entry.key)) return entry.value;
  }
  return _imagenesAvionGenerico;
}

const Map<String, String> _imagenHotelPorCiudad = {
  "cartagena":   "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=700&q=85",
  "san andres":  "https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=700&q=85",
  "san andrés":  "https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=700&q=85",
  "medellín":    "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=700&q=85",
  "medellin":    "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=700&q=85",
  "santa marta": "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=700&q=85",
  "punta cana":  "https://images.unsplash.com/photo-1564530497978-8c53f51e9cbc?w=700&q=85",
  "cancun":      "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=700&q=85",
  "cancún":      "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=700&q=85",
  "miami":       "https://images.unsplash.com/photo-1535498730771-e735b998cd64?w=700&q=85",
  "paris":       "https://images.unsplash.com/photo-1551634979-2b11f8c946fe?w=700&q=85",
  "bogotá":      "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=700&q=85",
  "bogota":      "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=700&q=85",
};

const List<String> _imagenesHotelAmenidades = [
  "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=85",
  "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=85",
  "https://images.unsplash.com/photo-1540541338537-0e0b353a7ed9?w=800&q=85",
  "https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800&q=85",
  "https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800&q=85",
  "https://images.unsplash.com/photo-1455587734955-081b22074882?w=800&q=85",
  "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&q=85",
  "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=85",
  "https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800&q=85",
  "https://images.unsplash.com/photo-1596178065887-1198b6148b2b?w=800&q=85",
];

String _getImagenHotelFallback(Map item) {
  final fromApi = item["imagen"]?.toString() ?? "";
  if (fromApi.isNotEmpty && fromApi.startsWith("http")) return fromApi;
  final key = (item["destino"] ?? "").toString().toLowerCase().trim();
  return _imagenHotelPorCiudad[key] ?? "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=700&q=85";
}

String _getImagenDestinoFallback(Map item) {
  final fromApi = item["imagen"]?.toString() ?? "";
  if (fromApi.isNotEmpty && fromApi.startsWith("http")) return fromApi;
  final key = (item["nombre"] ?? "").toString().toLowerCase().trim();
  return _imagenRealPorDestino[key] ?? "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=800&q=90";
}

List<String> _getGaleriaHotel(Map item) {
  final List<String> galeria = [];
  final fromApi = item["imagen"]?.toString() ?? "";
  if (fromApi.isNotEmpty && fromApi.startsWith("http")) galeria.add(fromApi);
  final extra = item["imagenes_extra"];
  if (extra is List) {
    for (final img in extra) { if (img.toString().isNotEmpty) galeria.add(img.toString()); }
  }
  for (final img in _imagenesHotelAmenidades) {
    if (galeria.length >= 8) break;
    if (!galeria.contains(img)) galeria.add(img);
  }
  return galeria;
}

class HomeScreen extends StatefulWidget {
  final String nombre;
  final String cedula;

  const HomeScreen({super.key, required this.nombre, required this.cedula});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List destinos = [];
  List hoteles = [];
  List vuelos = [];
  List tours = [];
  bool cargando = true;
  bool cargandoHoteles = false;
  bool cargandoVuelos = false;
  String busqueda = "";
  bool esVip = false;
  late AnimationController _iaController;
  late Animation<double> _iaAnimation;

  Map<String, String> precioMinPorDestino = {};

  Color get _primary => esVip ? const Color(0xFFD4AF37) : const Color(0xFF1A1A2E);
  Color get _accent => esVip ? const Color(0xFFFFD700) : const Color(0xFF4F8EF7);

  @override
  void initState() {
    super.initState();
    _iaController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _iaAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(CurvedAnimation(parent: _iaController, curve: Curves.easeInOut));
    cargarTodo();
  }

  @override
  void dispose() {
    _iaController.dispose();
    super.dispose();
  }

  Future<void> cargarTodo() async {
    setState(() => cargando = true);
    try {
      final futures = await Future.wait([
        http.get(Uri.parse("$baseUrl/obtener_destinos")),
        http.get(Uri.parse("$baseUrl/obtener_tours")),
        if (widget.cedula.isNotEmpty)
          http.get(Uri.parse("$baseUrl/mis_compras/${widget.cedula}")),
      ]);

      final destinosData = jsonDecode(futures[0].body)["destinos"] ?? [];
      final toursData = jsonDecode(futures[1].body)["tours"] ?? [];
      bool vip = false;

      if (widget.cedula.isNotEmpty && futures.length > 2) {
        final compras = jsonDecode(futures[2].body)["compras"] ?? [];
        vip = compras.length > 0;
      }

      setState(() {
        destinos = destinosData;
        tours = toursData;
        esVip = vip;
        cargando = false;
      });

      await Future.wait([
        cargarHotelesReales(destinosData),
        cargarVuelosReales(destinosData),
      ]);

    } catch (e) {
      print("❌ ERROR HOME: $e");
      setState(() => cargando = false);
    }
  }

  Future<void> cargarHotelesReales(List destinosData) async {
    setState(() => cargandoHoteles = true);
    try {
      List hotelesReales = [];
      final ciudades = destinosData.take(4).map((d) => d["nombre"].toString()).toList();
      final fecha = _fechaProxima(dias: 30);
      final fechaSalida = _fechaProxima(dias: 33);

      final resultados = await Future.wait(
        ciudades.map((ciudad) => http.post(
          Uri.parse("$baseUrl/buscar_hoteles_reales"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "ciudad": ciudad,
            "check_in": fecha,
            "check_out": fechaSalida,
            "personas": 2
          }),
        ).timeout(const Duration(seconds: 25))),
      );

      for (int i = 0; i < resultados.length; i++) {
        try {
          final data = jsonDecode(resultados[i].body);
          final lista = data["hoteles"] ?? [];
          hotelesReales.addAll(lista.take(3));
        } catch (e) {}
      }

      setState(() {
        hoteles = hotelesReales;
        cargandoHoteles = false;
      });
    } catch (e) {
      print("⚠️ Error hoteles: $e");
      setState(() => cargandoHoteles = false);
    }
  }

  Future<void> cargarVuelosReales(List destinosData) async {
    setState(() => cargandoVuelos = true);
    try {
      List vuelosReales = [];
      final fecha = _fechaProxima(dias: 30);
      final codigos = {
        "cartagena": "CTG", "san andres": "ADZ", "san andrés": "ADZ",
        "medellin": "MDE", "medellín": "MDE", "santa marta": "SMR",
        "bogota": "BOG", "bogotá": "BOG", "cali": "CLO",
        "barranquilla": "BAQ", "bucaramanga": "BGA", "pereira": "PEI",
        "punta cana": "PUJ", "cancun": "CUN", "miami": "MIA",
        "paris": "CDG", "madrid": "MAD",
      };

      final ciudades = destinosData.take(4).toList();

      final resultados = await Future.wait(
        ciudades.map((d) {
          final iata = codigos[d["nombre"].toString().toLowerCase()] ?? "CTG";
          return http.post(
            Uri.parse("$baseUrl/buscar_vuelos_reales"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "origen": "BOG",
              "destino": iata,
              "fecha": fecha,
              "tipo": "one-way"
            }),
          ).timeout(const Duration(seconds: 20));
        }),
      );

      for (int i = 0; i < resultados.length; i++) {
        try {
          final data = jsonDecode(resultados[i].body);
          final lista = data["vuelos"] ?? [];
          if (lista.isNotEmpty) {
            final vuelo = lista[0];
            vuelosReales.add(vuelo);
            final nombreDestino = ciudades[i]["nombre"].toString();
            precioMinPorDestino[nombreDestino] = vuelo["precio"] ?? "";
          }
        } catch (e) {}
      }

      setState(() {
        vuelos = vuelosReales;
        cargandoVuelos = false;
      });
    } catch (e) {
      print("⚠️ Error vuelos: $e");
      setState(() => cargandoVuelos = false);
    }
  }

  String _fechaProxima({int dias = 30}) {
    final fecha = DateTime.now().add(Duration(days: dias));
    return "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
  }

  List filtrar(List lista, String campo) {
    if (busqueda.isEmpty) return lista;
    return lista.where((item) =>
      (item[campo] ?? "").toString().toLowerCase().contains(busqueda.toLowerCase())
    ).toList();
  }

  void mostrarIADialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _IABottomSheet(esVip: esVip, cedula: widget.cedula),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool esInvitado = widget.nombre == "Invitado";
    final destinosFiltrados = filtrar(destinos, "nombre");
    final hotelesFiltrados = filtrar(hoteles, "nombre");
    final vuelosFiltrados = filtrar(vuelos, "destino");
    final toursFiltrados = filtrar(tours, "nombre");

    final bgColor = esVip ? const Color(0xFF0A0A0A) : const Color(0xFFF0F2F8);

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(esInvitado),
      floatingActionButton: _buildIAButton(),
      body: cargando
          ? Center(child: CircularProgressIndicator(color: esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7)))
          : RefreshIndicator(
              color: esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7),
              onRefresh: cargarTodo,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  _buildHero(),
                  const SizedBox(height: 28),
                  if (esVip) _buildVipBanner(),
                  if (destinosFiltrados.isNotEmpty) _buildSeccionDestinos(destinosFiltrados, esInvitado),
                  _buildTituloSeccion("Hoteles", "Alojamiento de lujo", Icons.hotel_rounded),
                  if (cargandoHoteles)
                    _buildCargando("Buscando hoteles disponibles...")
                  else if (hotelesFiltrados.isNotEmpty)
                    SizedBox(
                      height: 245,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: hotelesFiltrados.length,
                        itemBuilder: (context, index) => _HotelCard(
                          item: hotelesFiltrados[index],
                          cedula: widget.cedula,
                          esVip: esVip,
                          esInvitado: esInvitado,
                        ),
                      ),
                    )
                  else
                    _buildVacioSeccion("No hay hoteles disponibles"),
                  const SizedBox(height: 28),

                  _buildTituloSeccion("Vuelos", "Los mejores precios del día", Icons.flight_rounded),
                  if (cargandoVuelos)
                    _buildCargando("Buscando vuelos disponibles...")
                  else if (vuelosFiltrados.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: vuelosFiltrados.length,
                      itemBuilder: (context, index) => _VueloCard(
                        item: vuelosFiltrados[index],
                        cedula: widget.cedula,
                        esVip: esVip,
                        esInvitado: esInvitado,
                      ),
                    )
                  else
                    _buildVacioSeccion("No hay vuelos disponibles"),
                  const SizedBox(height: 28),

                  if (toursFiltrados.isNotEmpty) _buildSeccionTours(toursFiltrados, esInvitado),
                  _buildFooter(),
                ],
              ),
            ),
    );
  }

  Widget _buildCargando(String mensaje) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 14, height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7),
            ),
          ),
          const SizedBox(width: 10),
          Text(mensaje, style: TextStyle(color: esVip ? const Color(0xFFD4AF37).withOpacity(0.5) : Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildVacioSeccion(String mensaje) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(mensaje, style: TextStyle(color: esVip ? Colors.grey[600] : Colors.grey[400], fontSize: 13)),
    );
  }

  PreferredSizeWidget _buildAppBar(bool esInvitado) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: 64,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: esVip
                ? [const Color(0xFF0A0A0A), const Color(0xFF0A0A0A)]
                : [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: esVip
              ? const Border(bottom: BorderSide(color: Color(0xFFD4AF37), width: 0.5))
              : null,
        ),
      ),
      title: Row(
        children: [
          if (esVip)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFFFD700)]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text("VIP", style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "UNIX TRAVEL",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.5,
                  color: esVip ? const Color(0xFFD4AF37) : Colors.white,
                ),
              ),
              Text(
                "Bienvenido, ${widget.nombre}",
                style: TextStyle(
                  fontSize: 10,
                  color: esVip ? const Color(0xFFD4AF37).withOpacity(0.6) : Colors.white54,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        _AppBarIcon(
          icon: Icons.shopping_cart_outlined,
          esVip: esVip,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen(cedula: widget.cedula, esVip: esVip))),
        ),
        _AppBarIcon(
          icon: Icons.favorite_border_rounded,
          esVip: esVip,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FavoritesScreen(cedula: widget.cedula, esVip: esVip))),
        ),
        if (!esInvitado)
          _AppBarIcon(
            icon: Icons.person_outline_rounded,
            esVip: esVip,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(nombre: widget.nombre, cedula: widget.cedula))),
          ),
        if (esInvitado)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              ),
              child: const Text("Ingresar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildIAButton() {
    return ScaleTransition(
      scale: _iaAnimation,
      child: FloatingActionButton.extended(
        onPressed: mostrarIADialog,
        elevation: 8,
        backgroundColor: esVip ? const Color(0xFFD4AF37) : const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: Icon(Icons.auto_awesome_rounded, color: esVip ? Colors.black : Colors.white, size: 18),
        label: Text(
          esVip ? "IA VIP" : "Planear viaje",
          style: TextStyle(
            color: esVip ? Colors.black : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 100, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: esVip
              ? [const Color(0xFF0A0A0A), const Color(0xFF1A1200), const Color(0xFF0A0A0A)]
              : [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            esVip ? "Tu mundo,\nsin límites." : "¿A dónde\nquieres ir?",
            style: TextStyle(
              color: esVip ? const Color(0xFFD4AF37) : Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            esVip ? "Experiencias exclusivas para miembros VIP" : "Descubre destinos increíbles al mejor precio",
            style: TextStyle(
              color: esVip ? const Color(0xFFD4AF37).withOpacity(0.55) : Colors.white.withOpacity(0.55),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 22),
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: esVip ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: esVip ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.25)) : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(esVip ? 0.4 : 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => busqueda = v),
                    style: TextStyle(color: esVip ? Colors.white : Colors.black87, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Destinos, hoteles, vuelos...",
                      hintStyle: TextStyle(color: esVip ? Colors.grey[600] : Colors.grey[400], fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          // Filtros
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFiltro(Icons.flight_rounded, "Vuelos"),
              _buildFiltro(Icons.hotel_rounded, "Hoteles"),
              _buildFiltro(Icons.explore_rounded, "Destinos"),
              _buildFiltro(Icons.tour_rounded, "Tours"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFiltro(IconData icon, String texto) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: esVip ? const Color(0xFF1A1A1A) : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: esVip
                ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.25))
                : Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Icon(icon, color: esVip ? const Color(0xFFD4AF37) : Colors.white, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          texto,
          style: TextStyle(
            color: esVip ? const Color(0xFFD4AF37).withOpacity(0.75) : Colors.white.withOpacity(0.85),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVipBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1200), Color(0xFF2E2000), Color(0xFF1A1200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Text("👑", style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Miembro VIP Activo",
                  style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  "Accedes a precios y experiencias exclusivas",
                  style: TextStyle(color: const Color(0xFFD4AF37).withOpacity(0.55), fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: const Color(0xFFD4AF37).withOpacity(0.5), size: 20),
        ],
      ),
    );
  }

  Widget _buildSeccionDestinos(List data, bool esInvitado) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTituloSeccion("Destinos", "Explora el mundo", Icons.location_on_rounded),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: data.length,
            itemBuilder: (context, index) => _DestinoCard(
              item: data[index],
              cedula: widget.cedula,
              esVip: esVip,
              esInvitado: esInvitado,
              precioVuelo: precioMinPorDestino[data[index]["nombre"]] ?? "",
            ),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildSeccionTours(List data, bool esInvitado) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTituloSeccion("Tours", "Experiencias únicas", Icons.tour_rounded),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: data.length,
            itemBuilder: (context, index) => _TourCard(
              item: data[index],
              cedula: widget.cedula,
              esVip: esVip,
              esInvitado: esInvitado,
            ),
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildTituloSeccion(String titulo, String subtitulo, IconData icono) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: esVip ? const Color(0xFFD4AF37).withOpacity(0.12) : const Color(0xFF4F8EF7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icono, size: 16, color: esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: esVip ? Colors.white : const Color(0xFF1A1A2E),
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: TextStyle(fontSize: 11, color: esVip ? const Color(0xFFD4AF37).withOpacity(0.5) : Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: esVip ? const Color(0xFFD4AF37).withOpacity(0.1) : const Color(0xFF4F8EF7).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Ver todo",
              style: TextStyle(
                color: esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      child: Column(
        children: [
          Divider(color: esVip ? const Color(0xFFD4AF37).withOpacity(0.12) : Colors.grey[200]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 12, color: esVip ? Colors.grey[600] : Colors.grey[400]),
              const SizedBox(width: 5),
              Text("unixtravel@gmail.com", style: TextStyle(color: esVip ? Colors.grey[600] : Colors.grey[400], fontSize: 11)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone_outlined, size: 12, color: esVip ? Colors.grey[600] : Colors.grey[400]),
              const SizedBox(width: 5),
              Text("+57 300 123 4567", style: TextStyle(color: esVip ? Colors.grey[600] : Colors.grey[400], fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "© 2026 Unix Travel",
            style: TextStyle(
              color: esVip ? const Color(0xFFD4AF37).withOpacity(0.25) : Colors.grey[300],
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ========================
// Helper widget AppBar icon
// ========================
class _AppBarIcon extends StatelessWidget {
  final IconData icon;
  final bool esVip;
  final VoidCallback onTap;

  const _AppBarIcon({required this.icon, required this.esVip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: esVip ? const Color(0xFFD4AF37) : Colors.white, size: 20),
      ),
    );
  }
}

// =========================
// 🌍 DESTINO CARD
// =========================
class _DestinoCard extends StatelessWidget {
  final Map item;
  final String cedula;
  final bool esVip;
  final bool esInvitado;
  final String precioVuelo;

  const _DestinoCard({
    required this.item,
    required this.cedula,
    required this.esVip,
    required this.esInvitado,
    required this.precioVuelo,
  });

  @override
  Widget build(BuildContext context) {
    final imagenUrl = _getImagenDestinoFallback(item);

    return GestureDetector(
      onTap: () {
        if (esInvitado) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          return;
        }
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => DetailScreen(
            nombre: item["nombre"] ?? "",
            precio: item["precio"] ?? "",
            imagen: imagenUrl,
            cedula: cedula,
            tipo: "destino",
            esVip: esVip,
          ),
        ));
      },
      child: Container(
        width: 175,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: esVip ? const Color(0xFF141414) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: esVip ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.18)) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(esVip ? 0.35 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  Image.network(
                    imagenUrl,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, prog) => prog == null
                        ? child
                        : Container(height: 130, color: const Color(0xFF1A1A1A),
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24))),
                    errorBuilder: (_, __, ___) => Container(height: 130, color: Colors.grey[900]),
                  ),
                  Container(
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Badge
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: esVip ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        esVip ? "VIP" : "TOP",
                        style: TextStyle(
                          color: esVip ? Colors.black : const Color(0xFF1A1A2E),
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10, left: 10,
                    child: Text(
                      (item["categoria"]?.toString() ?? "").toUpperCase(),
                      style: const TextStyle(color: Colors.white60, fontSize: 9, letterSpacing: 1.2),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["nombre"] ?? "",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: esVip ? Colors.white : const Color(0xFF1A1A2E),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (precioVuelo.isNotEmpty)
                    Text(
                      "Desde $precioVuelo",
                      style: TextStyle(
                        color: esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    )
                  else
                    Text(
                      item["precio"] != null && item["precio"].toString().isNotEmpty
                          ? "Desde \$${item["precio"]}"
                          : "Ver precios",
                      style: TextStyle(
                        color: esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        "Explorar",
                        style: TextStyle(
                          color: esVip ? const Color(0xFFD4AF37).withOpacity(0.45) : Colors.grey[400],
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(Icons.arrow_forward_rounded,
                        size: 10,
                        color: esVip ? const Color(0xFFD4AF37).withOpacity(0.45) : Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// 🏨 HOTEL CARD
// =========================
class _HotelCard extends StatelessWidget {
  final Map item;
  final String cedula;
  final bool esVip;
  final bool esInvitado;

  const _HotelCard({required this.item, required this.cedula, required this.esVip, required this.esInvitado});

  @override
  Widget build(BuildContext context) {
    final imagenUrl = _getImagenHotelFallback(item);

    return GestureDetector(
      onTap: () {
        if (esInvitado) { Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())); return; }
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _HotelDetailSheet(item: item, cedula: cedula, esVip: esVip),
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: esVip ? const Color(0xFF141414) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: esVip ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.18)) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(esVip ? 0.35 : 0.07), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                children: [
                  Image.network(
                    imagenUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (ctx, child, prog) => prog == null
                        ? child
                        : Container(height: 120, color: const Color(0xFF1A1A1A),
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24))),
                    errorBuilder: (_, __, ___) => Container(height: 120, color: Colors.grey[900],
                        child: const Icon(Icons.hotel, color: Colors.white24, size: 36)),
                  ),
                  if (item["fuente"] == "real")
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text("REAL", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(
                      (item["estrellas"] ?? 3) as int,
                      (_) => Icon(Icons.star_rounded, size: 10, color: esVip ? const Color(0xFFD4AF37) : Colors.amber),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item["nombre"] ?? "",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: esVip ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 10, color: Colors.grey[500]),
                      const SizedBox(width: 2),
                      Text(item["destino"] ?? "", style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item["precio_noche"] ?? "Consultar",
                        style: TextStyle(
                          color: esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Text("/noche", style: TextStyle(color: Colors.grey[500], fontSize: 9)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// 🏨 HOTEL DETAIL SHEET
// =========================
class _HotelDetailSheet extends StatefulWidget {
  final Map item;
  final String cedula;
  final bool esVip;
  const _HotelDetailSheet({required this.item, required this.cedula, required this.esVip});
  @override
  State<_HotelDetailSheet> createState() => _HotelDetailSheetState();
}

class _HotelDetailSheetState extends State<_HotelDetailSheet> {
  int _currentImg = 0;
  late PageController _pc;
  late List<String> _galeria;

  Color get _primary => widget.esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7);
  Color get _bg => widget.esVip ? const Color(0xFF0A0A0A) : Colors.white;
  Color get _textColor => widget.esVip ? Colors.white : const Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    _pc = PageController();
    _galeria = _getGaleriaHotel(widget.item);
  }

  @override
  void dispose() { _pc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: widget.esVip ? const Border(top: BorderSide(color: Color(0xFFD4AF37), width: 1)) : null,
      ),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4,
          decoration: BoxDecoration(color: widget.esVip ? const Color(0xFFD4AF37) : Colors.grey[300], borderRadius: BorderRadius.circular(2))),
        Expanded(child: SingleChildScrollView(physics: const BouncingScrollPhysics(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 16),
          SizedBox(height: 240, child: Stack(children: [
            PageView.builder(
              controller: _pc, itemCount: _galeria.length,
              onPageChanged: (i) => setState(() => _currentImg = i),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(borderRadius: BorderRadius.circular(20),
                  child: Image.network(_galeria[i], fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]))),
              ),
            ),
            Positioned(top: 12, right: 28, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
              child: Text("${_currentImg + 1} / ${_galeria.length}", style: const TextStyle(color: Colors.white, fontSize: 11)),
            )),
            Positioned(bottom: 10, left: 0, right: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(
              _galeria.length > 10 ? 10 : _galeria.length,
              (i) => AnimatedContainer(duration: const Duration(milliseconds: 250), margin: const EdgeInsets.symmetric(horizontal: 2),
                width: _currentImg == i ? 16 : 5, height: 5,
                decoration: BoxDecoration(color: _currentImg == i ? (widget.esVip ? const Color(0xFFD4AF37) : Colors.white) : Colors.white38, borderRadius: BorderRadius.circular(3))),
            ))),
          ])),
          const SizedBox(height: 12),
          SizedBox(height: 62, child: ListView.builder(
            scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _galeria.length,
            itemBuilder: (ctx, i) => GestureDetector(
              onTap: () { _pc.animateToPage(i, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut); setState(() => _currentImg = i); },
              child: AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.only(right: 8),
                width: _currentImg == i ? 70 : 58,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: _currentImg == i ? _primary : Colors.transparent, width: 2)),
                child: ClipRRect(borderRadius: BorderRadius.circular(9), child: Image.network(_galeria[i], fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[800])))),
            ),
          )),
          Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: List.generate((widget.item["estrellas"] ?? 3) as int, (_) => Icon(Icons.star_rounded, size: 16, color: widget.esVip ? const Color(0xFFD4AF37) : Colors.amber))),
            const SizedBox(height: 8),
            Text(widget.item["nombre"] ?? "", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _textColor)),
            const SizedBox(height: 5),
            Row(children: [Icon(Icons.location_on_rounded, size: 14, color: Colors.grey[500]), const SizedBox(width: 4), Text(widget.item["destino"] ?? "", style: TextStyle(color: Colors.grey[500], fontSize: 13))]),
            const SizedBox(height: 18),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _Amenidad(icon: Icons.pool_rounded, label: "Piscina", esVip: widget.esVip),
              _Amenidad(icon: Icons.spa_rounded, label: "Spa", esVip: widget.esVip),
              _Amenidad(icon: Icons.restaurant_rounded, label: "Restaurante", esVip: widget.esVip),
              _Amenidad(icon: Icons.wifi_rounded, label: "WiFi", esVip: widget.esVip),
            ]),
            const SizedBox(height: 22),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.item["precio_noche"] ?? "Consultar", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _primary)),
                Text("por noche", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ]),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(nombre: widget.item["destino"] ?? "", precio: widget.item["precio_noche"] ?? "", imagen: _galeria.first, cedula: widget.cedula, tipo: "destino", esVip: widget.esVip)));
                },
                child: Text(widget.esVip ? "Reservar VIP" : "Reservar ahora", style: TextStyle(color: widget.esVip ? Colors.black : Colors.white, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 30),
          ])),
        ]))),
      ]),
    );
  }
}

class _Amenidad extends StatelessWidget {
  final IconData icon; final String label; final bool esVip;
  const _Amenidad({required this.icon, required this.label, required this.esVip});
  @override
  Widget build(BuildContext context) => Column(children: [
    Container(padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: esVip ? const Color(0xFFD4AF37).withOpacity(0.12) : const Color(0xFF4F8EF7).withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7), size: 18)),
    const SizedBox(height: 4),
    Text(label, style: TextStyle(fontSize: 10, color: esVip ? Colors.white60 : Colors.grey[600])),
  ]);
}

// =========================
// ✈️ VUELO CARD — estilo Avianca/Booking
// =========================
class _VueloCard extends StatelessWidget {
  final Map item;
  final String cedula;
  final bool esVip;
  final bool esInvitado;

  const _VueloCard({required this.item, required this.cedula, required this.esVip, required this.esInvitado});

  String _iataANombre(String iata) {
    final mapa = {
      "CTG": "Cartagena", "ADZ": "San Andres", "MDE": "Medellin",
      "SMR": "Santa Marta", "CLO": "Cali", "BAQ": "Barranquilla",
      "BGA": "Bucaramanga", "PEI": "Pereira", "PUJ": "Punta Cana",
      "CUN": "Cancun", "MIA": "Miami", "CDG": "Paris", "MAD": "Madrid",
    };
    return mapa[iata] ?? iata;
  }

  @override
  Widget build(BuildContext context) {
    final aerolinea = item["aerolinea"]?.toString() ?? "";
    final destinoNombre = _iataANombre(item["destino"] ?? "");
    final imgPortada = _getImagenesAerolinea(aerolinea).first;
    final esReal = item["fuente"] == "real";

    return GestureDetector(
      onTap: () {
        if (esInvitado) { Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())); return; }
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _VueloDetailSheet(item: item, cedula: cedula, esVip: esVip, destinoNombre: destinoNombre),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: esVip ? const Color(0xFF141414) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: esVip
              ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.15))
              : Border.all(color: Colors.grey.withOpacity(0.08)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(esVip ? 0.3 : 0.05), blurRadius: 12, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            // Imagen aerolínea circular
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: esVip
                    ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2))
                    : Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.network(
                  imgPortada,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: esVip ? const Color(0xFF1A1A1A) : const Color(0xFFF0F2F8),
                    child: Icon(Icons.flight_rounded, color: esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7), size: 22),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 13),
            // Ruta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item["origen"] ?? "",
                        style: TextStyle(fontWeight: FontWeight.w800, color: esVip ? Colors.white : const Color(0xFF1A1A2E), fontSize: 15, letterSpacing: -0.2),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(children: [
                          Container(width: 20, height: 1, color: Colors.grey.withOpacity(0.4)),
                          Icon(Icons.flight_rounded, size: 13, color: esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7)),
                          Container(width: 20, height: 1, color: Colors.grey.withOpacity(0.4)),
                        ]),
                      ),
                      Text(
                        item["destino"] ?? "",
                        style: TextStyle(fontWeight: FontWeight.w800, color: esVip ? Colors.white : const Color(0xFF1A1A2E), fontSize: 15, letterSpacing: -0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        aerolinea,
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                      Container(margin: const EdgeInsets.symmetric(horizontal: 5), width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey[500], shape: BoxShape.circle)),
                      Text(
                        item["duracion"] ?? "",
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Precio
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item["precio"] ?? "",
                  style: TextStyle(
                    color: esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                Text("p/persona", style: TextStyle(color: Colors.grey[500], fontSize: 9)),
                if (esReal)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: const Text("REAL", style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// ✈️ VUELO DETAIL SHEET
// =========================
class _VueloDetailSheet extends StatefulWidget {
  final Map item;
  final String cedula;
  final bool esVip;
  final String destinoNombre;
  const _VueloDetailSheet({required this.item, required this.cedula, required this.esVip, required this.destinoNombre});
  @override
  State<_VueloDetailSheet> createState() => _VueloDetailSheetState();
}

class _VueloDetailSheetState extends State<_VueloDetailSheet> {
  int _currentImg = 0;
  late PageController _pc;
  late List<String> _imagenes;

  Color get _primary => widget.esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7);
  Color get _bg => widget.esVip ? const Color(0xFF0A0A0A) : Colors.white;
  Color get _textColor => widget.esVip ? Colors.white : const Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    _pc = PageController();
    _imagenes = _getImagenesAerolinea(widget.item["aerolinea"]?.toString() ?? "");
  }

  @override
  void dispose() { _pc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final aerolinea = widget.item["aerolinea"]?.toString() ?? "Aerolínea";
    final origen = widget.item["origen"]?.toString() ?? "";
    final destino = widget.item["destino"]?.toString() ?? "";
    final precio = widget.item["precio"]?.toString() ?? "";
    final duracion = widget.item["duracion"]?.toString() ?? "";
    final horaSalida = widget.item["hora_salida"]?.toString() ?? "";
    final horaLlegada = widget.item["hora_llegada"]?.toString() ?? "";
    final esReal = widget.item["fuente"] == "real";

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: widget.esVip ? const Border(top: BorderSide(color: Color(0xFFD4AF37), width: 1)) : null,
      ),
      child: Column(children: [
        Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4,
          decoration: BoxDecoration(color: widget.esVip ? const Color(0xFFD4AF37) : Colors.grey[300], borderRadius: BorderRadius.circular(2))),
        Expanded(child: SingleChildScrollView(physics: const BouncingScrollPhysics(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 16),
          SizedBox(height: 230, child: Stack(children: [
            PageView.builder(
              controller: _pc, itemCount: _imagenes.length,
              onPageChanged: (i) => setState(() => _currentImg = i),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(borderRadius: BorderRadius.circular(20),
                  child: Image.network(_imagenes[i], fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey[800], child: const Icon(Icons.flight_rounded, color: Colors.white24, size: 60)))),
              ),
            ),
            Positioned(top: 12, right: 28, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
              child: Text("${_currentImg + 1} / ${_imagenes.length}", style: const TextStyle(color: Colors.white, fontSize: 11)),
            )),
            Positioned(bottom: 10, left: 0, right: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_imagenes.length, (i) => GestureDetector(
              onTap: () => _pc.animateToPage(i, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut),
              child: AnimatedContainer(duration: const Duration(milliseconds: 250), margin: const EdgeInsets.symmetric(horizontal: 2), width: _currentImg == i ? 18 : 5, height: 5, decoration: BoxDecoration(color: _currentImg == i ? (widget.esVip ? const Color(0xFFD4AF37) : Colors.white) : Colors.white38, borderRadius: BorderRadius.circular(3))),
            )))),
            if (_currentImg > 0) Positioned(left: 20, top: 0, bottom: 0, child: Center(child: GestureDetector(onTap: () => _pc.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut), child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle), child: const Icon(Icons.chevron_left, color: Colors.white, size: 20))))),
            if (_currentImg < _imagenes.length - 1) Positioned(right: 20, top: 0, bottom: 0, child: Center(child: GestureDetector(onTap: () => _pc.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut), child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle), child: const Icon(Icons.chevron_right, color: Colors.white, size: 20))))),
          ])),
          const SizedBox(height: 12),
          SizedBox(height: 58, child: ListView.builder(
            scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _imagenes.length,
            itemBuilder: (ctx, i) => GestureDetector(
              onTap: () { _pc.animateToPage(i, duration: const Duration(milliseconds: 350), curve: Curves.easeInOut); setState(() => _currentImg = i); },
              child: AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.only(right: 8), width: _currentImg == i ? 66 : 54,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(9), border: Border.all(color: _currentImg == i ? _primary : Colors.transparent, width: 2)),
                child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(_imagenes[i], fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey[800]))),
              ),
            ),
          )),
          Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.flight_rounded, color: _primary, size: 22)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(aerolinea, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _textColor)),
                if (esReal)
                  Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.green.withOpacity(0.3))), child: const Text("Precio en tiempo real", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w700))),
              ]),
            ]),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _primary.withOpacity(0.15)),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(children: [
                  Text(origen, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _textColor, letterSpacing: -0.5)),
                  if (horaSalida.isNotEmpty) Text(horaSalida.length > 16 ? horaSalida.substring(11, 16) : horaSalida, style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600)),
                  Text("Origen", style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                ]),
                Column(children: [
                  Icon(Icons.flight_rounded, color: _primary, size: 26),
                  const SizedBox(height: 5),
                  Text(duracion, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                  Container(width: 70, height: 1, color: Colors.grey.withOpacity(0.3)),
                ]),
                Column(children: [
                  Text(destino, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _textColor, letterSpacing: -0.5)),
                  if (horaLlegada.isNotEmpty) Text(horaLlegada.length > 16 ? horaLlegada.substring(11, 16) : horaLlegada, style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600)),
                  Text("Destino", style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                ]),
              ]),
            ),
            const SizedBox(height: 22),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(precio, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _primary, letterSpacing: -0.5)),
                Text("por persona", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ]),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(nombre: widget.destinoNombre, precio: precio, imagen: _imagenes.first, cedula: widget.cedula, tipo: "destino", esVip: widget.esVip)));
                },
                child: Text(widget.esVip ? "Reservar VIP" : "Reservar ahora", style: TextStyle(color: widget.esVip ? Colors.black : Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ]),
            const SizedBox(height: 30),
          ])),
        ]))),
      ]),
    );
  }
}

// =========================
// 🎯 TOUR CARD
// =========================
class _TourCard extends StatelessWidget {
  final Map item;
  final String cedula;
  final bool esVip;
  final bool esInvitado;

  const _TourCard({required this.item, required this.cedula, required this.esVip, required this.esInvitado});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (esInvitado) { Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())); return; }
        Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(
          nombre: item["nombre"] ?? "",
          precio: item["precio"] ?? "",
          imagen: item["imagen"] ?? "",
          cedula: cedula,
          tipo: "tour",
          esVip: esVip,
        )));
      },
      child: Container(
        width: 165,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: esVip ? const Color(0xFF141414) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: esVip ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.18)) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(esVip ? 0.3 : 0.06), blurRadius: 12)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                item["imagen"] ?? "",
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(height: 100, color: Colors.grey[900]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item["nombre"] ?? "",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: esVip ? Colors.white : const Color(0xFF1A1A2E)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.schedule_rounded, size: 10, color: Colors.grey[500]),
                    const SizedBox(width: 3),
                    Text(item["duracion"] ?? "", style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    item["precio"] ?? "",
                    style: TextStyle(
                      color: esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================
// 🤖 IA BOTTOM SHEET
// =========================
class _IABottomSheet extends StatefulWidget {
  final bool esVip;
  final String cedula;

  const _IABottomSheet({required this.esVip, required this.cedula});

  @override
  State<_IABottomSheet> createState() => _IABottomSheetState();
}

class _IABottomSheetState extends State<_IABottomSheet> with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  bool _pensando = false;
  String _respuesta = "";
  late AnimationController _animController;

  Color get _primary => widget.esVip ? const Color(0xFFD4AF37) : const Color(0xFF4F8EF7);
  Color get _bg => widget.esVip ? const Color(0xFF0A0A0A) : Colors.white;
  Color get _textColor => widget.esVip ? Colors.white : const Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generarPlan() async {
    if (_controller.text.isEmpty) return;
    setState(() { _pensando = true; _respuesta = ""; });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _pensando = false;
      _respuesta = _generarRespuestaIA(_controller.text);
    });
  }

  String _generarRespuestaIA(String consulta) {
    final planes = [
      """Plan A — Cartagena Perfecta
✈️ Vuelo Bogotá → Cartagena \$756.000 x2 = \$1.512.000
🏨 Hotel Santa Clara 4 noches \$450.000 = \$1.800.000
🎯 Tour Ciudad Amurallada \$80.000 x2 = \$160.000
💰 Total estimado: \$3.472.000 COP
⭐ Recomendación: Ideal para parejas""",
      """Plan B — San Andrés Todo Incluido
✈️ Vuelo Bogotá → San Andrés \$1.050.000 x2 = \$2.100.000
🏨 Decameron Aquarium 3 noches \$600.000 = \$1.800.000
🎯 Snorkel Johnny Cay \$120.000 x2 = \$240.000
💰 Total estimado: \$4.140.000 COP
⭐ Recomendación: Para amantes del mar""",
      """Plan C — Medellín Cultural
✈️ Vuelo Bogotá → Medellín \$504.000 x2 = \$1.008.000
🏨 Hotel Poblado 3 noches \$280.000 = \$840.000
🎯 Tour Comuna 13 \$60.000 x2 = \$120.000
💰 Total estimado: \$1.968.000 COP
⭐ Recomendación: El más económico""",
    ];
    return "Basado en tu consulta, aquí tienes 3 planes ideales:\n\n${planes.join("\n\n")}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: widget.esVip ? const Border(top: BorderSide(color: Color(0xFFD4AF37), width: 1)) : null,
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: widget.esVip ? const Color(0xFFD4AF37) : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.esVip
                          ? [const Color(0xFFD4AF37), const Color(0xFFFFD700)]
                          : [const Color(0xFF1A1A2E), const Color(0xFF4F8EF7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.auto_awesome_rounded, color: widget.esVip ? Colors.black : Colors.white, size: 18),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.esVip ? "Asistente VIP de Viajes" : "Planificador IA",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: _textColor, letterSpacing: -0.2),
                    ),
                    Text("Cuéntame qué sueñas y lo hago realidad", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: widget.esVip ? const Color(0xFFD4AF37).withOpacity(0.15) : Colors.grey[100]),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _pensando
                  ? Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const SizedBox(height: 40),
                        CircularProgressIndicator(color: _primary, strokeWidth: 2.5),
                        const SizedBox(height: 18),
                        Text("Analizando las mejores opciones...", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ]),
                    )
                  : _respuesta.isEmpty
                      ? Column(children: [
                          const SizedBox(height: 16),
                          Icon(Icons.explore_rounded, size: 52, color: _primary.withOpacity(0.18)),
                          const SizedBox(height: 14),
                          Text("¿Qué tipo de viaje buscas?", style: TextStyle(fontWeight: FontWeight.w700, color: _textColor, fontSize: 14)),
                          const SizedBox(height: 12),
                          ...[
                            "Quiero ir a la playa, tengo \$4M, somos 2",
                            "Busco algo cultural y económico",
                            "Viaje de aventura para 4 personas",
                          ].map((e) => GestureDetector(
                            onTap: () { _controller.text = e; },
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: _primary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _primary.withOpacity(0.15)),
                              ),
                              child: Row(children: [
                                Icon(Icons.arrow_forward_ios_rounded, size: 11, color: _primary.withOpacity(0.5)),
                                const SizedBox(width: 10),
                                Text(e, style: TextStyle(color: _textColor, fontSize: 13)),
                              ]),
                            ),
                          )).toList(),
                        ])
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: _primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _primary.withOpacity(0.18)),
                          ),
                          child: Text(_respuesta, style: TextStyle(color: _textColor, height: 1.7, fontSize: 13)),
                        ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: BoxDecoration(
              color: _bg,
              border: Border(top: BorderSide(color: widget.esVip ? const Color(0xFFD4AF37).withOpacity(0.12) : Colors.grey.withOpacity(0.1))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: widget.esVip ? const Color(0xFF1A1A1A) : const Color(0xFFF0F2F8),
                      borderRadius: BorderRadius.circular(14),
                      border: widget.esVip ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)) : null,
                    ),
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: _textColor, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Describe tu viaje ideal...",
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _generarPlan,
                  child: Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.esVip
                            ? [const Color(0xFFD4AF37), const Color(0xFFFFD700)]
                            : [const Color(0xFF1A1A2E), const Color(0xFF4F8EF7)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.send_rounded, color: widget.esVip ? Colors.black : Colors.white, size: 18),
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