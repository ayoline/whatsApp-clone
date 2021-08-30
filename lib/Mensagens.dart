import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Mensagem.dart';
import 'package:whatsapp/model/Usuario.dart';

// ignore: must_be_immutable
class Mensagens extends StatefulWidget {
  Usuario contato;

  Mensagens(this.contato);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  List<String> listaMensagens = [
    "teste 1,teste 1,teste 1,teste 1,teste 1,teste 1,teste 1,teste 1,teste 1,teste 1,teste 1,teste 1,",
    "teste 2,teste 2,teste 2,teste 2,teste 2,teste 2,teste 2,teste 2,teste 2,teste 2,teste 2,teste 2,",
    "teste 3",
    "teste 4",
    "teste 5",
    "teste 6",
    "teste 7",
    "teste 8",
    "teste 9",
    "teste 10",
  ];

  TextEditingController _controllerMensagem = TextEditingController();
  String? _idUsuarioLogado;
  String? _idUsuarioDestinatario;

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    var caixaMensagem = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerMensagem,
                autofocus: true,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                  hintText: "Digite uma mensagem...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  prefixIcon: IconButton(
                    onPressed: _enviarFoto,
                    icon: Icon(Icons.camera_alt),
                  ),
                ),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Color(0xff075E54),
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
            mini: true,
            onPressed: _enviarMensagem,
          ),
        ],
      ),
    );

    var listView = Expanded(
      child: ListView.builder(
          itemCount: listaMensagens.length,
          itemBuilder: (context, indice) {
            double larguraContainer = MediaQuery.of(context).size.width * 0.8;

            // Define cores e alinhamentos
            Alignment alinhamento = Alignment.centerRight;
            Color cor = Color(0xffd2ffa5);
            if (indice % 2 == 0) {
              alinhamento = Alignment.centerLeft;
              cor = Colors.white;
            }

            return Align(
              alignment: alinhamento,
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Container(
                  width: larguraContainer,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cor,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Text(
                    listaMensagens[indice],
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            );
          }),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
                maxRadius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: widget.contato.urlImagem != null
                    ? NetworkImage(widget.contato.urlImagem!)
                    : null),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(widget.contato.nome),
            ),
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
            child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              listView,
              caixaMensagem,
            ],
          ),
        )),
      ),
    );
  }

  _enviarMensagem() {
    String textoMensagem = _controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem = textoMensagem;
      mensagem.urlImagem = "";
      mensagem.tipo = "texto";

      _salvarMensagem(_idUsuarioLogado!, _idUsuarioDestinatario!, mensagem);
    }
  }

  _salvarMensagem(
      String idRemetente, String idDestinatario, Mensagem msg) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    await db
        .collection("mensagens")
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());

    // Limpar texto
    setState(() {
      _controllerMensagem.clear();
    });
  }

  _enviarFoto() {}

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final usuarioLogado = auth.currentUser!;
    _idUsuarioLogado = usuarioLogado.uid;
    _idUsuarioDestinatario = widget.contato.idUsuario;
  }
}
