import 'dart:convert';

import 'package:uresax_invoice_sys/apis/sql.dart';

class OverrideCode {
  int? id;
  String? name;
  OverrideCode({
    this.id,
    this.name,
  });
  static Future<List<OverrideCode>> get() async {
    try {
      final conne = SqlConector.connection;
      var result =
          await conne?.execute('select id, name from public."OverrideCodes"');
      return result
              ?.map((e) => OverrideCode(
                    id: e[0] as int,
                    name: e[1] as String,
                  ))
              .toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  OverrideCode copyWith({
    int? id,
    String? name,
  }) {
    return OverrideCode(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory OverrideCode.fromMap(Map<String, dynamic> map) {
    return OverrideCode(
      id: map['id'],
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory OverrideCode.fromJson(String source) =>
      OverrideCode.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'OverrideCode(id: $id, name: $name)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OverrideCode && o.id == id && o.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
