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
      this.discountId,
      this.discountName,
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
      this.returnQuantity,
      this.tax18,
      this.tax16,
      this.tax3,
      this.net18,
      this.net16,
      this.net3,
      this.exemptAmount,
      this.indicadorFacturacion,
      this.indicadorAgentePercepcion,
      this.price});

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
      'tax18': tax18,
      'tax16': tax16,
      'tax3': tax3,
      'net18': net18,
      'net16': net16,
      'net3': net3,
      'exemptAmount': exemptAmount,
      'indicadorFacturacion': indicadorFacturacion,
      'indicadorAgentePercepcion': indicadorAgentePercepcion
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
        discountId: map['discountId'],
        discountName: map['discountName'],
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
        retentionTaxId: map['retentionTaxId'],
        tax18: map['tax18'] != null ? double.parse(map['tax18']) : null,
        tax16: map['tax16'] != null ? double.parse(map['tax16']) : null,
        tax3: map['tax3'] != null ? double.parse(map['tax3']) : null,
        net18: map['net18'] != null ? double.parse(map['net18']) : null,
        net16: map['net16'] != null ? double.parse(map['net16']) : null,
        net3: map['net3'] != null ? double.parse(map['net3']) : null,
        exemptAmount: map['exemptAmount'] != null
            ? double.parse(map['exemptAmount'])
            : null,
        indicadorFacturacion: map['indicadorFacturacion'],
        indicadorAgentePercepcion: map['indicadorAgentePercepcion'],
        price: double.parse(map['price']));
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
  Map<String, dynamic> toDisplayReceipt() {
    return {
      'CANT': quantity.toString(),
      'DESCRIPCION': serviceName,
      'PRECIO': (net! / quantity!).toCoin(),
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

  @override
  double? exemptAmount;

  @override
  int? indicadorAgentePercepcion;

  @override
  int? indicadorFacturacion;

  @override
  double? net16;

  @override
  double? net18;

  @override
  double? net3;

  @override
  double? tax16;

  @override
  double? tax18;

  @override
  double? tax3;

  @override
  double get precio {
    return price ?? 0;
  }

  @override
  double? price;

  @override
  String? discountName;
}
