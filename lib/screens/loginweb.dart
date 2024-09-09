import 'dart:math';
import 'package:helloworld/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helloworld/models/colors.dart';
import 'package:helloworld/models/firebase_options.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:loading_btn/loading_btn.dart';
import 'package:provider/provider.dart';
import 'package:helloworld/models/constants.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/foundation.dart';

class LoginAppWeb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LoginScreenWeb(); // Aquí está la pantalla de login
  }
}

class LoginScreenWeb extends StatefulWidget {
  @override
  _LoginScreenWebState createState() => _LoginScreenWebState();
}

class _LoginScreenWebState extends State<LoginScreenWeb>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    if (kDebugMode) {
      _emailController.text = "lasheralberto@gmail.com";
      _passwordController.text = "lasheralberto";
    } else {
      _emailController.text = "";
      _passwordController.text = "";
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? _errorMessage;

  // Función para verificar el estado de autenticación y realizar sign-out si es necesario
  Future<void> _checkAndSignOut() async {
    try {
      User? currentUser = auth.currentUser; // Obtén el usuario actual
      if (currentUser != null) {
        // Si el usuario está autenticado, realiza sign-out
        await auth.signOut();
        print("Usuario estaba autenticado. Se ha realizado sign-out.");
      } else {
        print("No hay usuario autenticado.");
      }
    } catch (e) {
      print("Error al verificar o cerrar sesión: $e");
    }
  }

  Future<bool> _login() async {
    try {
      debugPrint('Inicio de sesión...');
      // Verifica si el usuario ya está autenticado y realiza sign-out solo si es el caso
      await _checkAndSignOut();

      // Intento de inicio de sesión con Firebase Authentication
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Verificar si el inicio de sesión fue exitoso comprobando el objeto `User`
      if (userCredential.user != null) {
        debugPrint('Usuario autenticado: ${userCredential.user!.uid}');

        // Navegar a la pantalla principal si el login es exitoso
        Navigator.pushReplacementNamed(
            context, '/mainScreen'); // Ejemplo de navegación

        return true;
      } else {
        debugPrint('Fallo en la autenticación. Credenciales incorrectas.');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      // Manejo de errores para mostrar un mensaje adecuado
      debugPrint('Error de FirebaseAuth: ${e.message}');

      setState(() {
        _errorMessage = e.message; // Actualiza el mensaje de error en el estado
      });

      return false;
    } catch (e) {
      // Cualquier otro error no relacionado con FirebaseAuth
      debugPrint('Error inesperado: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Lado izquierdo: Fondo con animación de texto
          // Expanded(
          //   flex: 1,
          //   child: Container(
          //     decoration: BoxDecoration(
          //       gradient: LinearGradient(
          //         begin: Alignment.centerLeft,
          //         end: Alignment.centerRight,
          //         colors: [AppColors.primaryColor, AppColors.primaryColor],
          //       ),
          //     ),
          //     child: Center(
          //       child: DefaultTextStyle(
          //         style: const TextStyle(
          //           fontSize: 20.0,
          //           fontFamily: 'Agne',
          //           color: Colors.white, // Cambia el color del texto aquí
          //         ),
          //         child: AnimatedTextKit(
          //           animatedTexts: [
          //             TypewriterAnimatedText('Automatizamos tus procesos',
          //                 speed: Duration(milliseconds: 20)),
          //             TypewriterAnimatedText(
          //                 'Optimiza procesos, maximiza resultados',
          //                 speed: Duration(milliseconds: 20)),
          //             TypewriterAnimatedText(
          //                 'La eficiencia es la clave del éxito en la era digital',
          //                 speed: Duration(milliseconds: 20)),
          //             TypewriterAnimatedText(
          //                 'Las empresas que integran IA incrementan un 35% su eficiencia operativa',
          //                 speed: Duration(milliseconds: 20)),
          //             TypewriterAnimatedText(
          //                 'Haz más con menos, gracias a la automatización',
          //                 speed: Duration(milliseconds: 20)),
          //             TypewriterAnimatedText(
          //                 'La innovación tecnológica impulsa tu crecimiento',
          //                 speed: Duration(milliseconds: 20)),
          //             TypewriterAnimatedText(
          //                 'Acelera el progreso de tu empresa con IA',
          //                 speed: Duration(milliseconds: 20)),
          //             TypewriterAnimatedText(
          //                 'El futuro es automatizado, y tu empresa puede estar a la vanguardia',
          //                 speed: Duration(milliseconds: 20)),
          //           ],
          //           onTap: () {
          //             print("Tap Event");
          //           },
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
          // Lado derecho: Controles de inicio de sesión
          Expanded(
            flex: 1, // Puedes ajustar el tamaño relativo de los controles
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 40),
                      Center(
                        child: Image.asset(
                          'lib/assets/pailogo.png', // Ruta de la imagen en los activos
                          width:
                              300, // Puedes ajustar el ancho según sea necesario
                          height:
                              300, // Puedes ajustar la altura según sea necesario
                          fit: BoxFit.cover, // Ajusta cómo se muestra la imagen
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Center(
                        child: Text(
                          'Área cliente',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      if (_errorMessage != null) ...[
                        Center(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                      Center(
                        child: SizedBox(
                          width: 300,
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Correo Electrónico',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width: 300,
                          child: TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            obscureText: true,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Center(
                        child: LoadingBtn(
                          height: 50,
                          borderRadius: 8,
                          animate: true,
                          color: AppColors.primaryColor,
                          width: MediaQuery.of(context).size.width *
                              0.10, // Ancho ajustado
                          loader: Center(
                            child: Container(
                              padding: const EdgeInsets.all(
                                  8), // Reduce el padding si es necesario
                              child:
                                  LoadingAnimationWidget.horizontalRotatingDots(
                                color: Colors.white,
                                size: 30, // Reducido el tamaño de la animación
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const Text(
                              "Iniciar sesión",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          onTap: (startLoading, stopLoading, btnState) async {
                            if (btnState == ButtonState.idle) {
                              startLoading();
                              // call your network api
                              await Future.delayed(const Duration(seconds: 2));
                              var _islogged = await _login();
                              if (_islogged == true) {
                                stopLoading();
                                Navigator.pushNamed(context, '/home');
                              } else {
                                stopLoading();
                              }
                            }
                          },
                        ),
                      ),

                      // Center(
                      //   child: SizedBox(
                      //     width: 300,
                      //     child: ElevatedButton(
                      //       onPressed: _login,
                      //       child: Padding(
                      //         padding:
                      //             const EdgeInsets.symmetric(vertical: 8.0),
                      //         child: Center(
                      //           child: Text(
                      //             'Iniciar Sesión',
                      //             style: TextStyle(
                      //               fontSize: 18,
                      //               color: Colors.white,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //       style: ElevatedButton.styleFrom(
                      //         minimumSize: Size(double.infinity,
                      //             50), // Botón ocupa todo el ancho
                      //         shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(12),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
