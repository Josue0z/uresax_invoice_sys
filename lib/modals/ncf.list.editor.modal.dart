import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresax_invoice_sys/models/ncf.secuencia.dart';
import 'package:uresax_invoice_sys/models/ncfList.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';

class NcfListEditorModal extends StatefulWidget {
  const NcfListEditorModal({super.key});

  @override
  State<NcfListEditorModal> createState() => _NcfListEditorModalState();
}

class _NcfListEditorModalState extends State<NcfListEditorModal> {
  String? currentNcfTypeId;
  String? currentNcfTypeName;
  DateTime expirationDate = DateTime.now().endOfYear();
  TextEditingController expirationDateController = TextEditingController();
  TextEditingController start = TextEditingController();
  TextEditingController end = TextEditingController();

  _onSubmit() async {
    try {
      int? xstart = int.tryParse(start.text);
      int? xend = int.tryParse(end.text);
      var ncfList = NcfsList(
          ncfTypeId: currentNcfTypeId,
          ncfTypeName: currentNcfTypeName,
          start: xstart,
          end: xend,
          expirationDate: expirationDate);

      var secuecia = NcfSecuencia(
          id: currentNcfTypeId,
          lastValue: xstart,
          minValue: xstart,
          maxValue: xend);
      await ncfList.create();
      await secuecia.update();

      Navigator.pop(context, 'CREATE');
    } catch (e) {
      showTopSnackBar(context, message: e.toString(), color: Colors.red);
    }
  }

  _showDatePicker2() async {
    var result = await showDatePicker(
        context: context,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365 * 25)));

    if (result != null) {
      expirationDate = result;
      expirationDateController.value =
          TextEditingValue(text: expirationDate.format(payload: 'DD/MM/YYYY'));
    }
  }

  @override
  void initState() {
    expirationDateController.value =
        TextEditingValue(text: expirationDate.format(payload: 'DD/MM/YYYY'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 450,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(kDefaultPadding),
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(
                  'AGREGANDO LISTA DE NCF',
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(color: Theme.of(context).primaryColor),
                )),
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
            DropdownButtonFormField(
                isExpanded: true,
                items: List.generate(ncfs.length, (index) {
                  var ncf = ncfs[index];
                  return DropdownMenuItem(
                      value: ncf.id, child: Text(ncf.name ?? ''));
                }),
                onChanged: (id) {
                  currentNcfTypeId = id;
                  currentNcfTypeName = ncfs.firstWhere((e) => e.id == id).name;
                }),
            SizedBox(
              height: kDefaultPadding,
            ),
            Row(
              children: [
                Expanded(
                    child: TextFormField(
                  controller: start,
                  decoration:
                      InputDecoration(labelText: 'INICIAL', hintText: '1'),
                )),
                SizedBox(
                  width: kDefaultPadding / 2,
                ),
                Expanded(
                    child: TextFormField(
                  controller: end,
                  decoration:
                      InputDecoration(labelText: 'FINAL', hintText: '9999999'),
                )),
              ],
            ),
            SizedBox(
              height: kDefaultPadding,
            ),
            TextFormField(
              controller: expirationDateController,
              readOnly: true,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                  labelText: 'FECHA DE VENCIMIENTO',
                  hintText: 'DD/MM/YYYY',
                  suffixIcon: IconButton(
                      onPressed: _showDatePicker2,
                      icon: Icon(Icons.calendar_month))),
            ),
            SizedBox(
              height: kDefaultPadding,
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child:
                  ElevatedButton(onPressed: _onSubmit, child: Text('AGREGAR')),
            )
          ],
        ),
      ),
    );
  }
}
