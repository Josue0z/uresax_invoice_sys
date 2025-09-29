import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';

class Discount {
  int? id;
  String? name;
  double? rate;
  int? symbolId;
  String? symbolName;
  Discount({
    this.id,
    this.name,
    this.rate,
    this.symbolId,
    this.symbolName,
  });
  static Future<List<Discount>> get() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute('select * from public."DiscountsView"');
      return result?.map((e) => Discount.fromMap(e.toColumnMap())).toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Discount> create() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute(
          Sql.named(
              '''insert into public."Discounts"(name,rate,"symbolId") values(@name,@rate,@symbolId) RETURNING *'''),
          parameters: {'name': name, 'rate': rate, 'symbolId': symbolId});

      return Discount.fromMap(result!.first.toColumnMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<Discount> update() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute(
          Sql.named(
              '''update public."Discounts" set name = @name, rate = @rate, symbolId = @symbolId where id = @id RETURNING *'''),
          parameters: {
            'id': id,
            'name': name,
            'rate': rate,
            'symbolId': symbolId
          });

      return Discount.fromMap(result!.first.toColumnMap());
    } catch (e) {
      rethrow;
    }
  }

  Discount copyWith({
    int? id,
    String? name,
    double? rate,
    int? symbolId,
    String? symbolName,
  }) {
    return Discount(
      id: id ?? this.id,
      name: name ?? this.name,
      rate: rate ?? this.rate,
      symbolId: symbolId ?? this.symbolId,
      symbolName: symbolName ?? this.symbolName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rate': rate,
      'symbolId': symbolId,
      'symbolName': symbolName,
    };
  }

  factory Discount.fromMap(Map<String, dynamic> map) {
    return Discount(
      id: map['id'],
      name: map['name'],
      rate: double.parse(map['rate']),
      symbolId: map['symbolId'],
      symbolName: map['symbolName'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Discount.fromJson(String source) =>
      Discount.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Discount(id: $id, name: $name, rate: $rate, symbolId: $symbolId, symbolName: $symbolName)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Discount &&
        o.id == id &&
        o.name == name &&
        o.rate == rate &&
        o.symbolId == symbolId &&
        o.symbolName == symbolName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        rate.hashCode ^
        symbolId.hashCode ^
        symbolName.hashCode;
  }
}
