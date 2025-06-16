import 'dart:convert';

import 'package:uresax_invoice_sys/apis/sql.dart';

class Role {
  int? id;
  String? name;
  Role({
    this.id,
    this.name,
  });

  static Future<List<Role>> get() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute('select * from public."Roles"');
      return result?.map((e) => Role.fromMap(e.toColumnMap())).toList() ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Role copyWith({
    int? id,
    String? name,
  }) {
    return Role(
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

  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      id: map['id'],
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Role.fromJson(String source) =>
      Role.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Role(id: $id, name: $name)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Role && o.id == id && o.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
