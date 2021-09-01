import 'package:cloud_firestore/cloud_firestore.dart';

class Conversa {
  String? _idRemetente;
  String? _idDestinatario;
  String? _nome;
  String? _mensagem;
  String? _caminhoFoto;
  String? _tipoMensagem;

  Conversa();

  salvar() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    await db
        .collection("conversas")
        .doc(this.idRemetente)
        .collection("ultima_conversa")
        .doc(this.idDestinatario)
        .set(this.toMap());
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idRemetente": this.idRemetente,
      "idDestinatario": this.idDestinatario,
      "nome": this.nome,
      "mensagem": this.mensagem,
      "caminhoFoto": this.caminhoFoto,
      "tipoMensagem": this.tipoMensagem,
    };
    return map;
  }

  get tipoMensagem => this._tipoMensagem;

  set tipoMensagem(value) => this._tipoMensagem = value;

  get idRemetente => this._idRemetente;

  set idRemetente(value) => this._idRemetente = value;

  get idDestinatario => this._idDestinatario;

  set idDestinatario(value) => this._idDestinatario = value;

  get nome => this._nome;

  set nome(value) => this._nome = value;

  get mensagem => this._mensagem;

  set mensagem(value) => this._mensagem = value;

  get caminhoFoto => this._caminhoFoto;

  set caminhoFoto(value) => this._caminhoFoto = value;
}
