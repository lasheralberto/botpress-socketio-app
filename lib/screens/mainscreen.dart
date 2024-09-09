import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:helloworld/models/constants.dart';
import 'package:helloworld/screens/chatscreen.dart';
import 'package:helloworld/screens/login.dart';
import 'package:helloworld/screens/loginweb.dart';
import 'package:helloworld/widgets/botbehavior.dart';
import 'package:intl/intl.dart';
import 'package:helloworld/models/colors.dart';
import 'package:helloworld/data/functions.dart';
import 'package:helloworld/screens/fileviewer.dart';
import 'package:helloworld/screens/botsettings.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:helloworld/models/firebase_options.dart';
import 'package:helloworld/data/firebase_functions.dart';
import 'package:helloworld/screens/botsettings.dart';
import 'package:helloworld/main.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
    // Mostrar la pantalla de escritorio si el ancho es mayor o igual al umbral, de lo contrario la pantalla móvil
    if (isWebSize(800, context)) {
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
  List<Map<String, dynamic>> _conversations = []; // Lista de conversaciones
  Widget? _bottomNavigationItems;
  bool? _isAllDataLoaded;

  @override
  void initState() {
    _isAllDataLoaded = false;
    super.initState();
    // Inicializa otras cosas si es necesario
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
          child: auth.currentUser == null
              ? CircleAvatar(child: Icon(Icons.person))
              : CircleAvatar(
                  child: Text(
                    auth.currentUser!.email.toString().substring(0, 1),
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
                  String? kbid = await fetchKbid(_selectedBotId.toString());

                  if (kbid != null) {
                    // Actualiza el estado con el kbid obtenido
                    setState(() {
                      _selectedKbid = kbid;
                      constants.setKbId(_selectedKbid.toString());
                    });
                  }

                  if (_selectedBotId!.isNotEmpty && _selectedKbid!.isNotEmpty) {
                    setState(() {
                      _isAllDataLoaded = true;
                    });
                  } else {
                    setState(() {
                      _isAllDataLoaded = false;
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

                      var selectedBot = _bots.firstWhere(
                          (bot) => bot['name'] == newValue,
                          orElse: () => {});

                      if (selectedBot.isEmpty) {
                        debugPrint('Selected bot not found.');
                        return;
                      }

                      setState(() {
                        _selectedBotId = selectedBot['id'];
                        _selectedBotName = selectedBot['name'];
                        constants.setBotId(_selectedBotId.toString());
                      });

                      // Obtén el kbid desde Firestore
                      String? kbid = await fetchKbid(_selectedBotId.toString());

                      if (kbid != null) {
                        // Actualiza el estado con el kbid obtenido
                        _selectedKbid = kbid;
                        constants.setKbId(_selectedKbid.toString());
                      }
                      if (_selectedBotId!.isNotEmpty &&
                          _selectedKbid!.isNotEmpty) {
                        setState(() {
                          _isAllDataLoaded = true;
                        });
                      } else {
                        setState(() {
                          _isAllDataLoaded = false;
                        });
                      }
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
      body: _isAllDataLoaded == false
          ? Center(
              child: LoadingAnimationWidget.bouncingBall(
                color: Colors.orange,
                size: 150,
              ),
            )
          : _selectedBotId!.isEmpty
              ? Center(
                  child: LoadingAnimationWidget.bouncingBall(
                    color: Colors.orange,
                    size: 150,
                  ),
                )
              : PDFAttachmentScreen(
                  conversations: _conversations,
                  botid: _selectedBotId.toString()),
    );
  }
}

class PDFAttachmentScreen extends StatefulWidget {
  final List<Map<String, dynamic>>
      conversations; // Acepta la lista de conversaciones
  final String botid;

  PDFAttachmentScreen({required this.conversations, required this.botid});

  @override
  _PDFAttachmentScreenState createState() => _PDFAttachmentScreenState();
}

class _PDFAttachmentScreenState extends State<PDFAttachmentScreen> {
  List<PlatformFile> _attachedFiles = [];

  //Decide
  Widget _BotBehaviorWidget(context) {
    if (isWebSize(800, context)) {
      return BotBehaviorCard();
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ChatScreen(),
            ),
            SizedBox(width: 16), // Espacio entre las columnas
            // Columna Izquierda: Widgets Originales
            VerticalDivider(width: 1, color: Colors.grey[300]),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16),
                  _BotBehaviorWidget(context),
                  SizedBox(height: 16),
                  Expanded(
                    child: FileListView(
                      onRemoveAttached: (index) {
                        _attachedFiles.removeAt(index);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Columna Derecha: Chat
          ],
        ),
      ),
    );
  }
}
