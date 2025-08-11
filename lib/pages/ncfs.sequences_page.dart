import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/models/ncf.secuencia.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';

class NcfsSequencesPage extends StatefulWidget {
  const NcfsSequencesPage({super.key});

  @override
  State<NcfsSequencesPage> createState() => _NcfsSequencesPageState();
}

class _NcfsSequencesPageState extends State<NcfsSequencesPage> {
  List<NcfSecuencia> ncfs = [];

  _initAsync() async {
    ncfs = await NcfSecuencia.get();
    setState(() {});
  }

  /*_updateNcf(NcfSecuencia ncf, TextEditingController min,
      TextEditingController max) async {
    try {
      var xmin = int.tryParse(min.text);
      var xmax = int.tryParse(max.text);

      if (xmin == null) return;

      ncf.lastValue = xmin;

      ncf.maxValue = xmax;
      await ncf.update();
      showTopSnackBar(context,
          message: 'LAS SECUENCIAS DE ${ncf.name} FUE EDITADA',
          color: Colors.green);
    } catch (e) {
      showTopSnackBar(context, message: e.toString(), color: Colors.red);
    }
  }*/

  @override
  void initState() {
    _initAsync();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('TUS COMPROBANTES (${ncfs.length})'),
        ),
        body: ListView.separated(
            itemCount: ncfs.length,
            separatorBuilder: (ctx, index) => const Divider(),
            itemBuilder: (ctx, index) {
              var ncf = ncfs[index];
              TextEditingController min =
                  TextEditingController(text: ncf.lastValue?.toString() ?? '1');

              TextEditingController max =
                  TextEditingController(text: ncf.maxValue.toString());

              return ListTile(
                title: Text(ncf.name ?? ''),
                minVerticalPadding: kDefaultPadding,
                minTileHeight: 70,
                leading: Container(
                  width: 70,
                  height: 70,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(90)),
                  child: Icon(
                    Icons.receipt_long,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                trailing: Wrap(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 50,
                      child: TextFormField(
                        readOnly: true,
                        controller: min,
                        decoration:
                            InputDecoration(labelText: 'MIN', hintText: '0'),
                      ),
                    ),
                    SizedBox(
                      width: kDefaultPadding / 2,
                    ),
                    SizedBox(
                      width: 100,
                      height: 50,
                      child: TextFormField(
                        readOnly: true,
                        controller: max,
                        decoration:
                            InputDecoration(labelText: 'MAX', hintText: '0'),
                      ),
                    ),
                    SizedBox(
                      width: kDefaultPadding / 2,
                    ),
                    /*SizedBox(
                      width: 190,
                      height: 50,
                      child: ElevatedButton(
                          onPressed: () {
                            _updateNcf(ncf, min, max);
                          },
                          child: Text('EDITAR NCF')),
                    )*/
                  ],
                ),
              );
            }));
  }
}
