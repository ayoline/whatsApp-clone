import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';

class Configuracoes extends StatefulWidget {
  const Configuracoes({Key? key}) : super(key: key);

  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes> {
  TextEditingController _controllerNome = TextEditingController();
  ImagePicker imagePicker = ImagePicker();
  File? imagemSelecionada;
  String? _idUsuarioLogado;
  UploadTask? task;
  String? _urlImagemRecuperada;

  @override
  void initState() {
    super.initState();

    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.grey,
                    backgroundImage: _urlImagemRecuperada != null
                        ? NetworkImage(_urlImagemRecuperada!)
                        : null),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        _recuperarImagem(true);
                      },
                      child: const Text("Câmera"),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        _recuperarImagem(false);
                      },
                      child: const Text("Galeria"),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _controllerNome,
                    autofocus: true,
                    keyboardType: TextInputType.text,
                    style: TextStyle(fontSize: 20),
                    /*
                    onChanged: (texto) {
                      _atualizarNomeFirestore(texto);
                    },
                    */
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Nome",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      primary: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    onPressed: () {
                      _atualizarNomeFirestore();
                    },
                    child: Text(
                      "Salvar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final usuarioLogado = auth.currentUser!;
    _idUsuarioLogado = usuarioLogado.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("whatsappUsers").doc(_idUsuarioLogado).get();

    Map<String, dynamic>? dados = snapshot.data() as Map<String, dynamic>?;
    _controllerNome.text = dados!["nome"];

    setState(() {
      if (dados["urlImagem"] != null) {
        _urlImagemRecuperada = dados["urlImagem"];
      }
    });
  }

  Future _uploadImagem() async {
    if (imagemSelecionada == null) return;

    final caminhoImagem = basename(_idUsuarioLogado!);
    final destination = "perfil/$caminhoImagem.jpg";

    final ref = FirebaseStorage.instance.ref(destination);
    task = ref.putFile(imagemSelecionada!);

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});

    _recuperarUrlImagem(snapshot);
  }

  Future _recuperarUrlImagem(TaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();

    _atualizarUrlImagemFirestore(url);

    setState(() {
      _urlImagemRecuperada = url;
    });
  }

  _atualizarNomeFirestore() {
    String nome = _controllerNome.text;
    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {"nome": nome};

    db.collection("whatsappUsers").doc(_idUsuarioLogado).update(dadosAtualizar);
  }

  _atualizarUrlImagemFirestore(String url) {
    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {"urlImagem": url};

    db.collection("whatsappUsers").doc(_idUsuarioLogado).update(dadosAtualizar);
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
}
