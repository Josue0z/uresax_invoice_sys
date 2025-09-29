import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uresax_invoice_sys/modals/client.editor.modal.dart';
import 'package:uresax_invoice_sys/models/client.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';

class ClientsPage extends StatefulWidget {
  bool selectorMode;

  Client? client;

  ClientsPage({super.key, this.selectorMode = false, this.client});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  List<Client> clients = [];
  Future? future;
  _initAsync([String? words]) async {
    try {
      clients = await Client.get(search: words);
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

  Widget get contentFilled {
    return ListView.separated(
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
            subtitle: Text(client.identification ?? ''),
            trailing: Wrap(
              children: [
                IconButton(
                    onPressed: () async {
                      var res =
                          await _showClientModal(client: client, editing: true);
                      if (res == 'UPDATE') {
                        setState(() {
                          future = _initAsync();
                        });
                        showTopSnackBar(context,
                            message: 'SE ACTUALIZO EL CLIENTE',
                            color: Colors.green);
                      }
                    },
                    icon: Icon(Icons.edit))
              ],
            ),
          );
        });
  }

  Widget get contentEmpty {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/svgs/undraw_terms_sx63.svg', width: 250)
        ],
      ),
    );
  }

  Widget get contentLoading {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget contentError(dynamic error) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(error.toString())],
      ),
    );
  }

  @override
  void initState() {
    setState(() {
      future = _initAsync();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TUS CLIENTES'),
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
                    setState(() {
                      future = _initAsync(words);
                    });
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
      body: FutureBuilder(
          future: future,
          builder: (ctx, s) {
            if (s.connectionState == ConnectionState.waiting) {
              return contentLoading;
            }

            if (s.hasError) {
              return contentError(s.error);
            }
            if (s.connectionState == ConnectionState.done &&
                clients.isNotEmpty) {
              return contentFilled;
            }

            return contentEmpty;
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var res = await _showClientModal(
              client:
                  Client(identification: widget.client?.identification ?? ''));
          if (res == 'CREATE') {
            setState(() {
              future = _initAsync();
            });
            showTopSnackBar(context,
                message: 'SE CREO UN CLIENTE', color: Colors.green);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
