import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';
import 'package:uresax_invoice_sys/models/sale.element.abs.dart';

class Products implements SaleElement {
  @override
  int? id;
  @override
  String? name;
  @override
  double? price;
  @override
  int? quantity;
  DateTime? createdAt;
  @override
  String? chassis;
  @override
  String? licensePlate;
  Products(
      {this.id,
      this.name,
      this.price,
      this.quantity,
      this.createdAt,
      this.chassis,
      this.licensePlate,
      this.taxId});
  Future<Products> create() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute(
          Sql.named(
              '''insert into public."Products"(name, price, quantity,chassis,"licensePlate","taxId") values(@name,@price,@quantity,@chassis,@licensePlate,@taxId) RETURNING *'''),
          parameters: {
            'name': name,
            'price': price,
            'quantity': quantity,
            'chassis': chassis,
            'licensePlate': licensePlate,
            'taxId': taxId
          });

      return Products.fromMap(result!.first.toColumnMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<Products> update() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute(
          Sql.named(
              '''update public."Products" set name = @name, price = @price, quantity = @quantity, chassis = @chassis, "licensePlate" = @licensePlate, "taxId" = @taxId where id = @id RETURNING *'''),
          parameters: {
            'id': id,
            'name': name,
            'price': price,
            'quantity': quantity,
            'chassis': chassis,
            'licensePlate': licensePlate,
            'taxId': taxId
          });

      return Products.fromMap(result!.first.toColumnMap());
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Products>> get({String? search}) async {
    try {
      final conne = SqlConector.connection;
      var parameters = {};
      String params = '';

      if (search != null) {
        params += 'where lower(name) like lower(@search)';
        parameters.addAll({'search': '%$search%'});
      }

      var result = await conne?.execute(
          Sql.named(
              'select id, name, price, quantity, chassis, "licensePlate", "taxId" from public."Products" $params order by "createdAt"'),
          parameters: parameters);
      return result
              ?.map(
                (e) => Products(
                    id: e[0] as int,
                    name: e[1] as String,
                    price: double.parse(e[2] as String),
                    quantity: e[3] as int,
                    chassis: e[4] as String,
                    licensePlate: e[5] as String,
                    taxId: e[6] as int?),
              )
              .toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  Products copyWith({
    int? id,
    String? name,
    double? price,
    int? quantity,
    DateTime? createdAt,
  }) {
    return Products(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'createdAt': createdAt,
      'taxId': taxId
    };
  }

  factory Products.fromMap(Map<String, dynamic> map) {
    return Products(
        id: map['id'],
        name: map['name'],
        price: double.parse(map['price']),
        quantity: map['quantity'],
        createdAt: map['createdAt'],
        chassis: map['chassis'],
        licensePlate: map['licensePlate'],
        taxId: map['taxId']);
  }

  String toJson() => json.encode(toMap());

  factory Products.fromJson(String source) =>
      Products.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Products(id: $id, name: $name, price: $price, quantity: $quantity, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Products &&
        o.id == id &&
        o.name == name &&
        o.price == price &&
        o.quantity == quantity &&
        o.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        price.hashCode ^
        quantity.hashCode ^
        createdAt.hashCode;
  }

  @override
  int? taxId;
}
