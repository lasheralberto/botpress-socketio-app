import 'package:flutter/material.dart';
import 'package:helloworld/models/colors.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isIncoming = message['direction'] == 'incoming';

    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Align(
        alignment: isIncoming ? Alignment.centerLeft : Alignment.centerRight,
        child: Card(
          elevation: 5,
          color: isIncoming ? Colors.grey[300] : AppColors.primaryColor,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message['payload']['text'],
                  style: TextStyle(
                    color: isIncoming ? Colors.black : Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  _formatDate(message['createdAt']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
  }
}
