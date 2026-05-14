import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'login_screen.dart';

const String baseUrl = "http://127.0.0.1:5000";

class AdminScreen extends StatefulWidget {
  final String nombre;
  final String cedula;

  const AdminScreen({super.key, required this.nombre, required this.cedula});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _tabIndex = 0;

  final List<Widget> _tabs = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _DashboardTab(),
      _DestinosTab(),
      _HotelesTab(),
      _VuelosTab(),
      _ToursTab(),
      _UsuariosTab(),
      _ReservasTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Unix Travel — Admin 🛠️",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Hola, ${widget.nombre}",
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Cerrar sesión",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: tabs[_tabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        selectedItemColor: const Color(0xFF2C5364),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Destinos"),
          BottomNavigationBarItem(icon: Icon(Icons.hotel), label: "Hoteles"),
          BottomNavigationBarItem(icon: Icon(Icons.flight), label: "Vuelos"),
          BottomNavigationBarItem(icon: Icon(Icons.tour), label: "Tours"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Usuarios"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Reservas"),
        ],
      ),
    );
  }
}

// =========================
// 📊 DASHBOARD
// =========================

class _DashboardTab extends StatefulWidget {
  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  Map stats = {};
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarStats();
  }

  Future<void> cargarStats() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/admin/stats"));
      final data = jsonDecode(response.body);
      setState(() {
        stats = data;
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Resumen general",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _StatCard("👥 Usuarios", "${stats["total_usuarios"] ?? 0}", Colors.blue),
              _StatCard("📦 Reservas", "${stats["total_reservas"] ?? 0}", Colors.green),
              _StatCard("🌍 Destinos", "${stats["total_destinos"] ?? 0}", Colors.orange),
              _StatCard("🏨 Hoteles", "${stats["total_hoteles"] ?? 0}", Colors.purple),
              _StatCard("✈️ Vuelos", "${stats["total_vuelos"] ?? 0}", Colors.cyan),
              _StatCard("🎯 Tours", "${stats["total_tours"] ?? 0}", Colors.red),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color color;

  const _StatCard(this.titulo, this.valor, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(valor,
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 6),
          Text(titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }
}

// =========================
// 🌍 DESTINOS — con toggle de aeropuerto
// =========================

class _DestinosTab extends StatefulWidget {
  @override
  State<_DestinosTab> createState() => _DestinosTabState();
}

class _DestinosTabState extends State<_DestinosTab> {
  List destinos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/obtener_destinos"));
      final data = jsonDecode(response.body);
      setState(() {
        destinos = data["destinos"];
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  Future<void> eliminar(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Eliminar destino?"),
        content: const Text("Esta acción no se puede deshacer."),
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
      await http.delete(Uri.parse("$baseUrl/eliminar_destino/$id"));
      cargar();
    }
  }

  Future<void> mostrarFormulario({Map? destino}) async {
    final nombreCtrl = TextEditingController(text: destino?["nombre"] ?? "");
    final descCtrl = TextEditingController(text: destino?["descripcion"] ?? "");
    final precioCtrl = TextEditingController(text: destino?["precio"] ?? "");
    final imagenCtrl = TextEditingController(text: destino?["imagen"] ?? "");
    final categoriaCtrl = TextEditingController(text: destino?["categoria"] ?? "");
    final iataCtrl = TextEditingController(text: destino?["codigo_iata"] ?? "");

    // 🔥 Campos para destinos SIN aeropuerto
    final aeropuertoCercanoCtrl = TextEditingController(text: destino?["aeropuerto_cercano"] ?? "");
    final iataCercanoCtrl = TextEditingController(text: destino?["iata_cercano"] ?? "");
    final instruccionesCtrl = TextEditingController(text: destino?["instrucciones_acceso"] ?? "");
    final transporteCtrl = TextEditingController(text: destino?["transporte_info"] ?? "");
    final tiempoTerrestreCtrl = TextEditingController(text: destino?["tiempo_terrestre"] ?? "");

    // 🔥 Estado del toggle — true = tiene aeropuerto, false = no tiene
    bool tieneAeropuerto = destino != null
        ? (destino["tiene_aeropuerto"] == 1 || destino["tiene_aeropuerto"] == true)
        : true;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(destino == null ? "Agregar Destino 🌍" : "Editar Destino ✏️"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Campo(ctrl: nombreCtrl, label: "Nombre del destino"),
                  _Campo(ctrl: descCtrl, label: "Descripción"),
                  _Campo(ctrl: precioCtrl, label: "Precio base"),
                  _Campo(ctrl: imagenCtrl, label: "URL Imagen"),
                  _Campo(ctrl: categoriaCtrl, label: "Categoría (playa, ciudad, isla...)"),

                  const SizedBox(height: 8),
                  const Divider(),
                  // 🔥 TOGGLE AEROPUERTO
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: tieneAeropuerto
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: tieneAeropuerto
                            ? Colors.green.withOpacity(0.4)
                            : Colors.orange.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          tieneAeropuerto ? Icons.flight_takeoff : Icons.directions_bus,
                          color: tieneAeropuerto ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tieneAeropuerto
                                    ? "✅ Tiene aeropuerto directo"
                                    : "🚌 No tiene aeropuerto directo",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: tieneAeropuerto ? Colors.green[700] : Colors.orange[700],
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                tieneAeropuerto
                                    ? "Los usuarios verán vuelos directos"
                                    : "Se mostrará info de transporte alternativo",
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: tieneAeropuerto,
                          activeColor: Colors.green,
                          inactiveTrackColor: Colors.orange.withOpacity(0.4),
                          onChanged: (val) => setStateDialog(() => tieneAeropuerto = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 🔥 SI TIENE AEROPUERTO → solo IATA
                  if (tieneAeropuerto) ...[
                    _Campo(ctrl: iataCtrl, label: "Código IATA (ej: CTG, ADZ, MDE)"),
                  ],

                  // 🔥 SI NO TIENE AEROPUERTO → campos de transporte
                  if (!tieneAeropuerto) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Información de acceso alternativo",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange),
                          ),
                          const SizedBox(height: 8),
                          _Campo(
                            ctrl: aeropuertoCercanoCtrl,
                            label: "Aeropuerto más cercano (ej: Bogotá - El Dorado)",
                          ),
                          _Campo(
                            ctrl: iataCercanoCtrl,
                            label: "IATA del aeropuerto cercano (ej: BOG)",
                          ),
                          _Campo(
                            ctrl: tiempoTerrestreCtrl,
                            label: "Tiempo de viaje terrestre (ej: 2h 30min)",
                          ),
                          _Campo(
                            ctrl: instruccionesCtrl,
                            label: "Instrucciones para llegar (texto libre)",
                          ),
                          _Campo(
                            ctrl: transporteCtrl,
                            label: "Opciones de transporte (Bus, Taxi, etc.)",
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C5364)),
                onPressed: () async {
                  final body = jsonEncode({
                    "nombre": nombreCtrl.text,
                    "descripcion": descCtrl.text,
                    "precio": precioCtrl.text,
                    "imagen": imagenCtrl.text,
                    "categoria": categoriaCtrl.text,
                    // 🔥 Nuevos campos de aeropuerto
                    "tiene_aeropuerto": tieneAeropuerto,
                    "codigo_iata": tieneAeropuerto ? iataCtrl.text : iataCercanoCtrl.text,
                    "aeropuerto_cercano": aeropuertoCercanoCtrl.text,
                    "iata_cercano": iataCercanoCtrl.text,
                    "instrucciones_acceso": instruccionesCtrl.text,
                    "transporte_info": transporteCtrl.text,
                    "tiempo_terrestre": tiempoTerrestreCtrl.text,
                  });
                  if (destino == null) {
                    await http.post(Uri.parse("$baseUrl/agregar_destino"),
                        headers: {"Content-Type": "application/json"}, body: body);
                  } else {
                    await http.post(Uri.parse("$baseUrl/editar_destino/${destino["id"]}"),
                        headers: {"Content-Type": "application/json"}, body: body);
                  }
                  Navigator.pop(context);
                  cargar();
                },
                child: const Text("Guardar", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2C5364),
        onPressed: () => mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : destinos.isEmpty
              ? const Center(child: Text("No hay destinos aún"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: destinos.length,
                  itemBuilder: (context, index) {
                    final d = destinos[index];
                    // 🔥 Muestra badge de aeropuerto en la card
                    final tieneAeropuerto = d["tiene_aeropuerto"] == 1 || d["tiene_aeropuerto"] == true;
                    return _ItemCard(
                      imagen: d["imagen"] ?? "",
                      titulo: d["nombre"] ?? "",
                      subtitulo: "${d["categoria"] ?? ""} — ${d["precio"] ?? ""}",
                      badge: tieneAeropuerto
                          ? null
                          : "Sin aeropuerto directo",
                      badgeColor: Colors.orange,
                      onEditar: () => mostrarFormulario(destino: d),
                      onEliminar: () => eliminar(d["id"]),
                    );
                  },
                ),
    );
  }
}

// =========================
// 🏨 HOTELES
// =========================

class _HotelesTab extends StatefulWidget {
  @override
  State<_HotelesTab> createState() => _HotelesTabState();
}

class _HotelesTabState extends State<_HotelesTab> {
  List hoteles = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/obtener_hoteles"));
      final data = jsonDecode(response.body);
      setState(() {
        hoteles = data["hoteles"];
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  Future<void> eliminar(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Eliminar hotel?"),
        content: const Text("Esta acción no se puede deshacer."),
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
      await http.delete(Uri.parse("$baseUrl/eliminar_hotel/$id"));
      cargar();
    }
  }

  Future<void> mostrarFormulario({Map? hotel}) async {
    final nombreCtrl = TextEditingController(text: hotel?["nombre"] ?? "");
    final descCtrl = TextEditingController(text: hotel?["descripcion"] ?? "");
    final precioCtrl = TextEditingController(text: hotel?["precio_noche"] ?? "");
    final imagenCtrl = TextEditingController(text: hotel?["imagen"] ?? "");
    final destinoCtrl = TextEditingController(text: hotel?["destino"] ?? "");
    final estrellasCtrl = TextEditingController(text: "${hotel?["estrellas"] ?? 3}");

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(hotel == null ? "Agregar Hotel 🏨" : "Editar Hotel ✏️"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Campo(ctrl: nombreCtrl, label: "Nombre"),
              _Campo(ctrl: descCtrl, label: "Descripción"),
              _Campo(ctrl: precioCtrl, label: "Precio por noche"),
              _Campo(ctrl: imagenCtrl, label: "URL Imagen"),
              _Campo(ctrl: destinoCtrl, label: "Destino"),
              _Campo(ctrl: estrellasCtrl, label: "Estrellas (1-5)", tipo: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C5364)),
            onPressed: () async {
              final body = jsonEncode({
                "nombre": nombreCtrl.text,
                "descripcion": descCtrl.text,
                "precio_noche": precioCtrl.text,
                "imagen": imagenCtrl.text,
                "destino": destinoCtrl.text,
                "estrellas": int.tryParse(estrellasCtrl.text) ?? 3,
              });
              if (hotel == null) {
                await http.post(Uri.parse("$baseUrl/agregar_hotel"),
                    headers: {"Content-Type": "application/json"}, body: body);
              } else {
                await http.post(Uri.parse("$baseUrl/editar_hotel/${hotel["id"]}"),
                    headers: {"Content-Type": "application/json"}, body: body);
              }
              Navigator.pop(context);
              cargar();
            },
            child: const Text("Guardar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2C5364),
        onPressed: () => mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : hoteles.isEmpty
              ? const Center(child: Text("No hay hoteles aún"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: hoteles.length,
                  itemBuilder: (context, index) {
                    final h = hoteles[index];
                    return _ItemCard(
                      imagen: h["imagen"] ?? "",
                      titulo: h["nombre"] ?? "",
                      subtitulo: "${h["destino"] ?? ""} — ${h["precio_noche"] ?? ""}/noche — ⭐${h["estrellas"] ?? 3}",
                      onEditar: () => mostrarFormulario(hotel: h),
                      onEliminar: () => eliminar(h["id"]),
                    );
                  },
                ),
    );
  }
}

// =========================
// ✈️ VUELOS
// =========================

class _VuelosTab extends StatefulWidget {
  @override
  State<_VuelosTab> createState() => _VuelosTabState();
}

class _VuelosTabState extends State<_VuelosTab> {
  List vuelos = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/obtener_vuelos"));
      final data = jsonDecode(response.body);
      setState(() {
        vuelos = data["vuelos"];
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  Future<void> eliminar(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Eliminar vuelo?"),
        content: const Text("Esta acción no se puede deshacer."),
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
      await http.delete(Uri.parse("$baseUrl/eliminar_vuelo/$id"));
      cargar();
    }
  }

  Future<void> mostrarFormulario({Map? vuelo}) async {
    final origenCtrl = TextEditingController(text: vuelo?["origen"] ?? "");
    final destinoCtrl = TextEditingController(text: vuelo?["destino"] ?? "");
    final precioCtrl = TextEditingController(text: vuelo?["precio"] ?? "");
    final imagenCtrl = TextEditingController(text: vuelo?["imagen"] ?? "");
    final aerolineaCtrl = TextEditingController(text: vuelo?["aerolinea"] ?? "");
    final duracionCtrl = TextEditingController(text: vuelo?["duracion"] ?? "");

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(vuelo == null ? "Agregar Vuelo ✈️" : "Editar Vuelo ✏️"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Campo(ctrl: origenCtrl, label: "Origen"),
              _Campo(ctrl: destinoCtrl, label: "Destino"),
              _Campo(ctrl: precioCtrl, label: "Precio"),
              _Campo(ctrl: imagenCtrl, label: "URL Imagen"),
              _Campo(ctrl: aerolineaCtrl, label: "Aerolínea"),
              _Campo(ctrl: duracionCtrl, label: "Duración (ej: 2h 30min)"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C5364)),
            onPressed: () async {
              final body = jsonEncode({
                "origen": origenCtrl.text,
                "destino": destinoCtrl.text,
                "precio": precioCtrl.text,
                "imagen": imagenCtrl.text,
                "aerolinea": aerolineaCtrl.text,
                "duracion": duracionCtrl.text,
              });
              if (vuelo == null) {
                await http.post(Uri.parse("$baseUrl/agregar_vuelo"),
                    headers: {"Content-Type": "application/json"}, body: body);
              } else {
                await http.post(Uri.parse("$baseUrl/editar_vuelo/${vuelo["id"]}"),
                    headers: {"Content-Type": "application/json"}, body: body);
              }
              Navigator.pop(context);
              cargar();
            },
            child: const Text("Guardar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2C5364),
        onPressed: () => mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : vuelos.isEmpty
              ? const Center(child: Text("No hay vuelos aún"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: vuelos.length,
                  itemBuilder: (context, index) {
                    final v = vuelos[index];
                    return _ItemCard(
                      imagen: v["imagen"] ?? "",
                      titulo: "${v["origen"] ?? ""} → ${v["destino"] ?? ""}",
                      subtitulo: "${v["aerolinea"] ?? ""} — ${v["precio"] ?? ""} — ${v["duracion"] ?? ""}",
                      onEditar: () => mostrarFormulario(vuelo: v),
                      onEliminar: () => eliminar(v["id"]),
                    );
                  },
                ),
    );
  }
}

// =========================
// 🎯 TOURS
// =========================

class _ToursTab extends StatefulWidget {
  @override
  State<_ToursTab> createState() => _ToursTabState();
}

class _ToursTabState extends State<_ToursTab> {
  List tours = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/obtener_tours"));
      final data = jsonDecode(response.body);
      setState(() {
        tours = data["tours"];
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  Future<void> eliminar(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Eliminar tour?"),
        content: const Text("Esta acción no se puede deshacer."),
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
      await http.delete(Uri.parse("$baseUrl/eliminar_tour/$id"));
      cargar();
    }
  }

  Future<void> mostrarFormulario({Map? tour}) async {
    final nombreCtrl = TextEditingController(text: tour?["nombre"] ?? "");
    final descCtrl = TextEditingController(text: tour?["descripcion"] ?? "");
    final precioCtrl = TextEditingController(text: tour?["precio"] ?? "");
    final imagenCtrl = TextEditingController(text: tour?["imagen"] ?? "");
    final destinoCtrl = TextEditingController(text: tour?["destino"] ?? "");
    final duracionCtrl = TextEditingController(text: tour?["duracion"] ?? "");

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tour == null ? "Agregar Tour 🎯" : "Editar Tour ✏️"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Campo(ctrl: nombreCtrl, label: "Nombre"),
              _Campo(ctrl: descCtrl, label: "Descripción"),
              _Campo(ctrl: precioCtrl, label: "Precio"),
              _Campo(ctrl: imagenCtrl, label: "URL Imagen"),
              _Campo(ctrl: destinoCtrl, label: "Destino"),
              _Campo(ctrl: duracionCtrl, label: "Duración"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2C5364)),
            onPressed: () async {
              final body = jsonEncode({
                "nombre": nombreCtrl.text,
                "descripcion": descCtrl.text,
                "precio": precioCtrl.text,
                "imagen": imagenCtrl.text,
                "destino": destinoCtrl.text,
                "duracion": duracionCtrl.text,
              });
              if (tour == null) {
                await http.post(Uri.parse("$baseUrl/agregar_tour"),
                    headers: {"Content-Type": "application/json"}, body: body);
              } else {
                await http.post(Uri.parse("$baseUrl/editar_tour/${tour["id"]}"),
                    headers: {"Content-Type": "application/json"}, body: body);
              }
              Navigator.pop(context);
              cargar();
            },
            child: const Text("Guardar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2C5364),
        onPressed: () => mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : tours.isEmpty
              ? const Center(child: Text("No hay tours aún"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: tours.length,
                  itemBuilder: (context, index) {
                    final t = tours[index];
                    return _ItemCard(
                      imagen: t["imagen"] ?? "",
                      titulo: t["nombre"] ?? "",
                      subtitulo: "${t["destino"] ?? ""} — ${t["precio"] ?? ""} — ${t["duracion"] ?? ""}",
                      onEditar: () => mostrarFormulario(tour: t),
                      onEliminar: () => eliminar(t["id"]),
                    );
                  },
                ),
    );
  }
}

// =========================
// 👥 USUARIOS
// =========================

class _UsuariosTab extends StatefulWidget {
  @override
  State<_UsuariosTab> createState() => _UsuariosTabState();
}

class _UsuariosTabState extends State<_UsuariosTab> {
  List usuarios = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/admin/usuarios"));
      final data = jsonDecode(response.body);
      setState(() {
        usuarios = data["usuarios"];
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  Future<void> cambiarRol(String cedula, String rolActual) async {
    final nuevoRol = rolActual == "admin" ? "cliente" : "admin";
    await http.post(
      Uri.parse("$baseUrl/admin/cambiar_rol"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"cedula": cedula, "tipo_usuario": nuevoRol}),
    );
    cargar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Rol cambiado a $nuevoRol ✅")),
    );
  }

  Future<void> eliminar(String cedula) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Eliminar usuario?"),
        content: const Text("Esta acción no se puede deshacer."),
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
      await http.delete(Uri.parse("$baseUrl/admin/eliminar_usuario/$cedula"));
      cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) return const Center(child: CircularProgressIndicator());
    if (usuarios.isEmpty) return const Center(child: Text("No hay usuarios"));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: usuarios.length,
      itemBuilder: (context, index) {
        final u = usuarios[index];
        final esAdmin = u["tipo_usuario"] == "admin";

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: esAdmin ? const Color(0xFF2C5364) : Colors.grey[300],
              child: Icon(
                esAdmin ? Icons.admin_panel_settings : Icons.person,
                color: esAdmin ? Colors.white : Colors.black54,
              ),
            ),
            title: Text("${u["nombre"]} ${u["apellidos"]}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${u["email"]}\nCédula: ${u["cedula"]}"),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: esAdmin ? "Quitar admin" : "Hacer admin",
                  child: IconButton(
                    icon: Icon(
                      esAdmin ? Icons.star : Icons.star_border,
                      color: esAdmin ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () => cambiarRol(u["cedula"], u["tipo_usuario"]),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => eliminar(u["cedula"]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =========================
// 📦 RESERVAS
// =========================

class _ReservasTab extends StatefulWidget {
  @override
  State<_ReservasTab> createState() => _ReservasTabState();
}

class _ReservasTabState extends State<_ReservasTab> {
  List reservas = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/admin/reservas"));
      final data = jsonDecode(response.body);
      setState(() {
        reservas = data["reservas"];
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) return const Center(child: CircularProgressIndicator());
    if (reservas.isEmpty) return const Center(child: Text("No hay reservas aún"));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: reservas.length,
      itemBuilder: (context, index) {
        final r = reservas[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    r["imagen"] ?? "",
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported, size: 60),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r["nombre_producto"] ?? "",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text("👤 ${r["nombre"]} ${r["apellidos"]}",
                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text("💰 ${r["precio"]}",
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      if (r["fecha_ida"] != null)
                        Text("✈️ ${r["fecha_ida"]} → ${r["fecha_vuelta"]}",
                            style: const TextStyle(fontSize: 12)),
                      Text("👥 ${r["personas"]} personas",
                          style: const TextStyle(fontSize: 12)),
                      Text("📅 Comprado: ${r["fecha_compra"]?.substring(0, 10) ?? ""}",
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =========================
// 🔧 WIDGETS REUTILIZABLES
// =========================

class _Campo extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final TextInputType tipo;

  const _Campo({
    required this.ctrl,
    required this.label,
    this.tipo = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: ctrl,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final String imagen;
  final String titulo;
  final String subtitulo;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _ItemCard({
    required this.imagen,
    required this.titulo,
    required this.subtitulo,
    this.badge,
    this.badgeColor,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imagen,
            width: 55,
            height: 55,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.image_not_supported, size: 55),
          ),
        ),
        title: Row(
          children: [
            Expanded(child: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold))),
            // 🔥 Badge "Sin aeropuerto" si aplica
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: (badgeColor ?? Colors.orange).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: badgeColor ?? Colors.orange,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(subtitulo, style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Color(0xFF2C5364)), onPressed: onEditar),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onEliminar),
          ],
        ),
      ),
    );
  }
}