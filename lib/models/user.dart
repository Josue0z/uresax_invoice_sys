import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uuid/uuid.dart';

class User {
  String? id;
  String? username;
  String? password;
  String? name;
  String? phone;
  String? email;
  List<String>? permissions;
  DateTime? createdAt;
  int? roleId;
  String? roleName;
  User(
      {this.id,
      this.username,
      this.password,
      this.name,
      this.phone,
      this.email,
      this.permissions = const [],
      this.createdAt,
      this.roleId,
      this.roleName});

  static Future<List<User>> get() async {
    try {
      final conne = SqlConector.connection;
      var res = await conne?.execute(
        Sql.named(
            '''select * from public."UsersView" order by "roleId" desc'''),
      );

      return res?.map((e) => User.fromMap(e.toColumnMap())).toList() ?? [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<User?> login(String username, String password) async {
    try {
      final conne = SqlConector.connection;
      var res = await conne?.execute(
          Sql.named(
              '''select * from public."UsersView" where username = @username;'''),
          parameters: {'username': username});

      if (res != null && res.isNotEmpty) {
        var el = res[0];
        User user = User.fromMap(el.toColumnMap());
        final bool checkPassword =
            BCrypt.checkpw(password, user.password ?? '');

        if (checkPassword) {
          return user;
        } else {
          throw 'CLAVE NO VALIDA';
        }
      } else {
        throw 'NO SE ENCONTRO EL USUARIO';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> create() async {
    try {
      final conne = SqlConector.connection;

      var result = await conne?.execute(
        Sql.named('select * from public."UsersView" where "roleId" = 3'),
      );

      if (result != null && result.isNotEmpty && roleId == 3) {
        throw 'YA EXISTE UN SUPER USUARIO';
      }

      await conne?.execute(
          Sql.named(
              '''insert into public."Users"(id, username, password, name, phone, email, "roleId", permissions) 
              values(@id,@username,@password, @name,@phone,@email, @roleId,@permissions)'''),
          parameters: {
            'id': Uuid().v4(),
            'username': username,
            'password':
                BCrypt.hashpw(password ?? '', BCrypt.gensalt(logRounds: 12)),
            'name': name,
            'phone': phone,
            'email': email,
            'permissions': '{${permissions?.map((e) => e).toList().join(',')}}',
            'roleId': roleId
          });

      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> update() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute(
        Sql.named('select * from public."UsersView" where "roleId" = 3'),
      );

      if (currentUser?.id != id) {
        if (result != null && result.isNotEmpty && roleId == 3) {
          throw 'YA EXISTE UN SUPER USUARIO';
        }
      }

      await conne?.execute(
          Sql.named(
              '''update public."Users" set username = @username, name = @name, phone = @phone, email = @email, permissions = @permissions, "roleId" = @roleId where id = @id'''),
          parameters: {
            'id': id,
            'username': username,
            'name': name,
            'phone': phone,
            'email': email,
            'permissions': '{${permissions?.map((e) => e).toList().join(',')}}',
            'roleId': roleId
          });

      return null;
    } catch (e) {
      rethrow;
    }
  }

  User copyWith({
    String? id,
    String? username,
    String? password,
    String? name,
    String? phone,
    String? email,
    List<String>? permissions,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'name': name,
      'phone': phone,
      'email': email,
      'permissions': permissions?.map((x) => x).toList(),
      'createdAt': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
        id: map['id'],
        username: map['username'],
        password: map['password'],
        name: map['name'],
        phone: map['phone'],
        email: map['email'],
        permissions: map['permissions'] != null
            ? (map['permissions'] as List).map((x) => x).toList().cast<String>()
            : null,
        createdAt: map['createdAt'],
        roleId: map['roleId'],
        roleName: map['roleName']);
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(id: $id, username: $username, password: $password, name: $name, phone: $phone, email: $email, permissions: $permissions, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is User &&
        o.id == id &&
        o.username == username &&
        o.password == password &&
        o.name == name &&
        o.phone == phone &&
        o.email == email &&
        listEquals(o.permissions, permissions) &&
        o.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        password.hashCode ^
        name.hashCode ^
        phone.hashCode ^
        email.hashCode ^
        permissions.hashCode ^
        createdAt.hashCode;
  }
}
