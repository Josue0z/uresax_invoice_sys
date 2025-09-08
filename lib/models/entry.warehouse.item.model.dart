import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/models/warehouse.obj.dart';
import 'package:uresax_invoice_sys/utils/extensions.dart';

class EntryWareHouseItemModel implements WareHouseElementItem {
  @override
  String? id;
  @override
  String? ordenId;
  @override
  String? entryId;
  @override
  int? productId;
  @override
  String? productName;
  @override
  int? providerId;
  @override
  String? providerName;
  @override
  int? quantity;
  @override
  int? units;
  @override
  double? price;
  @override
  double? net;
  @override
  double? discount;
  @override
  double? tax;
  @override
  double? total;
  @override
  DateTime? createdAt;
  EntryWareHouseItemModel({
    this.id,
    this.entryId,
    this.productId,
    this.productName,
    this.providerId,
    this.providerName,
    this.quantity,
    this.units,
    this.price,
    this.net,
    this.discount,
    this.tax,
    this.total,
    this.createdAt,
  });

  @override
  Future<EntryWareHouseItemModel?> create([TxSession? transaction]) async {
    try {
      var parameters = toMap();

      parameters.remove('createdAt');
      parameters.remove('productName');
      parameters.remove('providerId');
      parameters.remove('providerName');

      var result = await transaction?.execute(
          Sql.named('insert into public."EntriesWareHouseItems" '
              '(id, "entryId", "productId", quantity, units, price, net, discount, tax, total) '
              'values (@id,@entryId, @productId, @quantity, @units, @price, @net, @discount, @tax, @total) returning *'),
          parameters: parameters);

      await transaction?.execute(Sql.named(
          '''update public."Products" set quantity = quantity + $quantity where id = $productId'''));

      return EntryWareHouseItemModel.fromMap(result!.first.toColumnMap());
    } catch (e) {
      rethrow;
    }
  }

  @override
  Map<String, dynamic> toDisplay() {
    return {
      'CANTIDAD': quantity?.toStringAsFixed(2),
      'UNIDADES': units?.toStringAsFixed(2),
      'PRODUCTO': productName,
      'PROVEEDOR': providerName,
      'PRECIO': price?.toDop(),
      'NETO': net?.toDop(),
      'TOTAL': total?.toDop()
    };
  }

  @override
  Map<String, dynamic> toDisplayReceipt() {
    return {
      'DESCRIPCION.':
          '${quantity?.toStringAsFixed(2)} x ${price?.toCoin()}\n$productName\n$providerName',
      'UNT.': units?.toStringAsFixed(2),
      'NETO': net?.toDop(),
      'TOTAL': total?.toDop()
    };
  }

  EntryWareHouseItemModel copyWith({
    String? id,
    String? entryId,
    int? productId,
    String? productName,
    int? providerId,
    String? providerName,
    int? quantity,
    int? units,
    double? price,
    double? net,
    double? discount,
    double? tax,
    double? total,
    DateTime? createdAt,
  }) {
    return EntryWareHouseItemModel(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      quantity: quantity ?? this.quantity,
      units: units ?? this.units,
      price: price ?? this.price,
      net: net ?? this.net,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entryId': entryId,
      'productId': productId,
      'productName': productName,
      'providerId': providerId,
      'providerName': providerName,
      'quantity': quantity,
      'units': units,
      'price': price,
      'net': net,
      'discount': discount,
      'tax': tax,
      'total': total,
      'createdAt': createdAt
    };
  }

  factory EntryWareHouseItemModel.fromMap(Map<String, dynamic> map) {
    return EntryWareHouseItemModel(
        id: map['id'],
        entryId: map['entryId'],
        productId: map['productId'],
        productName: map['productName'],
        providerId: map['providerId'],
        providerName: map['providerName'],
        quantity: map['quantity'],
        units: map['units'],
        price: double.parse(map['price']),
        net: double.parse(map['net']),
        discount: double.parse(map['discount']),
        tax: double.parse(map['tax']),
        total: double.parse(map['total']),
        createdAt: map['createdAt']);
  }

  String toJson() => json.encode(toMap());

  factory EntryWareHouseItemModel.fromJson(String source) =>
      EntryWareHouseItemModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EntryWareHouseItemModel(id: $id, entryId: $entryId, productId: $productId, productName: $productName, providerId: $providerId, providerName: $providerName, quantity: $quantity, units: $units, price: $price, net: $net, discount: $discount, tax: $tax, total: $total, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is EntryWareHouseItemModel &&
        o.id == id &&
        o.entryId == entryId &&
        o.productId == productId &&
        o.productName == productName &&
        o.providerId == providerId &&
        o.providerName == providerName &&
        o.quantity == quantity &&
        o.units == units &&
        o.price == price &&
        o.net == net &&
        o.discount == discount &&
        o.tax == tax &&
        o.total == total &&
        o.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        entryId.hashCode ^
        productId.hashCode ^
        productName.hashCode ^
        providerId.hashCode ^
        providerName.hashCode ^
        quantity.hashCode ^
        units.hashCode ^
        price.hashCode ^
        net.hashCode ^
        discount.hashCode ^
        tax.hashCode ^
        total.hashCode ^
        createdAt.hashCode;
  }
}
