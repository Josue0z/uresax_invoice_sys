import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/modals/warehouses.editor.modal.dart';
import 'package:uresax_invoice_sys/models/warehouse.dart';
import 'package:uresax_invoice_sys/settings.dart';

class WareHousesPage extends StatefulWidget {
  bool selectorMode;
  WareHousesPage({super.key, this.selectorMode = false});

  @override
  State<WareHousesPage> createState() => _WareHousesPageState();
}

class _WareHousesPageState extends State<WareHousesPage> {
  List<WareHouses> wareHouses = [];

  _onSelected(WareHouses wareHouse) {
    Navigator.pop(context, wareHouse);
  }

  _showWareHousesEditorModal(BuildContext context,
      {required WareHouses wareHouse, bool editing = false}) {
    showDialog(
      context: context,
      builder: (context) {
        return WareHousesEditorModal(
          wareHouse: wareHouse,
          editing: editing,
        );
      },
    ).then((event) async {
      if (event != null) {
        if (event != null) {
          wareHouses = await WareHouses.get();
          setState(() {});
        }
      }
    });
  }

  _initAsync() async {
    try {
      wareHouses = await WareHouses.get();

      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    _initAsync();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    wareHouses.removeWhere((e) => e.id == null);
    return Scaffold(
      appBar: AppBar(
        title: Text('ALMACENES (${wareHouses.length})'),
        actions: [
          Wrap(
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 50,
                child: TextFormField(
                  onChanged: (words) async {
                    wareHouses = await WareHouses.get(search: words);
                    setState(() {});
                  },
                  decoration: InputDecoration(
                      hintText: 'Nombre...',
                      fillColor: Colors.white,
                      filled: true,
                      suffixIcon: Icon(Icons.search)),
                ),
              ),
              SizedBox(width: kDefaultPadding)
            ],
          )
        ],
      ),
      body: ListView.separated(
          itemCount: wareHouses.length,
          separatorBuilder: (ctx, i) => const Divider(),
          itemBuilder: (ctx, index) {
            var wareHouse = wareHouses[index];
            return ListTile(
              minVerticalPadding: kDefaultPadding,
              leading: Container(
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(90),
                  color: Theme.of(context).primaryColor.withOpacity(0.04),
                ),
                child: Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
              ),
              title: Text(wareHouse.name ?? ''),
              onTap: widget.selectorMode
                  ? () {
                      _onSelected(wareHouse);
                    }
                  : null,
              trailing: Wrap(
                children: [
                  widget.selectorMode
                      ? IconButton(
                          onPressed: () {
                            _onSelected(wareHouse);
                          },
                          icon: Icon(Icons.arrow_right_outlined))
                      : SizedBox(),
                  IconButton(
                      onPressed: () {
                        _showWareHousesEditorModal(context,
                            wareHouse: wareHouse, editing: true);
                      },
                      icon: Icon(Icons.edit))
                ],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showWareHousesEditorModal(context,
                wareHouse: WareHouses(), editing: false);
          },
          child: Icon(Icons.add)),
    );
  }
}
