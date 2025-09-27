import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/models/orden.item.model.dart';
import 'package:uresax_invoice_sys/models/product.dart';
import 'package:uresax_invoice_sys/models/warehouse.obj.dart';
import 'package:uresax_invoice_sys/pages/products_page.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/widgets/selector.item.widget.dart';

class OrdenItemGeneratorWidget extends StatefulWidget {
  final WareHouseElementItem ordenItemModel;

  Function(WareHouseElementItem) onChanged;
  OrdenItemGeneratorWidget(
      {super.key, required this.ordenItemModel, required this.onChanged});

  @override
  State<OrdenItemGeneratorWidget> createState() =>
      _OrdenItemGeneratorWidgetState();
}

class _OrdenItemGeneratorWidgetState extends State<OrdenItemGeneratorWidget> {
  TextEditingController quantity = TextEditingController();
  TextEditingController units = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController net = TextEditingController();
  TextEditingController total = TextEditingController();
  TextEditingController totalAmount = TextEditingController();

  Products? selectedProduct;

  bool get isOrdenItem {
    return widget.ordenItemModel is OrdenItemModel;
  }

  _calc() {
    var cost = selectedProduct?.cost ?? 0;
    var xquantity = widget.ordenItemModel.quantity ?? 1;
    var net = cost * xquantity;
    var factor = selectedProduct?.factor ?? 1;
    var xunits = xquantity * factor;

    widget.ordenItemModel.productId = selectedProduct?.id;

    widget.ordenItemModel.price = cost;
    widget.ordenItemModel.quantity = xquantity;
    widget.ordenItemModel.units = xunits.toInt();
    widget.ordenItemModel.net = net;
    widget.ordenItemModel.discount = 0;
    widget.ordenItemModel.tax = 0;
    widget.ordenItemModel.total = net;
    quantity.value = TextEditingValue(
        text: xquantity.toString(),
        selection:
            TextSelection.collapsed(offset: xquantity.toString().length));

    units.text = xunits.toStringAsFixed(2);
    price.text = cost.toStringAsFixed(2);
    total.text = net.toStringAsFixed(2);
    totalAmount.text = net.toStringAsFixed(2);
    widget.onChanged(widget.ordenItemModel);
  }

  @override
  void initState() {
    if (widget.ordenItemModel.id != null ||
        widget.ordenItemModel.productId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          selectedProduct = Products(
              id: widget.ordenItemModel.productId,
              name: widget.ordenItemModel.productName,
              cost: widget.ordenItemModel.price ?? 0);

          _calc();
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: kDefaultPadding),
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.only(right: kDefaultPadding),
            width: 150,
            child: TextFormField(
              controller: quantity,
              readOnly: !isOrdenItem,
              onChanged: (val) {
                var xquantity = int.tryParse(val) ?? 1;
                widget.ordenItemModel.quantity = xquantity;
                _calc();
              },
              decoration: InputDecoration(labelText: 'CANTIDAD', hintText: '0'),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: kDefaultPadding),
            width: 150,
            child: TextFormField(
              controller: units,
              readOnly: true,
              decoration: InputDecoration(labelText: 'UNIDADES', hintText: '0'),
            ),
          ),
          Container(
            width: 320,
            margin: EdgeInsets.only(right: kDefaultPadding),
            child: SelectorItemWidget<Products>(
                context: context,
                title: 'SELECCIONAR PRODUCTO',
                initialValue: selectedProduct,
                enabled: isOrdenItem,
                screen:
                    ProductsPage(selectedMode: true, isOrdenGenerator: true),
                onChanged: (xproduct) {
                  selectedProduct = xproduct;
                  _calc();
                }),
          ),
          Container(
            width: 150,
            height: 50,
            margin: EdgeInsets.only(right: kDefaultPadding),
            child: TextFormField(
              controller: price,
              readOnly: true,
              decoration:
                  InputDecoration(labelText: 'PRECIO', hintText: '0.00'),
            ),
          ),
          Container(
            width: 150,
            height: 50,
            child: TextFormField(
              controller: totalAmount,
              readOnly: true,
              decoration:
                  InputDecoration(labelText: 'MONTO TOTAL', hintText: '0.00'),
            ),
          )
        ],
      ),
    );
  }
}
