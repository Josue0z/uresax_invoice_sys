import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:open_file/open_file.dart';
import 'package:uresax_invoice_sys/models/entry.warehouse.item.model.dart';
import 'package:uresax_invoice_sys/models/entry.warehouse.model.dart';
import 'package:uresax_invoice_sys/models/orden.item.model.dart';
import 'package:uresax_invoice_sys/models/orden.model.dart';
import 'package:uresax_invoice_sys/pages/ordens_generator_page.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/extensions.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';
import 'package:uresax_invoice_sys/utils/invoices.functions.dart';
import 'package:path/path.dart' as path;
import 'package:uresax_invoice_sys/widgets/content.error.widget.dart';

class OrdensPurchasesPage extends StatefulWidget {
  const OrdensPurchasesPage({super.key});

  @override
  State<OrdensPurchasesPage> createState() => _OrdensPurchasesPageState();
}

class _OrdensPurchasesPageState extends State<OrdensPurchasesPage> {
  List<OrdenModel> ordens = [];

  Future? future;

  _initAsync() async {
    try {
      ordens = await OrdenModel.get();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  _showOrdenGeneratorPage({required OrdenModel orden, bool editing = false}) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => OrdensGeneratorPage(ordenModel: orden),
        )).then((value) {
      if (value != null && value is String) {
        _initAsync();
      }
    });
  }

  _showEntryPurchaseGenerator(OrdenModel orden) async {
    var value = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (ctx) => OrdensGeneratorPage(
                ordenModel: EntryWareHouseModel(
                    ordenId: orden.id,
                    ordenNum: orden.ordenNum,
                    driverId: orden.driverId,
                    driverIdentification: orden.driverIdentification,
                    driverName: orden.driverName,
                    driverEmail: orden.driverEmail,
                    driverPhone: orden.driverPhone,
                    items: orden.items
                        ?.map((e) => EntryWareHouseItemModel(
                              productId: e.productId,
                              productName: e.productName,
                              providerId: e.providerId,
                              providerName: e.providerName,
                              price: e.price,
                              quantity: e.quantity,
                              net: e.net,
                              discount: e.discount,
                              tax: e.tax,
                              total: e.total,
                            ))
                        .toList()))));

    if (value != null && value is String) {
      _initAsync();
    }
  }

  _showActionPage(int option, {required OrdenModel orden}) async {
    orden.items = await orden.getItems();
    switch (option) {
      case 1:
        _showEntryPurchaseGenerator(orden);
        break;
      default:
    }
  }

  _showOrdenPurchaseInvoice(OrdenModel orden) async {
    orden.items = await orden.getItems();
    var doc = createDefaultOrdenPurchase(orden);

    var bytes = await doc.save();
    var dir = await getUresaxInvoiceDir();

    var file = File(path.join(
        dir.path,
        'ORDENES DE COMPRAS',
        orden.createdAt?.format(payload: 'YYYYMM'),
        'PDFS',
        '${orden.ordenNum}-${company?.name}.PDF'));
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }

  Widget get contentFilled {
    return ListView.separated(
          itemBuilder: (ctx, index) {
            List<Map<String, dynamic>> options = [];

            var orden = ordens[index];

            if (orden.applyEntry == false) {
              options.add({'id': 1, 'title': 'Generar Entrada de Almacen'});
            }
            return ListTile(
              minTileHeight: 90,
              contentPadding: EdgeInsets.symmetric(
                  vertical: kDefaultPadding, horizontal: kDefaultPadding),
              leading: Container(
                width: 70,
                height: 70,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(90)),
                child: Icon(
                  Icons.receipt_long,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              title: Text('Orden ${orden.ordenNum.toString()}'),
              trailing: Wrap(
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(orden.createdAt?.format(payload: 'DD/MM/YYYY HH:mm') ??
                      ''),
                  SizedBox(
                    width: kDefaultPadding / 2,
                  ),
                  Text(orden.total?.toDop() ?? ''),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                    padding: EdgeInsets.all(kDefaultPadding / 2),
                    decoration: BoxDecoration(
                        color: orden.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30)),
                    child: Text(
                      orden.labelText,
                      style: TextStyle(color: orden.color),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        _showOrdenPurchaseInvoice(orden);
                      },
                      icon: Icon(Icons.visibility)),
                  options.isEmpty
                      ? SizedBox()
                      : PopupMenuButton<int>(onSelected: (id) {
                          _showActionPage(id, orden: orden);
                        }, itemBuilder: (ctx) {
                          return List.generate(options.length, (index) {
                            var item = options[index];
                            return PopupMenuItem(
                                value: item['id'], child: Text(item['title']));
                          });
                        })
                ],
              ),
            );
          },
          separatorBuilder: (ctx, i) => const Divider(),
          itemCount: ordens.length);
  }

    Widget get contentEmpty {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/svgs/undraw_logistics_8vri.svg', width: 280)
        ],
      ),
    );
  }

  Widget get contentLoading {
    return Center(
      child: CircularProgressIndicator(),
    );
  }



  @override
  void initState() {
   setState(() {
     future =  _initAsync();
   });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ORDENES DE COMPRAS (${ordens.length})'),
      ),
      body:FutureBuilder(future: future, builder: (ctx,s){
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
            if (s.connectionState == ConnectionState.done &&
                ordens.isNotEmpty) {
              return contentFilled;
            }

            return contentEmpty;
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showOrdenGeneratorPage(orden: OrdenModel(items: [OrdenItemModel()]));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
