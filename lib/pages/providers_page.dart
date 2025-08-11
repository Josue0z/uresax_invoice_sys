import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/modals/provider.editor.modal.dart';
import 'package:uresax_invoice_sys/models/provider.dart';
import 'package:uresax_invoice_sys/settings.dart';

class ProvidersPage extends StatefulWidget {
  bool selectorMode;
  ProvidersPage({super.key, this.selectorMode = false});

  @override
  State<ProvidersPage> createState() => _ProvidersPageState();
}

class _ProvidersPageState extends State<ProvidersPage> {
  List<Providers> providers = [];

  _onSelected(Providers provider) {
    Navigator.pop(context, provider);
  }

  _showProviderEditorModal(BuildContext context,
      {required Providers provider, bool editing = false}) {
    showDialog(
      context: context,
      builder: (context) {
        return ProviderEditorModal(
          provider: Providers(),
          editing: editing,
        );
      },
    ).then((event) async {
      if (event != null) {
        if (event != null) {
          providers = await Providers.get();
          setState(() {});
        }
      }
    });
  }

  _initAsync() async {
    try {
      providers = await Providers.get();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('TUS PROVEEDORES (${providers.length})'),
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
                    providers = await Providers.get(search: words);
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
          itemCount: providers.length,
          separatorBuilder: (ctx, i) => const Divider(),
          itemBuilder: (ctx, index) {
            var provider = providers[index];
            return ListTile(
              title: Text(provider.name ?? ''),
              onTap: widget.selectorMode
                  ? () {
                      _onSelected(provider);
                    }
                  : null,
              trailing: Wrap(
                children: [
                  widget.selectorMode
                      ? IconButton(
                          onPressed: () {
                            _onSelected(provider);
                          },
                          icon: Icon(Icons.arrow_right_outlined))
                      : SizedBox(),
                  IconButton(
                      onPressed: () {
                        _showProviderEditorModal(context,
                            provider: provider, editing: true);
                      },
                      icon: Icon(Icons.edit))
                ],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showProviderEditorModal(context,
                provider: Providers(), editing: false);
          },
          child: Icon(Icons.add)),
    );
  }
}
