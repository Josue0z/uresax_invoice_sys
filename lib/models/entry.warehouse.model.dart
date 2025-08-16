import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uresax_invoice_sys/models/entry.warehouse.item.model.dart';

class EntryWareHouseModel {
  String? id;
  String? ordenId;
  int? ordenNum;
  double? net;
  double? tax;
  double? total;
  DateTime? createdAt;
  List<EntryWareHouseItemModel>? items;
  double? amountPaid;
  String? authorId;
  String? authorName;
  EntryWareHouseModel({
    this.id,
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
  });

  EntryWareHouseModel copyWith({
    String? id,
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
      'ordenId': ordenId,
      'ordenNum': ordenNum,
      'net': net,
      'tax': tax,
      'total': total,
      'createdAt': createdAt,
      'items': items?.map((x) => x.toMap()).toList(),
      'amountPaid': amountPaid,
      'authorId': authorId,
      'authorName': authorName
    };
  }

  factory EntryWareHouseModel.fromMap(Map<String, dynamic> map) {
    return EntryWareHouseModel(
      id: map['id'],
      ordenId: map['ordenId'],
      ordenNum: map['ordenNum'],
      net: double.parse(map['net']),
      tax: double.parse(map['tax']),
      total: double.parse(map['total']),
      createdAt: map['createdAt'],
      items: (map['items'] as List)
          .map((x) => EntryWareHouseItemModel?.fromMap(x))
          .toList()
          .cast<EntryWareHouseItemModel>(),
      amountPaid: double.parse(map['amountPaid']),
      authorId: map['authorId'],
      authorName: map['authorName'],
    );
  }

  String toJson() => json.encode(toMap());

  factory EntryWareHouseModel.fromJson(String source) =>
      EntryWareHouseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EntryWareHouseModel(id: $id, ordenId: $ordenId, ordenNum: $ordenNum, net: $net, tax: $tax, total: $total, createdAt: $createdAt, items: $items, amountPaid: $amountPaid, authorId: $authorId, authorName: $authorName)';
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
}
