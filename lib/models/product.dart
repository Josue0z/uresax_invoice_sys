import 'dart:convert';

import 'package:flutter/material.dart';
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
      this.quantity,
      this.factor,
      this.quantityResultFactor,
      this.price,
      this.total,
      this.createdAt,
      this.chassis,
      this.licensePlate,
      this.taxId,
      this.providerId,
      this.providerName,
      this.wareHouseId,
      this.wareHouseName,
      this.code});

  Color get color {
    if (quantity == null) Colors.red;

    return quantity! >= 3 ? Colors.green : Colors.red;
  }

  Future<Products> create() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute(
          Sql.named(
              '''insert into public."Products"(name, price, quantity,chassis,"licensePlate","taxId","providerId","wareHouseId","code") values(@name,@price,@quantity,@chassis,@licensePlate,@taxId,@providerId,@wareHouseId,@code) RETURNING *'''),
          parameters: {
            'name': name,
            'price': price,
            'quantity': quantity,
            'chassis': chassis,
            'licensePlate': licensePlate,
            'taxId': taxId,
            'providerId': providerId,
            'wareHouseId': wareHouseId,
            'code': code
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
              '''update public."Products" set name = @name, price = @price, quantity = @quantity, chassis = @chassis, "licensePlate" = @licensePlate, "taxId" = @taxId, "providerId" = @providerId, "wareHouseId" = @wareHouseId, "code" = @code where id = @id RETURNING *'''),
          parameters: {
            'id': id,
            'name': name,
            'price': price,
            'quantity': quantity,
            'chassis': chassis,
            'licensePlate': licensePlate,
            'taxId': taxId,
            'providerId': providerId,
            'wareHouseId': wareHouseId,
            'code': code,
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
              'select * from public."ProductsView" $params order by "createdAt"'),
          parameters: parameters);
      return result
              ?.map(
                (e) => Products.fromMap(e.toColumnMap()),
              )
              .toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  static Future<Products?> findByCode({required String code}) async {
    try {
      final conne = SqlConector.connection;
      var parameters = {'code': code.trim()};

      var result = await conne?.execute(
          Sql.named('select * from public."ProductsView" where code = @code'),
          parameters: parameters);

      if (result != null && result.isEmpty) {
        return null;
      }

      return result
              ?.map(
                (e) => Products.fromMap(e.toColumnMap()),
              )
              .toList()
              .first ??
          [].first;
    } catch (e) {
      print(e);
      return null;
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
    var map = {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'createdAt': createdAt,
      'taxId': taxId
    };
    if (providerId != null) {
      map.addAll({'provideId': providerId});
    }
    if (wareHouseId != null) {
      map.addAll({'wareHouseId': wareHouseId});
    }

    if (code != null) {
      map.addAll({'code': code});
    }
    return map;
  }

  factory Products.fromMap(Map<String, dynamic> map) {
    return Products(
        id: map['id'],
        name: map['name'],
        quantity: map['quantity'],
        factor: map['factor'] != null ? double.parse(map['factor']) : null,
        price: map['price'] != null ? double.parse(map['price']) : null,
        quantityResultFactor: map['quantityResultFactor'] != null
            ? double.parse(map['quantityResultFactor'])
            : null,
        total: map['total'] != null ? double.parse(map['total']) : null,
        createdAt: map['createdAt'],
        chassis: map['chassis'],
        licensePlate: map['licensePlate'],
        taxId: map['taxId'],
        providerId: map['providerId'],
        providerName: map['providerName'],
        wareHouseId: map['wareHouseId'],
        wareHouseName: map['wareHouseName'],
        code: map['code']);
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

  @override
  double? factor;

  @override
  int? providerId;

  @override
  String? providerName;

  @override
  double? quantityResultFactor;

  @override
  double? total;

  @override
  int? wareHouseId;

  @override
  String? wareHouseName;

  @override
  String? code;
}
