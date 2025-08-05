import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:uresax_invoice_sys/modals/ncf.list.editor.modal.dart';
import 'package:uresax_invoice_sys/models/ncfList.dart';
import 'package:uresax_invoice_sys/settings.dart';

class NcfListPage extends StatefulWidget {
  const NcfListPage({super.key});

  @override
  State<NcfListPage> createState() => _NcfListPageState();
}

class _NcfListPageState extends State<NcfListPage> {
  List<NcfsList> ncfsList = [];

  _initAsync() async {
    try {
      ncfsList = await NcfsList.get();
      setState(() {});
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    _initAsync();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LISTA DE NCFS (${ncfsList.length})'),
      ),
      body: ListView.separated(
        itemCount: ncfsList.length,
        separatorBuilder: (ctx, i) => const Divider(),
        itemBuilder: (ctx, index) {
          var ncfList = ncfsList[index];
          return ListTile(
            minTileHeight: 90,
            contentPadding: EdgeInsets.symmetric(
                vertical: kDefaultPadding, horizontal: kDefaultPadding),
            title: Text(ncfList.ncfTypeName ?? ''),
            subtitle: Text('INICIAL: ${ncfList.start} - FINAL: ${ncfList.end}'),
            trailing: Wrap(
              children: [
                Text(
                    'Fecha de Vencimiento: ${ncfList.expirationDate?.format(payload: 'DD/MM/YYYY')}'),
                SizedBox(
                  width: kDefaultPadding,
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            var res = await showDialog(
                context: context,
                builder: (ctx) {
                  return NcfListEditorModal();
                });
            if (res == 'CREATE') {
              _initAsync();
            }
          }),
    );
  }
}
