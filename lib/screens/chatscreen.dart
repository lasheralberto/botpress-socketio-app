import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:helloworld/data/functions.dart';
import 'package:helloworld/models/colors.dart';
import 'package:helloworld/models/constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ChatScreen extends StatefulWidget {
  final String botid;
  final dynamic conversations;

  ChatScreen({required this.conversations, required this.botid});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? selectedConversationId;
  List<Map<String, dynamic>> selectedMessages = [];
  late WebSocketChannel channel; // WebSocketChannel para la conexión WebSocket
  List<dynamic> allConversations = [];

  // Crear un StreamController para gestionar los mensajes
  final StreamController<List<dynamic>> _messagesStreamController =
      StreamController<List<dynamic>>.broadcast();

  @override
  void initState() {
    _connectWebSocket(); // Conectar al WebSocket
    super.initState();
  }

  void _connectWebSocket() {
    // Crear un canal WebSocket
    channel = WebSocketChannel.connect(
        Uri.parse(Constants.RenderUrlWs)); // Reemplaza con tu URL de WebSocket

    // Escuchar eventos de mensaje
    channel.stream.listen((message) {
      print('Mensaje recibido: $message');
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
      // Intentar reconectar
      _connectWebSocket();
    });

    if (widget.botid.isNotEmpty) {
      _sendInitialMessage(widget.botid);
    }
  }

  // Función para enviar el mensaje inicial al WebSocket
  void _sendInitialMessage(String botid) {
    debugPrint("Sending initial message..");

    // Construir el mapa de datos
    Map<String, String> messageMap = {
      "bearer": "Bearer bp_pat_k0urSciyORrnJO3cRXPrsMdYjPL8eiTQXX4m",
      "botid": botid,
      "workspace_id": "wkspace_01HV70DJPN2A123AD5SJ7BEG2B",
      "integration_id": ""
    };

    // Convertir el mapa a JSON
    String jsonString = jsonEncode(messageMap);
    // Enviar el mensaje al servidor
    channel.sink.add(jsonString);
  }

  @override
  void dispose() {
    _messagesStreamController.close(); // Cerrar el StreamController
    channel.sink.close(
        status.goingAway); // Cerrar la conexión WebSocket de manera adecuada
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
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
              width: 250,
              child: Card(
                color: Colors.white,
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                child: StreamBuilder<List<dynamic>>(
                  stream:
                      _messagesStreamController.stream, // Escuchar el stream
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: Text('No hay conversaciones disponibles'));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(snapshot.data![index]['conversation']),
                          subtitle: Text(
                              'Integración: ${snapshot.data![index]['integration_name']}'),
                          onTap: () => selectConversation(
                              snapshot.data![index]['conversation'],
                              List<Map<String, dynamic>>.from(snapshot.data!)),
                          selected: selectedConversationId ==
                              snapshot.data![index]['conversation'],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 0),
            Expanded(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 16),
                    Expanded(
                      child: selectedMessages.isNotEmpty
                          ? Card(
                              elevation: 10.0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
                              child: ListView.builder(
                                itemCount: selectedMessages.length,
                                itemBuilder: (context, index) {
                                  var message = selectedMessages[index];
                                  bool isIncoming =
                                      message['direction'] == 'incoming';

                                  return Align(
                                    alignment: isIncoming
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 10),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isIncoming
                                            ? Colors.grey[300]
                                            : AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(15),
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
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Text('Selecciona una conversación'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
