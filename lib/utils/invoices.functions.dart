import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uresax_invoice_sys/models/orden.model.dart';
import 'package:uresax_invoice_sys/models/payment.dart';
import 'package:uresax_invoice_sys/models/sale.abs.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/extensions.dart';

Future<pw.Font> loadMaterialIconsFont() async {
  final fontData =
      await rootBundle.load("assets/fonts/MaterialIcons-Regular.ttf");
  return pw.Font.ttf(fontData);
}

pw.Document createDefaultInvoice(Sale sale) {
  var document = pw.Document();
  // Generar código QR
  final qr = pw.Barcode.qrCode();

  List<String> columns() {
    return sale.items[0].toDisplay().keys.toList();
  }

  document.addPage(pw.MultiPage(header: (ctx) {
    return pw.Column(children: [
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Expanded(
            flex: 2,
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(children: [
                    company?.logo != null
                        ? pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                                pw.Image(
                                    pw.MemoryImage(
                                        base64Decode(company!.logo!)),
                                    width: 80),
                                pw.SizedBox(width: kDefaultPadding / 2),
                              ])
                        : pw.SizedBox(),
                    pw.Text(company?.name ?? '',
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ]),
                  pw.SizedBox(height: kDefaultPadding / 2),
                  pw.Text(company?.rncOrId ?? '',
                      style: pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: kDefaultPadding / 2),
                  pw.Text(company?.address ?? '',
                      style: pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: kDefaultPadding / 2),
                  pw.Text(company?.phone1 ?? '',
                      style: pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: kDefaultPadding / 2),
                  pw.Text(company?.email ?? '',
                      style: pw.TextStyle(fontSize: 10))
                ])),
      ]),
      pw.SizedBox(height: kDefaultPadding),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Expanded(
          child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Facturado a:', style: pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: kDefaultPadding / 2),
                pw.Text(sale.clientName ?? '',
                    style: pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: kDefaultPadding / 2),
                pw.Text('Rnc/Cedula:', style: pw.TextStyle(fontSize: 10)),
                pw.SizedBox(height: kDefaultPadding / 2),
                pw.Text(sale.clientId ?? '', style: pw.TextStyle(fontSize: 10)),
              ]),
        ),
        pw.Expanded(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
              pw.Text(sale.ncfTypeName ?? '',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.SizedBox(height: kDefaultPadding),
              pw.Container(
                margin: pw.EdgeInsets.only(bottom: kDefaultPadding / 2),
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Factura #',
                        style: pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.right,
                      ),
                      pw.SizedBox(width: kDefaultPadding),
                      pw.Text(
                        sale.ncf ?? '',
                        style: pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.right,
                      )
                    ]),
              ),
              sale.ncfAffected != null
                  ? pw.Container(
                      margin: pw.EdgeInsets.only(
                        bottom: kDefaultPadding / 2,
                      ),
                      child: pw.Text(sale.ncfAffected ?? '',
                          style: pw.TextStyle(fontSize: 10)))
                  : pw.SizedBox(),
              pw.Container(
                margin: pw.EdgeInsets.symmetric(
                  vertical: kDefaultPadding / 2,
                ),
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Fecha',
                        style: pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.right,
                      ),
                      pw.SizedBox(width: kDefaultPadding),
                      pw.Text(
                        sale.createdAt?.format(payload: 'DD/MM/YYYY') ?? '',
                        style: pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.right,
                      )
                    ]),
              ),
              sale.retentionDate != null
                  ? pw.Container(
                      margin: pw.EdgeInsets.only(bottom: kDefaultPadding / 2),
                      child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                            pw.Text('Fecha de Retencion',
                                style: pw.TextStyle(fontSize: 10),
                                textAlign: pw.TextAlign.right),
                            pw.SizedBox(width: kDefaultPadding),
                            pw.Text(
                                sale.retentionDate?.format(
                                      payload: 'DD/MM/YYYY',
                                    ) ??
                                    '',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(fontSize: 10)),
                          ]))
                  : pw.SizedBox(),
              sale.expirationDate != null
                  ? pw.Container(
                      child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.end,
                          children: [
                          pw.Text('Fecha de Vencimiento',
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(fontSize: 10)),
                          pw.SizedBox(width: kDefaultPadding),
                          pw.Text(
                              sale.expirationDate
                                      ?.format(payload: 'DD/MM/YYYY') ??
                                  '',
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(fontSize: 10))
                        ]))
                  : pw.SizedBox()
            ]))
      ]),
    ]);
  }, build: (ctx) {
    return [
      pw.SizedBox(height: kDefaultPadding),
      pw.Table(children: [
        pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColor.fromHex('#343a40')),
            children: List.generate(columns().length, (index) {
              var col = columns()[index];

              return pw.Padding(
                  padding: pw.EdgeInsets.all(kDefaultPadding / 3),
                  child: pw.Text(col,
                      style:
                          pw.TextStyle(color: PdfColors.white, fontSize: 9)));
            })),
        ...List.generate(sale.items.length, (index) {
          var item = sale.items[index];
          var values = item.toDisplay().values.toList();
          return pw.TableRow(
              decoration: pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(color: PdfColor.fromHex('#e6e6e6')))),
              children: List.generate(values.length, (i) {
                var val = values[i];
                return pw.Padding(
                    padding: pw.EdgeInsets.all(kDefaultPadding / 2),
                    child: pw.Text(val, style: pw.TextStyle(fontSize: 8)));
              }));
        })
      ]),
      pw.SizedBox(height: kDefaultPadding),
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Expanded(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
              pw.Text(sale.description ?? '', style: pw.TextStyle(fontSize: 8)),
              pw.SizedBox(height: kDefaultPadding),
              pw.SizedBox(
                  width: 100,
                  height: 100,
                  child: pw.BarcodeWidget(
                      data: sale.dgiiURL != null
                          ? sale.dgiiURL ?? ''
                          : sale.ncf ?? '',
                      barcode: qr)),
              pw.SizedBox(height: kDefaultPadding / 2),
              sale.securityCode != null
                  ? pw.Container(
                      margin: pw.EdgeInsets.symmetric(
                          vertical: kDefaultPadding / 4),
                      child: pw.Row(children: [
                        pw.Text('Codigo de seguridad:',
                            style: pw.TextStyle(
                                fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(width: 5),
                        pw.Text(sale.securityCode ?? '',
                            style: pw.TextStyle(fontSize: 9)),
                      ]))
                  : pw.SizedBox(),
              sale.signatureDate != null
                  ? pw.Container(
                      margin: pw.EdgeInsets.symmetric(
                          vertical: kDefaultPadding / 4),
                      child: pw.Row(children: [
                        pw.Text('Fecha de Firma:',
                            style: pw.TextStyle(
                                fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(width: 5),
                        pw.Text(
                            sale.signatureDate
                                    ?.format(payload: 'DD-MM-YYYY HH:mm:ss') ??
                                '',
                            style: pw.TextStyle(fontSize: 9)),
                      ]))
                  : pw.SizedBox(),
              sale.authorName != null
                  ? pw.Container(
                      margin: pw.EdgeInsets.symmetric(
                          vertical: kDefaultPadding / 4),
                      child: pw.Row(children: [
                        pw.Text('Atendido por:',
                            style: pw.TextStyle(
                                fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(width: 5),
                        pw.Text(sale.authorName ?? '',
                            style: pw.TextStyle(fontSize: 9)),
                      ]))
                  : pw.SizedBox()
            ])),
        pw.Expanded(
            child: pw.Column(children: [
          pw.Container(
              margin: pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
              decoration: pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(color: PdfColor.fromHex('#e6e6e6')))),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Subtotal', style: pw.TextStyle(fontSize: 8)),
                    pw.Text(
                        sale.currencyId == 1
                            ? sale.net?.toDop()
                            : sale.net?.toUS() ?? '',
                        style: pw.TextStyle(fontSize: 8))
                  ])),
          pw.Container(
              margin: pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
              decoration: pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(color: PdfColor.fromHex('#e6e6e6')))),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Descuento', style: pw.TextStyle(fontSize: 8)),
                    pw.Text(
                        sale.currencyId == 1
                            ? sale.discount?.toDop()
                            : sale.discount?.toUS() ?? '',
                        style: pw.TextStyle(fontSize: 8))
                  ])),
          pw.Container(
              margin: pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
              decoration: pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(color: PdfColor.fromHex('#e6e6e6')))),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Itbis', style: pw.TextStyle(fontSize: 8)),
                    pw.Text(
                        sale.currencyId == 1
                            ? sale.tax?.toDop()
                            : sale.tax?.toUS() ?? '',
                        style: pw.TextStyle(fontSize: 8))
                  ])),
          pw.Container(
              margin: pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
              decoration: pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(color: PdfColor.fromHex('#e6e6e6')))),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total', style: pw.TextStyle(fontSize: 8)),
                    pw.Text(
                        sale.currencyId == 1
                            ? sale.total?.toDop()
                            : sale.total?.toUS() ?? '',
                        style: pw.TextStyle(fontSize: 8))
                  ])),
          pw.Container(
              margin: pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
              decoration: pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(color: PdfColor.fromHex('#e6e6e6')))),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Retencion Itbis',
                        style: pw.TextStyle(fontSize: 8)),
                    pw.Text(
                        sale.currencyId == 1
                            ? sale.retentionTax?.toDop()
                            : sale.retentionTax?.toUS() ?? '',
                        style: pw.TextStyle(fontSize: 8))
                  ])),
          pw.Container(
              margin: pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
              decoration: pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(color: PdfColor.fromHex('#e6e6e6')))),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Retencion Isr', style: pw.TextStyle(fontSize: 8)),
                    pw.Text(
                        sale.currencyId == 1
                            ? sale.retentionIsr?.toDop()
                            : sale.retentionIsr?.toUS() ?? '',
                        style: pw.TextStyle(fontSize: 8))
                  ])),
          pw.Container(
              margin: pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
              decoration: pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(color: PdfColor.fromHex('#e6e6e6')))),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                        sale.ncfTypeId!.contains('34')
                            ? 'Total a devolver'
                            : 'Total a pagar',
                        style: pw.TextStyle(fontSize: 8)),
                    pw.Text(
                        sale.currencyId == 1
                            ? (sale.total! -
                                    (sale.retentionIsr! + sale.retentionTax!))
                                .toDop()
                            : sale.amountPaid?.toUS() ?? '',
                        style: pw.TextStyle(fontSize: 8))
                  ])),
          pw.Container(
              margin: pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
              decoration: pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(color: PdfColor.fromHex('#e6e6e6')))),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Pagado', style: pw.TextStyle(fontSize: 8)),
                    pw.Text(
                        sale.currencyId == 1
                            ? sale.amountPaid?.toDop()
                            : sale.amountPaid?.toUS() ?? '',
                        style: pw.TextStyle(fontSize: 8))
                  ])),
        ]))
      ])
    ];
  }, footer: (ctx) {
    return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(children: [
            pw.Container(width: 150, height: 0.5, color: PdfColors.black),
            pw.SizedBox(height: kDefaultPadding / 2),
            pw.Text('Recibido por', style: pw.TextStyle(fontSize: 8))
          ]),
          pw.SizedBox(width: kDefaultPadding),
          pw.Column(children: [
            pw.Container(width: 150, height: 0.5, color: PdfColors.black),
            pw.SizedBox(height: kDefaultPadding / 2),
            pw.Text('Entregado por', style: pw.TextStyle(fontSize: 8))
          ]),
        ]);
  }));
  return document;
}

pw.Document createDefaultOrdenPurchase(OrdenModel orden) {
  var document = pw.Document();
  // Generar código QR
  // final qr = Barcode.qrCode();

  List<String> columns() {
    return orden.items![0].toDisplay().keys.toList();
  }

  document.addPage(pw.MultiPage(header: (ctx) {
    return pw.Column(children: [
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Expanded(
            flex: 2,
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(children: [
                    company?.logo != null
                        ? pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.start,
                            children: [
                                pw.Image(
                                    pw.MemoryImage(
                                        base64Decode(company!.logo!)),
                                    width: 80),
                                pw.SizedBox(width: kDefaultPadding / 2),
                              ])
                        : pw.SizedBox(),
                    pw.Text(company?.name ?? '',
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ]),
                  pw.SizedBox(height: kDefaultPadding / 2),
                  pw.Text(company?.rncOrId ?? '',
                      style: pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: kDefaultPadding / 2),
                  pw.Text(company?.address ?? '',
                      style: pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: kDefaultPadding / 2),
                  pw.Text(company?.phone1 ?? '',
                      style: pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: kDefaultPadding / 2),
                  pw.Text(company?.email ?? '',
                      style: pw.TextStyle(fontSize: 10))
                ])),
        pw.Expanded(
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
              pw.Text('ORDEN DE COMPRA',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.SizedBox(height: kDefaultPadding),
              pw.Container(
                margin: pw.EdgeInsets.only(bottom: kDefaultPadding / 2),
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Orden #',
                        style: pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.right,
                      ),
                      pw.SizedBox(width: kDefaultPadding),
                      pw.Text(
                        orden.ordenNum.toString(),
                        style: pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.right,
                      )
                    ]),
              ),
              pw.Container(
                margin: pw.EdgeInsets.symmetric(
                  vertical: kDefaultPadding / 2,
                ),
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Fecha',
                        style: pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.right,
                      ),
                      pw.SizedBox(width: kDefaultPadding),
                      pw.Text(
                        orden.createdAt?.format(payload: 'DD/MM/YYYY') ?? '',
                        style: pw.TextStyle(fontSize: 10),
                        textAlign: pw.TextAlign.right,
                      )
                    ]),
              ),
            ]))
      ]),
    ]);
  }, build: (ctx) {
    return [
      pw.SizedBox(height: kDefaultPadding),
      pw.Table(children: [
        pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColor.fromHex('#343a40')),
            children: List.generate(columns().length, (index) {
              var col = columns()[index];

              return pw.Padding(
                  padding: pw.EdgeInsets.all(kDefaultPadding / 4),
                  child: pw.Text(col,
                      style:
                          pw.TextStyle(color: PdfColors.white, fontSize: 6)));
            })),
        ...List.generate(orden.items?.length ?? 0, (index) {
          var item = orden.items?[index];
          var values = item?.toDisplay().values.toList();
          return pw.TableRow(
              decoration: pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(color: PdfColor.fromHex('#e6e6e6')))),
              children: List.generate(values?.length ?? 0, (i) {
                var val = values?[i];
                return pw.Padding(
                    padding: pw.EdgeInsets.all(kDefaultPadding / 4),
                    child: pw.Text(val, style: pw.TextStyle(fontSize: 6)));
              }));
        })
      ]),
      pw.SizedBox(height: kDefaultPadding),
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Expanded(child: pw.Container()),
        pw.Expanded(
            child: pw.Column(children: [
          pw.Container(
              margin: pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
              decoration: pw.BoxDecoration(
                  border: pw.Border(
                      bottom:
                          pw.BorderSide(color: PdfColor.fromHex('#e6e6e6')))),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total a Pagar', style: pw.TextStyle(fontSize: 8)),
                    pw.Text(orden.total?.toDop() ?? '',
                        style: pw.TextStyle(fontSize: 8))
                  ])),
        ]))
      ])
    ];
  }, footer: (ctx) {
    return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(children: [
            pw.Container(width: 150, height: 0.5, color: PdfColors.black),
            pw.SizedBox(height: kDefaultPadding / 2),
            pw.Text('Recibido por', style: pw.TextStyle(fontSize: 8))
          ]),
          pw.SizedBox(width: kDefaultPadding),
          pw.Column(children: [
            pw.Container(width: 150, height: 0.5, color: PdfColors.black),
            pw.SizedBox(height: kDefaultPadding / 2),
            pw.Text('Entregado por', style: pw.TextStyle(fontSize: 8))
          ]),
        ]);
  }));
  return document;
}

Future<pw.Document> createPaymentInvoice(Payment payment) async {
  var document = pw.Document();

  var materialFonts = await loadMaterialIconsFont();

  document.addPage(pw.MultiPage(
      margin: pw.EdgeInsets.all(kDefaultPadding * 3),
      mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      theme: pw.ThemeData.withFont(
        icons: materialFonts, // Carga la fuente de íconos
      ),
      build: (ctx) {
        return [
          pw.Center(
              child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Column(children: [
                        pw.Icon(
                          pw.IconData(0xe86c),
                          size: 200,
                          color: PdfColor.fromHex('#7BC113'),
                        ),
                        pw.SizedBox(height: kDefaultPadding),
                        pw.Text(
                            payment.currencyId == 1
                                ? payment.amount?.toDop()
                                : payment.amount?.toUS(),
                            style: pw.TextStyle(fontSize: 28)),
                        pw.SizedBox(height: kDefaultPadding),
                        pw.Text('COMPROBANTE DE PAGO',
                            style: pw.TextStyle(fontSize: 24)),
                      ])
                    ]),
                pw.SizedBox(height: kDefaultPadding * 4),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Fecha', style: pw.TextStyle(fontSize: 12)),
                      pw.Text(
                          payment.createdAt
                                  ?.toLocal()
                                  .format(payload: 'DD/MM/YYYY hh:mm:ss A') ??
                              '',
                          style: pw.TextStyle(fontSize: 12)),
                    ]),
                pw.Divider(),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Cliente', style: pw.TextStyle(fontSize: 12)),
                      pw.Text(payment.clientName ?? 'S/N',
                          style: pw.TextStyle(fontSize: 12)),
                    ]),
                pw.Divider(),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Banco', style: pw.TextStyle(fontSize: 12)),
                      pw.Text(payment.bankName ?? 'S/N',
                          style: pw.TextStyle(fontSize: 12)),
                    ]),
                pw.Divider(),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Forma de Pago',
                          style: pw.TextStyle(fontSize: 12)),
                      pw.Text(payment.paymentMethodName ?? '',
                          style: pw.TextStyle(fontSize: 12)),
                    ]),
                pw.Divider(),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Numero de cheque o transferencia',
                          style: pw.TextStyle(fontSize: 12)),
                      pw.Text(payment.transfRef ?? 'S/N',
                          style: pw.TextStyle(fontSize: 12)),
                    ]),
                pw.Divider(),
              ]))
        ];
      }));
  return document;
}

pw.Document createVerticalInvoice(Sale sale) {
  // Generar código QR
  final qr = pw.Barcode.qrCode();

  List<String> columns() {
    return sale.items[0].toDisplay().keys.toList();
  }

  List<pw.Widget> paymentsWidgets = [];

  if (sale.effective != 0) {
    paymentsWidgets.add(pw.Container(
        margin: pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 3),
        child: pw.Text('EFECTIVO', style: pw.TextStyle(fontSize: 8))));
  }

  if (sale.creditCard != 0) {
    paymentsWidgets.add(pw.Container(
        margin: pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 3),
        child: pw.Text('TARJETA DE CREDITO O DEBITO',
            style: pw.TextStyle(fontSize: 8))));
  }

  if (sale.checkOrTransf != 0) {
    paymentsWidgets.add(pw.Container(
        margin: pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 3),
        child: pw.Text('CHEQUE O TRANSFERENCIA',
            style: pw.TextStyle(fontSize: 8))));
  }

  if (sale.saleToCredit != 0) {
    paymentsWidgets.add(pw.Container(
        margin: pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 3),
        child: pw.Text('VENTA A CREDITO', style: pw.TextStyle(fontSize: 8))));
  }

  pw.Document document = pw.Document(
      theme: pw.ThemeData(defaultTextStyle: pw.TextStyle(fontSize: 8)));
  document.addPage(pw.MultiPage(
      margin: pw.EdgeInsets.symmetric(horizontal: 150, vertical: 60),
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      orientation: pw.PageOrientation.portrait,
      header: (ctx) {
        return pw
            .Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Column(children: [
                pw.Text(company?.name ?? '',
                    style: pw.TextStyle(
                        fontSize: 13, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: kDefaultPadding / 2),
                pw.Text('RNC: ${company?.rncOrId}')
              ])),
          pw.SizedBox(height: kDefaultPadding),
          pw.Container(
              margin: pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 3),
              child: pw.Text('Razon Social Cliente: ${sale.clientName}')),
          pw.Container(
              margin: pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 3),
              child: pw.Text('Rnc Cliente: ${sale.clientId}')),
          pw.Container(
              margin: pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 3),
              child: pw.Text(
                  'Fecha Emision: ${sale.createdAt?.format(payload: 'DD/MM/YYYY')}')),
          pw.Container(
              margin: pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 3),
              child: pw.Text('NCF: ${sale.ncf}')),
          sale.ncfAffected != null
              ? pw.Container(
                  margin:
                      pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 3),
                  child: pw.Text('NCF AFECTADO: ${sale.ncfAffected}'))
              : pw.SizedBox(),
          pw.Divider(color: PdfColor.fromHex('#9E9D9D'), height: 0.3),
          pw.Container(
            margin: pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 4),
            child: pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(sale.ncfTypeName ?? '',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 6))),
          ),
          pw.Divider(color: PdfColor.fromHex('#9E9D9D'), height: 0.3),
        ]);
      },
      build: (ctx) {
        return [
          pw.Table(children: [
            pw.TableRow(
                decoration: pw.BoxDecoration(
                    border: pw.Border(
                        bottom:
                            pw.BorderSide(color: PdfColor.fromHex('#e6e6e6')))),
                children: List.generate(columns().length, (index) {
                  var col = columns()[index];

                  return pw.Padding(
                      padding: pw.EdgeInsets.all(kDefaultPadding / 3),
                      child: pw.Text(col,
                          style: pw.TextStyle(
                              color: PdfColors.black, fontSize: 5)));
                })),
            ...List.generate(sale.items.length, (index) {
              var item = sale.items[index];
              var values = item.toDisplay().values.toList();
              return pw.TableRow(
                  decoration: pw.BoxDecoration(
                      border: pw.Border(
                          bottom: pw.BorderSide(
                              color: PdfColor.fromHex('#e6e6e6')))),
                  children: List.generate(values.length, (i) {
                    var val = values[i];
                    return pw.Padding(
                        padding: pw.EdgeInsets.all(kDefaultPadding / 3),
                        child: pw.Text(val, style: pw.TextStyle(fontSize: 5)));
                  }));
            })
          ]),
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                      pw.Container(
                          margin: pw.EdgeInsets.symmetric(
                              vertical: kDefaultPadding / 2),
                          child: pw.Text('Forma de pagos:',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      ...paymentsWidgets
                    ])),
                pw.Expanded(
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                      pw.Container(
                          margin: pw.EdgeInsets.symmetric(
                              vertical: kDefaultPadding / 2),
                          child: pw.Text('Subtotal: ${sale.net?.toCoin()}')),
                      pw.Container(
                          margin: pw.EdgeInsets.symmetric(
                              vertical: kDefaultPadding / 2),
                          child:
                              pw.Text('Descuento: ${sale.discount?.toCoin()}')),
                      pw.Container(
                          margin: pw.EdgeInsets.symmetric(
                              vertical: kDefaultPadding / 2),
                          child: pw.Text('Itbis: ${sale.tax?.toCoin()}')),
                      pw.Container(
                          margin: pw.EdgeInsets.symmetric(
                              vertical: kDefaultPadding / 2),
                          child: pw.Text('Total: ${sale.total?.toCoin()}'))
                    ]))
              ]),
          pw.SizedBox(height: kDefaultPadding),
          pw.Column(children: [
            pw.Container(
                width: 100,
                height: 100,
                margin: pw.EdgeInsets.symmetric(vertical: kDefaultPadding),
                child: pw.BarcodeWidget(
                    data: sale.dgiiURL != null
                        ? sale.dgiiURL ?? ''
                        : sale.ncf ?? '',
                    barcode: qr)),
            sale.securityCode != null
                ? pw.Container(
                    margin:
                        pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 4),
                    child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('Codigo de seguridad:',
                              style: pw.TextStyle(
                                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(width: 5),
                          pw.Text(sale.securityCode ?? '',
                              style: pw.TextStyle(fontSize: 9)),
                        ]))
                : pw.SizedBox(),
            sale.signatureDate != null
                ? pw.Container(
                    margin:
                        pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 4),
                    child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('Fecha de Firma:',
                              style: pw.TextStyle(
                                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(width: 5),
                          pw.Text(
                              sale.signatureDate?.format(
                                      payload: 'DD-MM-YYYY HH:mm:ss') ??
                                  '',
                              style: pw.TextStyle(fontSize: 9)),
                        ]))
                : pw.SizedBox(),
            sale.authorName != null
                ? pw.Container(
                    margin:
                        pw.EdgeInsets.symmetric(vertical: kDefaultPadding / 4),
                    child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text('Atendido por:',
                              style: pw.TextStyle(
                                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(width: 5),
                          pw.Text(sale.authorName ?? '',
                              style: pw.TextStyle(fontSize: 9)),
                        ]))
                : pw.SizedBox()
          ])
        ];
      }));

  return document;
}

Future<List<int>> createDefaultTicket(
    {String name = 'default', required Sale sale}) async {
  // Using default profile
  final profile = await CapabilityProfile.load(name: name);
  final generator = Generator(PaperSize.mm80, profile);
  List<int> bytes = [];
  generator.setStyles(PosStyles(width: PosTextSize.size6));

  createDivider() {
    final divider = '-' * 48; // Para mm80
    bytes += generator.text(divider, styles: PosStyles(align: PosAlign.center));
  }

  bytes += generator.text(company?.name ?? '',
      styles: PosStyles(bold: true, align: PosAlign.center));

  bytes += generator.text(company?.rncOrId ?? '',
      styles: PosStyles(align: PosAlign.center));

  bytes += generator.emptyLines(1);

  bytes += generator.text('Rnc/Cedula: ${sale.clientId}',
      styles: PosStyles(align: PosAlign.left));
  bytes += generator.text('Cliente: ${sale.clientName}',
      styles: PosStyles(align: PosAlign.left));
  bytes +=
      generator.text(sale.ncf ?? '', styles: PosStyles(align: PosAlign.left));

  if (sale.ncfAffected != null) {
    bytes += generator.text(sale.ncfAffected ?? '',
        styles: PosStyles(align: PosAlign.left));
  }
  bytes += generator.text(
      'Fecha de Emision: ${sale.createdAt?.format(payload: 'DD/MM/YYYY')}',
      styles: PosStyles(align: PosAlign.left));

  createDivider();

  bytes += generator.text(sale.ncfTypeName ?? '',
      styles: PosStyles(align: PosAlign.center, bold: true));

  createDivider();

  var cols = sale.items[0].toDisplayReceipt().keys.toList();
  bytes += generator.row(List.generate(cols.length, (i) {
    var e = cols[i];
    return PosColumn(text: e, width: i == 1 ? 4 : 2);
  }));
  createDivider();

  for (var item in sale.items) {
    var values = item.toDisplayReceipt().values.toList();

    bytes += generator.row(List.generate(values.length, (i) {
      var w = i == 0
          ? 1
          : i == 1
              ? 5
              : 2;
      var e = values[i];

      return PosColumn(text: e, width: w);
    }));

    createDivider();
  }

  bytes += generator.emptyLines(2);

  List<String> paymentsMethods = [];

  List<String> calcs = [
    'TOTAL NETO: ${sale.net?.toDop()}',
    'DESCUENTO: ${sale.discount?.toDop()}',
    'TOTAL ITBIS: ${sale.tax?.toDop()}',
    'TOTAL FACTURADO: ${sale.total?.toDop()}'
  ];

  if (sale.effective != 0) {
    paymentsMethods.add('EFECTIVO');
  }

  if (sale.creditCard != 0) {
    paymentsMethods.add('TARJETA DE CREDITO O DEBITO');
  }
  if (sale.checkOrTransf != 0) {
    paymentsMethods.add('CHEQUE O TRANSFERENCIA');
  }

  if (sale.saleToCredit != 0) {
    paymentsMethods.add('VENTA A CREDITO');
  }

  final maxLines = max(paymentsMethods.length, calcs.length);

  for (int i = 0; i < maxLines; i++) {
    final leftText = i < paymentsMethods.length ? paymentsMethods[i] : '';

    String? label;
    String? value;

    if (i < calcs.length) {
      final parts = calcs[i].split(':');
      label = parts.length > 1 ? '${parts[0].trim()}' : calcs[i];
      value = parts.length > 1 ? parts[1].trim() : '';
    }

    bytes += generator.row([
      PosColumn(
        text: leftText,
        width: 4,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: label ?? '',
        width: 4,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: value ?? '',
        width: 4,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
  }

  bytes += generator.emptyLines(5);

  bytes += generator.qrcode(sale.dgiiURL ?? sale.ncf ?? '',
      align: PosAlign.center, size: QRSize.size7);
  bytes += generator.emptyLines(1);

  if (sale.signatureDate != null) {
    bytes += generator.text('Codigo de Seguridad: ${sale.securityCode}',
        styles: PosStyles(align: PosAlign.center));

    bytes += generator.text(
        'Fecha de Firma: ${sale.signatureDate?.format(payload: 'DD-MM-YYYY HH:mm:ss')}',
        styles: PosStyles(align: PosAlign.center));
  }

  bytes += generator.feed(2);
  bytes += generator.cut();

  return bytes;
}
