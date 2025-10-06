import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Modelo de datos simulado para no depender de la API
class Teacher {
  final String id;
  final String name;
  final String subject;

  Teacher({required this.id, required this.name, required this.subject});
}

class TeachersPage extends StatefulWidget {
  const TeachersPage({super.key});

  @override
  State<TeachersPage> createState() => _TeachersPageState();
}

class _TeachersPageState extends State<TeachersPage> {
  // Datos de profesores simulados para visualización
  final List<Teacher> _simulatedTeachers = [
    Teacher(id: '1', name: 'Profesor García', subject: 'Matemáticas'),
    Teacher(id: '2', name: 'Profesora López', subject: 'Historia'),
    Teacher(id: '3', name: 'Dr. Sánchez', subject: 'Física Avanzada'),
    Teacher(id: '4', name: 'Lic. Ramírez', subject: 'Literatura Española'),
  ];

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color accentColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Profesores'),
      ),
      body: _simulatedTeachers.isEmpty
          ? const Center(child: Text('No hay profesores registrados.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: _simulatedTeachers.length,
              itemBuilder: (context, index) {
                final teacher = _simulatedTeachers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListTile(
                      // Icono circular profesional
                      leading: CircleAvatar(
                        backgroundColor: primaryColor.withOpacity(0.1),
                        child: Icon(Icons.person_pin, color: primaryColor),
                      ),
                      title: Text(
                        teacher.name,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: primaryColor,
                        ),
                      ),
                      subtitle: Text(
                        'Materia: ${teacher.subject}',
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right, color: accentColor),
                      onTap: () {
                        // Implementación futura: ver detalles del profesor/cursos asignados
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Ver perfil de ${teacher.name}')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
