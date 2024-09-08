import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; // Asegúrate de tener este paquete en pubspec.yaml

class LoadingListPage extends StatefulWidget {
  const LoadingListPage({super.key});

  @override
  State<LoadingListPage> createState() => _LoadingListPageState();
}

class _LoadingListPageState extends State<LoadingListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Centra la columna principal en la pantalla
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          enabled: true,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                // Simulación de conversación con más mensajes y menor espaciado
                ChatBubblePlaceholder(alignment: Alignment.centerLeft),
                SizedBox(height: 6.0),
                ChatBubblePlaceholder(alignment: Alignment.centerRight),
                SizedBox(height: 6.0),
                ChatBubblePlaceholder(alignment: Alignment.centerLeft),
                SizedBox(height: 6.0),
                ChatBubblePlaceholder(alignment: Alignment.centerRight),
                SizedBox(height: 6.0),
                ChatBubblePlaceholder(alignment: Alignment.centerLeft),
                SizedBox(height: 6.0),
                ChatBubblePlaceholder(alignment: Alignment.centerRight),
                SizedBox(height: 6.0),
                ChatBubblePlaceholder(alignment: Alignment.centerLeft),
                SizedBox(height: 6.0),
                ChatBubblePlaceholder(alignment: Alignment.centerRight),
                SizedBox(height: 6.0),
                ChatBubblePlaceholder(alignment: Alignment.centerLeft),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Nueva clase para simular burbujas de chat
class ChatBubblePlaceholder extends StatelessWidget {
  final Alignment alignment;

  const ChatBubblePlaceholder({super.key, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(10.0),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 12.0,
              width: double.infinity,
              color: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(vertical: 2.0),
            ),
            Container(
              height: 12.0,
              width: 150.0,
              color: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(vertical: 2.0),
            ),
          ],
        ),
      ),
    );
  }
}
