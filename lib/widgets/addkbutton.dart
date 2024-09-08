import 'package:flutter/material.dart';
import 'package:helloworld/models/colors.dart';

class AddKnowledgeBaseFileButton extends StatelessWidget {
  final VoidCallback onPressed;

  AddKnowledgeBaseFileButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,

                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16.0), // Bordes redondeados
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 24.0), // Padding interno
                elevation: 10, // Sombra
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_mode, size: 24.0),
                  SizedBox(width: 8.0),
                  Text(
                    'Añadir conocimiento',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
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
