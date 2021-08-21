import 'package:flutter/material.dart';
import 'package:whatsapp/Cadastro.dart';
import 'package:whatsapp/HomePage.dart';
import 'package:whatsapp/Login.dart';

class RouteGenerator {
  static const String ROTA_HOME = "/home";
  static const String ROTA_CADASTRO = "/cadastro";
  static const String ROTA_LOGIN = "/login";

  static Route<dynamic> generalRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(
          builder: (_) => Login(),
        );
      case ROTA_LOGIN:
        return MaterialPageRoute(
          builder: (_) => Login(),
        );
      case ROTA_CADASTRO:
        return MaterialPageRoute(
          builder: (_) => Cadastro(),
        );
      case ROTA_HOME:
        return MaterialPageRoute(
          builder: (_) => HomePage(),
        );
      default:
        _erroRota();
    }
    return _erroRota();
  }

  static Route<dynamic> _erroRota() {
    return MaterialPageRoute(
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Tela não encontrada!"),
          ),
          body: Center(
            child: Text("Tela não encontrada!"),
          ),
        );
      },
    );
  }
}
