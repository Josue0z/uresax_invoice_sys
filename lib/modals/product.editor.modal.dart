import 'package:amount_input_formatter/amount_input_formatter.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/models/product.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';

class ProductEditorModal extends StatefulWidget {
  bool editing;
  Products product;

  ProductEditorModal({super.key, this.editing = false, required this.product});

  @override
  State<ProductEditorModal> createState() => _ProductEditorModalState();
}

class _ProductEditorModalState extends State<ProductEditorModal> {
  TextEditingController name = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController chassis = TextEditingController();
  TextEditingController licensePlate = TextEditingController();
  AmountInputFormatter amountInputFormatter =
      AmountInputFormatter(fractionalDigits: 2);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int? currentTaxId;

  _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        widget.product.name = name.text;
        widget.product.price = amountInputFormatter.doubleValue;
        widget.product.quantity = int.parse(quantity.text);
        widget.product.chassis = chassis.text;
        widget.product.licensePlate = licensePlate.text;
        widget.product.taxId = currentTaxId;
        if (!widget.editing) {
          await widget.product.create();
          Navigator.pop(context, 'CREATE');
        } else {
          await widget.product.update();
          Navigator.pop(context, 'UPDATE');
          showTopSnackBar(context,
              message: widget.editing ? 'PRODUCTO EDITADO' : 'PRODUCTO CREADO',
              color: Colors.green);
        }
      } catch (e) {
        showTopSnackBar(context, message: e.toString(), color: Colors.red);
      }
    }
  }

  String get title {
    return widget.editing ? 'EDITANDO PRODUCTO' : 'AGREGANDO PRODUCTO';
  }

  String get btnTitle {
    return widget.editing ? 'EDITAR PRODUCTO' : 'AGREGAR PRODUCTO';
  }

  @override
  void initState() {
    name.value = TextEditingValue(text: widget.product.name ?? '');

    if (widget.editing) {
      amount.value = amountInputFormatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.product.price?.toStringAsFixed(2) ?? ''));
    }

    quantity.value =
        TextEditingValue(text: widget.product.quantity?.toString() ?? '');
    chassis.value = TextEditingValue(text: widget.product.chassis ?? '');
    licensePlate.value =
        TextEditingValue(text: widget.product.licensePlate ?? '');

    currentTaxId = widget.product.taxId;
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
          key: _formKey,
          child: SizedBox(
              width: 350,
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(kDefaultPadding),
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(title,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                      color: Theme.of(context).primaryColor))),
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
                    controller: name,
                    validator: (val) =>
                        val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                    decoration: InputDecoration(
                        labelText: 'NOMBRE', hintText: 'Escribir nombre...'),
                  ),
                  SizedBox(
                    height: kDefaultPadding,
                  ),
                  TextFormField(
                    controller: amount,
                    validator: (val) =>
                        val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                    inputFormatters: [amountInputFormatter],
                    decoration:
                        InputDecoration(labelText: 'PRECIO', hintText: '0.00'),
                  ),
                  SizedBox(
                    height: kDefaultPadding,
                  ),
                  TextFormField(
                    controller: chassis,
                    validator: (val) =>
                        val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                    decoration: InputDecoration(
                        labelText: 'CHASIS', hintText: 'Escribir...'),
                  ),
                  SizedBox(
                    height: kDefaultPadding,
                  ),
                  TextFormField(
                    controller: licensePlate,
                    validator: (val) =>
                        val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                    decoration: InputDecoration(
                        labelText: 'PLACA', hintText: 'Escribir...'),
                  ),
                  SizedBox(
                    height: kDefaultPadding,
                  ),
                  DropdownButtonFormField<int>(
                      value: currentTaxId,
                      items: List.generate(taxes.length, (index) {
                        var tax = taxes[index];
                        return DropdownMenuItem(
                            value: tax.id, child: Text(tax.name ?? ''));
                      }),
                      onChanged: (option) {
                        currentTaxId = option;
                      }),
                  SizedBox(
                    height: kDefaultPadding,
                  ),
                  !widget.editing
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: quantity,
                              validator: (val) =>
                                  val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  labelText: 'CANTIDAD', hintText: '0'),
                            ),
                            SizedBox(
                              height: kDefaultPadding,
                            ),
                          ],
                        )
                      : SizedBox(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        onPressed: _onSubmit, child: Text(btnTitle)),
                  )
                ],
              ))),
    );
  }
}
