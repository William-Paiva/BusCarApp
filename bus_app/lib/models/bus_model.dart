// lib/models/bus_model.dart

class BusModel {
  int? id;
  String linha;
  String sentido;
  String apelido; // algo que o usuário possa editar

  BusModel({
    this.id,
    required this.linha,
    required this.sentido,
    required this.apelido,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'linha': linha,
      'sentido': sentido,
      'apelido': apelido,
    };
  }

  factory BusModel.fromMap(Map<String, dynamic> map) {
    return BusModel(
      id: map['id'],
      linha: map['linha'],
      sentido: map['sentido'],
      apelido: map['apelido'],
    );
  }
}
