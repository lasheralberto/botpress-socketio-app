import 'dart:async';

import 'package:flutter/material.dart';
import 'package:helloworld/models/constants.dart';
import 'package:helloworld/main.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:mime_type/mime_type.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

 

void showCustomDialog(BuildContext context, String title, String content,
    {bool isLoading = false}) {
  showDialog(
    context: context,
    barrierDismissible: !isLoading,
    builder: (BuildContext context) {
      return AlertDialog(
        title: isLoading ? null : Text(title),
        content: isLoading
            ? Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text(content),
                ],
              )
            : Text(content),
        actions: isLoading
            ? null
            : <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
      );
    },
  );
}

Stream<List<Map<String, dynamic>>> fetchConversations(botid) async* {
  //final _constants = Provider.of<Constants>(context, listen: false);
  final url = 'https://gcloudpaikb-avdggb7tiq-nw.a.run.app/get_conversations';
  Map<String, String> headers = {'Content-Type': 'application/json'};
  debugPrint('Instancia de  botid:');
  debugPrint(constants.botIdHeader.toString());
  try {
    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode({
        "bearer": Constants.authorizationHeader,
        "botid": botid,
        "workspace_id": Constants.workspaceIdHeader,
      }),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        if (data is List) {
          // Ordena las conversaciones por fecha de más reciente a más antiguo
          for (var conversation in data) {
            conversation['messages'].sort((a, b) {
              DateTime dateA = DateTime.parse(a['createdAt']);
              DateTime dateB = DateTime.parse(b['createdAt']);
              return dateA.compareTo(dateB);
            });
          }

          yield data.cast<Map<String, dynamic>>();
        } else {
          print('Error: Formato de conversación inesperado.');
          yield [];
        }
      } catch (e) {
        print('Error decodificando JSON: $e');
        yield [];
      }
    } else {
      print('Error: ${response.reasonPhrase}');
      throw Exception('Failed to load conversations');
    }
  } catch (e) {
    print('Error fetching conversations: $e');
    yield [];
  }
}

Future<List<Map<String, String>>> getListBots(context) async {
  var botApiUrl = Constants.botUrl;
  final constants = Provider.of<Constants>(context, listen: false);

  var headers = {
    "accept": "application/json",
    "x-bot-id": constants.botIdHeader,
    "x-workspace-id": Constants.workspaceIdHeader,
    "authorization": Constants.authorizationHeader
  };
  var response = await http.get(Uri.parse(botApiUrl), headers: headers);

  if (response.statusCode == 200) {
    // Parse the JSON response
    final Map<String, dynamic> data = jsonDecode(response.body);

    // Extract the list of bots
    final List<dynamic> bots = data['bots'];

    // Convert the list of bots to a List<Map<String, String>>
    var botList = bots
        .map<Map<String, String>>((bot) => {
              "name": bot["name"] as String,
              "id": bot["id"] as String,
            })
        .toList();
    botList.add({"name": "", "id": ""}); // Optionally add an empty entry
    return botList;
  } else {
    return [];
  }
}

Future<bool> deleteFile(context, fileId) async {
  // Obtén la instancia de AppConfig desde el contexto
  final constants = Provider.of<Constants>(context, listen: false);
  var fileUrl = Constants.baseUrlFiles + '/' + fileId;
  var headers = {
    "accept": "application/json",
    "x-bot-id": constants.botIdHeader,
    "x-workspace-id": Constants.workspaceIdHeader,
    "authorization": Constants.authorizationHeader
  };

  var response1 = await http.delete(Uri.parse(fileUrl), headers: headers);

  if (response1.statusCode == 200) {
    return true;
  } else {
    showCustomDialog(context, 'Error', 'No se pudo borrar el archivo.',
        isLoading: false);
    return false;
  }
}

Future<void> uploadFile(BuildContext context, FilePickerResult result) async {
  // Primera parte: obtener la URL de carga
  var url = Uri.parse(Constants.baseUrlFiles);
  final constants = Provider.of<Constants>(context, listen: false);

  PlatformFile file = result.files.first;
  int fileSize = file.size;
  int fileSizeMax = 13000000; //20.000.000 -> 20 MB
  int fileSizeMaxConvertedMB = (fileSizeMax / 1000000).toInt();

  if (fileSize > fileSizeMax) {
    showCustomDialog(context, 'Error',
        'Tamaño máximo de archivo son $fileSizeMaxConvertedMB MB');
  } else {
    // Crear un ID basado en la fecha y hora actual
    String dateTimeId =
        'f' + DateFormat('yyyyMMddHHmmss').format(DateTime.now());
    debugPrint('El kbid es' + constants.kbId);
    var payload = {
      "key": file.name,
      "size": fileSize,
      "index": true,
      "accessPolicies": ["public_content"],
      "tags": {
        'datetime': dateTimeId,
        'source': 'knowledge-base',
        'kbId': constants.kbId
      },
    };

    var headers = {
      "accept": "application/json",
      "x-bot-id": constants.botIdHeader,
      "x-workspace-id": Constants.workspaceIdHeader,
      "content-type": "application/json",
      "authorization": Constants.authorizationHeader
    };

    try {
      var response1 =
          await http.put(url, headers: headers, body: json.encode(payload));

      if (response1.statusCode == 200) {
        var responseData = json.decode(response1.body);
        var uploadUrl = responseData['file']['uploadUrl'];

        // Segunda parte: cargar el archivo
        List<int> fileBytes = file.bytes!;

        // Extraer el hostname de la URL
        var uri = Uri.parse(uploadUrl);
        var hostname = uri.host;

        // Configurar los headers para la solicitud PUT
        var putHeaders = {
          "Content-Length": fileBytes.length.toString(),
          "Host": hostname,
        };

        // Realizar la solicitud PUT
        var response = await http.put(Uri.parse(uploadUrl),
            headers: putHeaders, body: fileBytes);

        if (response.statusCode == 200) {
          Future.delayed(Duration(seconds: 5), () {
            return CircularProgressIndicator();
          });
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Éxito'),
                content: Text('El archivo se subió correctamente.'),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        } else {
          throw Exception('Error al subir el archivo: ${response.statusCode}');
        }
      } else {
        throw Exception(
            'Error al obtener la URL de carga: ${response1.statusCode}');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error al realizar la solicitud: $e'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}

Map<String, Size> getButtonSizes(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;

  double buttonWidth = screenWidth / 30;
  double minHeight = screenWidth > 600 ? 40 : 30;
  double maxHeight = screenWidth > 600 ? 50 : 40;

  return {
    'minSize': Size(buttonWidth, minHeight),
    'maxSize': Size(buttonWidth, maxHeight),
  };
}

Stream<List<dynamic>> fetchFiles(context) async* {
  final constants = Provider.of<Constants>(context, listen: false);
  var url = Uri.parse(Constants.baseUrlFiles);

  var headers = {
    "accept": "application/json",
    "authorization": Constants.authorizationHeader,
    "x-bot-id": constants.botIdHeader,
    "x-workspace-id": Constants.workspaceIdHeader,
  };

  while (true) {
    try {
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List<dynamic> files = jsonResponse['files'];
        yield files; // Emit the list of files
      } else {
        yield* Stream.error(
            'Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      yield* Stream.error('Error: $e');
    }

    // Espera un intervalo antes de hacer otra solicitud (ajustar según necesidades)
    await Future.delayed(Duration(seconds: 10));
  }
}

bool isWebSize(threshold, context) {
  // Obtener las dimensiones de la pantalla
  final screenWidth = MediaQuery.of(context).size.width;

  // Definir el umbral de ancho para determinar si es escritorio o móvil
  const desktopScreenWidthThreshold = 800.0;

  if (screenWidth >= desktopScreenWidthThreshold) {
    return true;
  } else {
    return false;
  }
}

// class WebSocketService {
//   final WebSocketChannel _channel;
//   final _streamController =
//       StreamController<List<Map<String, dynamic>>>.broadcast();

//   WebSocketService(String url)
//       : _channel = WebSocketChannel.connect(Uri.parse(url));

//   Stream<List<Map<String, dynamic>>> get conversationsStream =>
//       _streamController.stream;

//   void fetchConversations(String botid) {
//     // Emitir evento para obtener conversaciones
//     _channel.sink.add(jsonEncode({
//       'event': 'get_conversations', // Evento que espera el servidor WebSocket
//       'data': {
//         "bearer": "Bearer bp_pat_k0urSciyORrnJO3cRXPrsMdYjPL8eiTQXX4m",
//         "botid": botid,
//         "workspace_id": "wkspace_01HV70DJPN2A123AD5SJ7BEG2B",
//       }
//     }));
//   }

//   void _handleMessage(dynamic message) {
//     final decodedMessage = jsonDecode(message);

//     if (decodedMessage['event'] == 'conversation_data') {
//       final data = decodedMessage['data'];

//       if (data is List) {
//         // Ordena las conversaciones por fecha de más reciente a más antiguo
//         for (var conversation in data) {
//           conversation['messages'].sort((a, b) {
//             DateTime dateA = DateTime.parse(a['createdAt']);
//             DateTime dateB = DateTime.parse(b['createdAt']);
//             return dateA.compareTo(dateB);
//           });
//         }

//         _streamController.add(data.cast<Map<String, dynamic>>());
//       } else {
//         print('Error: Formato de conversación inesperado.');
//         _streamController.add([]);
//       }
//     } else if (decodedMessage['event'] == 'error') {
//       print(
//           'Error desde el servidor WebSocket: ${decodedMessage['data']['message']}');
//       _streamController.add([]);
//     }
//   }

//   void listenToWebSocket() {
//     _channel.stream.listen(
//       _handleMessage,
//       onError: (error) {
//         print('Error en la conexión WebSocket: $error');
//         _streamController.add([]);
//       },
//       onDone: () {
//         print('Conexión WebSocket cerrada');
//         _streamController.close();
//       },
//     );
//   }

//   void dispose() {
//     _channel.sink.close(status.goingAway);
//     _streamController.close();
//   }
// }
