import 'package:flutter/material.dart';
import 'grades_page.dart'; // Asumiendo que existe
import 'messages_page.dart'; // Asumiendo que existe
import 'students_page.dart'; // Asumiendo que existe
import 'courses_page.dart'; // Asumiendo que existe
import 'teachers_page.dart'; // Asumiendo que existe
import 'login_page.dart'; // Asumiendo que existe
import 'package:google_fonts/google_fonts.dart';

// --- NUEVA PÁGINA DE CURSOS ADICIONALES ---

class AdditionalCoursesPage extends StatelessWidget {
  const AdditionalCoursesPage({super.key});

  final List<Map<String, String>> additionalCourses = const [
    {'title': 'Lengua Extranjera (Francés)', 'subtitle': 'Desarrollo de fluidez comunicativa.', 'icon': 'language'},
    {'title': 'Habilidades Tecnológicas', 'subtitle': 'Introducción a la Programación y Diseño Web.', 'icon': 'computer'},
    {'title': 'Habilidades de Lectura Avanzada', 'subtitle': 'Técnicas de lectura rápida y comprensión crítica.', 'icon': 'book'},
    {'title': 'Finanzas Personales', 'subtitle': 'Gestión de presupuestos y ahorro.', 'icon': 'paid'},
  ];

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cursos Adicionales'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: additionalCourses.length,
        itemBuilder: (context, index) {
          final course = additionalCourses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(
                course['icon'] == 'language' ? Icons.language 
                : course['icon'] == 'computer' ? Icons.computer
                : course['icon'] == 'book' ? Icons.menu_book
                : Icons.paid, 
                color: primaryColor, 
                size: 28
              ),
              title: Text(
                course['title']!,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: Text(course['subtitle']!, style: GoogleFonts.inter()),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}

// --- PÁGINA PRINCIPAL DASHBOARD ---

class DashboardPage extends StatelessWidget {
  final String userRole;
  final String userId;

  const DashboardPage({super.key, required this.userRole, required this.userId});

  @override
  Widget build(BuildContext context) {
    // Definimos las opciones de menú en una lista, incluyendo íconos
    List<Map<String, dynamic>> menuOptions = [];

    // Opciones para el rol de Administrador
    if (userRole == 'admin') {
      menuOptions.addAll([
        {'title': 'Gestión de Estudiantes', 'icon': Icons.people_alt, 'page': const StudentsPage()},
        {'title': 'Gestión de Profesores', 'icon': Icons.school, 'page': const TeachersPage()},
        {'title': 'Gestión de Cursos', 'icon': Icons.library_books, 'page': const CoursesPage()},
      ]);
    } 
    // Opciones para el rol de Profesor
    else if (userRole == 'teacher') {
      menuOptions.addAll([
        {'title': 'Gestión de Estudiantes', 'icon': Icons.people_alt, 'page': const StudentsPage()},
        {'title': 'Mis Cursos', 'icon': Icons.library_books, 'page': const CoursesPage()},
        {'title': 'Calificaciones', 'icon': Icons.score, 'page': GradesPage(studentId: userId)},
      ]);
    } 
    // Opciones para el rol de Estudiante
    else if (userRole == 'student') {
      menuOptions.addAll([
        {'title': 'Mis Cursos', 'icon': Icons.library_books, 'page': const CoursesPage()},
        {'title': 'Mis Calificaciones', 'icon': Icons.score, 'page': GradesPage(studentId: userId)},
      ]);
    }

    // Opciones universales (Cursos Adicionales y Mensajes)
    menuOptions.add({
      'title': 'Cursos Adicionales', 
      'icon': Icons.extension, 
      'page': const AdditionalCoursesPage() // Nueva página agregada aquí
    });
    menuOptions.add({
      'title': 'Mensajes', 
      'icon': Icons.chat_bubble_outline, 
      'page': MessagesPage(currentUserId: userId)
    });

    return Scaffold(
      appBar: AppBar(
        // El estilo de la AppBar viene del tema de main.dart
        title: Text('Dashboard de ${userRole.toUpperCase()}', style: Theme.of(context).appBarTheme.titleTextStyle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de sección estilizado
            Text(
              'Bienvenido al Portal',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold, 
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              'Selecciona una opción de acceso rápido:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // GridView para mostrar las opciones como tarjetas
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Desactiva el scroll interno
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Dos tarjetas por fila
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.0, // Tarjetas cuadradas
              ),
              itemCount: menuOptions.length,
              itemBuilder: (context, index) {
                final option = menuOptions[index];
                return _buildDashboardCard(
                  context,
                  option['title'],
                  option['icon'],
                  option['page'],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget de tarjeta profesional con estilo degradado y sombra
  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, Widget page) {
    // Usamos el color de acento (naranja) para Mensajes y Cursos Adicionales
    final bool isSpecialCard = title == 'Mensajes' || title == 'Cursos Adicionales';
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color accentColor = Theme.of(context).colorScheme.secondary;

    final Color cardColor = isSpecialCard 
        ? accentColor 
        : primaryColor;
    
    return Card(
      elevation: 10, // Sombra moderna
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            // Aplicamos un degradado sutil al color de la tarjeta
            gradient: LinearGradient(
              colors: [cardColor.withOpacity(1.0), cardColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  size: 48,
                  color: Colors.white, // Ícono blanco para alto contraste
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
