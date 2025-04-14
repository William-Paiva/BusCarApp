import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';

  void _register() async {
    String user = _userController.text;
    String password = _passwordController.text;

    if (user.isNotEmpty && password.isNotEmpty) {
      await DBHelper.registerUser(user, password);
      setState(() {
        _message = '✅ Usuário registrado com sucesso!';
      });
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context); // Volta para tela de login
      });
    } else {
      setState(() {
        _message = '⚠️ Preencha todos os campos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: InputDecoration(labelText: 'Usuário'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Registrar'),
            ),
            SizedBox(height: 20),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
