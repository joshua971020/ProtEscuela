import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardAlumnoPage extends StatelessWidget {
  final String nombre;

  const DashboardAlumnoPage({super.key, required this.nombre});

  @override
  Widget build(BuildContext context) {
    final Color azul = const Color(0xFF004AAD);
    final Color fondo = const Color(0xFFF4F6FB);
    final Color amarillo = const Color(0xFFFFC107);
    final Color textoOscuro = const Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: azul,
        title: Text(
          'Portal del Alumno',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
          ),
          const SizedBox(width: 8)
        ],
      ),

      // CUERPO
      body: Stack(
        children: [
          // Fondo decorativo
          Positioned(
            top: -50,
            right: -70,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: azul.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: amarillo.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Contenido
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Saludo con nombre
                Text(
                  '👋 Hola, $nombre',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: azul,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bienvenido a tu panel académico. Aquí puedes consultar tu información escolar.',
                  style: GoogleFonts.inter(fontSize: 15, color: Colors.grey[700]),
                ),
                const SizedBox(height: 25),

                // Tarjeta principal (promedio general)
                _buildResumenCard(azul, amarillo),

                const SizedBox(height: 30),

                // Accesos rápidos con tarjetas animadas
                Text(
                  'Accesos rápidos',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textoOscuro,
                  ),
                ),
                const SizedBox(height: 15),

                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildMenuCard(Icons.book_rounded, 'Mis Materias', Colors.lightBlueAccent, () {}),
                    _buildMenuCard(Icons.calendar_today_rounded, 'Calendario', Colors.purpleAccent, () {}),
                    _buildMenuCard(Icons.grade_rounded, 'Calificaciones', Colors.orangeAccent, () {}),
                    _buildMenuCard(Icons.account_circle_rounded, 'Perfil', Colors.greenAccent, () {}),
                  ],
                ),

                const SizedBox(height: 40),

                // Avisos o noticias
                Text(
                  'Avisos recientes',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textoOscuro,
                  ),
                ),
                const SizedBox(height: 15),

                _buildAvisoCard(
                  'Entrega de proyectos finales',
                  'La entrega de proyectos finales será el 20 de octubre. Verifica tus materias en el portal.',
                  azul,
                ),
                const SizedBox(height: 12),
                _buildAvisoCard(
                  'Suspensión de clases',
                  'No habrá clases el lunes 14 de octubre por mantenimiento de las instalaciones.',
                  azul,
                ),
                const SizedBox(height: 12),
                _buildAvisoCard(
                  'Evaluaciones parciales',
                  'Las evaluaciones parciales inician el 22 de octubre. Consulta tus horarios en el calendario.',
                  azul,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- COMPONENTES UI ----------

  Widget _buildResumenCard(Color azul, Color amarillo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [azul, azul.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: azul.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.school_rounded, color: amarillo, size: 50),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Promedio general',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '9.4',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 34,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 20),
        ],
      ),
    );
  }

  Widget _buildMenuCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvisoCard(String titulo, String desc, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
