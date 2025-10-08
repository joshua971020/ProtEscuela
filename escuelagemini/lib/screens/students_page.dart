import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// --- CONSTANTES GLOBALES ---
const String apiUrl = 'https://escolar-production-c025.up.railway.app/alumnos';
// Total de materias para calcular el progreso de la carrera (REQUERIMIENTO)
const int TOTAL_COURSES = 45; 

// --- FUNCIÓN AUXILIAR DE ESTILO ---

Color getGradeColor(double grade) {
  // 60 o menos es reprobado (rojo), 61 o más es aprobado (verde)
  return grade <= 60 ? Colors.red.shade700 : Colors.green.shade600;
}

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
  final String photoUrl;
  // NUEVO: Campo para la Carrera
  final String career;

  Student({
    required this.id, 
    required this.name, 
    required this.email, 
    required this.grade, 
    required this.courses,
    required this.photoUrl,
    required this.career, // Añadido
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    String rawName = json['nombre'] ?? 'Nombre Desconocido';
    
    // Simulación del nombre de Juan para prueba de ordenamiento
    if (rawName.toLowerCase().contains('juan')) {
      rawName = 'Miramontes De Jesus Juan Pablo';
    }
    
    final id = json['id']?.toString() ?? UniqueKey().toString(); 
    final name = rawName;
    final email = json['correo'] ?? 'correo@desconocido.com';
    final grade = '10'; 
    
    // URL de foto: Intentamos leer 'foto' de la API, si no existe, usamos placeholder
    final photoUrl = json['foto']?.toString() ?? 'https://i.pravatar.cc/150?u=$id'; 

    // ************************************************************
    // ***** NUEVA LÓGICA: ASIGNACIÓN DE CARRERA (SIMULADA) *****
    // ************************************************************
    final careers = ['DESARROLLO DE SOFTWARE', 'INGENIERÍA EN IA', 'ADMINISTRACIÓN DE EMPRESAS', 'MERCADOTECNIA DIGITAL'];
    // Asignamos una carrera basándonos en el ID para que sea pseudo-aleatorio pero estable
    final career = careers[id.hashCode % careers.length]; 

    // Generamos calificaciones entre 0 y 100
    final courses = [ 
      Course(id: 'C101', name: 'Matemáticas', teacher: 'Prof. A', grade: ((name.length * 5) % 90 + 10).toDouble()), 
      Course(id: 'C102', name: 'Lengua', teacher: 'Prof. B', grade: ((name.length * 7) % 100).toDouble()),
    ];

    return Student(
      id: id,
      name: name,
      email: email,
      grade: grade,
      courses: courses,
      photoUrl: photoUrl,
      career: career, // Asignado
    );
  }

  // Método para obtener el nombre en formato Apellido, Nombre (para mostrar)
  String get displayName {
    final parts = name.split(' ');
    if (parts.length < 3) {
      return name;
    }

    int numNames = 2; 
    if (parts.length == 3) {
      numNames = 1; 
    }
    
    final names = parts.sublist(parts.length - numNames).join(' ');
    final surnames = parts.sublist(0, parts.length - numNames).join(' ');

    return '$surnames, $names';
  }

  // Método para obtener la primera palabra (apellido) en minúsculas (para ordenar)
  String get sortName {
    final parts = name.split(' ');
    if (parts.isEmpty) return '';
    return parts.first.toLowerCase(); 
  }
}

// ----------------------------------------------------------------------
// --- FUNCIONES DE LA API (CRUD) ---
// ----------------------------------------------------------------------

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

Future<void> postStudent(String nombre, String correo) async {
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode(<String, String>{'nombre': nombre, 'correo': correo}),
  );
  if (response.statusCode != 201 && response.statusCode != 200) {
    throw Exception('Fallo al añadir el alumno. Código: ${response.statusCode}');
  }
}

Future<void> deleteStudent(String studentId) async {
  final urlWithId = '$apiUrl/$studentId';
  final response = await http.delete(Uri.parse(urlWithId));
  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception('Fallo al eliminar el alumno. Código: ${response.statusCode}');
  }
}

Future<void> updateStudent(String id, String nombre, String correo, String photoUrl) async {
  final urlWithId = '$apiUrl/$id'; 
  final response = await http.put(
    Uri.parse(urlWithId),
    headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode(<String, String>{
      'nombre': nombre, 
      'correo': correo,
      'foto': photoUrl, // Incluimos la foto para simular la actualización
    }),
  );
  if (response.statusCode != 200) {
    throw Exception('Fallo al actualizar el alumno. Código: ${response.statusCode}');
  }
}

// ----------------------------------------------------------------------
// --- PÁGINA PRINCIPAL DE ESTUDIANTES (StudentsPage) ---
// ----------------------------------------------------------------------

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
  
  void _refreshStudents() {
    setState(() {
      _studentsFuture = fetchStudents();
    });
  }

  void _deleteAndRefresh(String studentId, String studentName) async {
    try {
      await deleteStudent(studentId);
      _refreshStudents(); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estudiante "$studentName" eliminado!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
      _refreshStudents();
    }
  }

  double _calculateAverage(List<Course> courses) {
    if (courses.isEmpty) return 0.0;
    double totalGrade = courses.fold(0.0, (sum, course) => sum + course.grade);
    return totalGrade / courses.length;
  }

  void _navigateToEditPage(Student student) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStudentPage(studentToEdit: student), 
      ),
    );
    
    if (result == true) {
      _refreshStudents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${student.displayName} actualizado exitosamente!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión Escolar', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.2), 
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStudents,
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
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     const Icon(Icons.error_outline, color: Colors.red, size: 40),
                     const SizedBox(height: 10),
                     Text('Error de conexión:\n${snapshot.error}', textAlign: TextAlign.center),
                     ElevatedButton(
                       onPressed: _refreshStudents, 
                       child: const Text('Reintentar'),
                     ),
                   ],
                 ),
               ),
             );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 5));
          }

          if (snapshot.hasData) {
            final List<Student> students = snapshot.data!;
            
            // Lógica de ordenamiento por apellido
            final List<Student> sortedStudents = List.from(students);
            sortedStudents.sort((a, b) => a.sortName.compareTo(b.sortName));
            final displayList = sortedStudents;

            if (displayList.isEmpty) {
              return const Center(child: Text('No hay estudiantes registrados. Usa el botón "+" para añadir uno.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final student = displayList[index];
                final double averageGrade = _calculateAverage(student.courses);

                return Dismissible(
                  key: Key(student.id), 
                  direction: DismissDirection.endToStart, 
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirmar Eliminación"),
                          content: Text("¿Estás seguro de que quieres eliminar a ${student.displayName} permanentemente?"),
                          actions: <Widget>[
                            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("NO")),
                            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("SÍ, ELIMINAR", style: TextStyle(color: Colors.red))),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    _deleteAndRefresh(student.id, student.name);
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 6,
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
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(student.photoUrl), 
                        backgroundColor: primaryColor.withOpacity(0.1),
                        child: student.photoUrl.isEmpty 
                            ? Icon(Icons.person, color: primaryColor) 
                            : null,
                      ),
                      title: Text(
                        student.displayName, // Nombre Apellido, Nombre
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        '${student.career} | Correo: ${student.email}', // Muestra la carrera
                        style: GoogleFonts.inter()
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: primaryColor),
                            onPressed: () => _navigateToEditPage(student),
                            tooltip: 'Editar alumno',
                          ),
                          Chip(
                            label: Text(
                              averageGrade.toStringAsFixed(1),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: getGradeColor(averageGrade),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          
          return const Center(child: Text('Esperando datos...'));
        },
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddStudentPage(),
            ),
          );
          
          if (result == true) {
            _refreshStudents();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alumno añadido exitosamente!')),
              );
            }
          }
        },
        child: const Icon(Icons.person_add),
        tooltip: 'Añadir nuevo alumno',
      ),
    );
  }
}

// ----------------------------------------------------------------------
// --- PÁGINA: AÑADIR/EDITAR ALUMNO (AddStudentPage) ---
// ----------------------------------------------------------------------

class AddStudentPage extends StatefulWidget {
  final Student? studentToEdit; 

  const AddStudentPage({super.key, this.studentToEdit});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _photoController = TextEditingController(); 
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.studentToEdit != null) {
      _nameController.text = widget.studentToEdit!.name;
      _emailController.text = widget.studentToEdit!.email;
      _photoController.text = widget.studentToEdit!.photoUrl; 
    } else {
      // Valor por defecto en modo Añadir
      _photoController.text = 'https://i.pravatar.cc/150?u=${UniqueKey().toString()}';
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _photoController.dispose();
    super.dispose();
  }


  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final isEditing = widget.studentToEdit != null;
      final successMessage = isEditing ? 'actualizado' : 'guardado';
      
      final actionFunction = isEditing
          ? () => updateStudent(
              widget.studentToEdit!.id,
              _nameController.text,
              _emailController.text,
              _photoController.text, // Pasamos la URL de la foto
            )
          // La función postStudent solo acepta nombre y correo según su definición
          : () => postStudent(_nameController.text, _emailController.text); 

      try {
        await actionFunction();
        
        if (mounted) {
          Navigator.pop(context, true); 
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al ${successMessage}: ${e.toString()}')),
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
    final isEditing = widget.studentToEdit != null;
    final titleText = isEditing ? 'Editar Alumno' : 'Añadir Nuevo Alumno';
    final buttonText = isEditing ? 'Actualizar Datos' : 'Guardar Alumno';
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // *** VISTA PREVIA DEL AVATAR ***
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_photoController.text),
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: _photoController.text.isEmpty
                        ? Icon(Icons.person, size: 50, color: primaryColor)
                        : null,
                  ),
                ),
              ),
              
              // *** CAMPO URL DE LA FOTO ***
              TextFormField(
                controller: _photoController,
                onChanged: (value) {
                  setState(() {}); 
                },
                decoration: const InputDecoration(
                  labelText: 'URL de la Foto de Perfil',
                  icon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                  hintText: 'Deje vacío para usar el avatar por defecto',
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.isNotEmpty && !value.startsWith('http')) {
                    return 'Debe ser una URL válida (ej: http://...)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // *** CAMPO NOMBRE ***
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo (Apellido Apellido Nombre)',
                  icon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                  hintText: 'Ej: Miramontes De Jesus Juan Pablo',
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Introduce el nombre.' : null,
              ),
              const SizedBox(height: 20),
              
              // *** CAMPO CORREO ***
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  icon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                  hintText: 'Ej: juan.perez@email.com',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduce el correo electrónico.';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Introduce un correo válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              
              // *** BOTÓN GUARDAR/ACTUALIZAR ***
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitForm,
                icon: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Icon(isEditing ? Icons.update : Icons.save),
                label: Text(
                  _isLoading ? (isEditing ? 'Actualizando...' : 'Guardando...') : buttonText,
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// --- PÁGINA DE DETALLE DE MATERIAS (StudentCoursesPage) ---
// ----------------------------------------------------------------------

class StudentCoursesPage extends StatelessWidget {
  final Student student;

  const StudentCoursesPage({super.key, required this.student});

  Map<String, dynamic> _calculateProgress() {
    final int currentCourses = student.courses.length;
    // Cálculo del ratio de progreso
    final double progressRatio = currentCourses / TOTAL_COURSES; 
    final int percentage = (progressRatio * 100).round();
    
    return {
      'ratio': progressRatio.clamp(0.0, 1.0), 
      'percentage': percentage,
      'current': currentCourses,
    };
  }

  @override
  Widget build(BuildContext context) {
    final List<Course> sortedCourses = List.from(student.courses);
    sortedCourses.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    
    final progress = _calculateProgress();
    final double progressRatio = progress['ratio'];
    final int percentage = progress['percentage'];
    final int currentCourses = progress['current'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Materias de ${student.displayName}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.2),
      ),
      body: Column( 
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // VISUALIZACIÓN DEL PROGRESO DE LA CARRERA
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título de la Carrera
                Text(
                  student.career,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'Progreso de la Carrera:',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                // Barra de progreso con color naranja
                LinearProgressIndicator(
                  value: progressRatio,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                  backgroundColor: Colors.grey.shade300,
                  color: Colors.deepOrange, // *** COLOR NARANJA ***
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$percentage% Completado',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: primaryColor),
                    ),
                    Text(
                      'Materias: $currentCourses / $TOTAL_COURSES',
                      style: GoogleFonts.inter(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded( 
            child: sortedCourses.isEmpty
              ? Center(child: Text('No hay materias asignadas a ${student.displayName}.'))
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
                  itemCount: sortedCourses.length,
                  itemBuilder: (context, index) {
                    final course = sortedCourses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: Icon(Icons.menu_book, color: primaryColor),
                        ),
                        title: Text(
                          course.name,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        subtitle: Text(
                          'Profesor: ${course.teacher}', 
                          style: GoogleFonts.inter()
                        ),
                        trailing: Chip(
                            label: Text(
                              course.grade.toStringAsFixed(0),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            backgroundColor: getGradeColor(course.grade),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------------------
// --- CÓDIGO INICIAL (Necesario para ejecutar la aplicación) ---
// ----------------------------------------------------------------------

void main() {
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión Escolar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StudentsPage(),
    );
  }
}