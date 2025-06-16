import 'dart:convert';

import 'package:uresax_invoice_sys/apis/sql.dart';

class Taxes {
  int? id;
  String? name;
  double? rate;
  Taxes({
    this.id,
    this.name,
    this.rate,
  });

  static Future<List<Taxes>> get() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute('select * from public."Taxes"');
      return result
              ?.map((e) => Taxes(
                  id: e[0] as int,
                  name: e[1] as String,
                  rate: double.parse(e[2] as String)))
              .toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  Taxes copyWith({
    int? id,
    String? name,
    double? rate,
  }) {
    return Taxes(
      id: id ?? this.id,
      name: name ?? this.name,
      rate: rate ?? this.rate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rate': rate,
    };
  }

  factory Taxes.fromMap(Map<String, dynamic> map) {
    return Taxes(
      id: map['id'],
      name: map['name'],
      rate: map['rate'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Taxes.fromJson(String source) =>
      Taxes.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Taxes(id: $id, name: $name, rate: $rate)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Taxes && o.id == id && o.name == name && o.rate == rate;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ rate.hashCode;
}
