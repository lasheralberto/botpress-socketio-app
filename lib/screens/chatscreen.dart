import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:helloworld/models/colors.dart';
import 'package:helloworld/models/constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:intl/intl.dart';
import 'package:helloworld/main.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? selectedConversationId;
  List<Map<String, dynamic>> selectedMessages = [];
  late WebSocketChannel channel;
  List<dynamic> allConversations = [];

  final StreamController<List<dynamic>> _messagesStreamController =
      StreamController<List<dynamic>>.broadcast();

  @override
  void initState() {
    _connectWebSocket();
    super.initState();
  }

  void _connectWebSocket() {
    var botid = constants.botIdHeader;
    channel = WebSocketChannel.connect(Uri.parse(Constants.RenderUrlWs));

    channel.stream.listen((message) {
      var data = json.decode(message);
      if (data['event'] == 'conversation_data') {
        setState(() {
          allConversations = data['data'];
        });
        _messagesStreamController.sink.add(allConversations);
      }
    }, onError: (error) {
      print('Error de WebSocket: $error');
    }, onDone: () {
      print('WebSocket cerrado');
      _connectWebSocket();
    });

    if (botid.isNotEmpty) {
      _sendInitialMessage(botid);
    }
  }

  void _sendInitialMessage(String botid) {
    Map<String, String> messageMap = {
      "bearer": Constants.authorizationHeader,
      "botid": botid,
      "workspace_id": Constants.workspaceIdHeader,
      "integration_id": ""
    };

    String jsonString = jsonEncode(messageMap);
    channel.sink.add(jsonString);
  }

  @override
  void dispose() {
    _messagesStreamController.close();
    channel.sink.close(status.goingAway);
    super.dispose();
  }

  void selectConversation(
      String conversationId, List<Map<String, dynamic>> conversations) {
    setState(() {
      selectedConversationId = conversationId;
      selectedMessages = List<Map<String, dynamic>>.from(
        conversations.firstWhere((conversation) =>
            conversation['conversation'] == conversationId)['messages'],
      );

      // Ordenar mensajes cronológicamente
      selectedMessages.sort((a, b) {
        DateTime dateA = DateTime.parse(a['createdAt']);
        DateTime dateB = DateTime.parse(b['createdAt']);
        return dateA.compareTo(dateB);
      });
    });
  }

  String formatDate(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              margin: EdgeInsets.all(16),
              child: StreamBuilder<List<dynamic>>(
                stream: _messagesStreamController.stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text('No hay conversaciones disponibles'));
                  }

                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data![index]['conversation']),
                        subtitle: Text(
                            'Integración: ${snapshot.data![index]['integration_name']}'),
                        onTap: () => selectConversation(
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
            ),
          ),
          
          Expanded(
            flex: 3,
            child: Card(
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
                              bool isIncoming =
                                  message['direction'] == 'incoming';

                              return Align(
                                alignment: isIncoming
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 5),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isIncoming
                                          ? Colors.grey[300]
                                          : AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message['payload']['text'],
                                          style: TextStyle(
                                            color: isIncoming
                                                ? Colors.black
                                                : Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          formatDate(message['createdAt']),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(child: Text('Selecciona una conversación')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
