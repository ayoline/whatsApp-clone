import 'package:flutter/material.dart';
import 'package:whatsapp/Cadastro.dart';
import 'package:whatsapp/Configuracoes.dart';
import 'package:whatsapp/HomePage.dart';
import 'package:whatsapp/Login.dart';
import 'package:whatsapp/Mensagens.dart';
import 'package:whatsapp/model/Usuario.dart';

class RouteGenerator {
  static const String ROTA_HOME = "/home";
  static const String ROTA_CADASTRO = "/cadastro";
  static const String ROTA_LOGIN = "/login";
  static const String ROTA_CONFIG = "/configuracoes";
  static const String ROTA_MENSAGENS = "/mensagens";

  static Route<dynamic> generalRoute(RouteSettings settings) {
    final args = settings.arguments as Usuario?;

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
      case ROTA_CONFIG:
        return MaterialPageRoute(
          builder: (_) => Configuracoes(),
        );
      case ROTA_MENSAGENS:
        return MaterialPageRoute(
          builder: (_) => Mensagens(args!),
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
