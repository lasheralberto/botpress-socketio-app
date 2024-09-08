import 'package:flutter/material.dart';
import 'package:helloworld/models/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helloworld/main.dart';
import 'package:provider/provider.dart';
import 'package:helloworld/models/constants.dart';

class LoginAppMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LoginScreenMobile(); // Aquí está la pantalla de login
  }
}

class LoginScreenMobile extends StatefulWidget {
  @override
  _LoginScreenMobileState createState() => _LoginScreenMobileState();
}

class _LoginScreenMobileState extends State<LoginScreenMobile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    _emailController.text = "";
    _passwordController.text = "";
    super.initState();
  }

  void _login() async {
    try {
      debugPrint("Login intento");
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      debugPrint("Login exitoso");
      Navigator.pushNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      // Maneja el error de autenticación aquí
      print(e.message); // Muestra el error en consola
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Parte superior con color de fondo 1
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
          // Parte inferior con color de fondo 2 y el formulario de inicio de sesión
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white, // Color de fondo de la parte inferior
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextField(
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
                    SizedBox(height: 20),
                    TextField(
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
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      child: Text(
                        'Iniciar Sesión',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 10),
                    // TextButton(
                    //   onPressed: () {
                    //     // Implementa la lógica para recuperar la contraseña
                    //   },
                    //   child: Text(
                    //     '¿Olvidaste tu contraseña?',
                    //     style: TextStyle(color: Colors.grey),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
