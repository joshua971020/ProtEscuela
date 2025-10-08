import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dashboard_page.dart';
import 'dashboard_alumno_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = '';
  bool _loading = false;

  Future<void> _login() async {
    final nickname = _usernameController.text.trim();
    final pass = _passwordController.text.trim();

    if (nickname.isEmpty || pass.isEmpty) {
      setState(() {
        _message = 'Por favor ingresa usuario y contraseña.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      final response = await http.post(
        Uri.parse('https://escolar-production-c025.up.railway.app/usuarios/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nickname': nickname,
          'pass': pass,
        }),
      );

      final data = jsonDecode(response.body);
      setState(() => _loading = false);

      if (response.statusCode == 200 && data['ok'] == true) {
        final usuario = data['usuario'];
final rol = int.tryParse(usuario['rol'].toString()) ?? 0; // 👈 convierte a entero
String rolString = '';

switch (rol) {
  case 1:
    rolString = 'student';
    break;
  case 2:
    rolString = 'teacher';
    break;
  case 3:
    rolString = 'admin';
    break;
  default:
    rolString = 'unknown';
}


        // Redirigir según el rol
if (rol == 1) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => DashboardAlumnoPage(
        nombre: usuario['nombre'], // 👈 pasa el nombre real
      ),
    ),
  );
} else {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => DashboardPage(
        userRole: rolString,
        userId: usuario['id'].toString(),
      ),
    ),
  );
}

      } else {
        setState(() {
          _message = data['error'] ?? 'Usuario o contraseña incorrectos.';
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _message = 'Error de conexión con el servidor.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color accentColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Icono
              Icon(Icons.school_rounded, size: 90, color: primaryColor),
              const SizedBox(height: 10),

              // Título
              Text(
                'Portal Educativo',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Inicia sesión para continuar',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),

              // Usuario
              TextFormField(
                controller: _usernameController,
                style: GoogleFonts.inter(),
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  labelStyle: GoogleFonts.inter(color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.person, color: primaryColor),
                ),
              ),
              const SizedBox(height: 16),

              // Contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: GoogleFonts.inter(),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: GoogleFonts.inter(color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accentColor, width: 2),
                  ),
                  prefixIcon: Icon(Icons.lock, color: primaryColor),
                ),
              ),
              const SizedBox(height: 30),

              // Botón de login
              ElevatedButton(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'INGRESAR',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 20),

              // Mensaje de error
              if (_message.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    _message,
                    style: GoogleFonts.inter(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
