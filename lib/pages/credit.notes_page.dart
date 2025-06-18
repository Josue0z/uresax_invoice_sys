import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import 'package:uresax_invoice_sys/models/sale.abs.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/extensions.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';
import 'package:uresax_invoice_sys/utils/invoices.functions.dart';
import 'package:path/path.dart' as path;
import 'package:uresax_invoice_sys/widgets/date.range_widget.dart';

class CreditNotesPage extends StatefulWidget {
  const CreditNotesPage({super.key});

  @override
  State<CreditNotesPage> createState() => _CreditNotesPageState();
}

class _CreditNotesPageState extends State<CreditNotesPage> {
  TextEditingController searchController = TextEditingController();
  String? search;

  List<Sale> creditNotes = [];
  List<DateTime?> dates = [
    DateTime.now().startOfMonth(),
    DateTime.now().endOfMonth()
  ];

  List<Map<String, dynamic>> salesOptions = [
    {'id': 1, 'name': 'Ver Factura'},
  ];

  _showInvoice(Sale sale) async {
    try {
      var items = await sale.getSaleData();

      sale.items = items;
      var doc = createDefaultInvoice(sale);
    
      var bytes = await doc.save();
      var dir = await getUresaxInvoiceDir();

      var file = File(path.join(dir.path,'NOTAS DE CREDITO',sale.createdAt?.format(payload:'YYYYMM'),
      'PDFS',
          '${sale.ncf}-${company?.name}.PDF'));
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      await OpenFile.open(file.path);
    } catch (e) {
      print(e);
    }
  }

  _onSelectedSaleOption(int? option, Sale sale) {
    switch (option) {
      case 1:
        _showInvoice(sale);
        break;

      default:
    }
  }

  _initAsync() async {
    try {
      creditNotes = await getCreditNotes(
          startDate: dates.first!, endDate: dates.last!, search: search);
      setState(() {});
    } catch (e) {
      print(e);
    }
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

  Widget get contentFilled {
    return ListView.separated(
        separatorBuilder: (ctx, i) => const Divider(),
        itemCount: creditNotes.length,
        itemBuilder: (ctx, index) {
          var item = creditNotes[index];
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
            title: Text('${item.ncf} - ${item.ncfAffected}',
                style: Theme.of(context).textTheme.bodyMedium),
            subtitle: Text(item.clientName ?? ''),
            trailing: Wrap(
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                    item.currencyId == 1
                        ? item.total?.toDop()
                        : item.total?.toUS(),
                    style: Theme.of(context).textTheme.bodyMedium),
                SizedBox(width: kDefaultPadding),
                PopupMenuButton<int>(
                    onSelected: (option) => _onSelectedSaleOption(option, item),
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

  Widget get content {
    if (creditNotes.isEmpty) return contentEmpty;

    return contentFilled;
  }

  @override
  void initState() {
    _initAsync();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TUS NOTAS DE CREDITO (${creditNotes.length})'),
        actions: [
          Wrap(
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 190,
                child: TextFormField(
                  controller: searchController,
                  onFieldSubmitted: (words) {
                    search = words;
                    _initAsync();
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
                      _initAsync();
                    }),
              ),
              SizedBox(
                width: kDefaultPadding,
              ),
            ],
          )
        ],
      ),
      body: content,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {
                  search = '';
                  searchController.clear();
                  _initAsync();
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
      ),
    );
  }
}
