import 'package:flutter/material.dart';
import 'screens/dashboard_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos un rol y un ID de usuario por defecto para las pruebas.
    const String defaultRole = 'admin';
    const String defaultUserId = '4';
    
    // Definición de colores vibrantes y modernos
    const Color primaryColor = Color(0xFF00ADB5); // Azul verdoso (Teal) fresco
    const Color accentColor = Color(0xFFFF5722); // Naranja vibrante para el acento

    return MaterialApp(
      title: 'Sistema Escolar',
      theme: ThemeData(
        // Tema Material 3
        useMaterial3: true,
        // Color primario principal
        primaryColor: primaryColor,
        // Esquema de colores basado en el color primario
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: accentColor,
          // Fondo limpio
          background: const Color(0xFFEEEEEE),
        ),
        // Configuración de la AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Configuración de botones elevados para un aspecto moderno
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Bordes redondeados
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        // Usamos la fuente 'Inter' para un aspecto limpio y moderno
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      // Mantenemos el Dashboard como página de inicio para visualización
      home: const DashboardPage(userRole: defaultRole, userId: defaultUserId),
    );
  }
}
