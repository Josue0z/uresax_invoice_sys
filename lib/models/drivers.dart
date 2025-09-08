import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';

class Drivers {
  int? id;
  String? name;
  String? phone;
  String? email;
  DateTime? createdAt;
  Drivers({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.createdAt,
  });

  static Future<List<Drivers>> get({String? search}) async {
    try {
      final conne = SqlConector.connection;
      var parameters = {};
      String params = '';

      if (search != null) {
        params += 'where lower(name) like lower(@search)';
        parameters.addAll({'search': '%$search%'});
      }

      var result = await conne?.execute(
          Sql.named(
              'select * from public."Drivers" $params order by "createdAt"'),
          parameters: parameters);
      return result
              ?.map(
                (e) => Drivers.fromMap(e.toColumnMap()),
              )
              .toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Drivers> create() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute(
          Sql.named(
              '''insert into public."Drivers"(name,phone,email) values(@name,@phone,@email) RETURNING *'''),
          parameters: {'name': name, 'phone': phone, 'email': email});

      return Drivers.fromMap(result!.first.toColumnMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<Drivers> update() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute(
          Sql.named(
              '''update public."Drivers" set name = @name, phone = @phone, email = @email where id = @id RETURNING *'''),
          parameters: {'id': id, 'name': name, 'phone': phone, 'email': email});

      return Drivers.fromMap(result!.first.toColumnMap());
    } catch (e) {
      rethrow;
    }
  }

  Drivers copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    DateTime? createdAt,
  }) {
    return Drivers(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'createdAt': createdAt
    };
  }

  factory Drivers.fromMap(Map<String, dynamic> map) {
    return Drivers(
        id: map['id'],
        name: map['name'],
        phone: map['phone'],
        email: map['email'],
        createdAt: map['createdAt']);
  }

  String toJson() => json.encode(toMap());

  factory Drivers.fromJson(String source) =>
      Drivers.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Drivers(id: $id, name: $name, phone: $phone, email: $email, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Drivers &&
        o.id == id &&
        o.name == name &&
        o.phone == phone &&
        o.email == email &&
        o.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        phone.hashCode ^
        email.hashCode ^
        createdAt.hashCode;
  }
}
