import 'dart:convert';

import 'package:uresax_invoice_sys/models/sale.item.abs.dart';
import 'package:uresax_invoice_sys/utils/extensions.dart';

class SaleItemService implements SaleItem {
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

  SaleItemService(
      {this.id,
      this.serviceId,
      this.productId,
      this.discount = 0,
      this.net = 0,
      this.tax = 0,
      this.total = 0,
      this.retentionTax = 0,
      this.retentionIsr = 0,
      this.saleId,
      this.creditNoteId,
      this.quantity = 1,
      this.serviceName,
      this.productName,
      this.taxId,
      this.retentionIsrId,
      this.retentionTaxId,
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
      'saleId': saleId,
      'quantity': quantity,
      'discountId': discountId,
      'taxId': taxId,
      'retentionTaxId': retentionTaxId,
      'retentionIsrId': retentionIsrId,
    };
  }

  @override
  String? retentionIsrId;

  @override
  int? retentionTaxId;

  SaleItemService copyWith({
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
    return SaleItemService(
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

  factory SaleItemService.fromMap(Map<String, dynamic> map) {
    return SaleItemService(
        id: map['id'],
        serviceId: map['serviceId'],
        discount:
            map['discount'] != null ? double.parse(map['discount']) : null,
        net: map['net'] != null ? double.parse(map['net']) : null,
        tax: map['tax'] != null ? double.parse(map['tax']) : null,
        total: map['total'] != null ? double.parse(map['total']) : null,
        retentionTax: map['retentionTax'] != null
            ? double.parse(map['retentionTax'])
            : null,
        retentionIsr: map['retentionIsr'] != null
            ? double.parse(map['retentionIsr'])
            : null,
        saleId: map['saleId'],
        creditNoteId: map['creditNoteId'],
        quantity: map['quantity'],
        serviceName: map['serviceName'],
        productName: map['productName'],
        taxId: map['taxId'],
        retentionIsrId: map['retentionIsrId'],
        retentionTaxId: map['retentionTaxId']);
  }

  String toJson() => json.encode(toMap());

  factory SaleItemService.fromJson(String source) =>
      SaleItemService.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SaleItemService(id: $id, serviceId: $serviceId, discount: $discount, net: $net, tax: $tax, total: $total, retentionTax: $retentionTax, retentionIsr: $retentionIsr, saleId: $saleId, creditNoteId: $creditNoteId, quantity: $quantity)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is SaleItemService &&
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
