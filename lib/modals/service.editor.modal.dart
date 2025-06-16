import 'package:amount_input_formatter/amount_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/models/service.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';

class ServiceEditorModal extends StatefulWidget {
  bool editing;
  Services service;

  ServiceEditorModal({super.key, this.editing = false, required this.service});

  @override
  State<ServiceEditorModal> createState() => _ServiceEditorModalState();
}

class _ServiceEditorModalState extends State<ServiceEditorModal> {
  TextEditingController name = TextEditingController();
  TextEditingController amount = TextEditingController();

  AmountInputFormatter amountInputFormatter =
      AmountInputFormatter(fractionalDigits: 2);

  int? currentTaxId;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        widget.service.name = name.text;
        widget.service.price = amountInputFormatter.doubleValue;
        widget.service.taxId = currentTaxId;
        if (!widget.editing) {
          await widget.service.create();
          Navigator.pop(context, 'CREATE');
        } else {
          await widget.service.update();
          Navigator.pop(context, 'UPDATE');
          showTopSnackBar(context,
              message: widget.editing ? 'SERVICIO EDITADO' : 'SERVICIO CREADO',
              color: Colors.green);
        }
      } catch (e) {
        showTopSnackBar(context, message: e.toString(), color: Colors.red);
      }
    }
  }

  String get title {
    return widget.editing ? 'EDITANDO SERVICIO' : 'AGREGANDO SERVICIO';
  }

  String get btnTitle {
    return widget.editing ? 'EDITAR SERVICIO' : 'AGREGAR SERVICIO';
  }

  @override
  void initState() {
    name.value = TextEditingValue(text: widget.service.name ?? '');

    if (widget.service.price != null) {
      amount.value = amountInputFormatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.service.price?.toStringAsFixed(2) ?? ''));
    }
    currentTaxId = widget.service.taxId;
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
