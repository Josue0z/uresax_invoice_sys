import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uresax_invoice_sys/modals/service.editor.modal.dart';
import 'package:uresax_invoice_sys/models/service.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/extensions.dart';
import 'package:uresax_invoice_sys/widgets/content.error.widget.dart';

class ServicesPage extends StatefulWidget {
  bool selectedMode;
  ServicesPage({super.key, this.selectedMode = false});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  List<Services> services = [];
  Future? future;

  _showModal({bool editing = false, required Services service}) async {
    var res = await showDialog(
        context: context,
        builder: (ctx) => ServiceEditorModal(
              editing: editing,
              service: service,
            ));

    if (res == 'CREATE') {
      setState(() {
        future = _initAsync();
      });
    }

    if (res == 'UPDATE') {
      setState(() {
        future = _initAsync();
      });
    }
  }

  _initAsync([String? words]) async {
    try {
      services = await Services.get(search: words);
    } catch (e) {
      print(e);
    } finally {
      setState(() {});
    }
  }

  Widget get contentFilled {
    return ListView.separated(
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
        title: Text('TUS SERVICIOS (${services.length})'),
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
              SizedBox(width: kDefaultPadding)
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
              return ContentErrorWidget(
                error: s.error.toString(),
                onRetry: () {
                  setState(() {
                    future = _initAsync();
                  });
                },
              );
            }
            if (s.connectionState == ConnectionState.done &&
                services.isNotEmpty) {
              return contentFilled;
            }

            return contentEmpty;
          }),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _showModal(service: Services()),
          child: Icon(Icons.add)),
    );
  }
}
