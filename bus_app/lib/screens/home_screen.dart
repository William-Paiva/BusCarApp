import 'package:flutter/material.dart';
import 'login_screen.dart'; // Importando a tela de login
import '../widgets/map_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Horários de Ônibus',
          style: TextStyle(color: Colors.white), // Cor do texto branca
        ),
        backgroundColor: Colors.blue, // Fundo azul no header
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Ícone branco para contraste
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()), // Volta para a tela de login
            );
          },
        ),
      ),
      body: MapWidget(), // O widget do mapa
    );
  }
}

