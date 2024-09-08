import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:helloworld/models/constants.dart';
import 'package:helloworld/data/functions.dart';
import 'package:helloworld/models/colors.dart';
import 'package:helloworld/fileviewerclasses.dart';
import 'package:helloworld/widgets/addkbutton.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class FileListView extends StatefulWidget {
  final Function(int index)? onRemoveAttached;

  FileListView({Key? key, this.onRemoveAttached}) : super(key: key);

  @override
  _FileListViewState createState() => _FileListViewState();
}

class _FileListViewState extends State<FileListView> {
  late StreamController<List<dynamic>> _streamController;
  bool isLoading = true;
  late Constants _constants;
  List<dynamic> _files = [];
  late FileViewerFormatter _fileFormatter;
  List<PlatformFile> _attachedFiles = [];

  @override
  void initState() {
    super.initState();
    _fileFormatter = FileViewerFormatter();
    _streamController = StreamController<List<dynamic>>.broadcast();
    _startFetchingFiles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _constants = Provider.of<Constants>(context);
    _constants.addListener(_onConstantsChanged);
  }

  @override
  void dispose() {
    _streamController.close();
    _constants.removeListener(_onConstantsChanged);
    super.dispose();
  }

  void _onConstantsChanged() {
    if (mounted) {
      _startFetchingFiles();
    }
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
      allowMultiple: false,
    );

    if (result != null) {
      if (mounted) {
        setState(() {
          _attachedFiles = result.files;
        });
      }

      await uploadFile(context, result);

      PlatformFile platformFile = result.files.single;
      Map<String, dynamic> fileMap = {
        'key': platformFile.name,
        'size': platformFile.size,
        'createdAt': DateTime.now().toIso8601String(),
        'id': platformFile.identifier ?? '',
      };

      await addFileToStream(fileMap);
    }
  }

  void _startFetchingFiles() {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    fetchFiles().listen(
      (files) {
        if (mounted) {
          setState(() {
            _files = files;
            _streamController.add(files);
            isLoading = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          _streamController.addError(error);
          setState(() {
            isLoading = false;
          });
        }
      },
    );
  }

  Future<void> addFileToStream(Map<String, dynamic> file) async {
    if (mounted) {
      setState(() {
        _files.add(file);
        _streamController.add(_files);
      });
      debugPrint(_files.toString());
    }
  }

  Stream<List<dynamic>> fetchFiles() async* {
    var url = Uri.parse(Constants.baseUrlFiles);
    var headers = {
      "accept": "application/json",
      "authorization": Constants.authorizationHeader,
      "x-bot-id": _constants.botIdHeader,
      "x-workspace-id": Constants.workspaceIdHeader,
    };

    try {
      var response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List<dynamic> files = jsonResponse['files'];
        yield files;
      } else {
        yield* Stream.error(
            'Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      yield* Stream.error('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: MediaQuery.of(context).size.width / 3,
        child: Stack(
          children: [
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 20,
              margin: EdgeInsets.all(16),
              child: StreamBuilder<List<dynamic>>(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return Center(child: Text('No has subido ningún archivo'));
                  } else if (snapshot.connectionState ==
                          ConnectionState.waiting &&
                      isLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No se encontraron archivos'));
                  } else {
                    var files = snapshot.data!;
                    return ListView.builder(
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        var file = files[index];
                        return Dismissible(
                          key: Key(file['key']),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20.0),
                            child: Icon(Icons.delete,
                                color: Colors.white, size: 36),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) async {
                            // Asegúrate de que el archivo sigue presente en la lista antes de eliminarlo
                            if (files.contains(file)) {
                              var isDeleted =
                                  await deleteFile(context, file['id']);
                              if (isDeleted == true) {
                                if (mounted) {
                                  setState(() {
                                    _files.removeAt(index);
                                    _streamController.add(_files);
                                  });
                                }
                                widget.onRemoveAttached?.call(index);
                              }
                            }
                          },
                          child: ListTile(
                            title: Text(file['key'] ?? 'Sin nombre'),
                            subtitle: Text(
                                '${_fileFormatter.formatFileSize(file['size'] ?? 0)}\n'
                                'Subido: ${_fileFormatter.formatDate(file['createdAt'] ?? '')}'),
                            leading: Icon(Icons.file_present,
                                color: _fileFormatter.returnColorFile(file)),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            AddKnowledgeBaseFileButton(onPressed: _pickFiles)
          ],
        ),
      ),
    );
  }
}
