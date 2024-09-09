import 'package:flutter/material.dart';

class ConversationList extends StatelessWidget {
  final Stream<List<dynamic>> messagesStream;
  final String? selectedConversationId;
  final Function(String, List<Map<String, dynamic>>) onConversationSelected;

  const ConversationList({
    Key? key,
    required this.messagesStream,
    required this.selectedConversationId,
    required this.onConversationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      margin: EdgeInsets.all(16),
      child: StreamBuilder<List<dynamic>>(
        stream: messagesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay conversaciones disponibles'));
          }

          return ListView.separated(
            separatorBuilder: (context, index) => Divider(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data![index]['conversation']),
                subtitle: Text(
                    'Integración: ${snapshot.data![index]['integration_name']}'),
                onTap: () => onConversationSelected(
                  snapshot.data![index]['conversation'],
                  List<Map<String, dynamic>>.from(snapshot.data!),
                ),
                selected: selectedConversationId ==
                    snapshot.data![index]['conversation'],
              );
            },
          );
        },
      ),
    );
  }
}
