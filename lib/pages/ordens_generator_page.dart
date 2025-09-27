import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:uresax_invoice_sys/apis/printers.handler.dart';
import 'package:uresax_invoice_sys/models/drivers.dart';
import 'package:uresax_invoice_sys/models/orden.item.model.dart';
import 'package:uresax_invoice_sys/models/orden.model.dart';
import 'package:uresax_invoice_sys/models/warehouse.obj.dart';
import 'package:uresax_invoice_sys/pages/drivers_page.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/extensions.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';
import 'package:uresax_invoice_sys/utils/invoices.functions.dart';
import 'package:uresax_invoice_sys/widgets/orden_item_generator_widget.dart';
import 'package:uresax_invoice_sys/widgets/selector.item.widget.dart';

class OrdensGeneratorPage extends StatefulWidget {
  final WareHouseElement ordenModel;
  const OrdensGeneratorPage({super.key, required this.ordenModel});

  @override
  State<OrdensGeneratorPage> createState() => _OrdensGeneratorPageState();
}

class _OrdensGeneratorPageState extends State<OrdensGeneratorPage> {
  Drivers? driver;

  bool get isOrden {
    return widget.ordenModel is OrdenModel;
  }

  String get title {
    return isOrden
        ? 'GENERANDO ORDEN DE COMPRA...'
        : 'GENERANDO ENTRADA DE ALMACEN';
  }

  String get btnText {
    return isOrden ? 'CREAR ORDEN DE COMPRA' : 'CREAR ENTRADA DE ALMACEN';
  }

  double get totalAmount {
    return data['totalAmount'] ?? 0.0;
  }

  _onSubmit() async {
    try {
      widget.ordenModel.net = totalAmount;
      widget.ordenModel.tax = 0;
      widget.ordenModel.total = totalAmount;
      widget.ordenModel.amountPaid = 0;
      widget.ordenModel.authorId = currentUser?.id;
      widget.ordenModel.driverId = driver?.id;

      var orden = await widget.ordenModel.create();

      if (orden != null) {
        var printer = localStorage.getItem('printer') ?? '';
        var bytes = await createDefaultOrdenTicket(entry: orden);
        await PrinterHandler.printBytes(printer, bytes);
      }

      Navigator.pop(context, 'CREATE');
    } catch (e) {
      showTopSnackBar(context, message: e.toString(), color: Colors.red);
    }
  }

  Map<String, double> get data {
    double totalAmount = 0;
    for (int i = 0; i < widget.ordenModel.items!.length; i++) {
      var item = widget.ordenModel.items![i];

      totalAmount += item.total ?? 0;
    }
    return {'totalAmount': totalAmount};
  }

  @override
  void initState() {
    driver = Drivers(
        id: widget.ordenModel.driverId,
        name: widget.ordenModel.driverName,
        phone: widget.ordenModel.driverPhone,
        email: widget.ordenModel.driverEmail);

    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Padding(
            padding: EdgeInsets.all(kDefaultPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width * 0.60,
                        height: (widget.ordenModel.items!.length * 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                children: [
                                  ...List.generate(
                                      widget.ordenModel.items?.length ?? 0,
                                      (index) {
                                    var item = widget.ordenModel.items![index];

                                    return OrdenItemGeneratorWidget(
                                      ordenItemModel: item,
                                      onChanged: (ordenItem) {
                                        setState(() {});
                                      },
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        )),
                    isOrden
                        ? SizedBox(
                            width: 250,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                widget.ordenModel.items?.add(OrdenItemModel());
                                setState(() {});
                              },
                              child: Text('AGREGAR PRODUCTO'),
                            ),
                          )
                        : SizedBox(),
                  ],
                )),
                const Divider(),
                Expanded(
                    child: Container(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(vertical: kDefaultPadding),
                        child: SelectorItemWidget<Drivers>(
                            context: context,
                            initialValue: driver,
                            title: 'SELECCIONAR CONDUCTOR',
                            screen: DriversPage(selectedMode: true),
                            onChanged: (xdriver) {
                              driver = xdriver;
                              print(driver);
                            }),
                      ),
                      Container(
                          margin: EdgeInsets.only(bottom: kDefaultPadding),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text('MONTO TOTAL',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor))),
                              Expanded(
                                  child: Text(totalAmount.toDop() ?? '0.00',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      textAlign: TextAlign.right))
                            ],
                          )),
                      const Divider(),
                      Container(
                        width: double.infinity,
                        height: 50,
                        margin: EdgeInsets.symmetric(vertical: kDefaultPadding),
                        child: ElevatedButton(
                            onPressed: _onSubmit, child: Text(btnText)),
                      )
                    ],
                  ),
                ))
              ],
            )));
  }
}
