import 'dart:async'; // Para StreamController
import 'dart:convert'; // Para decodificación JSON
import 'package:flutter/material.dart';
import 'package:helloworld/data/functions.dart';
import 'package:helloworld/models/colors.dart';
import 'package:helloworld/models/constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
  late IO.Socket socket; // Socket para conexión con el servidor
  List<dynamic> allConversations = [];

  // Crear un StreamController para gestionar los mensajes
  final StreamController<List<dynamic>> _messagesStreamController =
      StreamController<List<dynamic>>.broadcast();

  @override
  void initState() {
    _connectSocket(); // Conectar al socket
    super.initState();
  }

  void _connectSocket() async {
    socket = IO.io(
      //"http://192.168.0.14:1988",
      Constants.RenderUrlWs, // Reemplaza por tu URL de Socket.IO
       IO.OptionBuilder()
        .setTransports(['websocket']) // Fuerza el transporte a WebSocket
       // .setExtraHeaders({'CustomHead': 'myHeaderValue'}) // Envía el header personalizado
        .disableAutoConnect() // Deshabilita la autoconexión inicialmente
        .build(),
    );

    socket.connect();

    // Escuchar eventos de conexión
    socket.onConnect((_) {
      print('Conectado al socket');
      _sendInitialMessage();
    });

    // Escuchar evento 'connect_error' para manejar errores de conexión
    socket.onConnectError((data) {
      print('Error de conexión: $data');
    });

    // Escuchar evento 'connect_timeout' para manejar tiempo de espera de conexión
    socket.onConnectTimeout((data) {
      print('Tiempo de espera de conexión: $data');
    });

    // Escuchar evento 'error' para manejar errores del servidor
    socket.onError((error) {
      print('Error del socket: $error');
    });

    // Escuchar evento 'reconnect_attempt' para ver intentos de reconexión
    socket.onReconnectAttempt((attempt) {
      print('Intento de reconexión: $attempt');
    });

    // Escuchar evento 'conversation_data' del servidor
    socket.on('conversation_data', (data) {
      print('Datos de conversación recibidos: $data');
      setState(() {
        allConversations =
            data['data']; // Actualizar la lista de conversaciones
      });
      _messagesStreamController.sink
          .add(allConversations); // Añadir los mensajes al stream
    });

    // Manejar eventos de desconexión
    socket.onDisconnect((_) => print('Desconectado del socket'));
  }

  // Función para enviar el mensaje inicial al socket
  void _sendInitialMessage() {
    Map<String, String> messageMap = {
      "bearer": "Bearer bp_pat_k0urSciyORrnJO3cRXPrsMdYjPL8eiTQXX4m",
      "botid": widget.botid,
      "workspace_id": "wkspace_01HV70DJPN2A123AD5SJ7BEG2B",
    };
    socket.emit('message', json.encode(messageMap)); // Emitir un evento
  }

  @override
  void dispose() {
    _messagesStreamController.close(); // Cerrar el StreamController
    socket.dispose(); // Cerrar la conexión del socket de manera adecuada
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
