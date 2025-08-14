import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';
import 'package:uresax_invoice_sys/models/orden.item.model.dart';
import 'package:uuid/uuid.dart';

class OrdenModel {
  String? id;
  int? ordenNum;
  double? net;
  double? tax;
  double? total;
  DateTime? createdAt;
  List<OrdenItemModel>? items;
  double? amountPaid;
  OrdenModel(
      {this.id,
      this.ordenNum,
      this.net,
      this.tax,
      this.total,
      this.createdAt,
      this.items = const [],
      this.amountPaid = 0});

  static Future<List<OrdenModel>> get() async {
    try {
      final conne = SqlConector.connection;
      var result =
          await conne?.execute('select * from public."OrdenPurchases"');
      return result?.map((e) => OrdenModel.fromMap(e.toColumnMap())).toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<OrdenItemModel>> getItems() async {
    try {
      final conne = SqlConector.connection;

      var result = await conne?.execute(
          Sql.named(
              'select * from public."OrdenItemsView" where "ordenId" = @ordenId order by "createdAt"'),
          parameters: {'ordenId': id});
      return result
              ?.map(
                (e) => OrdenItemModel.fromMap(e.toColumnMap()),
              )
              .toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  Future<OrdenModel?> create() async {
    try {
      OrdenModel? orden;
      var parameters = toMap();

      String ordenId = Uuid().v4();

      parameters['id'] = ordenId;

      parameters.remove('createdAt');
      parameters.remove('ordenNum');
      parameters.remove('items');

      final conne = SqlConector.connection;

      await conne?.runTx((transaction) async {
        var result = await transaction.execute(
            Sql.named(
                '''insert into public."OrdenPurchases"(id, net, tax, total,"amountPaid") values(@id, @net, @tax, @total,@amountPaid) RETURNING *'''),
            parameters: parameters);

        orden = OrdenModel.fromMap(result.first.toColumnMap());

        for (var item in items ?? [] as List<OrdenItemModel>) {
          item.id = Uuid().v4();
          item.ordenId = ordenId;
          await item.create(transaction);
        }
      });
      return orden;
    } catch (e) {
      rethrow;
    }
  }

  OrdenModel copyWith(
      {String? id,
      int? ordenNum,
      double? net,
      double? tax,
      double? total,
      DateTime? createdAt,
      List<OrdenItemModel>? items,
      double? amountPaid}) {
    return OrdenModel(
        id: id ?? this.id,
        ordenNum: ordenNum ?? this.ordenNum,
        net: net ?? this.net,
        tax: tax ?? this.tax,
        total: total ?? this.total,
        createdAt: createdAt ?? this.createdAt,
        amountPaid: amountPaid ?? this.amountPaid,
        items: items ?? this.items);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ordenNum': ordenNum,
      'net': net,
      'tax': tax,
      'total': total,
      'createdAt': createdAt,
      'amountPaid': amountPaid,
      'items': items?.map((e) => e.toMap()).toList(),
    };
  }

  factory OrdenModel.fromMap(Map<String, dynamic> map) {
    return OrdenModel(
        id: map['id'],
        ordenNum: map['ordenNum'],
        net: double.parse(map['net']),
        tax: double.parse(map['tax']),
        total: double.parse(map['total']),
        createdAt: map['createdAt'],
        amountPaid:
            map['amountPaid'] != null ? double.parse(map['amountPaid']) : 0,
        items: map['items'] != null
            ? List<OrdenItemModel>.from(
                (map['items'] as List).map((x) => OrdenItemModel.fromMap(x)))
            : []);
  }

  String toJson() => json.encode(toMap());

  factory OrdenModel.fromJson(String source) =>
      OrdenModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrdenModel(id: $id, ordenNum: $ordenNum, net: $net, tax: $tax, total: $total, createdAt: $createdAt, items: $items)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is OrdenModel &&
        o.id == id &&
        o.ordenNum == ordenNum &&
        o.net == net &&
        o.tax == tax &&
        o.total == total &&
        o.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        ordenNum.hashCode ^
        net.hashCode ^
        tax.hashCode ^
        total.hashCode ^
        createdAt.hashCode;
  }
}
