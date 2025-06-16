import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';

class TaxPayer {
  String? taxPayerId;
  String? taxPayerCompanyName;
  TaxPayer({
    this.taxPayerId,
    this.taxPayerCompanyName,
  });

  static Future<TaxPayer?> findById(String identification) async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute(
          Sql.named(
              'select * from public."TaxPayer" where "tax_payerId" = @id'),
          parameters: {'id': identification});

      if (result != null && result.length == 1) {
        return TaxPayer.fromMap(result.first.toColumnMap());
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  TaxPayer copyWith({
    String? taxPayerId,
    String? taxPayerCompanyName,
  }) {
    return TaxPayer(
      taxPayerId: taxPayerId ?? this.taxPayerId,
      taxPayerCompanyName: taxPayerCompanyName ?? this.taxPayerCompanyName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taxPayerId': taxPayerId,
      'taxPayerCompanyName': taxPayerCompanyName,
    };
  }

  factory TaxPayer.fromMap(Map<String, dynamic> map) {
    return TaxPayer(
      taxPayerId: map['tax_payerId'],
      taxPayerCompanyName: map['tax_payer_company_name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TaxPayer.fromJson(String source) =>
      TaxPayer.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'TaxPayer(taxPayerId: $taxPayerId, taxPayerCompanyName: $taxPayerCompanyName)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is TaxPayer &&
        o.taxPayerId == taxPayerId &&
        o.taxPayerCompanyName == taxPayerCompanyName;
  }

  @override
  int get hashCode => taxPayerId.hashCode ^ taxPayerCompanyName.hashCode;
}
