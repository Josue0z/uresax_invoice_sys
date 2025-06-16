import 'package:flutter/material.dart';
import 'package:multi_masked_formatter/multi_masked_formatter.dart';
import 'package:uresax_invoice_sys/models/client.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';

class ClientEditorModal extends StatefulWidget {
  bool editing;
  Client client;

  ClientEditorModal({super.key, this.editing = false, required this.client});

  @override
  State<ClientEditorModal> createState() => _ClientEditorModalState();
}

class _ClientEditorModalState extends State<ClientEditorModal> {
  TextEditingController name = TextEditingController();
  TextEditingController identification = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String get title {
    return widget.editing ? 'EDITANDO CLIENTE' : 'AGREGANDO CLIENTE';
  }

  String get btnTitle {
    return widget.editing ? 'EDITAR CLIENTE' : 'AGREGAR CLIENTE';
  }

  _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        widget.client.name = name.text;
        widget.client.identification = identification.text;
        widget.client.email = email.text;
        widget.client.phone = phone.text;

        if (!widget.editing) {
          await widget.client.create();
          Navigator.pop(context, 'CREATE');
        } else {
          await widget.client.update();
          Navigator.pop(context, 'UPDATE');
          showTopSnackBar(context,
              message: widget.editing ? 'CLIENTE EDITADO' : 'CLIENTE CREADO',
              color: Colors.green);
        }
      } catch (e) {
        showTopSnackBar(context, message: e.toString(), color: Colors.red);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    name.value = TextEditingValue(text: widget.client.name ?? '');
    identification.value =
        TextEditingValue(text: widget.client.identification ?? '');
    email.value = TextEditingValue(text: widget.client.email ?? '');
    phone.value = TextEditingValue(text: widget.client.phone ?? '');
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
                    controller: identification,
                    readOnly: widget.editing,
                    validator: (val) =>
                        val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                    decoration: InputDecoration(
                        labelText: 'RNC/CEDULA', hintText: 'Escribir algo...'),
                  ),
                  SizedBox(
                    height: kDefaultPadding,
                  ),
                  TextFormField(
                    controller: phone,
                    inputFormatters: [
                      MultiMaskedTextInputFormatter(
                          masks: ['xxx-xxx-xxxx'], separator: '-')
                    ],
                    decoration: InputDecoration(
                        labelText: 'TELEFONO', hintText: '809 000 0000'),
                  ),
                  SizedBox(
                    height: kDefaultPadding,
                  ),
                  TextFormField(
                    controller: email,
                    decoration: InputDecoration(
                        labelText: 'CORREO', hintText: 'correo@example.com'),
                  ),
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
