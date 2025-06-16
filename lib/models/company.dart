import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';

class Company {
  String? name;
  String? rncOrId;
  String? phone1;
  String? phone2;
  String? email;
  String? address;
  String? logo;
  Company({
    this.name,
    this.rncOrId,
    this.phone1,
    this.phone2,
    this.email,
    this.address,
    this.logo,
  });

  static Future<Company?> get() async {
    try {
      final conn = SqlConector.connection;
      var result = await conn?.execute(
          'select name, "rncOrId", phone1, phone2, email, address, logo from public."Company" LIMIT 1');
      if (result != null) {
        var first = result[0];
        return Company(
            name: first[0] as String?,
            rncOrId: first[1] as String?,
            phone1: first[2] as String?,
            phone2: first[3] as String?,
            email: first[4] as String?,
            address: first[5] as String,
            logo: first[6] as String?);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Company?> update() async {
    try {
      final conn = SqlConector.connection;
      await conn?.execute(
          Sql.named(
              '''update public."Company" set name = @name, "rncOrId" = @rncOrId, phone1 = @phone1, phone2 = @phone2, email = @email, address = @address, logo = @logo'''),
          parameters: toMap());
      return await get();
    } catch (e) {
      rethrow;
    }
  }

  Company copyWith({
    String? name,
    String? rncOrId,
    String? phone1,
    String? phone2,
    String? email,
    String? address,
    String? logo,
  }) {
    return Company(
      name: name ?? this.name,
      rncOrId: rncOrId ?? this.rncOrId,
      phone1: phone1 ?? this.phone1,
      phone2: phone2 ?? this.phone2,
      email: email ?? this.email,
      address: address ?? this.address,
      logo: logo ?? this.logo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'rncOrId': rncOrId,
      'phone1': phone1,
      'phone2': phone2,
      'email': email,
      'address': address,
      'logo': logo,
    };
  }

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      name: map['name'],
      rncOrId: map['rncOrId'],
      phone1: map['phone1'],
      phone2: map['phone2'],
      email: map['email'],
      address: map['address'],
      logo: map['logo'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Company.fromJson(String source) =>
      Company.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Company(name: $name, rncOrId: $rncOrId, phone1: $phone1, phone2: $phone2, email: $email, address: $address, logo: $logo)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Company &&
        o.name == name &&
        o.rncOrId == rncOrId &&
        o.phone1 == phone1 &&
        o.phone2 == phone2 &&
        o.email == email &&
        o.address == address &&
        o.logo == logo;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        rncOrId.hashCode ^
        phone1.hashCode ^
        phone2.hashCode ^
        email.hashCode ^
        address.hashCode ^
        logo.hashCode;
  }
}
