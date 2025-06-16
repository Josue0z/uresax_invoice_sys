import 'dart:convert';

import 'package:uresax_invoice_sys/apis/sql.dart';

class RetentionTax {
  int? id;
  String? name;
  double? rate;
  RetentionTax({
    this.id,
    this.name,
    this.rate,
  });

  static Future<List<RetentionTax>> get() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne
          ?.execute('select id, name,rate from public."RetentionsTaxes"');
      return result
              ?.map((e) => RetentionTax(
                  id: e[0] as int,
                  name: e[1] as String,
                  rate: double.parse(e[2] as String)))
              .toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  RetentionTax copyWith({
    int? id,
    String? name,
    double? rate,
  }) {
    return RetentionTax(
      id: id ?? this.id,
      name: name ?? this.name,
      rate: rate ?? this.rate,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'rate': rate};
  }

  factory RetentionTax.fromMap(Map<String, dynamic> map) {
    return RetentionTax(id: map['id'], name: map['name'], rate: map['rate']);
  }

  String toJson() => json.encode(toMap());

  factory RetentionTax.fromJson(String source) =>
      RetentionTax.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'RetentionTax(id: $id, name: $name, rate: $rate)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is RetentionTax && o.id == id && o.name == name && o.rate == rate;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ rate.hashCode;
}
