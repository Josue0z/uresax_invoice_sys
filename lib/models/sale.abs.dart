import 'dart:ui';

import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';
import 'package:uresax_invoice_sys/models/credit.note.product.dart';
import 'package:uresax_invoice_sys/models/credit.note.service.dart';
import 'package:uresax_invoice_sys/models/sale.item.abs.dart';
import 'package:uresax_invoice_sys/models/sale.product.dart';
import 'package:uresax_invoice_sys/models/sale.service.dart';
import 'package:uresax_invoice_sys/settings.dart';

abstract class Sale {
  String? id;
  String? clientId;
  String? ncf;
  String? ncfAffected;
  double? discount;
  double? net;
  double? tax;
  double? total;
  double? effective;
  double? creditCard;
  double? checkOrTransf;
  double? saleToCredit;
  double? law10;
  String? typeIncomeId;
  String? typeIncomeName;
  int? clientType;
  String? clientTypeName;
  DateTime? createdAt;
  double? retentionTax;
  double? retentionIsr;
  int? paymentMethodId;
  String? paymentMethodName;
  String? ncfTypeId;
  String? ncfTypeName;
  String? saleId;
  String? description;
  String? clientName;
  DateTime? retentionDate;
  String? prefix;
  int? invoiceTypeId;
  double? amountPaid;
  double? debt;
  List<SaleItem> items = [];

  double? paid;

  int? bankId;
  String? transfRef;

  int? currencyId;
  double? rate;

  int? maxSequence;

  bool get isPaid {
    throw UnimplementedError();
  }

  String get paidLabel {
    throw UnimplementedError();
  }

  Color get color {
    throw UnimplementedError();
  }

  static Future<Sale?> findById(String id) async {
    throw UnimplementedError();
  }

  static Future<List<Sale>> get() async {
    throw UnimplementedError();
  }

  static Future<List<Sale>> getSales607Form() async {
    throw UnimplementedError();
  }

  Future<List<SaleItem>> getSaleData() async {
    throw UnimplementedError();
  }

  Future<Sale?> create() async {
    throw UnimplementedError();
  }

  Future<Sale?> update() async {
    throw UnimplementedError();
  }

  Future<Sale?> paySale(double amount) {
    throw UnimplementedError();
  }

  Future<Sale?> delete() async {
    throw UnimplementedError();
  }

  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }

  Map<String, dynamic> toMapInsert() {
    throw UnimplementedError();
  }

  Map<String, dynamic> toDisplay() {
    throw UnimplementedError();
  }

  Map<String, dynamic> to607() {
    throw UnimplementedError();
  }
}

Future<List<Sale>> getSales(
    {String? ncfTypeId,
    String? search,
    SaleStatus? saleStatus,
    required DateTime startDate,
    required DateTime endDate}) async {
  try {
    String params = '';

    var parameters = {
      'date1': startDate.toIso8601String(),
      'date2': endDate.toIso8601String(),
    };

    if (ncfTypeId != null) {
      params = 'and "ncfTypeId" = @ncfTypeId';
      parameters.addAll({'ncfTypeId': ncfTypeId});
    }

    if (search != null) {
      params += ' and "ncf" like @ncf';
      parameters.addAll({'ncf': '%$search%'});
    }

    if (saleStatus == SaleStatus.paid) {
      params += ' and "debt" = 0';
    }

    if (saleStatus == SaleStatus.notPaid) {
      params += ' and "debt" > 0';
    }

    final conne = SqlConector.connection;
    var result = await conne?.execute(
        Sql.named(
            'select * from public."SalesView" where "createdAt" between @date1 and @date2 $params order by "ncf"'),
        parameters: parameters);
    return result
            ?.map((e) => e.toColumnMap()['invoiceTypeId'] == 1
                ? SaleService.fromMap(e.toColumnMap())
                : SaleProduct.fromMap(e.toColumnMap()))
            .toList() ??
        [];
  } catch (e) {
    rethrow;
  }
}

Future<List<Sale>> getCreditNotes(
    {required DateTime startDate,
    required DateTime endDate,
    String? search}) async {
  try {
    final conne = SqlConector.connection;
    String params = '';

    var parameters = {
      'date1': startDate.toIso8601String(),
      'date2': endDate.toIso8601String()
    };

    if (search != null) {
      params += ' and ("ncf" like @ncf or "ncfAffected" like @ncf)';

      parameters.addAll({'ncf': '%$search%'});
    }
    var result = await conne?.execute(
        Sql.named(
            'select * from public."CreditNotesView" where "createdAt" between @date1 and @date2 $params'),
        parameters: parameters);
    return result
            ?.map((e) => e.toColumnMap()['invoiceTypeId'] == 1
                ? CreditNoteAsService.fromMap(e.toColumnMap())
                : CreditNoteAsProduct.fromMap(e.toColumnMap()))
            .toList() ??
        [];
  } catch (e) {
    rethrow;
  }
}

Future<List<Map<String, dynamic>>> getSalesTypeIncomesReport(
    {String? ncfTypeId,
    required DateTime startDate,
    required DateTime endDate}) async {
  try {
    String params = '';

    var parameters = {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String()
    };

    if (ncfTypeId != null) {
      params = 'and "ncfTypeId" = @ncfTypeId';
      parameters.addAll({
        'ncfTypeId': ncfTypeId,
      });
    }
    final conne = SqlConector.connection;

    var res = await conne?.execute(Sql.named('''
  WITH Totales AS (
    SELECT
        "ncfTypeName" AS "NCF",
        count(*) AS "TOTAL NCFS",
        COALESCE(sum(net), 0) AS "TOTAL NETO", 
        COALESCE(sum(tax), 0) AS "ITBIS FACTURADO", 
        COALESCE(sum(total), 0) AS "TOTAL FACTURADO", 
        COALESCE(sum(effective), 0) AS "EFECTIVO", 
        COALESCE(sum("creditCard"), 0) AS "TARJETA DE CREDITO O DEBITO",
        COALESCE(sum("checkOrTransf"), 0) AS "CHEQUE O TRANSFERENCIA",
        COALESCE(sum("saleToCredit"), 0) AS "VENTA A CREDITO", 
        COALESCE(sum(law10), 0) AS "MONTO PROPINA LEGAL",
        COALESCE(sum("retentionTax"), 0) AS "RETENCION ITBIS", 
        COALESCE(sum("retentionIsr"), 0) AS "RETENCION ISR"
    FROM public."SalesView"
    WHERE "createdAt" BETWEEN @startDate AND @endDate $params
    GROUP BY "ncfTypeId", "ncfTypeName"

    UNION ALL

    SELECT
        "ncfTypeName" AS "NCF",
        count(*) AS "TOTAL NCFS",
        -COALESCE(sum(net), 0) AS "TOTAL NETO", 
        -COALESCE(sum(tax), 0) AS "ITBIS FACTURADO", 
        -COALESCE(sum(total), 0) AS "TOTAL FACTURADO", 
        -COALESCE(sum(effective), 0) AS "EFECTIVO", 
        -COALESCE(sum("creditCard"), 0) AS "TARJETA DE CREDITO O DEBITO",
        -COALESCE(sum("checkOrTransf"), 0) AS "CHEQUE O TRANSFERENCIA",
        -COALESCE(sum("saleToCredit"), 0) AS "VENTA A CREDITO", 
        -COALESCE(sum(law10), 0) AS "MONTO PROPINA LEGAL",
        -COALESCE(sum("retentionTax"), 0) AS "RETENCION ITBIS", 
        -COALESCE(sum("retentionIsr"), 0) AS "RETENCION ISR"
    FROM public."CreditNotesView"
    WHERE "createdAt" BETWEEN @startDate AND @endDate $params
    GROUP BY "ncfTypeId", "ncfTypeName"
)

  SELECT
    "ncfTypeName" AS "NCF",
    count(*) as "TOTAL NCFS",
    COALESCE(sum(net), 0)::money::text as "TOTAL NETO", 
    COALESCE(sum(tax), 0)::money::text as "ITBIS FACTURADO", 
    COALESCE(sum(total), 0)::money::text as "TOTAL FACTURADO", 
    COALESCE(sum(effective), 0)::money::text as "EFECTIVO", 
    COALESCE(sum("creditCard"), 0)::money::text as "TARJETA DE CREDITO O DEBITO",
    COALESCE(sum("checkOrTransf"), 0)::money::text as "CHEQUE O TRANSFERENCIA",
    COALESCE(sum("saleToCredit"), 0)::money::text as  "VENTA A CREDITO", 
    COALESCE(sum(law10), 0)::money::text as "MONTO PROPINA LEGAL",
    COALESCE(sum("retentionTax"), 0)::money::text as "RETENCION ITBIS", 
    COALESCE(sum("retentionIsr"), 0)::money::text as "RETENCION ISR"
FROM public."SalesView"
WHERE "createdAt" BETWEEN @startDate AND @endDate $params
GROUP BY "ncfTypeId","ncfTypeName"
UNION ALL
SELECT
    "ncfTypeName" AS "NCF",
    count(*) as "TOTAL NCFS",
    COALESCE(sum(net), 0)::money::text as "TOTAL NETO", 
    COALESCE(sum(tax), 0)::money::text as "ITBIS FACTURADO", 
    COALESCE(sum(total), 0)::money::text as "TOTAL FACTURADO", 
    COALESCE(sum(effective), 0)::money::text as "EFECTIVO", 
    COALESCE(sum("creditCard"), 0)::money::text as "TARJETA DE CREDITO O DEBITO",
    COALESCE(sum("checkOrTransf"), 0)::money::text as "CHEQUE O TRANSFERENCIA",
    COALESCE(sum("saleToCredit"), 0)::money::text as  "VENTA A CREDITO", 
    COALESCE(sum(law10), 0)::money::text as "MONTO PROPINA LEGAL",
    COALESCE(sum("retentionTax"), 0)::money::text as "RETENCION ITBIS", 
    COALESCE(sum("retentionIsr"), 0)::money::text as "RETENCION ISR"
FROM public."CreditNotesView"
WHERE "createdAt" BETWEEN @startDate AND @endDate $params
GROUP BY  "ncfTypeId","ncfTypeName"
UNION ALL
SELECT
    'TOTAL GENERAL' AS "NCF",
    SUM("TOTAL NCFS"),
    SUM("TOTAL NETO")::money::text,
    SUM("ITBIS FACTURADO")::money::text,
    SUM("TOTAL FACTURADO")::money::text,
    SUM("EFECTIVO")::money::text,
    SUM("TARJETA DE CREDITO O DEBITO")::money::text,
    SUM("CHEQUE O TRANSFERENCIA")::money::text,
    SUM("VENTA A CREDITO")::money::text,
    SUM("MONTO PROPINA LEGAL")::money::text,
    SUM("RETENCION ITBIS")::money::text,
    SUM("RETENCION ISR")::money::text
FROM Totales;
 '''), parameters: parameters);

    return res?.map((e) => e.toColumnMap()).toList() ?? [];
  } catch (e) {
    rethrow;
  }
}

Future<List<Sale>> getSalesList({String? search, int? invoiceTypeId}) async {
  try {
    String params = '';

    var parameters = {};

    if (search != null) {
      parameters.addAll({'search': '%$search%'});
      params += ' and ncf like @search';
    }

    if (invoiceTypeId != null) {
      parameters.addAll({'invoiceTypeId': invoiceTypeId});
      params += ' and "invoiceTypeId" = @invoiceTypeId';
    }

    final conne = SqlConector.connection;
    var result = await conne?.execute(
        Sql.named(
            '''select * from public."SalesView" where  ("ncfTypeId" = '01' or "ncfTypeId" = '15') $params order by "ncfTypeId" '''),
        parameters: parameters);
    return result
            ?.map((e) => e.toColumnMap()['invoiceTypeId'] == 1
                ? SaleService.fromMap(e.toColumnMap())
                : SaleProduct.fromMap(e.toColumnMap()))
            .toList() ??
        [];
  } catch (e) {
    rethrow;
  }
}

Future<List<Sale>> getSalesListByIdAndNcf(
    {String? rncOrId, String? ncf, int? invoiceTypeId}) async {
  try {
    String params = '';

    var parameters = {};

    if (ncf != null) {
      parameters.addAll({'ncf': ncf, 'rncOrId': rncOrId});

      params += ' and ncf = @ncf and "clientId" = @rncOrId';
    }

    if (invoiceTypeId != null) {
      parameters.addAll({'invoiceTypeId': invoiceTypeId});
      params += ' and "invoiceTypeId" = @invoiceTypeId';
    }

    final conne = SqlConector.connection;
    var result = await conne?.execute(
        Sql.named(
            '''select * from public."SalesView" where  ("ncfTypeId" = '01' or "ncfTypeId" = '15') $params order by "ncfTypeId" '''),
        parameters: parameters);
    return result
            ?.map((e) => e.toColumnMap()['invoiceTypeId'] == 1
                ? SaleService.fromMap(e.toColumnMap())
                : SaleProduct.fromMap(e.toColumnMap()))
            .toList() ??
        [];
  } catch (e) {
    rethrow;
  }
}

Future<void> calcDifOfNetsNcfs(String ncf) async {
  try {
    final conne = SqlConector.connection;
    var res = await conne?.execute(Sql.named('''
         select * from public."Sales607Form" where "ncfAffected" = @ncf
    '''), parameters: {'ncf': ncf});

    if (res != null && res.isNotEmpty) {
      throw 'EL COMPROBANTE $ncf YA FUE ANULADO';
    }
  } catch (e) {
    rethrow;
  }
}
