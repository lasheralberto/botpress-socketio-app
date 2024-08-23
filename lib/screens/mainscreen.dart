import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:helloworld/constants.dart';
import 'package:helloworld/screens/login.dart';
import 'package:helloworld/screens/loginweb.dart';
import 'package:intl/intl.dart';
import 'package:helloworld/colors.dart';
import 'package:helloworld/functions.dart';
import 'package:helloworld/screens/fileviewer.dart';
import 'package:helloworld/screens/botsettings.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:helloworld/firebase_options.dart';
import 'package:helloworld/firebase_functions.dart';
import 'package:helloworld/screens/botsettings.dart';
import 'package:helloworld/main.dart';

class SwitchRoute {
  static go(context, value) async {
    // Maneja la selección del menú aquí
    switch (value) {
      case 'Profile':
        // Navegar al perfil
        Navigator.pushNamed(context, '/profile');
        break;
      case 'Settings':
        // Navegar a configuración
        Navigator.pushNamed(context, '/settings');
        break;
      case 'Logout':
        // Cerrar sesión
        await FirebaseAuth.instance.signOut();
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ResponsiveLoginScreen()));
        //Navigator.pushNamed(context, '/login');
        break;
    }
  }
}

class ResponsiveLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtener las dimensiones de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;

    // Definir el umbral de ancho para determinar si es escritorio o móvil
    const desktopScreenWidthThreshold = 800.0;

    // Mostrar la pantalla de escritorio si el ancho es mayor o igual al umbral, de lo contrario la pantalla móvil
    if (screenWidth >= desktopScreenWidthThreshold) {
      return LoginAppWeb();
    } else {
      return LoginAppMobile();
    }
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Map<String, String>> _bots = [];
  String? _selectedBotId;
  String? _selectedBotName;
  String? _selectedKbid;

  static List<Widget> _widgetOptions = <Widget>[
    PDFAttachmentScreen(),
    BotSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Stream<List<Map<String, String>>> _fetchBots() async* {
    var bots = await getListBots(context);
    yield bots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PopupMenuButton<String>(
          onSelected: (value) async {
            SwitchRoute.go(context, value);
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem<String>(
                value: 'Logout',
                child: Text('Logout'),
              ),
            ];
          },
          child: FirebaseAuth.instance.currentUser == null
              ? CircleAvatar(child: Icon(Icons.person))
              : CircleAvatar(
                  child: Text(
                    FirebaseAuth.instance.currentUser!.email
                        .toString()
                        .substring(0, 1),
                  ),
                ),
        ),
        title: StreamBuilder<List<Map<String, String>>>(
          stream: _fetchBots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No bots available');
            } else {
              _bots = snapshot.data!;
              // Establece el botId y botName si no están ya establecidos.
              if (_selectedBotId == null && _selectedBotName == null) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
                  setState(() {
                    _selectedBotId = _bots[0]['id'];
                    _selectedBotName = _bots[0]['name'];
                    constants.setBotId(_selectedBotId.toString());
                  });

                  // Obtener kbid desde Firestore
                  debugPrint('fetching kb from firestore..');
                  String? kbid = await fetchKbid(_selectedBotId.toString());
                  debugPrint('fetched kb from firestore..');

                  if (kbid != null) {
                    // Actualiza el estado o realiza otras acciones necesarias con el kbid
                    setState(() {
                      _selectedKbid =
                          kbid; // Asegúrate de tener esta variable en tu estado
                      constants.setKbId(_selectedKbid.toString());
                      debugPrint(
                          'selected kbid es:' + _selectedKbid.toString());
                      debugPrint('-------------');
                    });
                  }
                });
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: _selectedBotName,
                    onChanged: (String? newValue) async {
                      if (newValue == null) return;

                      // Encuentra el bot seleccionado
                      var selectedBot = _bots.firstWhere(
                          (bot) => bot['name'] == newValue,
                          orElse: () =>
                              {} // Añade un valor predeterminado en caso de que no se encuentre el bot
                          );

                      if (selectedBot.isEmpty) {
                        debugPrint('Selected bot not found.');
                        return;
                      }

                      setState(() {
                        // Actualiza el estado con el bot seleccionado
                        _selectedBotId = selectedBot['id'];
                        _selectedBotName = selectedBot['name'];
                        constants.setBotId(_selectedBotId.toString());
                      });

                      debugPrint('Selected botid is: $_selectedBotId');
                      debugPrint('-------------');
                      debugPrint('Fetching kbid from Firestore..');

                      // Obtén el kbid desde Firestore
                      String? kbid = await fetchKbid(_selectedBotId.toString());

                      if (kbid != null) {
                        // Actualiza el estado con el kbid obtenido
                        _selectedKbid = kbid;
                        constants.setKbId(_selectedKbid.toString());

                        debugPrint(
                            'Selected kbid from dropdown is: $_selectedKbid');
                        debugPrint('-------------');
                      } else {
                        debugPrint('Kbid not found for the selected bot.');
                      }

                      debugPrint('Selected kb is: $_selectedKbid');
                    },
                    items: _bots.map<DropdownMenuItem<String>>((bot) {
                      return DropdownMenuItem<String>(
                        value: bot['name'],
                        child: Text(bot['name']!),
                      );
                    }).toList(),
                  ),
                ],
              );
            }
          },
        ),
        elevation: 0,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_file),
            label: 'Knowledge Base',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes del Bot',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.accentColor,
        onTap: _onItemTapped,
      ),
    );
  }
}

Future<List<Map<String, String>>> getListBots(BuildContext context) async {
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
    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> bots = data['bots'];
    var botList = bots
        .map<Map<String, String>>((bot) => {
              "name": bot["name"] as String,
              "id": bot["id"] as String,
            })
        .toList();
    botList.add({"name": "", "id": ""}); // Añadir opción vacía si lo necesitas
    return botList;
  } else {
    return [];
  }
}

class PDFAttachmentScreen extends StatefulWidget {
  @override
  _PDFAttachmentScreenState createState() => _PDFAttachmentScreenState();
}

class _PDFAttachmentScreenState extends State<PDFAttachmentScreen> {
  List<PlatformFile> _attachedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16),
            Expanded(child: FileListView(
              onRemoveAttached: (index) {
                _attachedFiles.removeAt(index);
              },
            )),
          ],
        ),
      ),
    );
  }
}
