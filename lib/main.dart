import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:helloworld/models/constants.dart';
import 'package:helloworld/screens/chatscreen.dart';
import 'package:helloworld/screens/login.dart';
import 'package:helloworld/screens/loginweb.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/main.dart';
import 'package:helloworld/models/colors.dart';
import 'data/functions.dart';
import 'screens/fileviewer.dart';
import 'screens/botsettings.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:helloworld/models/firebase_options.dart';
import 'package:helloworld/data/firebase_functions.dart';
import 'package:helloworld/screens/mainscreen.dart';

final constants = Constants.instance;
FirebaseAuth auth = FirebaseAuth.instance;

void main() async {
  // Ensure Flutter framework bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with better error handling

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  // Run the app
  runApp(RunMainApp());
}

// Define your main app widget in a separate class
class RunMainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Constants.instance,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeMaterial.theme,
        home: ResponsiveLoginScreen(),
        routes: {
          '/login': (context) => ResponsiveLoginScreen(),
          '/home': (context) => MainScreen(),
          '/settings': (context) => BotSettingsScreen(),
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => ResponsiveLoginScreen(),
          );
        },
      ),
    );
  }
}


