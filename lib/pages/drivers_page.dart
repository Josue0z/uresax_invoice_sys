import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/modals/drivers.editor.modal.dart';
import 'package:uresax_invoice_sys/models/drivers.dart';
import 'package:uresax_invoice_sys/settings.dart';

class DriversPage extends StatefulWidget {
  bool selectedMode;

  DriversPage({super.key, this.selectedMode = false});

  @override
  State<DriversPage> createState() => _DriversPageState();
}

class _DriversPageState extends State<DriversPage> {
  _initAsync() async {
    try {
      drivers = await Drivers.get();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  initState() {
    _initAsync();
    super.initState();
  }

  List<Drivers> drivers = [];
  _onSelected(Drivers? driver) {
    Navigator.pop(context, driver);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CONDUCTORES (${drivers.length})'),
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
                    drivers = await Drivers.get(search: words);
                    setState(() {});
                  },
                  decoration: InputDecoration(
                      hintText: 'Nombre...',
                      fillColor: Colors.white,
                      filled: true,
                      suffixIcon: Icon(Icons.search)),
                ),
              ),
              SizedBox(width: kDefaultPadding),
            ],
          )
        ],
      ),
      body: ListView.separated(
          itemBuilder: (ctx, index) {
            var driver = drivers[index];
            return ListTile(
              title: Text(driver.name ?? ''),
              onTap: !widget.selectedMode
                  ? null
                  : () {
                      _onSelected(driver);
                    },
              trailing: Wrap(
                children: [
                  IconButton(
                      onPressed: () {
                        _onSelected(driver);
                      },
                      icon: Icon(Icons.arrow_right)),
                  IconButton(
                      onPressed: () async {
                        var res = await showDialog(
                            context: context,
                            builder: (ctx) => DriversEditorModal(
                                  driver: driver,
                                  editing: true,
                                ));
                        if (res != null) {
                          drivers = await Drivers.get();
                          setState(() {});
                        }
                      },
                      icon: Icon(Icons.edit))
                ],
              ),
            );
          },
          separatorBuilder: (ctx, i) => const Divider(),
          itemCount: drivers.length),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var res = await showDialog(
                context: context,
                builder: (ctx) => DriversEditorModal(driver: Drivers()));
            if (res != null) {
              drivers = await Drivers.get();
              setState(() {});
            }
          },
          child: Icon(Icons.add)),
    );
  }
}
