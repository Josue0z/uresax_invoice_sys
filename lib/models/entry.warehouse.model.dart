import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';
import 'package:uresax_invoice_sys/models/entry.warehouse.item.model.dart';
import 'package:uresax_invoice_sys/models/warehouse.obj.dart';
import 'package:uuid/uuid.dart';

class EntryWareHouseModel implements WareHouseElement<EntryWareHouseItemModel> {
  @override
  String? id;
  @override
  String? entryId;
  @override
  int? entryNum;
  @override
  String? ordenId;
  @override
  int? ordenNum;
  @override
  double? net;
  @override
  double? tax;
  @override
  double? total;
  @override
  DateTime? createdAt;
  @override
  List<EntryWareHouseItemModel>? items;
  @override
  double? amountPaid;
  @override
  String? authorId;
  @override
  String? authorName;
  EntryWareHouseModel(
      {this.id,
      this.entryNum,
      this.ordenId,
      this.ordenNum,
      this.net,
      this.tax,
      this.total,
      this.createdAt,
      this.items,
      this.amountPaid,
      this.authorId,
      this.authorName,
      this.applyEntry,
      this.driverId,
      this.driverName,
      this.driverIdentification,
      this.driverPhone,
      this.driverEmail});

  static Future<List<EntryWareHouseModel>> get() async {
    try {
      final conne = SqlConector.connection;
      var result =
          await conne?.execute('select * from public."EntriesWareHousesView"');
      return result
              ?.map((e) => EntryWareHouseModel.fromMap(e.toColumnMap()))
              .toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<EntryWareHouseItemModel>> getItems([TxSession? tx]) async {
    try {
      final conne = tx ?? SqlConector.connection;

      var result = await conne?.execute(
          Sql.named(
              'select * from public."EntriesWareHouseItemsView" where "entryId" = @entryId order by "createdAt"'),
          parameters: {'entryId': id});
      return result
              ?.map(
                (e) => EntryWareHouseItemModel.fromMap(e.toColumnMap()),
              )
              .toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<EntryWareHouseModel?> create() async {
    try {
      EntryWareHouseModel? entry;
      var parameters = toMap();

      String entryId = Uuid().v4();

      parameters['id'] = ordenId;

      parameters.remove('createdAt');
      parameters.remove('ordenNum');
      parameters.remove('entryNum');
      parameters.remove('items');
      parameters.remove('authorName');

      final conne = SqlConector.connection;

      await conne?.runTx((transaction) async {
        var result = await transaction.execute(
            Sql.named(
                '''insert into public."EntriesWareHouses"(id, "ordenId", net, tax, total,"amountPaid","authorId","driverId") values(@id, @ordenId, @net, @tax, @total,@amountPaid,@authorId,@driverId) RETURNING *'''),
            parameters: parameters);

        entry = EntryWareHouseModel.fromMap(result.first.toColumnMap());

        for (var item in items ?? [] as List<EntryWareHouseItemModel>) {
          item.id = Uuid().v4();
          item.entryId = entryId;
          await item.create(transaction);
        }
        await transaction.execute(
            Sql.named(
                '''update public."OrdenPurchases" set "applyEntry" = true where id = @ordenId'''),
            parameters: {'ordenId': ordenId});

        id = entryId;

        entry?.items = await getItems(transaction);
      });
      return entry;
    } catch (e) {
      rethrow;
    }
  }

  EntryWareHouseModel copyWith({
    String? id,
    int? entryNum,
    String? ordenId,
    int? ordenNum,
    double? net,
    double? tax,
    double? total,
    DateTime? createdAt,
    List<EntryWareHouseItemModel>? items,
    double? amountPaid,
    String? authorId,
    String? authorName,
  }) {
    return EntryWareHouseModel(
      id: id ?? this.id,
      entryNum: entryNum ?? this.entryNum,
      ordenId: ordenId ?? this.ordenId,
      ordenNum: ordenNum ?? this.ordenNum,
      net: net ?? this.net,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      amountPaid: amountPaid ?? this.amountPaid,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entryNum': entryNum,
      'ordenId': ordenId,
      'ordenNum': ordenNum,
      'net': net,
      'tax': tax,
      'total': total,
      'createdAt': createdAt,
      'items': items?.map((x) => x.toMap()).toList(),
      'amountPaid': amountPaid,
      'authorId': authorId,
      'authorName': authorName,
      'driverId': driverId
    };
  }

  factory EntryWareHouseModel.fromMap(Map<String, dynamic> map) {
    return EntryWareHouseModel(
        id: map['id'],
        entryNum: map['entryNum'],
        ordenId: map['ordenId'],
        ordenNum: map['ordenNum'],
        net: double.parse(map['net']),
        tax: double.parse(map['tax']),
        total: double.parse(map['total']),
        createdAt: map['createdAt'],
        items: map['items'] != null
            ? (map['items'] as List)
                .map((x) => EntryWareHouseItemModel?.fromMap(x))
                .toList()
                .cast<EntryWareHouseItemModel>()
            : [],
        amountPaid: double.parse(map['amountPaid']),
        authorId: map['authorId'],
        authorName: map['authorName'],
        driverId: map['driverId'],
        driverName: map['driverName'],
        driverIdentification: map['driverIdentification'],
        driverEmail: map['driverEmail'],
        driverPhone: map['driverPhone']);
  }

  String toJson() => json.encode(toMap());

  factory EntryWareHouseModel.fromJson(String source) =>
      EntryWareHouseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EntryWareHouseModel(id: $id, entryNum: $entryNum, ordenId: $ordenId, ordenNum: $ordenNum, net: $net, tax: $tax, total: $total, createdAt: $createdAt, items: $items, amountPaid: $amountPaid, authorId: $authorId, authorName: $authorName, driverId: $driverId, driverName: $driverName, driverIdentification: $driverIdentification, driverPhone: $driverPhone, driverEmail: $driverEmail)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is EntryWareHouseModel &&
        o.id == id &&
        o.ordenId == ordenId &&
        o.ordenNum == ordenNum &&
        o.net == net &&
        o.tax == tax &&
        o.total == total &&
        o.createdAt == createdAt &&
        listEquals(o.items, items) &&
        o.amountPaid == amountPaid &&
        o.authorId == authorId &&
        o.authorName == authorName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        ordenId.hashCode ^
        ordenNum.hashCode ^
        net.hashCode ^
        tax.hashCode ^
        total.hashCode ^
        createdAt.hashCode ^
        items.hashCode ^
        amountPaid.hashCode ^
        authorId.hashCode ^
        authorName.hashCode;
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
