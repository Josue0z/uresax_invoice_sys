import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:open_file/open_file.dart';
import 'package:uresax_invoice_sys/modals/filter.sales.modal.dart';
import 'package:uresax_invoice_sys/modals/payment.editor.modal.dart';
import 'package:uresax_invoice_sys/models/sale.abs.dart';
import 'package:uresax_invoice_sys/models/sale.service.dart';
import 'package:uresax_invoice_sys/pages/invoice_generator_page.dart';
import 'package:uresax_invoice_sys/pages/payments.sales_page.dart';
import 'package:uresax_invoice_sys/pages/report.sales.page.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/extensions.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';
import 'package:uresax_invoice_sys/utils/invoices.functions.dart';
import 'package:path/path.dart' as path;
import 'package:uresax_invoice_sys/widgets/content.error.widget.dart';
import 'package:uresax_invoice_sys/widgets/date.range_widget.dart';
import 'package:pdf/widgets.dart' as pw;

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  List<Sale> sales = [];
  DateTime startDate = DateTime.now();
  late List<DateTime?> dates = [
    startDate.startOfMonth(),
    DateTime(startDate.year, startDate.month, startDate.day, 23, 59, 59)
        .endOfMonth()
  ];

  List<Map<String, dynamic>> options = [
    {'id': 1, 'name': 'Ver Reporte Por Tipo de Ncf'},
    {'id': 2, 'name': 'Ver Reporte Por Tipo de Ingreso'}
  ];

  String? ncfTypeId;
  String? search;
  SaleStatus? saleStatus = SaleStatus.all;

  int? estadoDgii;

  TextEditingController searchController = TextEditingController();

  Future? future;

  Future<void> _initAsync() async {
    try {
      sales = await getSales(
          startDate: dates.first!,
          endDate: dates.last!,
          ncfTypeId: ncfTypeId,
          saleStatus: saleStatus,
          estadoDgii: estadoDgii,
          search: search);

      setState(() {});
    } catch (e) {
      print(e);
      setState(() {});
      rethrow;
    }
  }

  _showInvoice(Sale sale) async {
    try {
      var items = await sale.getSaleData();

      sale.items = items;

      pw.Document doc;

      if (eCommerceMode) {
        doc = createVerticalInvoice(sale);
      } else {
        doc = createDefaultInvoice(sale);
      }

      var bytes = await doc.save();
      var dir = await getUresaxInvoiceDir();

      var file = File(path.join(
          dir.path,
          'VENTAS',
          sale.createdAt?.format(payload: 'YYYYMM'),
          'PDFS',
          '${sale.ncf}-${company?.name}.PDF'));
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      await OpenFile.open(file.path);
    } catch (e) {
      print(e);
    }
  }

  _showPaymentModal(Sale sale) async {
    var res = await showDialog(
        context: context, builder: (ctx) => PaymentEditorModal(sale: sale));
    if (res == 'UPDATE') {
      setState(() {
        future = _initAsync();
      });
    }
  }

  _showFiltersModal() async {
    var res = await showDialog(
        context: context,
        builder: (ctx) => FilterSalesModal(
            ncfTypeId: ncfTypeId,
            saleStatus: saleStatus,
            dgiiState: estadoDgii));
    if (res is Map) {
      ncfTypeId = res['ncfTypeId'];
      saleStatus = res['saleStatus'];
      estadoDgii = res['dgiiState'];

      setState(() {
        future = _initAsync();
      });
    }
  }

  _showReportByTypeNcf() async {
    try {
      var data = await getSalesReportByTypeNcf(
          startDate: dates.first!,
          endDate: dates.last!,
          ncfTypeId: ncfTypeId,
          estadoDgii: estadoDgii);

      var list = data['list'];

      var doc = data['document'];

      var bytes = data['bytes'];

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (ctx) => ReportSalesPage(
                  title: 'REPORTE POR TIPO DE NCF',
                  reportTypeId: 1,
                  data: list,
                  startDate: dates.first!,
                  endDate: dates.last!,
                  document: doc,
                  bytes: bytes)));
    } catch (e) {
      print(e);
    }
  }

  _showReportByTypeIncome() async {
    try {
      var data = await getSalesTypeIncomesReport(
          startDate: dates.first!,
          endDate: dates.last!,
          ncfTypeId: ncfTypeId,
          estadoDgii: estadoDgii);

      var list = data['list'];

      var doc = data['document'];

      var bytes = data['bytes'];

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (ctx) => ReportSalesPage(
                  title: 'REPORTE POR TIPO DE INGRESO',
                  reportTypeId: 2,
                  data: list,
                  startDate: dates.first!,
                  endDate: dates.last!,
                  document: doc,
                  bytes: bytes)));
    } catch (e) {
      print(e);
    }
  }

  _showPayments(Sale sale) async {
    Navigator.push(context,
        MaterialPageRoute(builder: (ctx) => PaymentSalesPage(sale: sale)));
  }

  _showInvoicePage(Sale sale) async {
    var items = await sale.getSaleData();
    sale.items = items;
    var res = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (ctx) => InvoiceGeneratorPage(
                editing: true,
                sale: sale,
                items: items,
                mode: sale is SaleService
                    ? SaleMode.service
                    : SaleMode.product)));

    if (res == 'UPDATE') {
      setState(() {
        future = _initAsync();
      });
    }
  }

  _onSelectedOption(int? option) async {
    switch (option) {
      case 1:
        _showReportByTypeNcf();
        break;
      case 2:
        _showReportByTypeIncome();
        break;
      default:
    }
  }

  _generateXmlFile(Sale sale) async {
    try {
      var dir = await getUresaxInvoiceDir();
      var file = File(path.join(dir.path, 'VENTAS',
          sale.createdAt?.format(payload: 'YYYYMM'), 'XML', '${sale.ncf}.xml'));
      await file.create(recursive: true);
      await file.writeAsString(sale.ecfXmlFirmado ?? '');

      await OpenFile.open(file.path);
    } catch (e) {
      showTopSnackBar(context, message: e.toString(), color: Colors.red);
    }
  }

  _onSelectedSaleOption(int? option, Sale sale) async {
    switch (option) {
      case 1:
        _showInvoice(sale);
        break;
      case 2:
        _showPayments(sale);
        break;
      case 3:
        _showPaymentModal(sale);
      case 4:
        _showInvoicePage(sale);
        break;
      case 5:
        _generateXmlFile(sale);
        break;
      default:
    }
  }

  Widget get contentFilled {
    return ListView.separated(
        separatorBuilder: (ctx, i) => const Divider(),
        itemCount: sales.length,
        itemBuilder: (ctx, index) {
          var sale = sales[index];

          List<Map<String, dynamic>> salesOptions = [
            {'id': 1, 'name': 'Ver Factura'},
            {'id': 2, 'name': 'Ver pagos'},
          ];

          if (sale.debt! > 0) {
            salesOptions.add(
              {'id': 3, 'name': 'Abonar pago'},
            );

            if (allowEditInvoice) {
              salesOptions.add({'id': 4, 'name': 'Editar Factura'});
            }
          }

          if (sale.ecfXmlFirmado != null) {
            salesOptions
                .add({'id': 5, 'name': 'Generar Archivo XML del ${sale.ncf}'});
          }

          return ListTile(
            minVerticalPadding: kDefaultPadding,
            leading: Container(
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(90),
                color: Theme.of(context).primaryColor.withOpacity(0.04),
              ),
              child: Center(
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
            ),
            title: Text(sale.ncf ?? '',
                style: Theme.of(context).textTheme.bodyMedium),
            subtitle: Text(sale.clientName ?? ''),
            trailing: Wrap(
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(kDefaultPadding / 2),
                  decoration: BoxDecoration(
                    color: sale.color.withOpacity(0.04),
                  ),
                  child: Text(
                    sale.paidLabel,
                    style: TextStyle(color: sale.color, fontSize: 18),
                  ),
                ),
                SizedBox(width: kDefaultPadding),
                sale.estadoDgii != null
                    ? Container(
                        margin: EdgeInsets.only(
                            left: kDefaultPadding / 2, right: kDefaultPadding),
                        padding: EdgeInsets.all(kDefaultPadding / 2),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: sale.statusColorDgii.withOpacity(0.04)),
                        child: Text(
                          sale.estadoDgiiNombre ?? '',
                          style: TextStyle(color: sale.statusColorDgii),
                        ),
                      )
                    : SizedBox(),
                Text(
                    sale.currencyId == 1
                        ? sale.total?.toDop()
                        : sale.total?.toUS(),
                    style: Theme.of(context).textTheme.bodyMedium),
                SizedBox(width: kDefaultPadding),
                PopupMenuButton<int>(
                    onSelected: (option) => _onSelectedSaleOption(option, sale),
                    itemBuilder: (ctx) {
                      return List.generate(salesOptions.length, (index) {
                        var option = salesOptions[index];
                        return PopupMenuItem(
                            value: option['id'], child: Text(option['name']));
                      });
                    }),
                SizedBox(width: kDefaultPadding),
              ],
            ),
          );
        });
  }

  Widget get contentLoading {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget get contentEmpty {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/svgs/undraw_printing-invoices_osgs.svg',
              width: 320)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('TUS FACTURAS (${sales.length})'),
          actions: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              children: [
                SizedBox(
                  width: 190,
                  child: TextFormField(
                    controller: searchController,
                    onFieldSubmitted: (words) {
                      search = words;
                      setState(() {
                        future = _initAsync();
                      });
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(style: BorderStyle.none, width: 0)),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'BUSCAR NCF...',
                        suffixIcon: Wrap(
                          runAlignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.search),
                            SizedBox(width: kDefaultPadding)
                          ],
                        )),
                  ),
                ),
                SizedBox(width: kDefaultPadding),
                SizedBox(
                  width: 290,
                  child: DateRangeWidget(
                      dates: dates,
                      onChanged: (xdates) async {
                        dates = xdates;
                        dates = [
                          xdates.first,
                          xdates.last!.copyWith(
                            hour: 23,
                            minute: 59,
                            second: 59,
                          )
                        ];

                        setState(() {
                          future = _initAsync();
                        });
                      }),
                ),
                SizedBox(
                  width: kDefaultPadding,
                ),
                IconButton(
                    onPressed: _showFiltersModal,
                    icon: Icon(Icons.tune_outlined)),
                SizedBox(
                  width: kDefaultPadding,
                ),
                PopupMenuButton<int>(
                    onSelected: _onSelectedOption,
                    itemBuilder: (ctx) {
                      return List.generate(options.length, (index) {
                        var item = options[index];
                        return PopupMenuItem(
                            value: item['id'], child: Text(item['name']));
                      });
                    }),
                SizedBox(
                  width: kDefaultPadding,
                ),
              ],
            )
          ],
        ),
        body: FutureBuilder(
            future: future,
            builder: (ctx, s) {
              if (s.connectionState == ConnectionState.waiting) {
                return contentLoading;
              }

              if (s.hasError) {
                return ContentErrorWidget(
                  error: s.error.toString(),
                  onRetry: () {
                    setState(() {
                      future = _initAsync();
                    });
                  },
                );
              }
              if (sales.isNotEmpty) {
                return contentFilled;
              }

              return contentEmpty;
            }),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    ncfTypeId = null;
                    saleStatus = SaleStatus.all;
                    search = null;

                    setState(() {
                      future = _initAsync();
                    });

                    searchController.clear();
                  },
                  child: Icon(Icons.restore),
                ),
                SizedBox(width: kDefaultPadding * 3)
              ],
            ),
            SizedBox(
              height: kDefaultPadding,
            )
          ],
        ));
  }
}
