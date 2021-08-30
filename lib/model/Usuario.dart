import 'package:flutter/material.dart';

class Usuario {
  String? _idUsuario;
  String? _nome;
  String? _email;
  String? _senha;
  String? _urlImagem;

  Usuario();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "nome": this.nome,
      "email": this.email,
    };
    return map;
  }

  get idUsuario => this._idUsuario;

  set idUsuario(value) => this._idUsuario = value;

  get nome => this._nome;

  set nome(value) => this._nome = value;

  get email => this._email;

  set email(value) => this._email = value;

  get senha => this._senha;

  set senha(value) => this._senha = value;

  get urlImagem => this._urlImagem;

  set urlImagem(value) => this._urlImagem = value;
}
