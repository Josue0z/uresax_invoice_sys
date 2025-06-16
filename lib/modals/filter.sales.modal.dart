import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/settings.dart';

class FilterSalesModal extends StatefulWidget {
  String? ncfTypeId;
  SaleStatus? saleStatus;
  FilterSalesModal(
      {super.key, required this.saleStatus, required this.ncfTypeId});

  @override
  State<FilterSalesModal> createState() => _FilterSalesModalState();
}

class _FilterSalesModalState extends State<FilterSalesModal> {
  List<Map<String, dynamic>> options = [
    {'id': SaleStatus.all, 'name': 'TODAS'},
    {'id': SaleStatus.paid, 'name': 'PAGADA'},
    {'id': SaleStatus.notPaid, 'name': 'PENDIENTE'}
  ];

  _onSaved() async {
    Navigator.pop(context,
        {'ncfTypeId': widget.ncfTypeId, 'saleStatus': widget.saleStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
          child: SizedBox(
        width: 400,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(kDefaultPadding),
          children: [
            Row(
              children: [
                Expanded(
                    child: Text('Filtros',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(color: Theme.of(context).primaryColor))),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close))
              ],
            ),
            SizedBox(
              height: kDefaultPadding,
            ),
            DropdownButtonFormField<String>(
                value: widget.ncfTypeId,
                isExpanded: true,
                decoration: InputDecoration(labelText: 'TIPO DE COMPROBANTE'),
                items: ncfs
                    .map((e) => DropdownMenuItem(
                        value: e.id, child: Text(e.name ?? '')))
                    .toList(),
                onChanged: (option) {
                  widget.ncfTypeId = option;
                }),
            SizedBox(height: kDefaultPadding),
            DropdownButtonFormField<SaleStatus>(
                value: widget.saleStatus,
                isExpanded: true,
                decoration: InputDecoration(labelText: 'ESTADO'),
                items: options
                    .map((e) => DropdownMenuItem(
                        value: e['id'] as SaleStatus,
                        child: Text(e['name'] ?? '')))
                    .toList(),
                onChanged: (option) {
                  widget.saleStatus = option;
                }),
            SizedBox(height: kDefaultPadding),
            SizedBox(
              width: double.infinity,
              height: 50,
              child:
                  ElevatedButton(onPressed: _onSaved, child: Text('APLICAR')),
            )
          ],
        ),
      )),
    );
  }
}
