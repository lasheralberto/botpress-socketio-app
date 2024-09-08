import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helloworld/colors.dart';
import 'package:provider/provider.dart';
import 'package:helloworld/constants.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    _emailController.text = "";
    _passwordController.text = "";
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? _errorMessage;

  void _login() async {
    try {
      debugPrint('Inicio de sesión..');
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Navegar a la pantalla principal si el login es exitoso
      debugPrint("Login exitoso");
      Navigator.pushNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Lado izquierdo: Fondo con animación de texto
          Expanded(
            flex: 1,
            child: Container(
              color:
                  AppColors.appBarColor, // Color de fondo de la parte superior
              child: Center(
                child: Image.asset(
                  'lib/assets/pailogo.png', // Ruta de la imagen en los activos
                  width: 300, // Puedes ajustar el ancho según sea necesario
                  height: 300, // Puedes ajustar la altura según sea necesario
                  fit: BoxFit.cover, // Ajusta cómo se muestra la imagen
                ),
              ),
            ),
          ),
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
                      Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: 40),
                      if (_errorMessage != null) ...[
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
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
                        child: SizedBox(
                          width: 300,
                          child: ElevatedButton(
                            onPressed: _login,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Center(
                                child: Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity,
                                  50), // Botón ocupa todo el ancho
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
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
