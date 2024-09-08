import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:helloworld/data/functions.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'models/constants.dart';
import 'package:provider/provider.dart';

class FileViewerFormatter {
  String formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(1)) + ' ' + suffixes[i];
  }

  String formatDate(String isoDate) {
    final DateTime dateTime = DateTime.parse(isoDate);
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');
    return formatter.format(dateTime);
  }

  Color returnColorFile(file) {
    var key = file['key']?.toString() ?? '';
    var parts = key.split('.');
    if (parts.length < 2) {
      return Colors.grey;
    }

    var formatFile = parts[1].toLowerCase();
    switch (formatFile) {
      case 'pdf':
        return Colors.red;
      case 'docx':
      case 'doc':
        return Colors.blue;
      case 'txt':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }
}

class FileManager {
  List<dynamic> _files = [];
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>.broadcast();

  Stream<List<dynamic>> get filesStream => _streamController.stream;

  void dispose() {
    _streamController.close();
  }

  void startFetchingFiles(BuildContext context) {
    Timer.periodic(Duration(seconds: 10), (timer) {
      fetchFiles(context).then((files) {
        if (!_listEquals(_files, files)) {
          _files = files;
          _streamController.add(files);
        }
      }).catchError((error) {
        _streamController.addError(error);
      });
    });
  }

  Future<List<dynamic>> fetchFiles(BuildContext context) async {
    final constants = Provider.of<Constants>(context, listen: false);
    var url = Uri.parse(Constants.baseUrlFiles);

    var headers = {
      "accept": "application/json",
      "authorization": Constants.authorizationHeader,
      "x-bot-id": constants.botIdHeader,
      "x-workspace-id": Constants.workspaceIdHeader,
    };

    try {
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return jsonResponse['files'] ?? [];
      } else {
        throw Exception('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  bool _listEquals(List<dynamic> list1, List<dynamic> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  void refreshFiles(BuildContext context) {
    fetchFiles(context).then((files) {
      if (!_listEquals(_files, files)) {
        _files = files;
        _streamController.add(files);
      }
    }).catchError((error) {
      _streamController.addError(error);
    });
  }
}
