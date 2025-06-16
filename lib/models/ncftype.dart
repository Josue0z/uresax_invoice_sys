import 'dart:convert';

import 'package:uresax_invoice_sys/apis/sql.dart';

class NcfType {
  String? id;
  String? name;
  NcfType({
    this.id,
    this.name,
  });

  static Future<List<NcfType>> get() async {
    try {
      final conne = SqlConector.connection;
      var result =
          await conne?.execute('select id,name from public."NcfsTypes"');
      return result
              ?.map((e) => NcfType(id: e[0] as String, name: e[1] as String))
              .toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getLastSeq() async {
    try {
      final conne = SqlConector.connection;
      var result =
          await conne?.execute('select last_value from public."${id}_seq"');

      if (result != null && result.isNotEmpty) {
        var el = result.first;
        var obj = el.toColumnMap();
        var lastVal = obj['last_value'];

        return lastVal.toString();
      }
      return '0';
    } catch (e) {
      rethrow;
    }
  }

  NcfType copyWith({
    String? id,
    String? name,
  }) {
    return NcfType(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory NcfType.fromMap(Map<String, dynamic> map) {
    return NcfType(
      id: map['id'],
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory NcfType.fromJson(String source) =>
      NcfType.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'NcfType(id: $id, name: $name)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is NcfType && o.id == id && o.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
