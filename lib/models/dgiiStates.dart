import 'dart:convert';

import 'package:uresax_invoice_sys/apis/sql.dart';

class DgiiState {
  int? id;
  String? name;
  DgiiState({
    this.id,
    this.name,
  });

  static Future<List<DgiiState>> get() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute('select * from public."DgiiStates"');
      return result?.map((e) => DgiiState.fromMap(e.toColumnMap())).toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  DgiiState copyWith({
    int? id,
    String? name,
  }) {
    return DgiiState(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory DgiiState.fromMap(Map<String, dynamic> map) {
    return DgiiState(
      id: map['id'],
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory DgiiState.fromJson(String source) =>
      DgiiState.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'DgiiState(id: $id, name: $name)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is DgiiState && o.id == id && o.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
