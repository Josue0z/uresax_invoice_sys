import 'dart:convert';

import 'package:uresax_invoice_sys/apis/sql.dart';

class Permission {
  String? name;
  String? displayName;
  Permission({this.name, this.displayName});

  static Future<List<Permission>> get() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute('select * from public."Permissions"');
      return result?.map((e) => Permission.fromMap(e.toColumnMap())).toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  Permission copyWith({
    String? name,
  }) {
    return Permission(
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  factory Permission.fromMap(Map<String, dynamic> map) {
    return Permission(name: map['name'], displayName: map['displayName']);
  }

  String toJson() => json.encode(toMap());

  factory Permission.fromJson(String source) =>
      Permission.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Permission(name: $name)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Permission && o.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
