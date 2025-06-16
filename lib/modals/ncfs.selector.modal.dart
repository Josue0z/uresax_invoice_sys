import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/models/sale.abs.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';

class NcfsSelectorModal extends StatefulWidget {
  SaleMode saleMode;
  NcfsSelectorModal({super.key, required this.saleMode});

  @override
  State<NcfsSelectorModal> createState() => _NcfsSelectorModalState();
}

class _NcfsSelectorModalState extends State<NcfsSelectorModal> {
  List<Sale> sales = [];
  Sale? _currentSale;
  _initAsync() async {
    try {
      if (widget.saleMode == SaleMode.service) {
        sales = await getSalesList(invoiceTypeId: 1);
      }
      if (widget.saleMode == SaleMode.product) {
        sales = await getSalesList(invoiceTypeId: 2);
      }

      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    _initAsync();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
          child: SizedBox(
              width: 400,
              height: 400,
              child: Padding(
                  padding: EdgeInsets.all(kDefaultPadding),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text('Selecciona el Ncf',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(
                                          color:
                                              Theme.of(context).primaryColor))),
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.close))
                        ],
                      ),
                      SizedBox(
                        height: kDefaultPadding,
                      ),
                      Expanded(
                          child: ListView.separated(
                              itemCount: sales.length,
                              separatorBuilder: (ctx, i) => const Divider(),
                              itemBuilder: (ctx, index) {
                                var sale = sales[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  selected: _currentSale?.id == sale.id,
                                  title: Text(sale.ncf ?? ''),
                                  onTap: () {
                                    _currentSale = sale;
                                    setState(() {});
                                  },
                                );
                              })),
                      SizedBox(
                        height: kDefaultPadding,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                            onPressed: () async {
                              try {
                                Navigator.pop(context, _currentSale);
                              } catch (e) {
                                showTopSnackBar(context,
                                    message: e.toString(), color: Colors.red);
                              }
                            },
                            child: Text('APLICAR')),
                      )
                    ],
                  )))),
    );
  }
}
