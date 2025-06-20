import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/modals/service.editor.modal.dart';
import 'package:uresax_invoice_sys/models/service.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/extensions.dart';

class ServicesPage extends StatefulWidget {
  bool selectedMode;
  ServicesPage({super.key, this.selectedMode = false});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  List<Services> services = [];

  _showModal({bool editing = false, required Services service}) async {
    var res = await showDialog(
        context: context,
        builder: (ctx) => ServiceEditorModal(
              editing: editing,
              service: service,
            ));

    if (res == 'CREATE') {
      services = await Services.get();
      setState(() {});
    }

    if (res == 'UPDATE') {
      services = await Services.get();
      setState(() {});
    }
  }

  _initAsync() async {
    try {
      services = await Services.get();
      setState(() {});
    } catch (e) {}
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
        title: Text('TUS SERVICIOS (${services.length})'),
      ),
      body: ListView.separated(
          separatorBuilder: (ctx, i) => const Divider(),
          itemCount: services.length,
          itemBuilder: (ctx, index) {
            var service = services[index];
            return ListTile(
              minVerticalPadding: kDefaultPadding,
              onTap: widget.selectedMode
                  ? () {
                      Navigator.pop(context, service);
                    }
                  : null,
              leading: Container(
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(90),
                  color: Theme.of(context).primaryColor.withOpacity(0.04),
                ),
                child: Center(
                  child: Icon(
                    Icons.local_mall_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
              ),
              title: Text(service.name ?? '',
                  style: Theme.of(context).textTheme.bodyMedium),
              trailing: Wrap(
                children: [
                  Text(service.price?.toCoin() ?? '',
                      style: Theme.of(context).textTheme.bodyMedium),
                  SizedBox(width: kDefaultPadding),
                  IconButton(
                      onPressed: () {
                        _showModal(editing: true, service: service);
                      },
                      icon: Icon(Icons.edit))
                ],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _showModal(service: Services()),
          child: Icon(Icons.add)),
    );
  }
}
