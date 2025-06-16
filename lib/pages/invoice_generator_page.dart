import 'package:amount_input_formatter/amount_input_formatter.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:printing/printing.dart';
import 'package:uresax_invoice_sys/modals/ncfs.selector.modal.dart';
import 'package:uresax_invoice_sys/models/credit.note.item.product.dart';
import 'package:uresax_invoice_sys/models/credit.note.item.service.dart';
import 'package:uresax_invoice_sys/models/credit.note.product.dart';
import 'package:uresax_invoice_sys/models/credit.note.service.dart';
import 'package:uresax_invoice_sys/models/ncftype.dart';
import 'package:uresax_invoice_sys/models/sale.abs.dart';
import 'package:uresax_invoice_sys/models/sale.item.abs.dart';
import 'package:uresax_invoice_sys/models/sale.item.product.dart';
import 'package:uresax_invoice_sys/models/sale.item.service.dart';
import 'package:uresax_invoice_sys/models/sale.product.dart';
import 'package:uresax_invoice_sys/models/sale.service.dart';
import 'package:uresax_invoice_sys/models/taxpayer.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/extensions.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';
import 'package:uresax_invoice_sys/utils/invoices.functions.dart';
import 'package:uresax_invoice_sys/widgets/invoice_item_generator_widget.dart';
import 'package:uresax_invoice_sys/widgets/rnc.query.widget.dart';

class InvoiceGeneratorPage extends StatefulWidget {
  SaleMode mode;
  Sale sale;
  List<SaleItem> items;

  bool editing;

  InvoiceGeneratorPage(
      {super.key,
      this.mode = SaleMode.service,
      required this.sale,
      this.items = const [],
      this.editing = false});

  @override
  State<InvoiceGeneratorPage> createState() => _InvoiceGeneratorPageState();
}

class _InvoiceGeneratorPageState extends State<InvoiceGeneratorPage> {
  String? currentNcfTypeId = '50';
  int? currentPaymentMethodId;
  int? currentBankId;
  int? currentCurrencyId;
  String? currentTypeIncomeId = '01';
  TaxPayer? taxPayer;
  TextEditingController description = TextEditingController();
  TextEditingController retentionDateController = TextEditingController();
  DateTime? retentionDate;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AmountInputFormatter amountInputFormatter =
      AmountInputFormatter(fractionalDigits: 2);
  TextEditingController amount = TextEditingController();
  TextEditingController rncOrId = TextEditingController();
  TextEditingController clientName = TextEditingController();
  TextEditingController transfRef = TextEditingController();
  TextEditingController rate = TextEditingController();

  bool isValid = false;
  List<NcfType> _ncfs = [];

  Sale? _currentSale;

  _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        widget.sale.ncfTypeId = currentNcfTypeId;
        widget.sale.items = widget.items;
        widget.sale.net = calcs[0];
        widget.sale.discount = calcs[1];
        widget.sale.tax = calcs[2];
        widget.sale.total = calcs[3];
        widget.sale.retentionIsr = calcs[4];
        widget.sale.retentionTax = calcs[5];
        widget.sale.paymentMethodId = currentPaymentMethodId;
        widget.sale.clientId = rncOrId.text;
        widget.sale.typeIncomeId = currentTypeIncomeId;
        widget.sale.description = description.text;
        widget.sale.clientName = clientName.text;
        widget.sale.retentionDate = retentionDate;
        widget.sale.currencyId = currentCurrencyId;

        widget.sale.rate = 1;

        if (rate.text.isNotEmpty) {
          widget.sale.rate = double.tryParse(rate.text);
        }

        widget.sale.clientType = rncOrId.text.length == 9
            ? 1
            : rncOrId.text.length == 11
                ? 2
                : null;

        if (widget.sale is SaleService) {
          widget.sale.invoiceTypeId = 1;
        }

        if (widget.sale is SaleProduct) {
          widget.sale.invoiceTypeId = 2;
        }

        if (!widget.editing) {
          widget.sale.effective = 0;
          widget.sale.creditCard = 0;
          widget.sale.checkOrTransf = 0;
          widget.sale.saleToCredit = 0;
          widget.sale.law10 = 0;
        }
        widget.sale.paid = 0;

        widget.sale.bankId = currentBankId;
        widget.sale.transfRef = transfRef.text;
        if (currentNcfTypeId != null && currentNcfTypeId!.startsWith('3')) {
          widget.sale.prefix = 'E';
          widget.sale.maxSequence = 10;
        } else if (currentNcfTypeId != null && currentNcfTypeId == '50') {
          widget.sale.prefix = 'P';
          widget.sale.maxSequence = 8;
        } else {
          widget.sale.prefix = 'B';
          widget.sale.maxSequence = 8;
        }

        widget.sale.paid = amountInputFormatter.doubleValue;

        if (!widget.editing &&
            (widget.sale.debt == 0 || widget.sale.debt == null)) {
          if (currentPaymentMethodId == 1) {
            widget.sale.effective = widget.sale.paid;
          }

          if (currentPaymentMethodId == 2) {
            widget.sale.creditCard = widget.sale.paid;
          }

          if (currentPaymentMethodId == 3) {
            widget.sale.checkOrTransf = widget.sale.paid;
          }

          if (currentPaymentMethodId == 4) {
            widget.sale.saleToCredit = widget.sale.paid;
          }
        } else {
          if (currentPaymentMethodId == 1) {
            widget.sale.effective = widget.sale.effective! + widget.sale.paid!;
          }

          if (currentPaymentMethodId == 2) {
            widget.sale.creditCard =
                widget.sale.creditCard! + widget.sale.paid!;
          }

          if (currentPaymentMethodId == 3) {
            widget.sale.checkOrTransf =
                widget.sale.checkOrTransf! + widget.sale.paid!;
          }

          if (currentPaymentMethodId == 4) {
            widget.sale.saleToCredit =
                widget.sale.saleToCredit! + widget.sale.paid!;
          }
        }

        Sale? sale;

        if (!widget.editing) {
          sale = await widget.sale.create();
        } else {
          sale = await widget.sale.update();
        }

        var doc = createDefaultInvoice(sale!);
        await Printing.layoutPdf(
          onLayout: (format) async => await doc.save(),
        );

        Navigator.pop(context, widget.editing ? 'UPDATE' : null);

        showTopSnackBar(context,
            message: widget.editing ? 'FACTURA EDITADA' : 'FACTURA CREADA',
            color: Colors.green);
      } catch (e) {
        showTopSnackBar(context, message: e.toString(), color: Colors.red);
      }
    }
  }

  _onSelectedNcf(String? option) async {
    currentNcfTypeId = option;

    if (option == '50') {
      currentPrefix = 'P';
      maxSequence = 8;
    } else {
      if (!electronicNcfEnabled) {
        currentPrefix = 'B';
        maxSequence = 8;
      } else {
        currentPrefix = 'E';
        maxSequence = 10;
      }
    }
    /*if (option != null) {
       await _getNcfLabel();
    } else {
    ncfLabel = '';
    }*/
  }

  _addSaleItemService() async {
    widget.items.add(SaleItemService());
    setState(() {});
  }

  _addSaleItemProduct() {
    widget.items.add(SaleItemProduct());
    setState(() {});
  }

  _addSaleItem() {
    if (widget.mode == SaleMode.service) {
      _addSaleItemService();
    }

    if (widget.mode == SaleMode.product) {
      _addSaleItemProduct();
    }
  }

  List<double> get calcs {
    double subtotal = 0;
    double discount = 0;
    double tax = 0;
    double total = 0;
    double retentionTax = 0;
    double retentionIsr = 0;
    for (int i = 0; i < widget.items.length; i++) {
      var item = widget.items[i];

      subtotal += item.enabled == true ? widget.items[i].net ?? 0 : 0;
      discount += item.enabled == true ? widget.items[i].discount ?? 0 : 0;
      tax += item.enabled == true ? widget.items[i].tax ?? 0 : 0;
      total += item.enabled == true ? widget.items[i].total ?? 0 : 0;
      retentionIsr +=
          item.enabled == true ? widget.items[i].retentionIsr ?? 0 : 0;
      retentionTax +=
          item.enabled == true ? widget.items[i].retentionTax ?? 0 : 0;
    }

    return [
      subtotal,
      discount,
      tax,
      total,
      retentionIsr,
      retentionTax,
      (total - (retentionIsr + retentionTax))
    ];
  }

  List<double> get calcsDollarsToDop {
    double xrate = 1;

    double? calcRate = double.tryParse(rate.text);
    if (calcRate != null) {
      xrate = calcRate;
    }
    return [
      calcs[0] * xrate,
      calcs[1] * xrate,
      calcs[2] * xrate,
      calcs[3] * xrate,
      calcs[4] * xrate,
      calcs[5] * xrate,
      calcs[6] * xrate
    ];
  }

  String get net {
    if (currentCurrencyId == 2) {
      return calcs[0].toUS();
    }

    return calcs[0].toDop();
  }

  String get discount {
    if (currentCurrencyId == 2) {
      return calcs[1].toUS();
    }

    return calcs[1].toDop();
  }

  String get tax {
    if (currentCurrencyId == 2) {
      return calcs[2].toUS();
    }
    return calcs[2].toDop();
  }

  String get total {
    if (currentCurrencyId == 2) {
      return calcs[3].toUS();
    }
    return calcs[3].toDop();
  }

  String get retentionTax {
    if (currentCurrencyId == 2) {
      return calcs[5].toUS();
    }
    return calcs[5].toDop();
  }

  String get retentionIsr {
    if (currentCurrencyId == 2) {
      return calcs[4].toUS();
    }
    return calcs[4].toDop();
  }

  String get amountPaid {
    if (currentCurrencyId == 2) {
      return calcs[6].toUS();
    }
    return calcs[6].toDop();
  }

  _showDatePicker() async {
    var result = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365 * 25)));

    retentionDate = result;
    retentionDateController.value = TextEditingValue(
        text: retentionDate?.format(payload: 'DD/MM/YYYY') ?? '');
  }

  bool get isSale {
    return widget.sale is SaleService || widget.sale is SaleProduct;
  }

  double get debt {
    if (widget.sale.amountPaid != null && widget.editing) {
      return (calcs[6] - (widget.sale.amountPaid!));
    }
    return (calcs[6] - (amountInputFormatter.doubleValue));
  }

  NcfType? currentNcfType;
  String currentPrefix = 'P';
  int maxSequence = 8;

  String ncfLabel = '';

  _getNcfLabel() async {
    currentNcfType = _ncfs.firstWhere((e) => e.id == currentNcfTypeId);

    var lastSeq = await currentNcfType?.getLastSeq();

    ncfLabel =
        '$currentPrefix$currentNcfTypeId${lastSeq?.padLeft(maxSequence, '0')}';

    setState(() {});

    return ncfLabel;
  }

  @override
  void initState() {
    _ncfs = [...ncfs];

    if (!electronicNcfEnabled) {
      _ncfs.removeWhere(
          (e) => e.id == '31' || e.id == '32' || e.id == '34' || e.id == '315');
    } else {
      _ncfs.removeWhere(
          (e) => e.id == '01' || e.id == '02' || e.id == '04' || e.id == '15');
    }

    if (isSale) {
      _ncfs.removeWhere((e) => e.id?.contains('4') == true);
    } else {
      if (!electronicNcfEnabled) {
        currentNcfTypeId = '04';
        currentPrefix = 'B';
        maxSequence = 8;
      } else {
        currentNcfTypeId = '34';
        currentPrefix = 'E';
        maxSequence = 10;
      }
    }

    if (widget.editing) {
      clientName.value = TextEditingValue(text: widget.sale.clientName ?? '');
      rncOrId.value = TextEditingValue(text: widget.sale.clientId ?? '');
      currentNcfTypeId = widget.sale.ncfTypeId;
      currentTypeIncomeId = widget.sale.typeIncomeId;
      retentionDate = widget.sale.retentionDate;
      retentionDateController.value = TextEditingValue(
          text: retentionDate?.format(payload: 'DD/MM/YYYY') ?? '');
      description.value = TextEditingValue(text: widget.sale.description ?? '');
      currentCurrencyId = widget.sale.currencyId;
    }

    setState(() {});
    super.initState();
  }

  String get labelTag {
    if (widget.editing) {
      return 'EDITANDO';
    }
    return 'FACTURANDO';
  }

  String get title {
    if (widget.sale is SaleService) {
      return '$labelTag SERVICIO...';
    }
    if (widget.sale is SaleProduct) {
      return '$labelTag PRODUCTO...';
    }

    if (widget.sale is CreditNoteAsService) {
      return '${_currentSale?.ncf ?? ''} $labelTag NOTA DE CREDITO - SERVICIO';
    }
    if (widget.sale is CreditNoteAsProduct) {
      return '${_currentSale?.ncf ?? ''} $labelTag NOTA DE CREDITO - PRODUCTO';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: false,
          actions: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              runAlignment: WrapAlignment.center,
              children: [
                Text(ncfLabel),
                SizedBox(
                  width: kDefaultPadding,
                ),
                !isSale
                    ? IconButton(
                        onPressed: () async {
                          setState(() {
                            rncOrId.value = TextEditingValue.empty;
                            widget.items = [];
                          });
                          var res = await showDialog(
                              context: context,
                              builder: (ctx) =>
                                  NcfsSelectorModal(saleMode: widget.mode));
                          if (res is Sale) {
                            _currentSale = res;
                            widget.sale.saleId = res.id;
                            widget.sale.typeIncomeId = res.typeIncomeId;
                            widget.sale.clientType = res.clientType;
                            widget.sale.invoiceTypeId = res.invoiceTypeId;
                            currentTypeIncomeId = res.typeIncomeId;
                            widget.sale.clientId = res.clientId;
                            widget.sale.effective = res.effective;
                            widget.sale.creditCard = res.creditCard;
                            widget.sale.checkOrTransf = res.checkOrTransf;
                            widget.sale.saleToCredit = res.saleToCredit;
                            widget.sale.description = res.description;
                            widget.sale.amountPaid = res.amountPaid;
                            widget.sale.ncf = res.ncf;

                            currentCurrencyId = res.currencyId;

                            widget.sale.currencyId = currentCurrencyId;

                            widget.sale.rate = res.rate;

                            if (res.rate != null) {
                              rate.value = TextEditingValue(
                                  text: widget.sale.rate?.toStringAsFixed(2) ??
                                      '');
                            }

                            rncOrId.value = TextEditingValue(
                                text: res.clientId?.replaceAll('-', '') ?? '');

                            var items = await res.getSaleData();
                            items = items
                                .map((e) => e is SaleItemService
                                    ? CreditNoteService(
                                        serviceId: e.serviceId,
                                        saleId: e.saleId,
                                        productId: e.productId,
                                        productName: e.productName,
                                        discount: e.discount,
                                        discountId: e.discountId,
                                        net: e.net,
                                        taxId: e.taxId,
                                        tax: e.tax,
                                        total: e.total,
                                        retentionIsr: e.retentionIsr,
                                        retentionTax: e.retentionTax,
                                        retentionTaxId: e.retentionTaxId,
                                        retentionIsrId: e.retentionIsrId,
                                        enabled: e.enabled,
                                        chassis: e.chassis,
                                        licensePlate: e.licensePlate,
                                        creditNoteId: e.creditNoteId,
                                        quantity: e.quantity,
                                        returnQuantity: e.returnQuantity)
                                    : CreditNoteProduct(
                                        serviceId: e.serviceId,
                                        saleId: e.saleId,
                                        productId: e.productId,
                                        productName: e.productName,
                                        discount: e.discount,
                                        discountId: e.discountId,
                                        net: e.net,
                                        taxId: e.taxId,
                                        tax: e.tax,
                                        total: e.total,
                                        retentionIsr: e.retentionIsr,
                                        retentionTax: e.retentionTax,
                                        retentionTaxId: e.retentionTaxId,
                                        retentionIsrId: e.retentionIsrId,
                                        enabled: e.enabled,
                                        chassis: e.chassis,
                                        licensePlate: e.licensePlate,
                                        creditNoteId: e.creditNoteId,
                                        quantity: e.quantity,
                                        returnQuantity: e.returnQuantity))
                                .toList();

                            for (int i = 0; i < items.length; i++) {
                              var item = items[i];
                              widget.items.add(item);
                              setState(() {});
                            }
                            description.value =
                                TextEditingValue(text: res.description ?? '');
                          }
                        },
                        icon: Icon(Icons.document_scanner))
                    : const SizedBox(),
                const SizedBox(
                  width: kDefaultPadding,
                )
              ],
            )
          ],
        ),
        body: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(
                        children: [
                          DropdownButtonFormField(
                              value: currentNcfTypeId,
                              isExpanded: true,
                              validator: (val) =>
                                  val == null ? 'CAMPO OBLIGATORIO' : null,
                              decoration: InputDecoration(
                                  labelText: 'TIPO DE COMPROBANTE'),
                              items: _ncfs
                                  .map((e) => DropdownMenuItem(
                                      value: e.id, child: Text(e.name ?? '')))
                                  .toList(),
                              onChanged: !isSale || widget.editing
                                  ? null
                                  : _onSelectedNcf),
                          SizedBox(
                            height: kDefaultPadding,
                          ),
                          RncQueryWidget(
                            clientName: clientName,
                            editingController: rncOrId,
                            onChanged: (xtaxPayer, xisValid) {
                              taxPayer = xtaxPayer;
                              isValid = xisValid;
                              setState(() {});
                            },
                          )
                        ],
                      )),
                      SizedBox(width: kDefaultPadding),
                      Expanded(
                          child: Column(
                        children: [
                          DropdownButtonFormField(
                              value: currentTypeIncomeId,
                              isExpanded: true,
                              validator: (val) =>
                                  val == null ? 'CAMPO OBLIGATORIO' : null,
                              decoration:
                                  InputDecoration(labelText: 'TIPO DE INGRESO'),
                              items: typesIncomes
                                  .map((e) => DropdownMenuItem(
                                      value: e.id, child: Text(e.name ?? '')))
                                  .toList(),
                              onChanged: (option) {
                                currentTypeIncomeId = option;
                              }),
                          SizedBox(
                            height: kDefaultPadding,
                          ),
                          TextFormField(
                            controller: retentionDateController,
                            readOnly: true,
                            style: Theme.of(context).textTheme.bodyMedium,
                            decoration: InputDecoration(
                                labelText: 'FECHA DE RETENCION',
                                hintText: 'DD/MM/YYYY',
                                suffixIcon: IconButton(
                                    onPressed: _showDatePicker,
                                    icon: Icon(Icons.calendar_month))),
                          )
                        ],
                      ))
                    ],
                  ),
                  SizedBox(
                    height: kDefaultPadding,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 100.00 * (widget.items.length),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
                          ...List.generate(widget.items.length, (index) {
                            var item = widget.items[index];
                            return InvoiceItemGeneratorWidget(
                              saleItem: item,
                              saleItems: widget.items,
                              editing: widget.editing,
                              enableds: widget.items
                                  .where((e) => e.enabled == true)
                                  .toList(),
                              onChanged: (saleItem) {
                                setState(() {});
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: kDefaultPadding),
                  !isSale || widget.editing
                      ? SizedBox()
                      : SizedBox(
                          width: 150,
                          height: 50,
                          child: ElevatedButton(
                              onPressed: _addSaleItem, child: Text('AGREGAR')),
                        ),
                  SizedBox(height: kDefaultPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: description,
                            maxLines: 8,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                                labelText: 'DESCRIPCION',
                                hintText: 'Escribir algo...'),
                          )),
                      SizedBox(width: kDefaultPadding),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text('Subtotal',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor))),
                              Expanded(
                                  child: Text(net,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.right))
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text('Descuento',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor))),
                              Expanded(
                                  child: Text(discount,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.right))
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text('Itbis',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor))),
                              Expanded(
                                  child: Text(tax,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.right))
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text('Total',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor))),
                              Expanded(
                                  child: Text(total,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.right))
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text('Retencion Itbis',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor))),
                              Expanded(
                                  child: Text(retentionTax,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.right))
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text('Retencion Isr',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor))),
                              Expanded(
                                  child: Text(retentionIsr,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.right))
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                      isSale
                                          ? 'Total a pagar'
                                          : 'Total a Devolver',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor))),
                              Expanded(
                                  child: Text(amountPaid,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.right))
                            ],
                          ),
                          const Divider(),
                          SizedBox(
                            height: kDefaultPadding,
                          ),
                          DropdownButtonFormField(
                              value: currentCurrencyId,
                              validator: (val) =>
                                  val == null ? 'CAMPO OBLIGATORIO' : null,
                              decoration: InputDecoration(labelText: 'MONEDA'),
                              items: List.generate(currencies.length, (index) {
                                var currency = currencies[index];
                                return DropdownMenuItem(
                                    value: currency.id,
                                    child: Text(currency.name ?? ' '));
                              }),
                              onChanged: (option) {
                                currentCurrencyId = option;
                                setState(() {});
                              }),
                          currentCurrencyId == 2
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: kDefaultPadding),
                                    TextFormField(
                                      controller: rate,
                                      validator: (val) => val!.isEmpty
                                          ? 'CAMPO OBLIGATORIO'
                                          : null,
                                      onChanged: (_) {
                                        setState(() {});
                                      },
                                      decoration: InputDecoration(
                                          labelText: 'TASA DE CAMBIO',
                                          hintText: '0.00'),
                                    ),
                                    SizedBox(height: kDefaultPadding)
                                  ],
                                )
                              : SizedBox(
                                  height: kDefaultPadding,
                                ),
                          widget.sale.debt == 0
                              ? SizedBox()
                              : DropdownButtonFormField(
                                  value: currentPaymentMethodId,
                                  validator: (val) =>
                                      val == null ? 'CAMPO OBLIGATORIO' : null,
                                  decoration: InputDecoration(
                                      labelText: isSale
                                          ? 'METODO DE PAGO'
                                          : 'FORMA DE PAGO'),
                                  items: paymentsMethods
                                      .map((e) => DropdownMenuItem(
                                          value: e.id,
                                          child: Text(e.name ?? '')))
                                      .toList(),
                                  onChanged: (option) {
                                    currentPaymentMethodId = option;
                                    setState(() {});
                                  }),
                          currentPaymentMethodId == 3
                              ? Column(
                                  children: [
                                    SizedBox(height: kDefaultPadding),
                                    DropdownButtonFormField(
                                        validator: (val) => val == null
                                            ? 'CAMPO OBLIGATORIO'
                                            : null,
                                        items: List.generate(banks.length,
                                            (index) {
                                          var bank = banks[index];
                                          return DropdownMenuItem(
                                              value: bank.id,
                                              child: Text(bank.name ?? ''));
                                        }),
                                        onChanged: (option) {
                                          currentBankId = option;
                                        }),
                                    SizedBox(height: kDefaultPadding),
                                    TextFormField(
                                      controller: transfRef,
                                      validator: (val) => val!.isEmpty
                                          ? 'CAMPO OBLIGATORIO'
                                          : null,
                                      decoration: InputDecoration(
                                          hintText: 'Escribir algo...',
                                          labelText:
                                              'NUMERO DE CHEQUE O REFERENCIA'),
                                    ),
                                    SizedBox(height: kDefaultPadding)
                                  ],
                                )
                              : SizedBox(height: kDefaultPadding),
                          widget.sale.debt == 0
                              ? SizedBox()
                              : Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                            isSale
                                                ? 'Deuda'
                                                : 'Pendiente a Devolver',
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium
                                                ?.copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColor))),
                                    Text(debt.toDop(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge),
                                  ],
                                ),
                          widget.sale.debt == 0
                              ? SizedBox()
                              : SizedBox(
                                  height: kDefaultPadding,
                                ),
                          widget.sale.debt == 0
                              ? SizedBox()
                              : TextFormField(
                                  controller: amount,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  onChanged: (_) {
                                    setState(() {});
                                  },
                                  validator: (val) => val!.isEmpty
                                      ? 'CAMPO OBLIGATORIO'
                                      : !isSale &&
                                              amountInputFormatter
                                                      .doubleValue !=
                                                  calcs[6]
                                          ? 'EL MONTO DEBE SER IGUAL'
                                          : !widget.editing &&
                                                  amountInputFormatter
                                                          .doubleValue >
                                                      calcs[6]
                                              ? isSale
                                                  ? 'EL MONTO ES MAYOR QUE EL TOTAL A PAGAR'
                                                  : 'EL MONTO ES MAYOR QUE EL TOTAL A DEVOLVER'
                                              : widget.editing &&
                                                      amountInputFormatter
                                                              .doubleValue >
                                                          debt
                                                  ? 'EL MONTO A PAGAR ES MAYOR QUE LA DEUDA'
                                                  : null,
                                  inputFormatters: [amountInputFormatter],
                                  decoration: InputDecoration(
                                      labelText: 'MONTO', hintText: '0.00'),
                                ),
                          SizedBox(
                            height: kDefaultPadding,
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                                onPressed: isValid || widget.editing
                                    ? _onSubmit
                                    : null,
                                child: Text(widget.editing
                                    ? 'EDITAR FACTURA'
                                    : 'CREAR FACTURA')),
                          )
                        ],
                      ))
                    ],
                  )
                ],
              ),
            )));
  }
}
