import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/models/credit.note.item.product.dart';
import 'package:uresax_invoice_sys/models/credit.note.item.service.dart';
import 'package:uresax_invoice_sys/models/product.dart';
import 'package:uresax_invoice_sys/models/retention.isr.dart';
import 'package:uresax_invoice_sys/models/retention.tax.dart';
import 'package:uresax_invoice_sys/models/sale.element.abs.dart';
import 'package:uresax_invoice_sys/models/sale.item.abs.dart';
import 'package:uresax_invoice_sys/models/sale.item.product.dart';
import 'package:uresax_invoice_sys/models/sale.item.service.dart';
import 'package:uresax_invoice_sys/models/service.dart';
import 'package:uresax_invoice_sys/models/taxes.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uuid/uuid.dart';

class InvoiceItemGeneratorWidget extends StatefulWidget {
  SaleItem saleItem;

  List<SaleItem> saleItems;

  List<SaleItem> enableds;

  bool editing;

  Function(SaleItem) onChanged;

  InvoiceItemGeneratorWidget(
      {super.key,
      this.editing = false,
      required this.saleItem,
      required this.saleItems,
      required this.enableds,
      required this.onChanged});

  @override
  State<InvoiceItemGeneratorWidget> createState() =>
      _InvoiceItemGeneratorWidgetState();
}

class _InvoiceItemGeneratorWidgetState
    extends State<InvoiceItemGeneratorWidget> {
  List<SaleElement> elements = [];
  List<Taxes> taxes = [];
  List<RetentionTax> retentionsTaxes = [];
  List<RetentionIsr> retentionsIsrs = [];
  TextEditingController net = TextEditingController();
  TextEditingController tax = TextEditingController();
  TextEditingController total = TextEditingController();
  TextEditingController totalToPay = TextEditingController();
  TextEditingController quantity = TextEditingController();

  int? currenId;
  int? currentTaxId;
  int? currentRetentionTaxId;
  String? currentRetentionIsrId;

  SaleElement? el;
  RetentionTax? retentionTax;
  RetentionIsr? retentionIsr;
  Taxes? currentTax;

  int startQuantity = 0;

  String get title {
    if (widget.saleItem is SaleItemService) {
      return 'SERVICIO';
    }

    if (widget.saleItem is SaleItemProduct) {
      return 'PRODUCTO';
    }
    if (widget.saleItem is CreditNoteService) {
      return 'SERVICIO';
    }
    if (widget.saleItem is CreditNoteProduct) {
      return 'PRODUCTO';
    }
    return '';
  }

  _onSelected(int? option) {
    currenId = option;

    if (widget.saleItem is SaleItemService) {
      widget.saleItem.serviceId = option;
    }

    if (widget.saleItem is SaleItemProduct) {
      widget.saleItem.productId = option;
    }

    el = elements.firstWhere((e) => e.id == option);

    currentTaxId = el?.taxId;

    currentTax = taxes.firstWhere((e) => e.id == currentTaxId);

    widget.saleItem.taxId = currentTaxId;

    widget.saleItem.productName = el?.name;

    if (option != null) {
    } else {
      widget.saleItem.total = null;
      widget.saleItem.tax = null;
      widget.saleItem.taxId = null;
      widget.saleItem.discount = null;
      widget.saleItem.discountId = null;
      currentTaxId = null;
      currentRetentionTaxId = null;
    }
    _calc();
  }

  _onSelectedTax(int? option) {
    currentTaxId = option;
    currentTax = taxes.firstWhere((e) => e.id == option);
    widget.saleItem.taxId = option;

    _calc();
  }

  _onSelectedRetentionTax(int? option) {
    currentRetentionTaxId = option;
    retentionTax = retentionsTaxes.firstWhere((e) => e.id == option);

    widget.saleItem.retentionTaxId = option;

    _calc();
  }

  _onSelectedRetentionIsr(String? option) {
    currentRetentionIsrId = option;
    retentionIsr = retentionsIsrs.firstWhere((e) => e.id == option);

    widget.saleItem.retentionIsrId = option;

    _calc();
  }

  _onChangedQuantity(String value) {
    widget.saleItem.quantity = int.tryParse(value) ?? 1;
    _calc();
  }

  _calc() {
    widget.saleItem.net = (el?.price ?? 0) * (widget.saleItem.quantity ?? 1);
    if (widget.saleItem.net != null) {
      widget.saleItem.tax =
          widget.saleItem.net! * ((currentTax?.rate ?? 0) / 100);
    }
    if (widget.saleItem.tax != null) {
      widget.saleItem.retentionTax =
          widget.saleItem.tax! * ((retentionTax?.rate ?? 0) / 100);
    }
    if (widget.saleItem.net != null) {
      widget.saleItem.retentionIsr =
          widget.saleItem.net! * ((retentionIsr?.rate ?? 0) / 100);
    }

    if (widget.saleItem.net != null && widget.saleItem.tax != null) {
      widget.saleItem.total = widget.saleItem.net! + widget.saleItem.tax!;
    }

    net.value =
        TextEditingValue(text: widget.saleItem.net?.toStringAsFixed(2) ?? '');

    total.value =
        TextEditingValue(text: widget.saleItem.total?.toStringAsFixed(2) ?? '');

    var netToPaid = widget.saleItem.total! -
        (widget.saleItem.retentionTax ?? 0) -
        (widget.saleItem.retentionIsr ?? 0);

    quantity.value =
        TextEditingValue(text: widget.saleItem.quantity?.toString() ?? '');

    totalToPay.value = TextEditingValue(
        text:
            widget.saleItem.total == null ? '' : netToPaid.toStringAsFixed(2));
    setState(() {});

    widget.onChanged(widget.saleItem);
  }

  _initAsync() async {
    try {
      if (widget.saleItem is SaleItemService ||
          widget.saleItem is CreditNoteService) {
        elements = [Services(name: 'SERVICIO'), ...await Services.get()];
      }

      if (widget.saleItem is SaleItemProduct ||
          widget.saleItem is CreditNoteProduct) {
        elements = [Products(name: 'PRODUCTO'), ...await Products.get()];
      }

      el = elements.firstWhere((e) => e.id == currenId);
      taxes = [Taxes(name: 'ITBIS'), ...await Taxes.get()];
      retentionsTaxes = [
        RetentionTax(name: 'RETENCION ITBIS'),
        ...await RetentionTax.get()
      ];
      retentionsIsrs = [
        RetentionIsr(name: 'RETENCION ISR'),
        ...await RetentionIsr.get()
      ];
      currentTax = taxes.firstWhere((e) => e.id == currentTaxId);
      retentionTax =
          retentionsTaxes.firstWhere((e) => e.id == currentRetentionTaxId);

      retentionIsr =
          retentionsIsrs.firstWhere((e) => e.id == currentRetentionIsrId);

      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  double get amountPaid {
    if (widget.saleItem.total == null || widget.saleItem.total == 0) {
      return 0;
    }

    return widget.saleItem.total! -
        (widget.saleItem.retentionTax ?? 0) -
        (widget.saleItem.retentionIsr ?? 0);
  }

  @override
  void initState() {
    if (!mounted) return;

    currenId = widget.saleItem.serviceId ?? widget.saleItem.productId;
    currentTaxId = widget.saleItem.retentionTaxId;
    currentRetentionIsrId = widget.saleItem.retentionIsrId;
    currentRetentionTaxId = widget.saleItem.retentionTaxId;

    _initAsync();

    net.value =
        TextEditingValue(text: widget.saleItem.net?.toStringAsFixed(2) ?? '');

    tax.value =
        TextEditingValue(text: widget.saleItem.tax?.toStringAsFixed(2) ?? '');
    total.value =
        TextEditingValue(text: widget.saleItem.total?.toStringAsFixed(2) ?? '');

    startQuantity = widget.saleItem.quantity ?? 1;

    widget.saleItem.returnQuantity = startQuantity;

    quantity.value =
        TextEditingValue(text: (widget.saleItem.quantity ?? 1).toString());

    currentTaxId = widget.saleItem.taxId;

    currentRetentionTaxId = widget.saleItem.retentionTaxId;

    currentRetentionIsrId = widget.saleItem.retentionIsrId;

    totalToPay.value = TextEditingValue(text: amountPaid.toStringAsFixed(2));

    setState(() {});

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          widget.saleItem is CreditNoteProduct ||
                  widget.saleItem is CreditNoteService
              ? Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (widget.saleItem.enabled == true) {
                          if (widget.enableds.length > 1) {
                            widget.saleItem.enabled = false;
                          }
                        } else {
                          widget.saleItem.enabled = true;
                        }
                        setState(() {});

                        widget.onChanged(widget.saleItem);
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.black12),
                        child: widget.saleItem.enabled == true
                            ? Icon(Icons.remove)
                            : Icon(Icons.add),
                      ),
                    ),
                    SizedBox(
                      width: kDefaultPadding,
                    )
                  ],
                )
              : SizedBox(),
          SizedBox(
            width: 250,
            child: DropdownButtonFormField(
                value: currenId,
                isExpanded: true,
                validator: (val) => val == null ? 'CAMPO OBLIGATORIO' : null,
                decoration: InputDecoration(labelText: title),
                items: elements
                    .map((e) => DropdownMenuItem(
                        value: e.id, child: Text(e.name ?? '')))
                    .toList(),
                onChanged: widget.saleItem is CreditNoteProduct ||
                        widget.saleItem is CreditNoteService ||
                        widget.editing
                    ? null
                    : _onSelected),
          ),
          SizedBox(
            width: kDefaultPadding,
          ),
          SizedBox(
            width: 150,
            child: TextFormField(
              controller: net,
              readOnly: true,
              decoration: InputDecoration(labelText: 'NETO', hintText: '0.00'),
            ),
          ),
          SizedBox(
            width: kDefaultPadding,
          ),
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'DESCUENTO'),
                items: [],
                onChanged: widget.saleItem is CreditNoteProduct ||
                        widget.saleItem is CreditNoteService
                    ? null
                    : (option) {}),
          ),
          SizedBox(
            width: kDefaultPadding,
          ),
          SizedBox(
            width: 150,
            child: DropdownButtonFormField(
                value: currentTaxId,
                decoration: InputDecoration(labelText: 'ITBIS'),
                items: taxes
                    .map((e) => DropdownMenuItem(
                        value: e.id, child: Text(e.name ?? '')))
                    .toList(),
                onChanged: widget.saleItem is CreditNoteProduct ||
                        widget.saleItem is CreditNoteService ||
                        widget.editing
                    ? null
                    : _onSelectedTax),
          ),
          SizedBox(
            width: kDefaultPadding,
          ),
          SizedBox(
            width: 150,
            child: TextFormField(
              controller: total,
              readOnly: true,
              decoration: InputDecoration(labelText: 'TOTAL', hintText: '0.00'),
            ),
          ),
          SizedBox(
            width: kDefaultPadding,
          ),
          SizedBox(
            width: 150,
            child: TextFormField(
              controller: quantity,
              readOnly: widget.saleItem is CreditNoteProduct ||
                  widget.saleItem is CreditNoteService ||
                  widget.editing,
              onChanged: _onChangedQuantity,
              decoration: InputDecoration(
                  labelText: 'CANTIDAD',
                  hintText: '0',
                  suffixIcon: widget.saleItem is CreditNoteProduct
                      ? Wrap(
                          children: [
                            IconButton(
                                onPressed: () {
                                  if (widget.saleItem.quantity == 1) return;
                                  widget.saleItem.quantity =
                                      widget.saleItem.quantity! - 1;
                                  widget.saleItem.returnQuantity =
                                      widget.saleItem.returnQuantity! - 1;
                                  _calc();
                                },
                                icon: Icon(Icons.remove)),
                            SizedBox(
                              width: kDefaultPadding / 2,
                            ),
                            IconButton(
                                onPressed: () {
                                  if (widget.saleItem.quantity! >=
                                      startQuantity) {
                                    return;
                                  }
                                  widget.saleItem.quantity =
                                      widget.saleItem.quantity! + 1;
                                  widget.saleItem.returnQuantity =
                                      widget.saleItem.returnQuantity! + 1;

                                  _calc();
                                },
                                icon: Icon(Icons.add)),
                            SizedBox(
                              width: kDefaultPadding / 2,
                            )
                          ],
                        )
                      : SizedBox()),
            ),
          ),
          SizedBox(
            width: kDefaultPadding,
          ),
          SizedBox(
            width: 150,
            child: DropdownButtonFormField(
                isExpanded: true,
                value: currentRetentionTaxId,
                decoration: InputDecoration(labelText: 'RETENCION ITBIS'),
                items: retentionsTaxes
                    .map((e) => DropdownMenuItem(
                        value: e.id, child: Text(e.name ?? '')))
                    .toList(),
                onChanged: widget.saleItem is CreditNoteProduct ||
                        widget.saleItem is CreditNoteService ||
                        (widget.editing &&
                            widget.saleItem.retentionTaxId != null)
                    ? null
                    : _onSelectedRetentionTax),
          ),
          SizedBox(
            width: kDefaultPadding,
          ),
          SizedBox(
            width: 150,
            child: DropdownButtonFormField(
                value: currentRetentionIsrId,
                isExpanded: true,
                decoration: InputDecoration(labelText: 'RETENCION ISR'),
                items: retentionsIsrs
                    .map((e) => DropdownMenuItem(
                        value: e.id, child: Text(e.name ?? '')))
                    .toList(),
                onChanged: widget.saleItem is CreditNoteProduct ||
                        widget.saleItem is CreditNoteService ||
                        (widget.editing &&
                            widget.saleItem.retentionIsrId != null)
                    ? null
                    : _onSelectedRetentionIsr),
          ),
          SizedBox(
            width: kDefaultPadding,
          ),
          SizedBox(
            width: 150,
            child: TextFormField(
              controller: totalToPay,
              readOnly: true,
              decoration:
                  InputDecoration(labelText: 'TOTAL A PAGAR', hintText: '0.00'),
            ),
          )
        ],
      ),
    );
  }
}
