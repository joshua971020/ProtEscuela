import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'asignar_horarios_por_alumno_page.dart'; // 👈 Importamos la nueva pantalla

class AsignarMateriasPage extends StatefulWidget {
  const AsignarMateriasPage({super.key});

  @override
  State<AsignarMateriasPage> createState() => _AsignarMateriasPageState();
}

class _AsignarMateriasPageState extends State<AsignarMateriasPage> {
  List<dynamic> alumnos = [];
  List<dynamic> materias = [];
  String? alumnoSeleccionado;
  List<String> materiasSeleccionadas = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarAlumnos();
  }

  Future<void> _cargarAlumnos() async {
    try {
      final res = await http.get(
        Uri.parse('https://escolar-production-c025.up.railway.app/alumnos'),
      );
      if (res.statusCode == 200) {
        setState(() {
          alumnos = json.decode(res.body);
          cargando = false;
        });
      } else {
        throw Exception("Error al cargar alumnos");
      }
    } catch (e) {
      setState(() => cargando = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

  Future<void> _cargarMateriasDeAlumno(String alumnoId) async {
    setState(() {
      cargando = true;
      materias = [];
      materiasSeleccionadas.clear();
    });

    try {
      final res = await http.get(Uri.parse(
          'https://escolar-production-c025.up.railway.app/materias?alumno=$alumnoId'));
      if (res.statusCode == 200) {
        setState(() {
          materias = json.decode(res.body);
          cargando = false;
        });
      } else {
        throw Exception("Error al cargar materias");
      }
    } catch (e) {
      setState(() => cargando = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    }
  }

  Future<void> _guardarAsignacion() async {
    if (alumnoSeleccionado == null || materiasSeleccionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("⚠️ Selecciona un alumno y al menos una materia."),
        backgroundColor: Colors.orange,
      ));
      return;
    }

    final body = {
      "alumno": int.parse(alumnoSeleccionado!),
      "materias":
          materiasSeleccionadas.map((id) => int.parse(id)).toList(),
    };

    try {
      final res = await http.post(
        Uri.parse(
            'https://escolar-production-c025.up.railway.app/materias/asignar'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      final data = json.decode(res.body);

      if (res.statusCode == 200 && data["ok"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["mensaje"]),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ Ahora abrimos la pantalla de asignar horarios
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AsignarHorariosPorAlumnoPage(
              idAlumno: int.parse(alumnoSeleccionado!),
            ),
          ),
        );
      } else {
        throw Exception(data["error"] ?? "Error desconocido");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error al asignar materias: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Asignar Materias a Alumnos',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: cargando
          ? const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Selecciona un alumno",
                      border: OutlineInputBorder(),
                    ),
                    value: alumnoSeleccionado,
                    items: alumnos.map<DropdownMenuItem<String>>((a) {
                      return DropdownMenuItem<String>(
                        value: a['id'].toString(),
                        child: Text(a['nombre']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => alumnoSeleccionado = value);
                      if (value != null) _cargarMateriasDeAlumno(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Selecciona las materias:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.maxFinite,
                    height: 250,
                    child: materias.isEmpty
                        ? const Center(
                            child: Text(
                              "🎓 No hay materias disponibles para este alumno.",
                            ),
                          )
                        : ListView.builder(
                            itemCount: materias.length,
                            itemBuilder: (context, index) {
                              final materia = materias[index];
                              final id = materia['id'].toString();
                              return CheckboxListTile(
                                title: Text(materia['nombre']),
                                value: materiasSeleccionadas.contains(id),
                                onChanged: (bool? selected) {
                                  setState(() {
                                    if (selected == true) {
                                      materiasSeleccionadas.add(id);
                                    } else {
                                      materiasSeleccionadas.remove(id);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton.icon(
          onPressed: _guardarAsignacion,
          icon: const Icon(Icons.save),
          label: const Text("Guardar"),
        ),
      ],
    );
  }
}
