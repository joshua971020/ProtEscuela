import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_page.dart'; // Asegúrate de que este archivo exista

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = '';

  // *** Lógica de Autenticación Simulada para Visualización ***
  // Reemplazar con la llamada a ApiService cuando esté lista.
  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    
    // Simulación de roles y credenciales (admin, profesor, estudiante)
    final Map<String, String> simulatedUsers = {
      'admin': 'admin', // Role: admin, ID: 4
      'profesor': 'profesor', // Role: teacher, ID: 3
      'juanp': 'juanp', // Role: student, ID: 1
    };

    String role = '';
    String userId = '';

    if (simulatedUsers.containsKey(username) && simulatedUsers[username] == password) {
      if (username == 'admin') {
        role = 'admin';
        userId = '4';
      } else if (username == 'profesor') {
        role = 'teacher';
        userId = '3';
      } else {
        role = 'student';
        userId = '1';
      }

      // Simular un pequeño retraso para una experiencia de usuario realista
      await Future.delayed(const Duration(milliseconds: 500)); 

      // Navega al dashboard si el login es exitoso
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(userRole: role, userId: userId),
        ),
      );
    } else {
      setState(() {
        _message = 'Usuario o contraseña inválidos.';
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
              // Icono Grande y Llamativo
              Icon(
                Icons.school_rounded,
                size: 90,
                color: primaryColor,
              ),
              const SizedBox(height: 10),
              
              // Título Estilizado
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

              // Campo de Usuario
              TextFormField(
                controller: _usernameController,
                style: GoogleFonts.inter(),
                decoration: InputDecoration(
                  labelText: 'Usuario (Ej: admin, profesor, juanp)',
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
              
              // Campo de Contraseña
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
              
              // Botón de Iniciar Sesión (aprovecha el estilo de main.dart)
              ElevatedButton(
                onPressed: _login,
                child: const Text('INGRESAR'),
              ),
              
              const SizedBox(height: 20),
              
              // Mensaje de Error
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
                    style: GoogleFonts.inter(color: Colors.red.shade800, fontWeight: FontWeight.w500),
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
