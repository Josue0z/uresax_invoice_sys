
import 'dart:ui';

import 'package:moment_dart/moment_dart.dart';
import 'package:pdf/pdf.dart';
import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';
import 'package:uresax_invoice_sys/models/credit.note.product.dart';
import 'package:uresax_invoice_sys/models/credit.note.service.dart';
import 'package:uresax_invoice_sys/models/sale.item.abs.dart';
import 'package:uresax_invoice_sys/models/sale.product.dart';
import 'package:uresax_invoice_sys/models/sale.service.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:pdf/widgets.dart' as pw;

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
  double? coinBack;
  List<SaleItem> items = [];

  double? paid;

  int? bankId;
  String? transfRef;

  int? currencyId;
  double? rate;

  int? maxSequence;

  double? tax18;

  double? tax16;

  double? tax3;

  double? net18;

  double? net16;

  double? net3;

  double? exemptAmount;

  DateTime? signatureDate;

  String? securityCode;

  String? dgiiURL;

  String? ecfXmlFirmado;

  int? estadoDgii;

  int? tipoPago;

  DateTime? expirationDate;

  String? authorId;

  String? authorName;

  int? ncfSeq;

  String? estadoDgiiNombre;

  DateTime? ncfAffectedCreatedAt;

  String? clientAddress;

  double? paidInvoice;

  bool get isPaid {
    throw UnimplementedError();
  }

  String get paidLabel {
    throw UnimplementedError();
  }

  Color get color {
    throw UnimplementedError();
  }

  Color get statusColorDgii {
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

  Future<void> updateStock() async {
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

  Future<void> updateEcfInfo() async {}
}

Future<List<Sale>> getSales(
    {String? ncfTypeId,
    List<String>? ncfsTypes,
    String? search,
    SaleStatus? saleStatus,
    int? estadoDgii,
    required DateTime startDate,
    required DateTime endDate}) async {
  try {
    String params = '';

    var parameters = {
      'date1': startDate.toIso8601String(),
      'date2': endDate.toIso8601String(),
    };

    if (ncfsTypes != null && ncfsTypes.isNotEmpty) {
      params += ' "ncfTypeId" = ANY(@ncfsTypes) and ';
      parameters.addAll({'ncfsTypes': '{${ncfsTypes.join(',')}}'});
    }
    if (estadoDgii != null) {
      params += ' "estadoDgii" = @estadoDgii and ';
      parameters.addAll({'estadoDgii': estadoDgii.toString()});
    }

    if (search != null) {
      params +=
          ' lower("ncf") like @ncf or lower("clientName") like @clientName and ';
      parameters.addAll({
        'ncf': '%${search.toLowerCase()}%',
        'clientName': '%${search.toLowerCase()}%'
      });
    }

    if (saleStatus == SaleStatus.paid) {
      params += ' and "debt" = 0';
    }

    if (saleStatus == SaleStatus.notPaid) {
      params += ' and "debt" > 0';
    }

    final conne = SqlConector.connection;
    var qr =
        'select * from public."SalesView" where $params ("createdAt" between @date1 and @date2) order by "ncf"';

    var result = await conne?.execute(Sql.named(qr), parameters: parameters);
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
      params +=
          ' (lower("ncf") like @ncf or lower("clientName") like @clientName or lower("ncfAffected") like @ncfAffected) and ';

      parameters.addAll({
        'ncf': '%${search.toLowerCase()}%',
        'ncfAffected': '%${search.toLowerCase()}%',
        'clientName': '%${search.toLowerCase()}%'
      });
    }
    var result = await conne?.execute(
        Sql.named(
            'select * from public."CreditNotesView" where  $params ("createdAt" between @date1 and @date2) order by ncf'),
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

Future<Map<String, dynamic>> getSalesTypeIncomesReport({
  String? ncfTypeId,
  List<String>? ncfsTypes,
  int? estadoDgii,
  required DateTime startDate,
  required DateTime endDate,
}) async {
  try {
    String params = '';
    var parameters = {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String()
    };

    if (ncfsTypes != null && ncfsTypes.isNotEmpty) {
      params += ' and "ncfTypeId" = ANY(@ncfsTypes)  ';
      parameters.addAll({'ncfsTypes': '{${ncfsTypes.join(',')}}'});
    }
    if (estadoDgii != null) {
      params += ' and "estadoDgii" = @estadoDgii';
      parameters['estadoDgii'] = estadoDgii.toString();
    }

    final conne = SqlConector.connection;

    var res = await conne?.execute(Sql.named('''
      WITH Movimientos AS (
        SELECT
          "typeIncomeId",
          "typeIncomeName",
          net, tax, total, effective,
          "creditCard", "checkOrTransf", "saleToCredit",
          law10, "retentionTax", "retentionIsr",rate,
          1 AS signo
        FROM public."SalesView"
        WHERE "createdAt" BETWEEN @startDate AND @endDate $params

        UNION ALL

        SELECT
          "typeIncomeId",
          "typeIncomeName",
          net, tax, total, effective,
          "creditCard", "checkOrTransf", "saleToCredit",
          law10, "retentionTax", "retentionIsr",rate,
          -1 AS signo
        FROM public."CreditNotesView"
        WHERE "createdAt" BETWEEN @startDate AND @endDate $params
      )

      SELECT * FROM (
        SELECT
          "typeIncomeName" AS "TIPO DE INGRESO",
          COUNT(*) AS "TOTAL NCFS",
          COALESCE(SUM((net * rate) * signo), 0)::money::text AS "TOTAL NETO",
          COALESCE(SUM((tax * rate) * signo), 0)::money::text AS "ITBIS FACTURADO",
          COALESCE(SUM((total * rate) * signo), 0)::money::text AS "TOTAL FACTURADO",
          COALESCE(SUM((effective * rate) * signo), 0)::money::text AS "EFECTIVO",
          COALESCE(SUM(("creditCard" * rate) * signo), 0)::money::text AS "TARJETA DE CREDITO O DEBITO",
          COALESCE(SUM(("checkOrTransf" * rate) * signo), 0)::money::text AS "CHEQUE O TRANSFERENCIA",
          COALESCE(SUM(("saleToCredit" * rate) * signo), 0)::money::text AS "VENTA A CREDITO",
          COALESCE(SUM((law10 * rate) * signo), 0)::money::text AS "MONTO PROPINA LEGAL",
          COALESCE(SUM(("retentionTax" * rate) * signo), 0)::money::text AS "RETENCION ITBIS",
          COALESCE(SUM(("retentionIsr" * rate) * signo), 0)::money::text AS "RETENCION ISR"
        FROM Movimientos
        GROUP BY "typeIncomeId", "typeIncomeName"

        UNION ALL

        SELECT
          'TOTAL GENERAL',
          COUNT(*) AS "TOTAL NCFS",
          COALESCE(SUM((net * rate) * signo), 0)::money::text,
          COALESCE(SUM((tax * rate) * signo), 0)::money::text,
          COALESCE(SUM((total * rate) * signo), 0)::money::text,
          COALESCE(SUM((effective * rate) * signo), 0)::money::text,
          COALESCE(SUM(("creditCard" * rate) * signo), 0)::money::text,
          COALESCE(SUM(("checkOrTransf" * rate) * signo), 0)::money::text,
          COALESCE(SUM(("saleToCredit" * rate) * signo), 0)::money::text,
          COALESCE(SUM((law10 * rate) * signo), 0)::money::text,
          COALESCE(SUM(("retentionTax" * rate) * signo), 0)::money::text,
          COALESCE(SUM(("retentionIsr" * rate) * signo), 0)::money::text
        FROM Movimientos
      ) AS reporte
      ORDER BY "TIPO DE INGRESO"
    '''), parameters: parameters);

    var list = res?.map((e) => e.toColumnMap()).toList() ?? [];
    var columns = list.first.keys.where((k) => k != 'typeIncomeId').toList();

    var doc = pw.Document();
    PdfColor color = PdfColor.fromHex('#CECECE');

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      orientation: pw.PageOrientation.landscape,
      margin: pw.EdgeInsets.all(8),
      theme: pw.ThemeData(defaultTextStyle: pw.TextStyle(fontSize: 5)),
      header: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(company?.name ?? '',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.Text('REPORTE POR TIPO DE INGRESO',
              style:
                  pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.Text(
              'FECHAS: ${startDate.format(payload: 'DD/MM/YYYY')} - ${endDate.format(payload: 'DD/MM/YYYY')}',
              style:
                  pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.Table(
            defaultColumnWidth: pw.FixedColumnWidth(40),
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(
                    border: pw.Border(bottom: pw.BorderSide(color: color))),
                children: columns
                    .map((col) => pw.Padding(
                          padding: pw.EdgeInsets.all(kDefaultPadding / 3),
                          child: pw.Text(col,
                              textAlign: pw.TextAlign.left,
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ))
                    .toList(),
              )
            ],
          )
        ],
      ),
      build: (ctx) => [
        pw.Table(
          defaultVerticalAlignment: pw.TableCellVerticalAlignment.bottom,
          defaultColumnWidth: pw.FixedColumnWidth(40),
          children: list.map((item) {
            var values = columns.map((k) => item[k]).toList();
            bool isTotal = item['TIPO DE INGRESO'] == 'TOTAL GENERAL';
            return pw.TableRow(
              decoration: pw.BoxDecoration(
                color: isTotal ? PdfColor.fromHex('#F0F0F0') : null,
                border: pw.Border(bottom: pw.BorderSide(color: color)),
              ),
              children: values
                  .map((el) => pw.Padding(
                        padding: pw.EdgeInsets.all(kDefaultPadding / 2),
                        child: pw.Text(el.toString(),
                            style: pw.TextStyle(
                              fontWeight: isTotal
                                  ? pw.FontWeight.bold
                                  : pw.FontWeight.normal,
                            ),
                            textAlign: pw.TextAlign.left),
                      ))
                  .toList(),
            );
          }).toList(),
        )
      ],
    ));

    return {'list': list, 'document': doc, 'bytes': await doc.save()};
  } catch (e) {
    rethrow;
  }
}

Future<Map<String, dynamic>> getSalesReportByTypeNcf(
    {String? ncfTypeId,
    List<String>? ncfsTypes,
    int? estadoDgii,
    required DateTime startDate,
    required DateTime endDate}) async {
  try {
    String params = '';

    var parameters = {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String()
    };

    if (ncfsTypes != null && ncfsTypes.isNotEmpty) {
      params += ' and "ncfTypeId" = ANY(@ncfsTypes)  ';
      parameters.addAll({'ncfsTypes': '{${ncfsTypes.join(',')}}'});
    }

    if (estadoDgii != null) {
      params += ' and "estadoDgii" = @estadoDgii';
      parameters.addAll({'estadoDgii': estadoDgii.toString()});
    }

    final conne = SqlConector.connection;

    var res = await conne?.execute(Sql.named('''
 WITH Movimientos AS (
  SELECT
    "ncfTypeId",
    "ncfTypeName",
    net, tax, total, effective,
    "creditCard", "checkOrTransf", "saleToCredit",
    law10, "retentionTax", "retentionIsr", rate,
    1 AS signo
  FROM public."SalesView"
  WHERE "createdAt" BETWEEN @startDate AND @endDate $params

  UNION ALL

  SELECT
    "ncfTypeId",
    "ncfTypeName",
    net, tax, total, effective,
    "creditCard", "checkOrTransf", "saleToCredit",
    law10, "retentionTax", "retentionIsr", rate,
    -1 AS signo
  FROM public."CreditNotesView"
  WHERE "createdAt" BETWEEN @startDate AND @endDate $params
)

SELECT * FROM (
  SELECT
    "ncfTypeName" AS "NCF",
    COUNT(*) AS "TOTAL NCFS",
    COALESCE(SUM((net * rate) * signo),0)::money::text AS "TOTAL NETO",
    COALESCE(SUM((tax * rate) * signo),0)::money::text AS "ITBIS FACTURADO",
    COALESCE(SUM((total * rate) * signo),0)::money::text AS "TOTAL FACTURADO",
    COALESCE(SUM((effective * rate) * signo),0)::money::text AS "EFECTIVO",
    COALESCE(SUM(("creditCard" * rate) * signo),0)::money::text AS "TARJETA DE CREDITO O DEBITO",
    COALESCE(SUM(("checkOrTransf" * rate) * signo),0)::money::text AS "CHEQUE O TRANSFERENCIA",
    COALESCE(SUM(("saleToCredit" * rate) * signo),0)::money::text AS "VENTA A CREDITO",
    COALESCE(SUM((law10 * rate) * signo),0)::money::text AS "MONTO PROPINA LEGAL",
    COALESCE(SUM(("retentionTax" * rate) * signo),0)::money::text AS "RETENCION ITBIS",
    COALESCE(SUM(("retentionIsr" * rate) * signo),0)::money::text AS "RETENCION ISR"
  FROM Movimientos
  GROUP BY "ncfTypeId","ncfTypeName"

  UNION ALL

  SELECT
    'TOTAL GENERAL',
    COUNT(*) AS "TOTAL NCFS",
    COALESCE(SUM((net * rate) * signo),0)::money::text,
    COALESCE(SUM((tax * rate) * signo),0)::money::text,
    COALESCE(SUM((total * rate) * signo),0)::money::text,
    COALESCE(SUM((effective * rate) * signo),0)::money::text,
    COALESCE(SUM(("creditCard" * rate) * signo),0)::money::text,
    COALESCE(SUM(("checkOrTransf" * rate) * signo),0)::money::text,
    COALESCE(SUM(("saleToCredit" * rate) * signo),0)::money::text,
    COALESCE(SUM((law10 * rate) * signo),0)::money::text,
    COALESCE(SUM(("retentionTax" * rate) * signo),0)::money::text,
    COALESCE(SUM(("retentionIsr" * rate) * signo),0)::money::text
  FROM Movimientos
) AS reporte
ORDER BY "NCF";

 '''), parameters: parameters);

    var list = res?.map((e) => e.toColumnMap()).toList() ?? [];

    var columns = list.first.keys.toList();

    var doc = pw.Document();
    PdfColor color = PdfColor.fromHex('#CECECE');
    doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.landscape,
        margin: pw.EdgeInsets.all(8),
        theme: pw.ThemeData(defaultTextStyle: pw.TextStyle(fontSize: 5)),
        header: (ctx) {
          return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  margin: pw.EdgeInsets.symmetric(
                    vertical: kDefaultPadding / 2,
                  ),
                  child: pw.Text(company?.name ?? '',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Container(
                  margin: pw.EdgeInsets.symmetric(
                    vertical: kDefaultPadding / 2,
                  ),
                  child: pw.Text('REPORTE POR TIPO DE NCF',
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Container(
                  margin: pw.EdgeInsets.symmetric(
                    vertical: kDefaultPadding / 2,
                  ),
                  child: pw.Text(
                      'FECHAS: ${startDate.format(payload: 'DD/MM/YYYY')} - ${endDate.format(payload: 'DD/MM/YYYY')}',
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ),
                pw.Table(
                    defaultColumnWidth: pw.FixedColumnWidth(40),
                    children: [
                      pw.TableRow(
                          decoration: pw.BoxDecoration(
                              border: pw.Border(
                                  bottom: pw.BorderSide(color: color))),
                          children: List.generate(columns.length, (index) {
                            var col = columns[index];
                            return pw.Padding(
                                padding: pw.EdgeInsets.all(kDefaultPadding / 3),
                                child:
                                    pw.Text(col, textAlign: pw.TextAlign.left));
                          }))
                    ])
              ]);
        },
        build: (ctx) {
          return [
            pw.Table(
                defaultVerticalAlignment: pw.TableCellVerticalAlignment.bottom,
                defaultColumnWidth: pw.FixedColumnWidth(40),
                children: List.generate(list.length, (i) {
                  var item = list[i];
                  var values = item.values.toList();
                  return pw.TableRow(
                      decoration: pw.BoxDecoration(
                          border:
                              pw.Border(bottom: pw.BorderSide(color: color))),
                      children: List.generate(values.length, (j) {
                        var el = values[j];
                        return pw.Padding(
                            padding: pw.EdgeInsets.all(kDefaultPadding / 2),
                            child: pw.Text(el.toString(),
                                textAlign: pw.TextAlign.left));
                      }));
                }))
          ];
        }));

    return {'list': list, 'document': doc, 'bytes': await doc.save()};
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

      params += ' ncf = @ncf and "clientId" = @rncOrId';
    }

    if (invoiceTypeId != null) {
      parameters.addAll({'invoiceTypeId': invoiceTypeId});
      params += ' and "invoiceTypeId" = @invoiceTypeId';
    }

    final conne = SqlConector.connection;
    var result = await conne?.execute(
        Sql.named(
            '''select * from public."SalesView" where   $params order by "ncfTypeId" '''),
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

Future<void> calcDifOfNetsNcfs(
    {required String ncfAffected,
    required DateTime ncfAffectedCreatedAt,
    required double currentTotal}) async {
  try {
    final conne = SqlConector.connection;
    String date = ncfAffectedCreatedAt.format(payload: 'YYYY-MM-DD');

    var ncfOriginal = await conne?.execute(
        Sql.named(
          '''select * from public."SalesView" WHERE ncf = @ncf and to_char("createdAt",'YYYY-MM-DD') = @createdAt''',
        ),
        parameters: {'ncf': ncfAffected, 'createdAt': date});

    var ncfCreditNote = await conne?.execute(Sql.named('''
         select sum(total)  as "total" from public."CreditNotesView" where "ncfAffected" = @ncfAffected and "estadoDgii" != 2
    '''), parameters: {'ncfAffected': ncfAffected});

    if (ncfCreditNote != null && ncfCreditNote.isNotEmpty) {
      var sale = ncfOriginal?.first.toColumnMap();
      var creditNote = ncfCreditNote.first.toColumnMap();

      var saleTotal = sale?['total'] != null ? double.parse(sale?['total']) : 0;
      var creditNoteTotal =
          creditNote['total'] != null ? double.parse(creditNote['total']) : 0;

      var dif = saleTotal - creditNoteTotal;

      if (dif == 0) {
        throw 'EL COMPROBANTE $ncfAffected YA FUE ANULADO COMPLETAMENTE';
      }
    }
  } catch (e) {
    rethrow;
  }
}

Future<double> getCreditNoteAmountByNcf({
  required String ncfAffected,
  required DateTime ncfAffectedCreatedAt,
}) async {
  try {
    final conne = SqlConector.connection;

    var ncfCreditNote = await conne?.execute(Sql.named('''
         select sum("amountPaid")  as "amountPaid" from public."CreditNotesView" where "ncfAffected" = @ncfAffected and "estadoDgii" != 2
    '''), parameters: {'ncfAffected': ncfAffected});

    if (ncfCreditNote != null && ncfCreditNote.isNotEmpty) {
      var creditNote = ncfCreditNote.first.toColumnMap();

      var creditNoteTotal =
          creditNote['amountPaid'] != null ? double.parse(creditNote['amountPaid'].toString()) : 0;

      return creditNoteTotal.toDouble();
    }
    return 0.0;
  } catch (e) {
    rethrow;
  }
}
