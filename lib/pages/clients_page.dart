import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/modals/client.editor.modal.dart';
import 'package:uresax_invoice_sys/models/client.dart';
import 'package:uresax_invoice_sys/settings.dart';

class ClientsPage extends StatefulWidget {
  bool selectorMode;

  Client? client;

  ClientsPage({super.key, this.selectorMode = false, this.client});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  List<Client> clients = [];
  _initAsync() async {
    try {
      clients = await Client.get();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  _showClientModal({required Client client, bool editing = false}) {
    return showDialog(
        context: context,
        builder: (ctx) => ClientEditorModal(client: client, editing: editing));
  }

  _selectedClient(Client client) async {
    Navigator.pop(context, client);
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
        title: Text('TUS CLIENTES'),
      ),
      body: ListView.separated(
          separatorBuilder: (ctx, i) => const Divider(),
          itemCount: clients.length,
          itemBuilder: (ctx, index) {
            var client = clients[index];
            return ListTile(
              minVerticalPadding: kDefaultPadding,
              onTap: widget.selectorMode ? () => _selectedClient(client) : null,
              leading: Container(
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(90),
                  color: Theme.of(context).primaryColor.withOpacity(0.04),
                ),
                child: Center(
                  child: Icon(
                    Icons.person_2,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
              ),
              title: Text(client.name ?? ''),
              trailing: Wrap(
                children: [
                  IconButton(
                      onPressed: () async {
                        var res = await _showClientModal(
                            client: client, editing: true);
                        if (res == 'UPDATE') {
                          clients = await Client.get();
                          setState(() {});
                        }
                      },
                      icon: Icon(Icons.edit))
                ],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var res = await _showClientModal(
              client:
                  Client(identification: widget.client?.identification ?? ''));
          if (res == 'CREATE') {
            clients = await Client.get();
            setState(() {});
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('SE CREO UN CLIENTE')));
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
