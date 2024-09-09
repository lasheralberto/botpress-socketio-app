import 'dart:async';
import 'package:flutter/material.dart';
import 'package:helloworld/data/websocket_manager.dart';
import 'package:helloworld/models/colors.dart';
import 'package:helloworld/models/constants.dart';
import 'package:helloworld/widgets/message_list.dart';
import 'package:helloworld/data/websocket_manager.dart';
import 'package:helloworld/widgets/conversations_list.dart';
import 'package:helloworld/widgets/message_list.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  String botid;
  ChatScreen({required this.botid});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? selectedConversationId;
  List<Map<String, dynamic>> selectedMessages = [];
  WebSocketManager?
      webSocketManager; // Cambiado a un nullable para evitar errores de inicialización.
  List<dynamic> allConversations = [];

  final StreamController<List<dynamic>> _messagesStreamController =
      StreamController<List<dynamic>>.broadcast();

  late Constants _constants;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _constants = Provider.of<Constants>(context, listen: false);
    _constants.addListener(_onConstantsChanged);

    // Inicializa el WebSocket por primera vez.
    _initializeWebSocket();
  }

  @override
  void dispose() {
    _messagesStreamController.close();
    webSocketManager
        ?.disconnect(); // Asegúrate de desconectar solo si no es nulo.
    _constants.removeListener(_onConstantsChanged);
    super.dispose();
  }

  void _onConstantsChanged() {
    if (mounted) {
      setState(() {
        widget.botid = _constants.botIdHeader;
        _initializeWebSocket(); // Reconecta el WebSocket cuando cambie el botid.
      });
    }
  }

  void _initializeWebSocket() {
    if (webSocketManager != null) {
      webSocketManager!
          .disconnect(); // Desconectar si ya existe un WebSocketManager.
    }

    // Crear un nuevo WebSocketManager solo si `botid` no es nulo o vacío.
    if (widget.botid.isNotEmpty) {
      webSocketManager = WebSocketManager(
        botid: widget.botid,
        onNewData: (data) {
          setState(() {
            allConversations = [];
            allConversations = data;
            selectedMessages.clear();
          });
          _messagesStreamController.sink.add(allConversations);
        },
        onError: (error) => print('Error de WebSocket: $error'),
        onDone: _reconnectWebSocket,
      );

      webSocketManager!.connect(widget.botid);
    }
  }

  void _reconnectWebSocket() {
    print('WebSocket cerrado');
    if (webSocketManager != null) {
      webSocketManager!.connect(
          widget.botid); // Reconectar solo si el WebSocketManager no es nulo.
    }
  }

  void selectConversation(
      String conversationId, List<Map<String, dynamic>> conversations) {
    setState(() {
      selectedConversationId = conversationId;
      selectedMessages = List<Map<String, dynamic>>.from(
        conversations.firstWhere((conversation) =>
            conversation['conversation'] == conversationId)['messages'],
      );

      // Ordenar mensajes cronológicamente.
      selectedMessages.sort((a, b) {
        DateTime dateA = DateTime.parse(a['createdAt']);
        DateTime dateB = DateTime.parse(b['createdAt']);
        return dateA.compareTo(dateB);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: ConversationList(
              messagesStream: _messagesStreamController.stream,
              selectedConversationId: selectedConversationId,
              onConversationSelected: selectConversation,
            ),
          ),
          Expanded(
            flex: 3,
            child: MessageList(selectedMessages: selectedMessages),
          ),
        ],
      ),
    );
  }
}
