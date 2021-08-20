import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversa.dart';

class AbaConversas extends StatefulWidget {
  const AbaConversas({Key? key}) : super(key: key);

  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {
  List<Conversa> listaConversas = [
    Conversa(
      "Fulana de tal",
      "Olá mundo",
      "https://firebasestorage.googleapis.com/v0/b/velvety-decoder-312222.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=4a029a80-587c-434b-bb56-2cc0c8a9a14d",
    ),
    Conversa(
      "Ciclano de tal",
      "Olá mundo",
      "https://firebasestorage.googleapis.com/v0/b/velvety-decoder-312222.appspot.com/o/perfil%2Fperfil2.jpg?alt=media&token=2be22532-9972-4b52-be32-c8b530c136eb",
    ),
    Conversa(
      "Beltrano de tal",
      "Olá mundo",
      "https://firebasestorage.googleapis.com/v0/b/velvety-decoder-312222.appspot.com/o/perfil%2Fperfil3.jpg?alt=media&token=ff68ac21-1c65-4c17-a030-9b4262cca224",
    ),
    Conversa(
      "Fulano de tal",
      "Olá mundo",
      "https://firebasestorage.googleapis.com/v0/b/velvety-decoder-312222.appspot.com/o/perfil%2Fperfil4.jpg?alt=media&token=20ddc400-aa58-4866-b939-e131cdd71872",
    ),
    Conversa(
      "Beltrano de tal",
      "Olá mundo",
      "https://firebasestorage.googleapis.com/v0/b/velvety-decoder-312222.appspot.com/o/perfil%2Fperfil5.jpg?alt=media&token=1292de44-2bcd-4de2-810f-7fbe0e64b0b8",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listaConversas.length,
      itemBuilder: (context, index) {
        Conversa conversa = listaConversas[index];

        return ListTile(
          contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          leading: CircleAvatar(
            maxRadius: 30,
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(conversa.caminhoFoto),
          ),
          title: Text(
            conversa.nome,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            conversa.mensagem,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        );
      },
    );
  }
}
