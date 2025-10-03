import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/apis/log.handler.dart';
import 'package:uresax_invoice_sys/models/provider.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';

class ProviderEditorModal extends StatefulWidget {
  final Providers provider;
  bool editing;
  ProviderEditorModal(
      {super.key, required this.provider, this.editing = false});

  @override
  State<ProviderEditorModal> createState() => _ProviderEditorModalState();
}

class _ProviderEditorModalState extends State<ProviderEditorModal> {
  TextEditingController name = TextEditingController();
  TextEditingController rncOrId = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String get title {
    return widget.editing ? 'EDITANDO PROVEEDOR' : 'AGREGANDO PROVEEDOR';
  }

  String get btnText {
    return widget.editing ? 'EDITAR PROVEEDOR' : 'CREAR PROVEEDOR';
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      Providers? provider;
      try {
        widget.provider.name = name.text;
        widget.provider.rncOrId = rncOrId.text;
        if (widget.editing) {
          await widget.provider.update();
          await LogHandler.printEvent(
              'PROVEEDOR: ${widget.provider.name} ACTUALIZADO');
        } else {
          provider = await widget.provider.create();
          await LogHandler.printEvent(
              'PROVEEDOR: ${widget.provider.name} CREADO');
        }
        Navigator.pop(context, widget.editing ? 'UPDATE' : 'CREATE');
      } catch (e) {
        await LogHandler.printError(e.toString());
        showTopSnackBar(context, message: e.toString(), color: Colors.red);
      }
    }
  }

  @override
  void initState() {
    name.text = widget.provider.name ?? '';
    rncOrId.text = widget.provider.rncOrId ?? '';
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
                Container(
                  margin: EdgeInsets.symmetric(vertical: kDefaultPadding),
                  child: TextFormField(
                    controller: rncOrId,
                    validator: (val) =>
                        val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                    decoration: InputDecoration(
                        labelText: 'Rnc/Cedula', hintText: 'Escribir algo...'),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: kDefaultPadding),
                  child: TextFormField(
                    controller: name,
                    validator: (val) =>
                        val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                    decoration: InputDecoration(
                        labelText: 'Nombre', hintText: 'Escribir algo...'),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: _onSubmit, child: Text(btnText)),
                )
              ],
            ),
          )),
    );
  }
}
