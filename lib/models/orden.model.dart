import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';
import 'package:uresax_invoice_sys/models/orden.item.model.dart';
import 'package:uresax_invoice_sys/models/warehouse.obj.dart';
import 'package:uuid/uuid.dart';

class OrdenModel implements WareHouseElement<OrdenItemModel> {
  @override
  String? id;
  @override
  String? ordenId;
  @override
  int? ordenNum;
  @override
  String? entryId;
  @override
  int? entryNum;
  @override
  double? net;
  @override
  double? tax;
  @override
  double? total;
  @override
  DateTime? createdAt;
  @override
  List<OrdenItemModel>? items;
  @override
  double? amountPaid;
  @override
  String? authorId;
  @override
  String? authorName;
  OrdenModel(
      {this.id,
      this.ordenNum,
      this.net,
      this.tax,
      this.total,
      this.createdAt,
      this.items = const [],
      this.amountPaid = 0,
      this.authorId,
      this.authorName,
      this.applyEntry,
      this.driverId,
      this.driverName,
      this.driverIdentification,
      this.driverPhone,
      this.driverEmail});

  Color get color {
    return applyEntry == true ? Colors.green : Colors.red;
  }

  String get labelText {
    return applyEntry == true ? 'ORDEN APLICADA' : 'ORDEN NO APLICADA';
  }

  static Future<List<OrdenModel>> get() async {
    try {
      final conne = SqlConector.connection;
      var result =
          await conne?.execute('select * from public."OrdenPurchasesView"');
      return result?.map((e) => OrdenModel.fromMap(e.toColumnMap())).toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<OrdenItemModel>> getItems([TxSession? tx]) async {
    try {
      final conne = tx ?? SqlConector.connection;

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

  @override
  Future<OrdenModel?> create() async {
    try {
      OrdenModel? orden;
      var parameters = toMap();

      String ordenId = Uuid().v4();

      parameters['id'] = ordenId;

      parameters.remove('createdAt');
      parameters.remove('ordenNum');
      parameters.remove('items');
      parameters.remove('authorName');
      parameters.remove('applyEntry');

      final conne = SqlConector.connection;

      await conne?.runTx((transaction) async {
        var result = await transaction.execute(
            Sql.named(
                '''insert into public."OrdenPurchases"(id, net, tax, total,"amountPaid","authorId","driverId") values(@id, @net, @tax, @total,@amountPaid,@authorId,@driverId) RETURNING *'''),
            parameters: parameters);

        orden = OrdenModel.fromMap(result.first.toColumnMap());

        for (var item in items ?? [] as List<OrdenItemModel>) {
          item.id = Uuid().v4();
          item.ordenId = ordenId;
          await item.create(transaction);
        }
        id = ordenId;

        orden?.items = await getItems(transaction);
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
      double? amountPaid,
      String? authorId,
      String? authorName}) {
    return OrdenModel(
        id: id ?? this.id,
        ordenNum: ordenNum ?? this.ordenNum,
        net: net ?? this.net,
        tax: tax ?? this.tax,
        total: total ?? this.total,
        createdAt: createdAt ?? this.createdAt,
        amountPaid: amountPaid ?? this.amountPaid,
        items: items ?? this.items,
        authorId: authorId ?? this.authorId,
        authorName: authorName ?? this.authorName);
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
      'authorId': authorId,
      'authorName': authorName,
      'applyEntry': applyEntry,
      'driverId': driverId,
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
            : [],
        authorId: map['authorId'],
        authorName: map['authorName'],
        applyEntry: map['applyEntry'],
        driverId: map['driverId'],
        driverName: map['driverName'],
        driverIdentification: map['driverIdentification'],
        driverPhone: map['driverPhone'],
        driverEmail: map['driverEmail']);
  }

  String toJson() => json.encode(toMap());

  factory OrdenModel.fromJson(String source) =>
      OrdenModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrdenModel(id: $id, ordenNum: $ordenNum, net: $net, tax: $tax, total: $total, createdAt: $createdAt, items: $items, authorId: $authorId, authorName: $authorName, applyEntry: $applyEntry)';
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

  @override
  bool? applyEntry;

  @override
  String? driverEmail;

  @override
  int? driverId;

  @override
  String? driverIdentification;

  @override
  String? driverName;

  @override
  String? driverPhone;
}
