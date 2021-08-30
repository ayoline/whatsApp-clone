import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/RouteGenerator.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AbaContatos extends StatefulWidget {
  const AbaContatos({Key? key}) : super(key: key);

  @override
  _AbaContatosState createState() => _AbaContatosState();
}

class _AbaContatosState extends State<AbaContatos> {
  late String _idUsuarioLogado;
  late String _emailUsuarioLogado;

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
      future: _recuperarContatos(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: [
                  Text("Carregando contatos"),
                  CircularProgressIndicator(),
                ],
              ),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) {
                List<Usuario>? listaItens = snapshot.data;
                Usuario usuario = listaItens![index];

                return ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, RouteGenerator.ROTA_MENSAGENS,
                        arguments: usuario);
                  },
                  contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  leading: CircleAvatar(
                      maxRadius: 30,
                      backgroundColor: Colors.grey,
                      backgroundImage: usuario.urlImagem != null
                          ? NetworkImage(usuario.urlImagem!)
                          : null),
                  title: Text(
                    usuario.nome,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            );
        }
      },
    );
  }

  Future<List<Usuario>> _recuperarContatos() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await db.collection("whatsappUsers").get();

    List<Usuario> listaUsuarios = List<Usuario>.empty(growable: true);
    for (DocumentSnapshot item in querySnapshot.docs) {
      var dados = item.data() as Map<String, dynamic>?;

      // Serve para pular o for no usuario que está logado
      if (dados!["email"] == _emailUsuarioLogado) continue;

      Usuario usuario = Usuario();
      usuario.idUsuario = item.id;
      usuario.email = dados["email"];
      usuario.nome = dados["nome"];
      usuario.urlImagem = dados["urlImagem"];

      listaUsuarios.add(usuario);
    }
    return listaUsuarios;
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final usuarioLogado = auth.currentUser!;
    _idUsuarioLogado = usuarioLogado.uid;
    _emailUsuarioLogado = usuarioLogado.email!;
  }
}
