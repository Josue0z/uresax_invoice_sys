import 'dart:convert';

import 'package:uresax_invoice_sys/apis/sql.dart';

class RetentionIsr {
  String? id;
  String? name;
  double? rate;
  RetentionIsr({
    this.id,
    this.name,
    this.rate,
  });

  static Future<List<RetentionIsr>> get() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne
          ?.execute('select id, name,rate from public."RetentionsIsrs"');
      return result
              ?.map((e) => RetentionIsr(
                  id: e[0] as String,
                  name: e[1] as String,
                  rate: double.parse(e[2] as String)))
              .toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  RetentionIsr copyWith({
    String? id,
    String? name,
    double? rate,
  }) {
    return RetentionIsr(
      id: id ?? this.id,
      name: name ?? this.name,
      rate: rate ?? this.rate,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'rate': rate};
  }

  factory RetentionIsr.fromMap(Map<String, dynamic> map) {
    return RetentionIsr(id: map['id'], name: map['name'], rate: map['rate']);
  }

  String toJson() => json.encode(toMap());

  factory RetentionIsr.fromJson(String source) =>
      RetentionIsr.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'RetentionIsr(id: $id, name: $name, rate: $rate)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is RetentionIsr && o.id == id && o.name == name && o.rate == rate;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ rate.hashCode;
}
