import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:helloworld/constants.dart';
import 'package:helloworld/screens/login.dart';
import 'package:helloworld/screens/loginweb.dart';
import 'package:intl/intl.dart';
import 'colors.dart';
import 'functions.dart';
import 'screens/fileviewer.dart';
import 'screens/botsettings.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:helloworld/firebase_options.dart';
import 'package:helloworld/firebase_functions.dart';
import 'package:helloworld/screens/mainscreen.dart';

final constants = Constants.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeMaterial.theme,
      home: ResponsiveLoginScreen(),
      // Definir las rutas
      routes: {
        '/login': (context) => ChangeNotifierProvider(
            create: (context) => Constants.instance,
            child: ResponsiveLoginScreen()), // Ruta principal
        '/home': (context) => ChangeNotifierProvider(
            create: (context) => Constants.instance, child: MainScreen()),

        '/settings': (context) => ChangeNotifierProvider(
            create: (context) => Constants.instance, child: BotSettingsScreen())
      },
      // Definir una ruta desconocida (opcional)
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => ResponsiveLoginScreen());
      },
    ),
  );
}
