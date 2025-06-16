import 'dart:convert';

import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

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
  final qr = Barcode.qrCode();

  List<String> columns() {
    return sale.items[0].toDisplay().keys.toList();
  }

  String labelInvoice = 'FACTURA';

  if (sale.ncfTypeId == '50') {
    labelInvoice = 'PROFORMA';
  }

  if (sale.ncfTypeId?.contains('4') == true) {
    labelInvoice = 'NOTA DE CREDITO';
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
                      style: pw.TextStyle(fontSize: 12)),
                  pw.SizedBox(height: kDefaultPadding / 2),
                  pw.Text(company?.address ?? ''),
                  pw.SizedBox(height: kDefaultPadding / 2),
                  pw.Text(company?.phone1 ?? ''),
                  pw.SizedBox(height: kDefaultPadding / 2),
                  pw.Text(company?.email ?? '')
                ])),
      ]),
      pw.SizedBox(height: kDefaultPadding),
      pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(labelInvoice,
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 17))),
      pw.SizedBox(height: kDefaultPadding),
      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text('Facturado a:'),
          pw.SizedBox(height: kDefaultPadding / 2),
          pw.Text(sale.clientName ?? ''),
          pw.SizedBox(height: kDefaultPadding / 2),
          pw.Text('Rnc/Cedula:'),
          pw.SizedBox(height: kDefaultPadding / 2),
          pw.Text(sale.clientId ?? ''),
        ]),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Row(children: [
            pw.Text('Factura #'),
            pw.SizedBox(width: kDefaultPadding),
            pw.Text(sale.ncf ?? '')
          ]),
          sale.ncfAffected != null
              ? pw.Column(children: [
                  pw.SizedBox(height: kDefaultPadding / 2),
                  pw.Text(sale.ncfAffected ?? '')
                ])
              : pw.SizedBox(),
          pw.SizedBox(height: kDefaultPadding / 2),
          pw.Row(children: [
            pw.Text('Fecha'),
            pw.SizedBox(width: kDefaultPadding),
            pw.Text(sale.createdAt?.format(payload: 'DD/MM/YYYY') ?? '')
          ])
        ])
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
                  child: pw.BarcodeWidget(data: sale.ncf ?? '', barcode: qr))
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
                    pw.Text('Subtotal', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(
                        sale.currencyId == 1
                            ? sale.net?.toDop()
                            : sale.net?.toUS() ?? '',
                        style: pw.TextStyle(fontSize: 10))
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
                    pw.Text('Descuento', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(
                        sale.currencyId == 1
                            ? sale.discount?.toDop()
                            : sale.discount?.toUS() ?? '',
                        style: pw.TextStyle(fontSize: 10))
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
                    pw.Text('Itbis', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(
                        sale.currencyId == 1
                            ? sale.tax?.toDop()
                            : sale.tax?.toUS() ?? '',
                        style: pw.TextStyle(fontSize: 10))
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
                    pw.Text('Total', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(
                        sale.currencyId == 1
                            ? sale.total?.toDop()
                            : sale.total?.toUS() ?? '',
                        style: pw.TextStyle(fontSize: 10))
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
                        style: pw.TextStyle(fontSize: 10)),
                    pw.Text(
                        sale.currencyId == 1
                            ? sale.retentionTax?.toDop()
                            : sale.retentionTax?.toUS() ?? '',
                        style: pw.TextStyle(fontSize: 10))
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
                    pw.Text('Retencion Isr', style: pw.TextStyle(fontSize: 10)),
                    pw.Text(
                        sale.currencyId == 1
                            ? sale.retentionIsr?.toDop()
                            : sale.retentionIsr?.toUS() ?? '',
                        style: pw.TextStyle(fontSize: 10))
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
                        sale.ncfTypeId!.contains('4')
                            ? 'Total a devolver'
                            : 'Total a pagar',
                        style: pw.TextStyle(fontSize: 10)),
                    pw.Text(
                        sale.currencyId == 1
                            ? sale.amountPaid?.toDop()
                            : sale.amountPaid?.toUS() ?? '',
                        style: pw.TextStyle(fontSize: 10))
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
