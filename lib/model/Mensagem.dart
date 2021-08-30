class Mensagem {
  String? _idUsuario;
  String? _mensagem;
  String? _urlImagem;
  String? _tipo;

  Mensagem();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idUsuario": this.idUsuario,
      "mensagem": this.mensagem,
      "urlImagem": this.urlImagem,
      "tipo": this.tipo,
    };
    return map;
  }

  get idUsuario => this._idUsuario;

  set idUsuario(value) => this._idUsuario = value;

  get mensagem => this._mensagem;

  set mensagem(value) => this._mensagem = value;

  get urlImagem => this._urlImagem;

  set urlImagem(value) => this._urlImagem = value;

  get tipo => this._tipo;

  set tipo(value) => this._tipo = value;
}
