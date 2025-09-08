import 'package:postgres/postgres.dart';

abstract class WareHouseElement<T> {
  String? id;
  String? ordenId;
  int? ordenNum;
  String? entryId;
  int? entryNum;
  double? net;
  double? tax;
  double? total;
  DateTime? createdAt;
  List<T>? items;
  double? amountPaid;
  String? authorId;
  String? authorName;
  bool? applyEntry;
  int? driverId;
  String? driverName;
  String? driverIdentification;
  String? driverPhone;
  String? driverEmail;

  static Future<List<WareHouseElement>> get() async {
    throw UnimplementedError();
  }

  Future<List<WareHouseElementItem>> getItems() async {
    throw UnimplementedError();
  }

  Future<WareHouseElement?> create() async {
    throw UnimplementedError();
  }
}

abstract class WareHouseElementItem {
  String? id;
  String? ordenId;
  String? entryId;
  int? productId;
  String? productName;
  int? providerId;
  String? providerName;
  int? quantity;
  int? units;
  double? price;
  double? net;
  double? discount;
  double? tax;
  double? total;
  DateTime? createdAt;

  Future<WareHouseElementItem?> create([TxSession? transaction]) async {
    throw UnimplementedError();
  }

  Map<String, dynamic> toDisplay() {
    throw UnimplementedError();
  }

  Map<String, dynamic> toDisplayReceipt() {
    throw UnimplementedError();
  }
}
