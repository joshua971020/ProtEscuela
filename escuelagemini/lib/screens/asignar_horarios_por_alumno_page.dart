import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'asignar_horario_page.dart';

class AsignarHorariosPorAlumnoPage extends StatefulWidget {
  final int idAlumno;

  const AsignarHorariosPorAlumnoPage({super.key, required this.idAlumno});

  @override
  State<AsignarHorariosPorAlumnoPage> createState() =>
      _AsignarHorariosPorAlumnoPageState();
}

class _AsignarHorariosPorAlumnoPageState
    extends State<AsignarHorariosPorAlumnoPage> {
  List<dynamic> materiasAsignadas = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarMateriasAsignadas();
  }

  Future<void> _cargarMateriasAsignadas() async {
    try {
      final res = await http.get(Uri.parse(
          'https://escolar-production-c025.up.railway.app/materias/asignaciones/${widget.idAlumno}'));

      if (res.statusCode == 200) {
        setState(() {
          materiasAsignadas = json.decode(res.body);
          cargando = false;
        });
      } else {
        throw Exception("Error al obtener materias asignadas");
      }
    } catch (e) {
      setState(() => cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al cargar materias: $e")),
      );
    }
  }

void _abrirAsignarHorario(int idAsignacion, String materia) async {
  final result = await showDialog(
    context: context,
    builder: (context) => AsignarHorarioPage(idAsignacion: idAsignacion),
  );

  if (result == true) {
    // 🔹 Refresca la lista al cerrar el diálogo con "Finalizar"
    _cargarMateriasAsignadas();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ Horarios actualizados para $materia"),
        backgroundColor: Colors.green,
      ),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Asignar Horarios"),
        backgroundColor: Colors.blueAccent,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : materiasAsignadas.isEmpty
              ? const Center(
                  child: Text("🎓 El alumno no tiene materias asignadas."),
                )
              : ListView.builder(
                  itemCount: materiasAsignadas.length,
                  itemBuilder: (context, index) {
                    final m = materiasAsignadas[index];
                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        title: Text(m["materia_nombre"] ?? "Materia"),
                        subtitle: Text("Estatus: ${m["estatus"] ?? "Activo"}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.schedule),
                          onPressed: () => _abrirAsignarHorario(
                              m["id_asignacion"], m["materia_nombre"]),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
