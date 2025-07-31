import 'dart:convert';

import 'package:uresax_invoice_sys/apis/sql.dart';

class PaymentType {
  int? id;
  String? name;
  PaymentType({
    this.id,
    this.name,
  });

  static Future<List<PaymentType>> get() async {
    try {
      final conne = SqlConector.connection;
      var result =
          await conne?.execute('select id, name from public."PaymentType"');
      return result
              ?.map((e) => PaymentType(
                    id: e[0] as int,
                    name: e[1] as String,
                  ))
              .toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  PaymentType copyWith({
    int? id,
    String? name,
  }) {
    return PaymentType(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory PaymentType.fromMap(Map<String, dynamic> map) {
    return PaymentType(id: map['id'], name: map['name']);
  }

  String toJson() => json.encode(toMap());

  factory PaymentType.fromJson(String source) =>
      PaymentType.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'PaymentType(id: $id, name: $name)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is PaymentType && o.id == id && o.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
