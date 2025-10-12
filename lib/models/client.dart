import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';
import 'package:uuid/uuid.dart';

class Client {
  String? id;
  String? name;
  String? identification;
  String? phone;
  String? email;
  String? address;
  DateTime? createdAt;
  Client({
    this.id,
    this.name,
    this.identification,
    this.phone,
    this.email,
    this.address,
    this.createdAt,
  });

  static Future<List<Client>> get({String? search}) async {
    try {
      final conne = SqlConector.connection;

      var parameters = {};
      String params = '';

      if (search != null) {
        params += 'where lower(name) like lower(@search)';
        parameters.addAll({'search': '%$search%'});
      }

      var res = await conne?.execute(
          Sql.named('select * from public."Clients" $params order by name'),
          parameters: parameters);
      return res?.map((e) => Client.fromMap(e.toColumnMap())).toList() ?? [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<Client?> findById(String identification) async {
    try {
      final conne = SqlConector.connection;
      var res = await conne?.execute(
          Sql.named(
              '''select * from public."Clients" where identification = @identification'''),
          parameters: {'identification': identification});

      if (res != null && res.isNotEmpty) {
        var el = res[0];
        return Client.fromMap(el.toColumnMap());
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Client> create() async {
    try {
      final conne = SqlConector.connection;
      var map = toMapInsert();
      map['id'] = Uuid().v4();

      var result = await conne?.execute(
          Sql.named(
              '''insert into public."Clients"(id,name, identification, phone, email,address) values(@id,@name,@identification,@phone,@email,@address) RETURNING *'''),
          parameters: map);

      return Client.fromMap(result!.first.toColumnMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<Client> update() async {
    try {
      final conne = SqlConector.connection;

      var result = await conne?.execute(
          Sql.named(
              '''update public."Clients" set name = @name, phone = @phone, email = @email, identification = @identification, address = @address where id = @id RETURNING *'''),
          parameters: toMapInsert());

      return Client.fromMap(result!.first.toColumnMap());
    } catch (e) {
      rethrow;
    }
  }

  Client copyWith({
    String? id,
    String? name,
    String? identification,
    String? phone,
    String? email,
    DateTime? createdAt,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      identification: identification ?? this.identification,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'identification': identification,
      'phone': phone,
      'email': email,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toMapInsert() {
    return {
      'id': id,
      'name': name,
      'identification': identification,
      'phone': phone,
      'email': email,
      'address': address
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      identification: map['identification'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      createdAt: map['createdAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Client.fromJson(String source) =>
      Client.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Client(id: $id, name: $name, identification: $identification, phone: $phone, email: $email, address: $address, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Client &&
        o.id == id &&
        o.name == name &&
        o.identification == identification &&
        o.phone == phone &&
        o.email == email &&
        o.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        identification.hashCode ^
        phone.hashCode ^
        email.hashCode ^
        createdAt.hashCode;
  }
}
