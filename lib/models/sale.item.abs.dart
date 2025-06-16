abstract class SaleItem {
  String? id;
  int? serviceId;
  int? productId;
  double? discount;
  double? net;
  double? tax;
  double? total;
  double? retentionTax;
  double? retentionIsr;
  String? saleId;
  String? creditNoteId;
  int? quantity;
  int? taxId;
  int? discountId;
  int? retentionTaxId;
  String? retentionIsrId;
  String? serviceName;
  String? productName;
  String? chassis;
  String? licensePlate;
  bool? enabled;
  int? returnQuantity;

  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }

  Map<String, dynamic> toDisplay() {
    throw UnimplementedError();
  }
}
