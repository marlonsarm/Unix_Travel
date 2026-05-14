import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateUserScreen extends StatefulWidget {
  const UpdateUserScreen({super.key});

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen> {
  final nombreController = TextEditingController();
  final apellidosController = TextEditingController();
  final emailController = TextEditingController();
  final telefonoController = TextEditingController();

  bool usuarioCargado = false;
  bool guardando = false;
  bool esVip = false;
  String? cedula;
  String? fotoBase64;

  Color get _primary => esVip ? const Color(0xFFD4AF37) : const Color(0xFF2C5364);
  Color get _bg => esVip ? const Color(0xFF0A0A0A) : const Color(0xFFF4F6FB);
  Color get _cardBg => esVip ? const Color(0xFF1A1A1A) : Colors.white;
  Color get _textColor => esVip ? Colors.white : Colors.black87;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  Future<void> cargarUsuario() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      cedula = prefs.getString("cedula");
      if (cedula == null) return;

      final response = await http.get(Uri.parse("http://127.0.0.1:5000/user/$cedula"));
      final comprasRes = await http.get(Uri.parse("http://127.0.0.1:5000/mis_compras/$cedula"));

      final data = jsonDecode(response.body);
      final comprasData = jsonDecode(comprasRes.body);

      if (response.statusCode == 200) {
        final usuario = data["usuario"];
        final compras = comprasData["compras"] ?? [];

        setState(() {
          nombreController.text = usuario["nombre"] ?? "";
          apellidosController.text = usuario["apellidos"] ?? "";
          emailController.text = usuario["email"] ?? "";
          telefonoController.text = usuario["telefono"] ?? "";
          fotoBase64 = usuario["foto_perfil"];
          esVip = compras.length > 0;
          usuarioCargado = true;
        });
      }
    } catch (e) {
      print("ERROR: $e");
    }
  }

  Future<void> seleccionarFoto() async {
    // Simulamos selección de foto con un color aleatorio como demo
    // En producción usarías image_picker
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardBg,
        title: Text("Foto de perfil", style: TextStyle(color: _textColor)),
        content: Text(
          "Para subir una foto real necesitas agregar el paquete image_picker al proyecto. Por ahora puedes usar una URL de imagen.",
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Entendido", style: TextStyle(color: _primary)),
          ),
        ],
      ),
    );
  }

  Future<void> actualizarUsuario() async {
    if (nombreController.text.isEmpty || emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa los campos obligatorios")),
      );
      return;
    }

    setState(() => guardando = true);

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/update_user"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "cedula": cedula,
          "nombre": nombreController.text,
          "apellidos": apellidosController.text,
          "email": emailController.text,
          "telefono": telefonoController.text,
        }),
      );

      final data = jsonDecode(response.body);

      setState(() => guardando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["mensaje"]),
          backgroundColor: response.statusCode == 200 ? Colors.green : Colors.red,
        ),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error de conexión")),
      );
    }
  }

  Widget _buildInput(String label, TextEditingController controller, IconData icon, {TextInputType tipo = TextInputType.text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _primary.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        style: TextStyle(color: _textColor),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _primary, size: 20),
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: esVip ? const Color(0xFF0A0A0A) : const Color(0xFF0F2027),
        title: Text(
          "Editar Perfil",
          style: TextStyle(color: esVip ? const Color(0xFFD4AF37) : Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: esVip ? const Color(0xFFD4AF37) : Colors.white),
        elevation: 0,
      ),
      body: !usuarioCargado
          ? Center(child: CircularProgressIndicator(color: _primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  // FOTO PERFIL
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _primary, width: 3),
                            boxShadow: esVip
                                ? [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.3), blurRadius: 20)]
                                : [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15)],
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: esVip ? const Color(0xFF1A1A1A) : const Color(0xFF243B55),
                            child: fotoBase64 != null
                                ? ClipOval(
                                    child: Image.memory(
                                      base64Decode(fotoBase64!),
                                      width: 110,
                                      height: 110,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Text(
                                    nombreController.text.isNotEmpty ? nombreController.text[0].toUpperCase() : "U",
                                    style: TextStyle(fontSize: 36, color: esVip ? const Color(0xFFD4AF37) : Colors.white, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: seleccionarFoto,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: _bg, width: 2),
                              ),
                              child: Icon(Icons.camera_alt, size: 16, color: esVip ? Colors.black : Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (esVip)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFFFD700)]),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text("MIEMBRO VIP", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1)),
                    ),

                  const SizedBox(height: 30),

                  // CAMPOS
                  _buildInput("Nombre *", nombreController, Icons.person_outline),
                  _buildInput("Apellidos", apellidosController, Icons.person),
                  _buildInput("Correo electrónico *", emailController, Icons.email_outlined, tipo: TextInputType.emailAddress),
                  _buildInput("Teléfono", telefonoController, Icons.phone_outlined, tipo: TextInputType.phone),

                  const SizedBox(height: 10),

                  // BOTÓN GUARDAR
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      onPressed: guardando ? null : actualizarUsuario,
                      child: guardando
                          ? CircularProgressIndicator(color: esVip ? Colors.black : Colors.white)
                          : Text(
                              "Guardar cambios",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: esVip ? Colors.black : Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}