import 'dart:convert';

import 'package:uresax_invoice_sys/apis/sql.dart';

class PaymentMethod {
  int? id;
  String? name;
  PaymentMethod({
    this.id,
    this.name,
  });

  static Future<List<PaymentMethod>> get() async {
    try {
      final conne = SqlConector.connection;
      var result =
          await conne?.execute('select id, name from public."PaymentsMethods"');
      return result
              ?.map((e) => PaymentMethod(
                    id: e[0] as int,
                    name: e[1] as String,
                  ))
              .toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  PaymentMethod copyWith({
    int? id,
    String? name,
  }) {
    return PaymentMethod(
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

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'],
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory PaymentMethod.fromJson(String source) =>
      PaymentMethod.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'PaymentMethod(id: $id, name: $name)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is PaymentMethod && o.id == id && o.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
