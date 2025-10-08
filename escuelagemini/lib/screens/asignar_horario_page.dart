import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AsignarHorarioPage extends StatefulWidget {
  final int idAsignacion;

  const AsignarHorarioPage({super.key, required this.idAsignacion});

  @override
  State<AsignarHorarioPage> createState() => _AsignarHorarioPageState();
}

class _AsignarHorarioPageState extends State<AsignarHorarioPage> {
  final List<String> diasSemana = [
    "Lunes",
    "Martes",
    "Miércoles",
    "Jueves",
    "Viernes",
    "Sábado",
  ];

  final List<Map<String, String>> bloquesHorario = [
    {"inicio": "07:00", "fin": "08:00"},
    {"inicio": "08:00", "fin": "09:00"},
    {"inicio": "09:00", "fin": "10:00"},
    {"inicio": "10:00", "fin": "11:00"},
    {"inicio": "11:00", "fin": "12:00"},
    {"inicio": "12:00", "fin": "13:00"},
    {"inicio": "13:00", "fin": "14:00"},
    {"inicio": "14:00", "fin": "15:00"},
    {"inicio": "15:00", "fin": "16:00"},
  ];

  String? diaSeleccionado;
  Map<String, String>? bloqueSeleccionado;
  final TextEditingController salonController = TextEditingController();
  bool enviando = false;

  Future<void> _guardarHorario() async {
    if (diaSeleccionado == null || bloqueSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Selecciona un día y un bloque horario."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final body = {
      "id_asignacion": widget.idAsignacion,
      "dia_semana": diaSeleccionado,
      "hora_inicio": bloqueSeleccionado!["inicio"],
      "hora_fin": bloqueSeleccionado!["fin"],
      "salon": salonController.text.trim(),
    };

    setState(() => enviando = true);

    try {
      final response = await http.post(
        Uri.parse('https://escolar-production-c025.up.railway.app/horarios'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data["ok"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Horario asignado (${diaSeleccionado!})"),
            backgroundColor: Colors.green,
          ),
        );

        // 🔹 Limpiar para permitir asignar otro día
        setState(() {
          diaSeleccionado = null;
          bloqueSeleccionado = null;
          salonController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ ${data["error"] ?? "Error desconocido"}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error de conexión: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Asignar Horario',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Día de la semana",
                border: OutlineInputBorder(),
              ),
              value: diaSeleccionado,
              items: diasSemana.map((dia) {
                return DropdownMenuItem(
                  value: dia,
                  child: Text(dia),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => diaSeleccionado = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Map<String, String>>(
              decoration: const InputDecoration(
                labelText: "Bloque horario",
                border: OutlineInputBorder(),
              ),
              value: bloqueSeleccionado,
              items: bloquesHorario.map((bloque) {
                final texto = "${bloque["inicio"]} - ${bloque["fin"]}";
                return DropdownMenuItem(
                  value: bloque,
                  child: Text(texto),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => bloqueSeleccionado = value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: salonController,
              decoration: const InputDecoration(
                labelText: "Salón (opcional)",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        // 🔹 Botón para cerrar el diálogo
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Finalizar"),
        ),
        ElevatedButton.icon(
          onPressed: enviando ? null : _guardarHorario,
          icon: const Icon(Icons.add),
          label: const Text("Agregar"),
        ),
      ],
    );
  }
}
