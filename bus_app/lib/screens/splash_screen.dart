import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';
import '../widgets/background_image.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Inicia o fade-in do ícone
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Aguarda 4 segundos e navega para a tela de login com transição
    Timer(Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(_slideRightTransition(LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BackgroundImage(imagePath: 'assets/tela-load.jpg'),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: Duration(seconds: 2),
                  child: Image.asset('assets/icon.png', height: 120),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(color: Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Função para criar transição de Slide para a direita
  PageRouteBuilder _slideRightTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation =
            Tween<Offset>(begin: Offset(-1.0, 0.0), end: Offset.zero).animate(animation);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: Duration(milliseconds: 700), // Duração da transição
    );
  }
}
