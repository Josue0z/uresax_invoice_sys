import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';

class Providers {
  int? id;
  String? name;
  String? rncOrId;
  DateTime? createdAt;
  Providers({this.id, this.name, this.rncOrId, this.createdAt});
  static Future<List<Providers>> get({String? search}) async {
    try {
      final conne = SqlConector.connection;

      var parameters = {};
      String params = '';

      if (search != null) {
        params +=
            '''where lower(name) like  lower(@search) or lower("rncOrId") like  lower(@search)''';
        parameters.addAll({'search': '%$search%'});
      }
      var result = await conne?.execute(
          Sql.named('select * from public."Providers" $params order by name'),
          parameters: parameters);
      return [
        Providers(name: 'SELECCIONAR PROVEEDOR'),
        ...result?.map((e) => Providers.fromMap(e.toColumnMap())).toList() ?? []
      ];
    } catch (e) {
      rethrow;
    }
  }

  Future<Providers?> create() async {
    try {
      final conne = SqlConector.connection;
      var parameters = toMap();
      parameters.remove('id');
      parameters.remove('createdAt');

      var result = await conne?.execute(
          Sql.named('insert into public."Providers" '
              '(name, "rncOrId") values (@name, @rncOrId) returning *'),
          parameters: parameters);
      return Providers.fromMap(result!.first.toColumnMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update() async {
    try {
      final conne = SqlConector.connection;
      var parameters = toMap();

      parameters.remove('createdAt');

      await conne?.execute(
          Sql.named(
              'update public."Providers" set name = @name, "rncOrId" = @rncOrId where id = @id returning *'),
          parameters: parameters);
    } catch (e) {
      rethrow;
    }
  }

  Providers copyWith({
    int? id,
    String? name,
    String? rncOrId,
    DateTime? createdAt,
  }) {
    return Providers(
      id: id ?? this.id,
      name: name ?? this.name,
      rncOrId: rncOrId ?? this.rncOrId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'rncOrId': rncOrId, 'createdAt': createdAt};
  }

  factory Providers.fromMap(Map<String, dynamic> map) {
    return Providers(
        id: map['id'],
        name: map['name'],
        rncOrId: map['rncOrId'],
        createdAt: map['createdAt']);
  }

  String toJson() => json.encode(toMap());

  factory Providers.fromJson(String source) =>
      Providers.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Providers(id: $id, name: $name, rncOrId: $rncOrId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Providers &&
        o.id == id &&
        o.name == name &&
        o.rncOrId == rncOrId &&
        o.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ rncOrId.hashCode ^ createdAt.hashCode;
  }
}
