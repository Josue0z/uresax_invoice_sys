import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/models/categorie.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';

class CategoryEditorModal extends StatefulWidget {
  Category category;
  bool editing;
  CategoryEditorModal(
      {super.key, required this.category, this.editing = false});

  @override
  State<CategoryEditorModal> createState() => _CategoryEditorModalState();
}

class _CategoryEditorModalState extends State<CategoryEditorModal> {
  TextEditingController name = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String get title {
    return widget.editing ? 'EDITANDO CATEGORIA...' : 'CREANDO CATEGORIA...';
  }

  String get btnTitle {
    return widget.editing ? 'EDITAR CATEGORIA' : 'CREAR CATEGORIA';
  }

  _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        widget.category.name = name.text;

        if (!widget.editing) {
          await widget.category.create();
        } else {
          await widget.category.update();
        }
        Navigator.pop(context, widget.editing ? 'UPDATE' : 'CREATE');
      } catch (e) {
        showTopSnackBar(context, message: e.toString(), color: Colors.red);
      }
    }
  }

  @override
  void initState() {
    name.text = widget.category.name ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Form(
            key: _formKey,
            child: Container(
              padding: EdgeInsets.all(kDefaultPadding),
              width: 350,
              child: ListView(
                shrinkWrap: true,
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
                      controller: name,
                      validator: (val) =>
                          val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                      decoration: InputDecoration(
                          labelText: 'NOMBRE', hintText: 'Escribir algo...'),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        onPressed: _onSubmit, child: Text(btnTitle)),
                  )
                ],
              ),
            )));
  }
}
