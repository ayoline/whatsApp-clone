import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp/model/Conversa.dart';
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
  TextEditingController _controllerMensagem = TextEditingController();
  String? _idUsuarioLogado;
  String? _idUsuarioDestinatario;
  FirebaseFirestore db = FirebaseFirestore.instance;
  ImagePicker imagePicker = ImagePicker();
  File? imagemSelecionada;
  UploadTask? task;
  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();

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
                cursorColor: Color(0xff075E54),
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
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: IconButton(
                    onPressed: () {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Tipo Imagem'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                _recuperarImagem(true);
                                Navigator.pop(context, 'Camera');
                              },
                              child: const Text('Camera'),
                            ),
                            TextButton(
                              onPressed: () {
                                _recuperarImagem(false);
                                Navigator.pop(context, 'Galeria');
                              },
                              child: const Text('Galeria'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.camera_alt),
                    color: Color(0xff075E54),
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

    var stream = StreamBuilder(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: [
                  Text("Carregando mensagens"),
                  CircularProgressIndicator(),
                ],
              ),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            QuerySnapshot? querySnapshot =
                snapshot.data as QuerySnapshot<Object?>?;
            if (snapshot.hasError) {
              return Text("Erro ao carregar os dados!");
            } else {
              return Expanded(
                child: ListView.builder(
                    controller: _scrollController,
                    itemCount: querySnapshot!.docs.length,
                    itemBuilder: (context, indice) {
                      // Recupera mensagem
                      List<DocumentSnapshot> mensagens =
                          querySnapshot.docs.toList();
                      DocumentSnapshot item = mensagens[indice];

                      double larguraContainer =
                          MediaQuery.of(context).size.width * 0.8;

                      // Define cores e alinhamentos
                      Alignment alinhamento = Alignment.centerRight;
                      Color cor = Color(0xffd2ffa5);
                      if (_idUsuarioLogado != item["idUsuario"]) {
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            child: item["tipo"] == "texto"
                                ? Text(
                                    item["mensagem"],
                                    style: TextStyle(fontSize: 18),
                                  )
                                : Image.network(item["urlImagem"]),
                          ),
                        ),
                      );
                    }),
              );
            }
        }
      },
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
              stream,
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
      mensagem.time = DateTime.now();

      // Salvar mensagem para remetente
      _salvarMensagem(_idUsuarioLogado!, _idUsuarioDestinatario!, mensagem);

      // Salvar mensagem para o destin??tario
      _salvarMensagem(_idUsuarioDestinatario!, _idUsuarioLogado!, mensagem);

      // Salvar conversa
      _salvarConversa(mensagem);
    }
  }

  _salvarConversa(Mensagem msg) {
    // Salvar conversa remetente
    Conversa cRemetente = Conversa();
    cRemetente.idRemetente = _idUsuarioLogado;
    cRemetente.idDestinatario = _idUsuarioDestinatario;
    cRemetente.mensagem = msg.mensagem;
    cRemetente.nome = widget.contato.nome;
    cRemetente.caminhoFoto = widget.contato.urlImagem;
    cRemetente.tipoMensagem = msg.tipo;
    cRemetente.salvar();

    // Salvar conversa para destinat??rio
    Conversa cDestinatario = Conversa();
    cDestinatario.idRemetente = _idUsuarioDestinatario;
    cDestinatario.idDestinatario = _idUsuarioLogado;
    cDestinatario.mensagem = msg.mensagem;
    cDestinatario.nome = widget.contato.nome;
    cDestinatario.caminhoFoto = widget.contato.urlImagem;
    cDestinatario.tipoMensagem = msg.tipo;
    cDestinatario.salvar();
  }

  _salvarMensagem(
      String idRemetente, String idDestinatario, Mensagem msg) async {
    // Limpar texto
    _controllerMensagem.clear();

    await db
        .collection("mensagens")
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());
  }

  Future _recuperarImagem(bool daCamera) async {
    final XFile? imagemTemporaria;

    if (daCamera) {
      // camera
      imagemTemporaria = await imagePicker.pickImage(
        source: ImageSource.camera,
      );
    } else {
      // galeria
      imagemTemporaria = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );
    }

    setState(() {
      if (imagemTemporaria != null) {
        imagemSelecionada = File(imagemTemporaria.path);
        _uploadImagem();
      }
    });
  }

  Future _uploadImagem() async {
    if (imagemSelecionada == null) return;

    String nomeImagem = DateTime.now().microsecondsSinceEpoch.toString();
    final destination = "mensagens/$_idUsuarioLogado/$nomeImagem.jpg";

    final ref = FirebaseStorage.instance.ref(destination);
    task = ref.putFile(imagemSelecionada!);

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});

    _recuperarUrlImagem(snapshot);
  }

  Future _recuperarUrlImagem(TaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();

    Mensagem mensagem = Mensagem();
    mensagem.idUsuario = _idUsuarioLogado;
    mensagem.mensagem = "";
    mensagem.urlImagem = url;
    mensagem.tipo = "imagem";
    mensagem.time = DateTime.now();

    // Salvar mensagem para remetente
    _salvarMensagem(_idUsuarioLogado!, _idUsuarioDestinatario!, mensagem);

    // Salvar mensagem para o destin??tario
    _salvarMensagem(_idUsuarioDestinatario!, _idUsuarioLogado!, mensagem);

    // Salvar conversa
    _salvarConversa(mensagem);
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final usuarioLogado = auth.currentUser!;
    _idUsuarioLogado = usuarioLogado.uid;
    _idUsuarioDestinatario = widget.contato.idUsuario;

    _adicionarListenerMensagens();
  }

  Stream<QuerySnapshot>? _adicionarListenerMensagens() {
    final stream = db
        .collection("mensagens")
        .doc(_idUsuarioLogado)
        .collection(_idUsuarioDestinatario!)
        .orderBy("time", descending: false)
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
      Timer(Duration(seconds: 1), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
  }
}
