import 'dart:convert';

import 'package:uresax_invoice_sys/models/sale.item.abs.dart';
import 'package:uresax_invoice_sys/utils/extensions.dart';

class CreditNoteService implements SaleItem {
  @override
  String? id;
  @override
  int? serviceId;
  @override
  double? discount;
  @override
  double? net;
  @override
  double? tax;
  @override
  double? total;
  @override
  double? retentionTax;
  @override
  double? retentionIsr;
  @override
  String? saleId;
  @override
  String? creditNoteId;
  @override
  int? quantity;

  CreditNoteService(
      {this.id,
      this.productId,
      this.serviceId,
      this.discount,
      this.net,
      this.tax,
      this.total,
      this.retentionTax,
      this.retentionIsr,
      this.saleId,
      this.creditNoteId,
      this.quantity,
      this.serviceName,
      this.productName,
      this.licensePlate,
      this.taxId,
      this.retentionIsrId,
      this.retentionTaxId,
      this.chassis,
      this.discountId,
      this.enabled = true,
      this.returnQuantity});

  @override
  int? productId;

  @override
  int? discountId;

  @override
  int? taxId;

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceId': serviceId,
      'discount': discount,
      'net': net,
      'tax': tax,
      'total': total,
      'retentionTax': retentionTax,
      'retentionIsr': retentionIsr,
      'creditNoteId': creditNoteId,
      'quantity': quantity,
      'taxId': taxId,
      'retentionTaxId': retentionTaxId,
      'retentionIsrId': retentionIsrId,
      'discountId': discountId
    };
  }

  @override
  String? retentionIsrId;

  @override
  int? retentionTaxId;

  CreditNoteService copyWith({
    String? id,
    int? serviceId,
    double? discount,
    double? net,
    double? tax,
    double? total,
    double? retentionTax,
    double? retentionIsr,
    String? saleId,
    String? creditNoteId,
    int? quantity,
  }) {
    return CreditNoteService(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      discount: discount ?? this.discount,
      net: net ?? this.net,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      retentionTax: retentionTax ?? this.retentionTax,
      retentionIsr: retentionIsr ?? this.retentionIsr,
      saleId: saleId ?? this.saleId,
      creditNoteId: creditNoteId ?? this.creditNoteId,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CreditNoteService.fromMap(Map<String, dynamic> map) {
    return CreditNoteService(
      id: map['id'],
      serviceId: map['serviceId'],
      serviceName: map['serviceName'],
      productId: map['productId'],
      productName: map['productName'],
      discount: map['discount'] != null ? double.parse(map['discount']) : null,
      net: double.parse(map['net']),
      tax: double.parse(map['tax']),
      total: double.parse(map['total']),
      retentionTax: double.parse(map['retentionTax']),
      retentionIsr: double.parse(map['retentionIsr']),
      saleId: map['saleId'],
      creditNoteId: map['creditNoteId'],
      quantity: map['quantity'],
      licensePlate: map['licensePlate'],
      taxId: map['taxId'],
      discountId: map['discountId'],
      retentionTaxId: map['retentionTaxId'],
      retentionIsrId: map['retentionIsrId'],
      chassis: map['chassis'],
      enabled: true,
    );
  }

  String toJson() => json.encode(toMap());

  factory CreditNoteService.fromJson(String source) =>
      CreditNoteService.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CreditNoteService(id: $id, serviceId: $serviceId, discount: $discount, net: $net, tax: $tax, total: $total, retentionTax: $retentionTax, retentionIsr: $retentionIsr, saleId: $saleId, creditNoteId: $creditNoteId, quantity: $quantity)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is CreditNoteService &&
        o.id == id &&
        o.serviceId == serviceId &&
        o.discount == discount &&
        o.net == net &&
        o.tax == tax &&
        o.total == total &&
        o.retentionTax == retentionTax &&
        o.retentionIsr == retentionIsr &&
        o.saleId == saleId &&
        o.creditNoteId == creditNoteId &&
        o.quantity == quantity;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        serviceId.hashCode ^
        discount.hashCode ^
        net.hashCode ^
        tax.hashCode ^
        total.hashCode ^
        retentionTax.hashCode ^
        retentionIsr.hashCode ^
        saleId.hashCode ^
        creditNoteId.hashCode ^
        quantity.hashCode;
  }

  @override
  Map<String, dynamic> toDisplay() {
    return {
      'CANTIDAD': quantity.toString(),
      'DESCRIPCION': serviceName,
      'PRECIO UNITARIO': (net! / quantity!).toCoin(),
      'ITBIS': tax?.toCoin(),
      'TOTAL': total?.toCoin() ?? ''
    };
  }

  @override
  String? serviceName;

  @override
  String? productName;

  @override
  String? chassis;

  @override
  String? licensePlate;

  @override
  bool? enabled;

  @override
  int? returnQuantity;
}
