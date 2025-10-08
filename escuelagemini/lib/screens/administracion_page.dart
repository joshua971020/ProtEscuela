import 'package:flutter/material.dart';
import 'crear_materia_page.dart';
import 'asignar_materias_page.dart';
import 'ver_horarios_page.dart'; // 👈 Importa la nueva pantalla

class AdministracionPage extends StatelessWidget {
  const AdministracionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Panel de Administración',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 📚 Asignar maestros
            _buildOptionCard(
              context,
              title: 'Asignar Maestros a Materias',
              icon: Icons.school,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Abrir asignación de maestros')),
                );
              },
            ),
            const SizedBox(height: 16),

            // 👩‍🎓 Asignar materias
            _buildOptionCard(
              context,
              title: 'Asignar Materias a Alumnos',
              icon: Icons.people_alt,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const AsignarMateriasPage(),
                );
              },
            ),
            const SizedBox(height: 16),

            // 🆕 Crear materia
            _buildOptionCard(
              context,
              title: 'Crear Materia Nueva',
              icon: Icons.add_box,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CrearMateriaPage()),
                );
              },
            ),
            const SizedBox(height: 16),

            // 🗓️ Nuevo card: Calendarios alumnos
            _buildOptionCard(
              context,
              title: 'Calendarios Alumnos',
              icon: Icons.calendar_month,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VerHorariosPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 36),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
