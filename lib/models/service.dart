import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';
import 'package:uresax_invoice_sys/models/sale.element.abs.dart';

class Services implements SaleElement {
  @override
  int? id;
  @override
  String? name;
  @override
  int? quantity;
  @override
  double? price;
  Services({this.id, this.name, this.quantity = 1, this.price, this.taxId});

  Future<Services> create() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute(
          Sql.named(
              '''insert into public."Services"(name, price,"taxId") values(@name,@price,@taxId) RETURNING *'''),
          parameters: {'name': name, 'price': price, 'taxId': taxId});

      return Services.fromMap(result!.first.toColumnMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<Services> update() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute(
          Sql.named(
              '''update public."Services" set name = @name, price = @price, "taxId" = @taxId where id = @id RETURNING *'''),
          parameters: {'name': name, 'price': price, 'id': id, 'taxId': taxId});

      return Services.fromMap(result!.first.toColumnMap());
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Services>> get({String? search}) async {
    try {
      final conne = SqlConector.connection;

      var parameters = {};
      String params = '';

      if (search != null) {
        params += "where lower(name) like  lower(@search)";
        parameters.addAll({'search': '%$search%'});
      }

      var result = await conne?.execute(
          Sql.named(
              'select id, name, price, "taxId" from public."Services" $params'),
          parameters: parameters);
      return result
              ?.map((e) => Services(
                  id: e[0] as int,
                  name: e[1] as String,
                  price: double.parse(e[2] as String),
                  taxId: e[3] as int))
              .toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  Services copyWith({
    int? id,
    String? name,
    int? quantity,
    double? price,
  }) {
    return Services(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'taxId': taxId
    };
  }

  factory Services.fromMap(Map<String, dynamic> map) {
    return Services(
        id: map['id'],
        name: map['name'],
        quantity: map['quantity'],
        price: double.parse(
          map['price'],
        ),
        taxId: map['taxId']);
  }

  String toJson() => json.encode(toMap());

  factory Services.fromJson(String source) =>
      Services.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Services(id: $id, name: $name, quantity: $quantity, price: $price)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Services &&
        o.id == id &&
        o.name == name &&
        o.quantity == quantity &&
        o.price == price;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ quantity.hashCode ^ price.hashCode;
  }

  @override
  String? chassis;

  @override
  String? licensePlate;

  @override
  int? taxId;
}
