import 'dart:convert';

import 'package:uresax_invoice_sys/apis/sql.dart';

class SymbolModel {
  int? id;
  String? name;
  SymbolModel({
    this.id,
    this.name,
  });

  static Future<List<SymbolModel>> get() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute('select * from public."Symbols"');
      return result
              ?.map((e) => SymbolModel.fromMap(e.toColumnMap()))
              .toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  SymbolModel copyWith({
    int? id,
    String? name,
  }) {
    return SymbolModel(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory SymbolModel.fromMap(Map<String, dynamic> map) {
    return SymbolModel(id: map['id'], name: map['name']);
  }

  String toJson() => json.encode(toMap());

  factory SymbolModel.fromJson(String source) =>
      SymbolModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'SymbolModel(id: $id, name: $name)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is SymbolModel && o.id == id && o.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
