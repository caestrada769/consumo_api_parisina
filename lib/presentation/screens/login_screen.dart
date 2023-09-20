import 'dart:convert';
import 'dart:io';



import 'package:consumo_api/presentation/screens/admin_screen.dart';
import 'package:consumo_api/presentation/screens/empleado_tortas_screen.dart';
import 'package:consumo_api/presentation/screens/tortas_screen.dart';
import 'package:consumo_api/presentation/screens/user_register_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isVisible = true;

  final String url = 'https://api-parisina-flutter.onrender.com/api/users/login';

  void apiLogin() async {
    final email = emailController.text;
    final password = passwordController.text;

    final body = jsonEncode({'correo': email, 'contrasena': password});

    final response = await http.post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final area = responseData['area'];
      final message = responseData['message'];

      if (area == 'Tortas') {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => TortasScreen()));
      } else if (area == 'Panaderia') {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const TortasScreen()));
      } else if (area == 'Reposteria') {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const EmpleadoTortasScreen()));
      } else if (area == 'Comida de sal') {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const EmpleadoTortasScreen()));
      } 
    } else if (response.statusCode == 401) {
      final responseData = jsonDecode(response.body);
      final error = responseData['error'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(60.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'Ingrese su correo',
                    prefixIcon: Icon(Icons.email_outlined)),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Ingrese su contraseña',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isVisible = !_isVisible;
                        });
                      },
                      icon: _isVisible
                          ? Icon(Icons.visibility)
                          : Icon(Icons.visibility_off)),
                ),
                obscureText: _isVisible,
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    apiLogin();
                  },
                  child: const Text('Iniciar Sesión')),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserRegisterScreen()));
                  },
                  child: const Text('Registrarse'))
            ],
          ),
        ),
      ),
    );
  }
}
