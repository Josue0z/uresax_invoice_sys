import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';

class Category {
  int? id;
  String? name;
  DateTime? createdAt;
  Category({
    this.id,
    this.name,
    this.createdAt,
  });

  static Future<List<Category>> get({String? search}) async {
    try {
      var params = '';
      var parameters = {};

      if (search != null) {
        params = 'where lower(name) like lower(@name)';
        parameters = {'name': '%$search%'};
      }

      final conne = SqlConector.connection;
      var res = await conne?.execute(
          Sql.named(
              ''' select * from public."Categories"  $params order by name'''),
          parameters: parameters);
      return res?.map((e) => Category.fromMap(e.toColumnMap())).toList() ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Category> create() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute(
          Sql.named(
              '''insert into public."Categories"(name) values(@name) RETURNING *'''),
          parameters: {'name': name});

      return Category.fromMap(result!.first.toColumnMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<Category> update() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute(
          Sql.named(
              '''update public."Categories" set name = @name where id = @id RETURNING *'''),
          parameters: {'id': id, 'name': name});

      return Category.fromMap(result!.first.toColumnMap());
    } catch (e) {
      rethrow;
    }
  }

  Category copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
        id: map['id'], name: map['name'], createdAt: map['createdAt']);
  }

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String source) =>
      Category.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Category(id: $id, name: $name, createdAt: $createdAt)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Category &&
        o.id == id &&
        o.name == name &&
        o.createdAt == createdAt;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ createdAt.hashCode;
}
