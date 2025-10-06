import 'package:flutter/material.dart';

// Modelo de datos simulado para no depender de la API
class Grade {
  final String studentId;
  final String courseId;
  final double grade;

  Grade({required this.studentId, required this.courseId, required this.grade});
}

class GradesPage extends StatefulWidget {
  final String studentId;
  const GradesPage({super.key, required this.studentId});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  // Datos de calificaciones simulados para visualización
  final List<Grade> _simulatedGrades = [
    Grade(studentId: '1', courseId: '101', grade: 9.5),
    Grade(studentId: '1', courseId: '102', grade: 8.0),
    Grade(studentId: '2', courseId: '101', grade: 8.5),
  ];

  @override
  Widget build(BuildContext context) {
    // Filtramos las calificaciones según el ID del estudiante
    final studentGrades = _simulatedGrades
        .where((grade) => grade.studentId == widget.studentId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Calificaciones'),
      ),
      body: studentGrades.isEmpty
          ? const Center(child: Text('No hay calificaciones registradas.'))
          : ListView.builder(
              itemCount: studentGrades.length,
              itemBuilder: (context, index) {
                final grade = studentGrades[index];
                return ListTile(
                  title: Text('Curso ID: ${grade.courseId}'),
                  subtitle: Text('Nota: ${grade.grade}'),
                );
              },
            ),
    );
  }
}
