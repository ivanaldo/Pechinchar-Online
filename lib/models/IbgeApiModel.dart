import 'dart:convert';

class IbgeApiModel {
  final String nome;

  IbgeApiModel({this.nome});

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
    };
  }

  static IbgeApiModel fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return IbgeApiModel(
      nome: map['nome'],
    );
  }

  String toJson() => json.encode(toMap());

  static IbgeApiModel fromJson(String source) => fromMap(json.decode(source));
}