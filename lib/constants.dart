import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:helloworld/colors.dart';


class Constants extends ChangeNotifier {
  static const String baseUrlFiles = "https://api.botpress.cloud/v1/files";
  static const String botUrl = "https://api.botpress.cloud/v1/admin/bots";
  static const String workspaceIdHeader =
      "wkspace_01HV70DJPN2A123AD5SJ7BEG2B"; // Mantenerlo final
  static const String authorizationHeader =
      "Bearer bp_pat_k0urSciyORrnJO3cRXPrsMdYjPL8eiTQXX4m";

  String _kbId = ' ';

  // Propiedades privadas para almacenar el estado
  String _botIdHeader = " ";

  // Constructor privado para crear la instancia Singleton
  Constants._privateConstructor();
  // Instancia Singleton
  static final Constants _instance = Constants._privateConstructor();
  // Getter para la instancia Singleton
  static Constants get instance => _instance;
  // Métodos getter
  String get botIdHeader => _botIdHeader;
  String get kbId => _kbId;

  // Método setter solo para botIdHeader
  void setBotId(String newBotId) {
    if (_botIdHeader != newBotId) {
      _botIdHeader = newBotId;
      notifyListeners();
    }
  }

  void setKbId(String newKbId) {
    if (_kbId != newKbId) {
      _kbId = newKbId;
      notifyListeners();
    }
  }
}

class ImageConstants {
  static const String logoUrl =
      'https://ik.imagekit.io/aml28/processai/4-removebg-preview_GDuNF6iIg.png?updatedAt=1720721269004';
}

class ThemeMaterial {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        primary: AppColors.primaryColor,
        onPrimary: Colors.white,
        secondary: AppColors.accentColor,
      ),
      scaffoldBackgroundColor: AppColors.backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.appBarColor,
        iconTheme: IconThemeData(color: AppColors.iconColor),
        titleTextStyle: TextStyle(
          color: AppColors.textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        bodySmall: TextStyle(color: AppColors.textColor),
        bodyMedium: TextStyle(color: AppColors.textColor),
        headlineSmall: TextStyle(
          color: AppColors.textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(AppColors.primaryColor),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          padding:
              MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 15)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}
