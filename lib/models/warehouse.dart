import 'dart:convert';

import 'package:uresax_invoice_sys/apis/sql.dart';

class WareHouses {
  int? id;
  String? name;
  DateTime? createdAt;
  WareHouses({
    this.id,
    this.name,
    this.createdAt,
  });
  static Future<List<WareHouses>> get() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute('select * from public."WareHouses"');
      return result?.map((e) => WareHouses.fromMap(e.toColumnMap())).toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  WareHouses copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
  }) {
    return WareHouses(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'createdAt': createdAt};
  }

  factory WareHouses.fromMap(Map<String, dynamic> map) {
    return WareHouses(
      id: map['id'],
      name: map['name'],
      createdAt: map['createdAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory WareHouses.fromJson(String source) =>
      WareHouses.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'WareHouses(id: $id, name: $name, createdAt: $createdAt)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is WareHouses &&
        o.id == id &&
        o.name == name &&
        o.createdAt == createdAt;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ createdAt.hashCode;
}
