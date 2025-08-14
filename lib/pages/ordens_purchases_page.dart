import 'dart:io';

import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:open_file/open_file.dart';
import 'package:uresax_invoice_sys/models/orden.item.model.dart';
import 'package:uresax_invoice_sys/models/orden.model.dart';
import 'package:uresax_invoice_sys/pages/ordens_generator_page.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/extensions.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';
import 'package:uresax_invoice_sys/utils/invoices.functions.dart';
import 'package:path/path.dart' as path;

class OrdensPurchasesPage extends StatefulWidget {
  const OrdensPurchasesPage({super.key});

  @override
  State<OrdensPurchasesPage> createState() => _OrdensPurchasesPageState();
}

class _OrdensPurchasesPageState extends State<OrdensPurchasesPage> {
  List<OrdenModel> ordens = [];

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

  @override
  void initState() {
    _initAsync();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ORDENES DE COMPRAS (${ordens.length})'),
      ),
      body: ListView.separated(
          itemBuilder: (ctx, index) {
            var orden = ordens[index];
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
                  SizedBox(
                    width: kDefaultPadding,
                  ),
                  IconButton(
                      onPressed: () {
                        _showOrdenPurchaseInvoice(orden);
                      },
                      icon: Icon(Icons.visibility))
                ],
              ),
            );
          },
          separatorBuilder: (ctx, i) => const Divider(),
          itemCount: ordens.length),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showOrdenGeneratorPage(orden: OrdenModel(items: [OrdenItemModel()]));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
