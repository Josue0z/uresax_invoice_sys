import 'dart:convert';

import 'package:uresax_invoice_sys/models/sale.item.abs.dart';
import 'package:uresax_invoice_sys/utils/extensions.dart';

class SaleItemProduct implements SaleItem {
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

  SaleItemProduct(
      {this.id,
      this.productId,
      this.serviceId,
      this.discount = 0,
      this.net = 0,
      this.tax = 0,
      this.total = 0,
      this.retentionTax = 0,
      this.retentionIsr = 0,
      this.saleId,
      this.creditNoteId,
      this.quantity = 1,
      this.productName,
      this.chassis,
      this.licensePlate,
      this.taxId,
      this.retentionIsrId,
      this.retentionTaxId,
      this.discountId,
      this.serviceName,
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
      'productId': productId,
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
      'retentionIsrId': retentionIsrId
    };
  }

  @override
  String? retentionIsrId;

  @override
  int? retentionTaxId;

  @override
  Map<String, dynamic> toDisplay() {
    String description = productName ?? '';

    if (chassis != null) {
      description = '$productName\nCHASIS: $chassis\nPLACA: $licensePlate';
    }
    return {
      'CANTIDAD': quantity.toString(),
      'DESCRIPCION': description,
      'PRECIO UNITARIO': (net! / quantity!).toCoin(),
      'ITBIS': tax?.toCoin(),
      'TOTAL': total?.toCoin() ?? ''
    };
  }

  @override
  String? serviceName;

  SaleItemProduct copyWith({
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
    return SaleItemProduct(
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

  factory SaleItemProduct.fromMap(Map<String, dynamic> map) {
    return SaleItemProduct(
        id: map['id'],
        productId: map['productId'],
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
        quantity: map['quantity'],
        productName: map['productName'],
        chassis: map['chassis'],
        licensePlate: map['licensePlate'],
        taxId: map['taxId'],
        retentionIsrId: map['retentionIsrId'],
        retentionTaxId: map['retentionTaxId']);
  }

  String toJson() => json.encode(toMap());

  factory SaleItemProduct.fromJson(String source) =>
      SaleItemProduct.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SaleItemProduct(id: $id, serviceId: $serviceId, discount: $discount, net: $net, tax: $tax, total: $total, retentionTax: $retentionTax, retentionIsr: $retentionIsr, saleId: $saleId, creditNoteId: $creditNoteId, quantity: $quantity)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is SaleItemProduct &&
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
