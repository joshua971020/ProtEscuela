import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class VerHorariosPage extends StatefulWidget {
  const VerHorariosPage({super.key});

  @override
  State<VerHorariosPage> createState() => _VerHorariosPageState();
}

class _VerHorariosPageState extends State<VerHorariosPage> {
  List<dynamic> alumnos = [];
  List<dynamic> horarios = [];
  String? alumnoSeleccionado;
  bool cargando = false;
  CalendarFormat calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_MX');
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
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al cargar alumnos: $e")),
      );
    }
  }

  Future<void> _cargarHorarios(String idAlumno) async {
    setState(() {
      cargando = true;
      horarios = [];
    });

    try {
      final res = await http.get(Uri.parse(
          'https://escolar-production-c025.up.railway.app/horarios/alumno/$idAlumno'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          horarios = data["horarios"] ?? [];
        });
      } else {
        throw Exception("Error al obtener horarios");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error al cargar horarios: $e")),
      );
    } finally {
      setState(() => cargando = false);
    }
  }

  // 🔹 Genera un color aleatorio pero fijo por materia
  final Map<String, Color> _coloresMaterias = {};
  Color _obtenerColor(String materia) {
    if (_coloresMaterias.containsKey(materia)) {
      return _coloresMaterias[materia]!;
    } else {
      final color = Colors.primaries[
          materia.hashCode % Colors.primaries.length].shade400;
      _coloresMaterias[materia] = color;
      return color;
    }
  }

  // 🔹 Agrupar horarios por día
  Map<String, List<Map<String, dynamic>>> _agruparPorDia() {
    final Map<String, List<Map<String, dynamic>>> agrupado = {};
    for (var h in horarios) {
      final dia = h["dia_semana"];
      if (!agrupado.containsKey(dia)) {
        agrupado[dia] = [];
      }
      agrupado[dia]!.add(h);
    }
    return agrupado;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, dynamic>>> horariosPorDia =
        _agruparPorDia();

    return Scaffold(
      appBar: AppBar(
        title: const Text("📅 Calendarios de Alumnos"),
        backgroundColor: Colors.indigo,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Selecciona un alumno",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.people),
              ),
              value: alumnoSeleccionado,
              items: alumnos.map<DropdownMenuItem<String>>((a) {
                return DropdownMenuItem<String>(
                  value: a["id"].toString(),
                  child: Text(a["nombre"]),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => alumnoSeleccionado = value);
                if (value != null) _cargarHorarios(value);
              },
            ),
            const SizedBox(height: 20),

            Expanded(
              child: cargando
                  ? const Center(child: CircularProgressIndicator())
                  : horarios.isEmpty
                      ? const Center(
                          child: Text(
                            "Sin horarios registrados para este alumno.",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : _buildCalendarioSemanal(horariosPorDia),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarioSemanal(
      Map<String, List<Map<String, dynamic>>> horariosPorDia) {
    final dias = [
      "Lunes",
      "Martes",
      "Miércoles",
      "Jueves",
      "Viernes",
      "Sábado"
    ];
    final horas = List.generate(10, (i) => "${7 + i}:00");

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          border: TableBorder.symmetric(
            inside: BorderSide(color: Colors.grey.shade300),
          ),
          defaultColumnWidth: const FixedColumnWidth(120),
          children: [
            // Cabecera de días
            TableRow(
              children: [
                const SizedBox(), // espacio para la columna de horas
                ...dias.map(
                  (dia) => Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    color: Colors.indigo.shade100,
                    child: Text(
                      dia,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Filas de horas
            ...horas.map(
              (hora) => TableRow(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    alignment: Alignment.center,
                    color: Colors.indigo.withOpacity(0.05),
                    child: Text(hora,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  ...dias.map(
                    (dia) {
                      final clase = horarios.firstWhere(
                        (h) =>
                            h["dia_semana"] == dia &&
                            h["hora_inicio"].substring(0, 5) == hora,
                        orElse: () => {},
                      );

                      if (clase.isEmpty) {
                        return Container(
                          height: 60,
                          color: Colors.white,
                        );
                      }

                      final color = _obtenerColor(clase["materia"]);

                      return Container(
                        height: 60,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            clase["materia"],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
