import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';
import 'package:uuid/uuid.dart';

class Payment {
  String? id;
  String? saleId;
  int? paymentMethodId;
  double? amount;
  DateTime? createdAt;
  String? clientName;
  String? ncf;
  String? paymentMethodName;
  int? bankId;
  String? bankName;
  String? transfRef;
  int? currencyId;

  Payment(
      {this.id,
      this.saleId,
      this.paymentMethodId,
      this.amount,
      this.createdAt,
      this.clientName,
      this.ncf,
      this.paymentMethodName,
      this.bankId,
      this.bankName,
      this.transfRef,
      this.currencyId});

  static Future<List<Payment>> get({required String saleId}) async {
    try {
      final conne = SqlConector.connection;
      var res = await conne?.execute(
          Sql.named(
              'select * from public."PaymentsView" where "saleId" = @saleId'),
          parameters: {'saleId': saleId});

      return res?.map((e) => Payment.fromMap(e.toColumnMap())).toList() ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Payment?> create() async {
    try {
      final conne = SqlConector.connection;
      var res = await conne?.execute(
          Sql.named(
              '''insert into public."Payments" (id,"saleId","paymentMethodId",amount) values(@id,@saleId,@paymentMethodId,@amount) returning *'''),
          parameters: {
            'id': Uuid().v4(),
            'saleId': saleId,
            'paymentMethodId': paymentMethodId,
            'amount': amount
          });
      var el = res?[0];

      if (el != null) {
        return Payment.fromMap(el.toColumnMap());
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Payment copyWith({
    String? id,
    String? saleId,
    int? paymentMethodId,
    double? amount,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'saleId': saleId,
      'paymentMethodId': paymentMethodId,
      'amount': amount,
      'createdAt': createdAt
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
        id: map['id'],
        saleId: map['saleId'],
        paymentMethodId: map['paymentMethodId'],
        amount: double.parse(map['amount']),
        createdAt: map['createdAt'],
        clientName: map['clientName'],
        ncf: map['ncf'],
        paymentMethodName: map['paymentMethodName'],
        bankId: map['bankId'],
        bankName: map['bankName'],
        transfRef: map['transfRef'],
        currencyId: map['currencyId']);
  }

  String toJson() => json.encode(toMap());

  factory Payment.fromJson(String source) =>
      Payment.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Payment(id: $id, saleId: $saleId, paymentMethodId: $paymentMethodId, amount: $amount, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Payment &&
        o.id == id &&
        o.saleId == saleId &&
        o.paymentMethodId == paymentMethodId &&
        o.amount == amount &&
        o.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        saleId.hashCode ^
        paymentMethodId.hashCode ^
        amount.hashCode ^
        createdAt.hashCode;
  }
}
