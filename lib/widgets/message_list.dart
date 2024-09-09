import 'package:flutter/material.dart';
import 'package:helloworld/widgets/message_bubble.dart';
 

class MessageList extends StatelessWidget {
  final List<Map<String, dynamic>> selectedMessages;

  const MessageList({Key? key, required this.selectedMessages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      margin: EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: selectedMessages.isNotEmpty
                ? ListView.builder(
                    itemCount: selectedMessages.length,
                    itemBuilder: (context, index) {
                      var message = selectedMessages[index];
                      return MessageBubble(message: message);
                    },
                  )
                : Center(child: Text('Selecciona una conversación')),
          ),
        ],
      ),
    );
  }
}
