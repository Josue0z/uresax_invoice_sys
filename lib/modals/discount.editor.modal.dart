import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/models/discount.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';

class DiscountEditorModal extends StatefulWidget {
  Discount discount;
  bool editing;
  DiscountEditorModal(
      {super.key, required this.discount, this.editing = false});

  @override
  State<DiscountEditorModal> createState() => _DiscountEditorModalState();
}

class _DiscountEditorModalState extends State<DiscountEditorModal> {
  TextEditingController name = TextEditingController();
  TextEditingController rate = TextEditingController();
  int? currentSymbolId;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String get title {
    return widget.editing ? 'EDITANDO DESCUENTO...' : 'CREANDO DESCUENTO...';
  }

  String get btnTitle {
    return widget.editing ? 'EDITAR DESCUENTO' : 'CREAR DESCUENTO';
  }

  _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        widget.discount.name = name.text;
        widget.discount.rate = double.tryParse(rate.text);
        widget.discount.symbolId = currentSymbolId;
        if (!widget.editing) {
          await widget.discount.create();
        } else {
          await widget.discount.update();
        }
        Navigator.pop(context, widget.editing ? 'UPDATE' : 'CREATE');
      } catch (e) {
        showTopSnackBar(context, message: e.toString(), color: Colors.red);
      }
    }
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
                    controller: rate,
                    validator: (val) =>
                        val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                    decoration:
                        InputDecoration(labelText: 'TASA', hintText: '0.00'),
                  ),
                  SizedBox(
                    height: kDefaultPadding,
                  ),
                  DropdownButtonFormField(
                      initialValue: currentSymbolId,
                      validator: (val) =>
                          val == null ? 'CAMPO OBLIGATORIO' : null,
                      items: List.generate(symbols.length, (index) {
                        var symbol = symbols[index];
                        return DropdownMenuItem(
                            value: symbol.id, child: Text(symbol.name ?? ''));
                      }),
                      onChanged: (option) {
                        currentSymbolId = option;
                      }),
                  SizedBox(
                    height: kDefaultPadding,
                  ),
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
