import 'package:flutter/material.dart';

// Modelo de datos simulado para no depender de la API
class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;

  Message({required this.id, required this.senderId, required this.receiverId, required this.content});
}

class MessagesPage extends StatefulWidget {
  final String currentUserId;
  const MessagesPage({super.key, required this.currentUserId});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  // Datos de mensajes simulados para visualización
  final List<Message> _simulatedMessages = [
    Message(id: 'msg1', senderId: '1', receiverId: '2', content: 'Hola Ana, ¿cómo vas con el proyecto?'),
    Message(id: 'msg2', senderId: '2', receiverId: '1', content: '¡Hola Juan! Va muy bien, gracias.'),
    Message(id: 'msg3', senderId: '3', receiverId: '1', content: 'Recordatorio: Mañana es la entrega del trabajo.'),
    Message(id: 'msg4', senderId: '4', receiverId: '1', content: 'Bienvenido al sistema escolar.'),
    Message(id: 'msg5', senderId: '1', receiverId: '4', content: '¡Gracias!'),
  ];

  @override
  Widget build(BuildContext context) {
    // Filtramos los mensajes que pertenecen al usuario actual (enviados o recibidos)
    final userMessages = _simulatedMessages
        .where((message) => message.senderId == widget.currentUserId || message.receiverId == widget.currentUserId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes'),
      ),
      body: userMessages.isEmpty
          ? const Center(child: Text('No hay mensajes.'))
          : ListView.builder(
              itemCount: userMessages.length,
              itemBuilder: (context, index) {
                final message = userMessages[index];
                return ListTile(
                  title: Text('De: ${message.senderId}'),
                  subtitle: Text(message.content),
                );
              },
            ),
    );
  }
}
