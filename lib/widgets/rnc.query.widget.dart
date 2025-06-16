import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uresax_invoice_sys/models/client.dart';
import 'package:uresax_invoice_sys/models/taxpayer.dart';
import 'package:uresax_invoice_sys/pages/clients_page.dart';
import 'package:uresax_invoice_sys/settings.dart';

class RncQueryWidget extends StatefulWidget {
  TextEditingController editingController;
  TextEditingController clientName;

  Function(TaxPayer?, bool isValid) onChanged;
  RncQueryWidget(
      {super.key,
      required this.editingController,
      required this.clientName,
      required this.onChanged});

  @override
  State<RncQueryWidget> createState() => _RncQueryWidgetState();
}

class _RncQueryWidgetState extends State<RncQueryWidget> {
  Client? client;
  TaxPayer? taxPayer;
  bool notFound = false;

  _handler() async {
    setState(() {
      notFound = false;
    });
    var words = widget.editingController.text;
    if (words.length == 9 || words.length == 11) {
      client = await Client.findById(words);

      if (client == null) {
        taxPayer = await TaxPayer.findById(words);
      }

      var name = client?.name ?? taxPayer?.taxPayerCompanyName;

      if (name != null) {
        widget.clientName.value = TextEditingValue(text: name);
        widget.onChanged(taxPayer, true);
      } else {
        widget.clientName.value = TextEditingValue(text: 'NO ENCONTRADO');
        widget.onChanged(null, false);
        setState(() {
          notFound = true;
        });
      }
    } else {
      widget.clientName.value = TextEditingValue.empty;
      widget.onChanged(null, false);
    }
  }

  _showClientsPage() async {
    client = await Navigator.push<Client?>(
        context,
        MaterialPageRoute(
            builder: (ctx) => ClientsPage(
                  selectorMode: true,
                  client: Client(identification: widget.editingController.text),
                )));

    if (client != null) {
      widget.clientName.value = TextEditingValue(text: client?.name ?? '');
      widget.editingController.value =
          TextEditingValue(text: client?.identification ?? '');
      setState(() {});
    }
  }

  @override
  void initState() {
    widget.editingController.addListener(_handler);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.clientName,
          readOnly: true,
          decoration:
              InputDecoration(labelText: 'RAZON SOCIAL', hintText: 'NOMBRE...'),
        ),
        SizedBox(
          height: kDefaultPadding,
        ),
        TextFormField(
          controller: widget.editingController,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (val) => val!.isEmpty
              ? 'CAMPO OBLIGATORIO'
              : !(val.length == 9 || val.length == 11)
                  ? 'LA CANTIDAD DE DIGITOS DEBE SER 9 O 11'
                  : null,
          decoration: InputDecoration(
              labelText: 'RNC/CEDULA',
              hintText: 'IDENTIFICACION',
              suffixIcon: notFound
                  ? IconButton(
                      onPressed: _showClientsPage, icon: Icon(Icons.add))
                  : SizedBox()),
        )
      ],
    );
  }
}
