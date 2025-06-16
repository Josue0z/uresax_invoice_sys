import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';

class Bank {
  int? id;
  String? name;
  DateTime? createdAt;
  Bank({this.id, this.name, this.createdAt});

  static Future<List<Bank>> get() async {
    try {
      final conne = SqlConector.connection;
      var res =
          await conne?.execute(Sql.named(''' select * from public."Banks" '''));
      return res?.map((e) => Bank.fromMap(e.toColumnMap())).toList() ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Bank copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
  }) {
    return Bank(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'createdAt': createdAt?.toIso8601String()};
  }

  factory Bank.fromMap(Map<String, dynamic> map) {
    return Bank(id: map['id'], name: map['name'], createdAt: map['createdAt']);
  }

  String toJson() => json.encode(toMap());

  factory Bank.fromJson(String source) =>
      Bank.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Bank(id: $id, name: $name, createdAt: $createdAt)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Bank &&
        o.id == id &&
        o.name == name &&
        o.createdAt == createdAt;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ createdAt.hashCode;
}
