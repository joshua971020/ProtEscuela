import 'package:flutter/material.dart';

// Modelo de datos simulado para no depender de la API
class Course {
  final String id;
  final String name;

  Course({required this.id, required this.name});
}

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  // Datos de cursos simulados para visualización
  final List<Course> _simulatedCourses = [
    Course(id: '101', name: 'Introducción a la Programación'),
    Course(id: '102', name: 'Historia Mundial'),
    Course(id: '103', name: 'Literatura Española'),
    Course(id: '104', name: 'Ciencias Naturales'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Cursos'),
      ),
      body: _simulatedCourses.isEmpty
          ? const Center(child: Text('No hay cursos disponibles.'))
          : ListView.builder(
              itemCount: _simulatedCourses.length,
              itemBuilder: (context, index) {
                final course = _simulatedCourses[index];
                return ListTile(
                  title: Text(course.name),
                  subtitle: Text('ID del curso: ${course.id}'),
                );
              },
            ),
    );
  }
}
