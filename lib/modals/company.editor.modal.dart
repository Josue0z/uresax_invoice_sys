import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uresax_invoice_sys/settings.dart';

class CompanyEditorModal extends StatefulWidget {
  const CompanyEditorModal({super.key});

  @override
  State<CompanyEditorModal> createState() => _CompanyEditorModalState();
}

class _CompanyEditorModalState extends State<CompanyEditorModal> {
  TextEditingController name = TextEditingController();
  TextEditingController identification = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController phone2 = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();
  String? logo;

  _onSubmit() async {
    try {
      company?.name = name.text;
      company?.rncOrId = identification.text;
      company?.phone1 = phone.text;
      company?.phone2 = phone2.text;
      company?.email = email.text;
      company?.address = address.text;
      company = await company?.update();
      Navigator.pop(context, 'UPDATE');
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    name.value = TextEditingValue(text: company?.name ?? '');
    identification.value = TextEditingValue(text: company?.rncOrId ?? '');
    phone.value = TextEditingValue(text: company?.phone1 ?? '');
    phone2.value = TextEditingValue(text: company?.phone2 ?? '');
    email.value = TextEditingValue(text: company?.email ?? '');
    address.value = TextEditingValue(text: company?.address ?? '');
    logo = company?.logo;
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
          child: SizedBox(
        width: 400,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(kDefaultPadding),
          children: [
            Row(
              children: [
                Expanded(
                    child: Text('EDITANDO EMPRESA...',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(color: Theme.of(context).primaryColor))),
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
            ImagePickerWidget(logo: logo),
            SizedBox(
              height: kDefaultPadding,
            ),
            TextFormField(
              controller: name,
              decoration: InputDecoration(
                  labelText: 'NOMBRE', hintText: 'Escribir algo...'),
            ),
            SizedBox(height: kDefaultPadding),
            TextFormField(
              controller: identification,
              decoration: InputDecoration(
                  labelText: 'RNC/CEDULA', hintText: 'Escribir algo...'),
            ),
            SizedBox(height: kDefaultPadding),
            TextFormField(
              controller: phone,
              decoration: InputDecoration(
                  labelText: 'TELEFONO 1', hintText: '809 000 0000'),
            ),
            SizedBox(height: kDefaultPadding),
            TextFormField(
              controller: phone2,
              decoration: InputDecoration(
                  labelText: 'TELEFONO 2', hintText: '809 000 0000'),
            ),
            SizedBox(height: kDefaultPadding),
            TextFormField(
              controller: email,
              decoration: InputDecoration(
                  labelText: 'CORREO', hintText: 'correo@example.com'),
            ),
            SizedBox(height: kDefaultPadding),
            TextFormField(
              controller: address,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                  labelText: 'DIRECCION', hintText: 'Escribir algo...'),
            ),
            SizedBox(height: kDefaultPadding),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                  onPressed: _onSubmit, child: Text('EDITAR DATOS')),
            )
          ],
        ),
      )),
    );
  }
}

class ImagePickerWidget extends StatefulWidget {
  String? logo;
  ImagePickerWidget({super.key, this.logo});

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? file;

  _onOpenPicker() async {
    final ImagePicker picker = ImagePicker();
    var res = await picker.pickImage(source: ImageSource.gallery);
    if (res != null) {
      file = File(res.path);
      var bytes = await file?.readAsBytes();
      widget.logo = base64Encode(bytes!);
      company?.logo = widget.logo;
      await company?.update();
      setState(() {});
    }
  }

  _removeImagen() async {
    file = null;
    widget.logo = null;
    company?.logo = widget.logo;
    await company?.update();
    setState(() {});
  }

  Widget get contentFilled {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12)),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.memory(base64Decode(widget.logo ?? ''), width: 180),
            SizedBox(height: kDefaultPadding),
            TextButton(onPressed: _removeImagen, child: Text('Eliminar Imagen'))
          ],
        ),
      ),
    );
  }

  Widget get contentDefault {
    return GestureDetector(
      onTap: _onOpenPicker,
      child: Container(
        width: double.infinity,
        height: 250,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black12)),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 90, color: Colors.black12),
              SizedBox(height: kDefaultPadding),
              Text('Cargar Imagen')
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.logo != null) {
      return contentFilled;
    } else {
      return contentDefault;
    }
  }
}
