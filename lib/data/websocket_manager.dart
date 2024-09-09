import 'dart:convert';
import 'package:helloworld/main.dart';
import 'package:helloworld/models/constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketManager {
  late WebSocketChannel _channel;
  final Function(List<dynamic>) onNewData;
  final Function(dynamic) onError;
  final Function() onDone;
  String botid;

  WebSocketManager({
    required this.botid,
    required this.onNewData,
    required this.onError,
    required this.onDone,
  });

  void connect(_botid) {
     
    _channel = WebSocketChannel.connect(Uri.parse(Constants.RenderUrlWs));
    _sendInitialMessage(_botid);

    _channel.stream.listen((message) {
      var data = json.decode(message);
      if (data['event'] == 'conversation_data') {
        onNewData(data['data']);
      }
    }, onError: onError, onDone: onDone);
  }

  void _sendInitialMessage(String _botid) {
    Map<String, String> messageMap = {
      "bearer": Constants.authorizationHeader,
      "botid": _botid,
      "workspace_id": Constants.workspaceIdHeader,
      "integration_id": ""
    };

    String jsonString = jsonEncode(messageMap);
    _channel.sink.add(jsonString);
  }

  void disconnect() {
    _channel.sink.close(status.goingAway);
  }
}
