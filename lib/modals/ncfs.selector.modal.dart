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
  TextEditingController rncOrId = TextEditingController();
  TextEditingController ncf = TextEditingController();
  Sale? _currentSale;
  _onSubmit() async {
    try {
      if (widget.saleMode == SaleMode.service) {
        sales = await getSalesListByIdAndNcf(
            invoiceTypeId: 1, rncOrId: rncOrId.text, ncf: ncf.text);
      }
      if (widget.saleMode == SaleMode.product) {
        sales = await getSalesListByIdAndNcf(
            invoiceTypeId: 2, rncOrId: rncOrId.text, ncf: ncf.text);
      }

      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
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
                      TextFormField(
                        controller: rncOrId,
                        decoration: InputDecoration(
                            labelText: 'RNC/CEDULA',
                            hintText: 'Escribir algo...'),
                      ),
                      SizedBox(
                        height: kDefaultPadding,
                      ),
                      TextFormField(
                        controller: ncf,
                        onFieldSubmitted: (_) => _onSubmit(),
                        decoration: InputDecoration(
                            labelText: 'NCF',
                            hintText: 'Escribir algo...',
                            suffixIcon: IconButton(
                                onPressed: _onSubmit,
                                icon: Icon(Icons.search))),
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
