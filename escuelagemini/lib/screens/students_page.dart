import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// --- CONSTANTE DE LA API ---
const String apiUrl = 'https://escolar-production-c025.up.railway.app/alumnos';

// --- MODELOS DE DATOS ---

class Course {
  final String id;
  final String name;
  final String teacher;
  final double grade;

  Course({required this.id, required this.name, required this.teacher, required this.grade});
}

class Student {
  final String id;
  final String name;
  final String email;
  final String grade;
  final List<Course> courses; 

  Student({required this.id, required this.name, required this.email, required this.grade, required this.courses});

  factory Student.fromJson(Map<String, dynamic> json) {
    // Usamos las claves correctas de tu JSON: 'id', 'nombre', 'correo'
    final id = json['id']?.toString() ?? UniqueKey().toString(); 
    final name = json['nombre'] ?? 'Nombre Desconocido';
    final email = json['correo'] ?? 'correo@desconocido.com';
    
    // Datos de ejemplo simulados (se mantienen)
    final grade = '10'; 
    final courses = [ 
      Course(id: 'C101', name: 'Matemáticas', teacher: 'Prof. A', grade: (name.length * 0.5) % 10 + 1), 
      Course(id: 'C102', name: 'Lengua', teacher: 'Prof. B', grade: (name.length * 0.7) % 10 + 1),
    ];

    return Student(
      id: id,
      name: name,
      email: email,
      grade: grade,
      courses: courses,
    );
  }
}

// --- FUNCIÓN PARA OBTENER DATOS (GET) ---

Future<List<Student>> fetchStudents() async {
  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Student.fromJson(json)).toList();
    } else {
      throw Exception('Fallo al cargar estudiantes. Código: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error de conexión o datos: $e');
  }
}

// --- FUNCIÓN PARA AÑADIR DATOS (POST) ---

Future<void> postStudent(String nombre, String correo) async {
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    // Codificamos los datos a enviar con las claves que tu API espera
    body: jsonEncode(<String, String>{
      'nombre': nombre,
      'correo': correo,
    }),
  );

  if (response.statusCode != 201 && response.statusCode != 200) {
    // Muchas APIs REST devuelven 201 Created para POST exitosos.
    throw Exception('Fallo al añadir el alumno. Código: ${response.statusCode}');
  }
  // Si fue exitoso, no necesitamos hacer nada más que retornar.
}

// --- PÁGINA PRINCIPAL DE ESTUDIANTES (Muestra el Promedio y el FAB) ---

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  late Future<List<Student>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = fetchStudents(); 
  }
  
  // Función para recargar la lista de estudiantes
  void _refreshStudents() {
    setState(() {
      _studentsFuture = fetchStudents();
    });
  }

  double _calculateAverage(List<Course> courses) {
    if (courses.isEmpty) return 0.0;
    double totalGrade = courses.fold(0.0, (sum, course) => sum + course.grade);
    return totalGrade / courses.length;
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Estudiantes (API)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStudents, // Usamos la nueva función de recarga
          ),
        ],
      ),
      body: FutureBuilder<List<Student>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            final List<Student> students = snapshot.data!;

            if (students.isEmpty) {
              return const Center(child: Text('No hay estudiantes registrados en la API.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final double averageGrade = _calculateAverage(student.courses);

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentCoursesPage(student: student),
                        ),
                      );
                    },
                    leading: Icon(Icons.person_pin, color: primaryColor, size: 30),
                    title: Text(
                      student.name,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      'Correo: ${student.email} | Promedio: ${averageGrade.toStringAsFixed(2)}', 
                      style: GoogleFonts.inter()
                    ),
                    trailing: Icon(Icons.star, color: primaryColor, size: 20),
                  ),
                );
              },
            );
          }
          
          return const Center(child: Text('Esperando datos...'));
        },
      ),
      
      // **********************************************
      // ************ BOTÓN FLOTANTE AÑADIDO ************
      // **********************************************
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navega a la página para añadir alumno y espera un resultado (true si se añadió)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddStudentPage(),
            ),
          );
          
          // Si la página de añadir devolvió 'true' (alumno agregado), recarga la lista.
          if (result == true) {
            _refreshStudents();
            // Muestra una confirmación rápida
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Alumno añadido exitosamente!')),
            );
          }
        },
        child: const Icon(Icons.person_add),
        tooltip: 'Añadir nuevo alumno',
      ),
      // **********************************************
    );
  }
}

// --- NUEVA PÁGINA: AÑADIR ALUMNO ---

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await postStudent(_nameController.text, _emailController.text);
        
        // Si es exitoso, regresa a la página anterior con el resultado 'true'
        // para que StudentsPage sepa que debe refrescar.
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        // Muestra el error en caso de fallo
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: ${e.toString()}')),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Nuevo Alumno'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Campo de Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  icon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce el nombre del alumno.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Campo de Correo
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  icon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce el correo electrónico.';
                  }
                  // Validación de formato de correo simple
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Por favor, introduce un correo válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              
              // Botón de Guardar
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitForm,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isLoading ? 'Guardando...' : 'Guardar Alumno',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- PÁGINA DE DETALLE DE MATERIAS (Se mantiene sin cambios) ---

class StudentCoursesPage extends StatelessWidget {
  final Student student;

  const StudentCoursesPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final List<Course> sortedCourses = List.from(student.courses);
    sortedCourses.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text('Materias de ${student.name}'),
      ),
      body: sortedCourses.isEmpty
          ? const Center(child: Text('Este estudiante no tiene materias asignadas.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: sortedCourses.length,
              itemBuilder: (context, index) {
                final course = sortedCourses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(Icons.menu_book, color: primaryColor, size: 28),
                    title: Text(
                      course.name,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Text(
                      'Profesor: ${course.teacher} | Calificación: ${course.grade.toStringAsFixed(1)} (Simulada)', 
                      style: GoogleFonts.inter()
                    ),
                  ),
                );
              },
            ),
    );
  }
}