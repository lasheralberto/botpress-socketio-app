import 'package:flutter/material.dart';
import 'package:helloworld/constants.dart';
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
