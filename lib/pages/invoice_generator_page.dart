import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amount_input_formatter/amount_input_formatter.dart';
import 'package:dio/dio.dart';
import 'package:ecf_dgii/ecf_dgii.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:uresax_invoice_sys/apis/log.handler.dart';
import 'package:uresax_invoice_sys/apis/printers.handler.dart';
import 'package:uresax_invoice_sys/modals/ncfs.selector.modal.dart';
import 'package:uresax_invoice_sys/models/credit.note.item.product.dart';
import 'package:uresax_invoice_sys/models/credit.note.item.service.dart';
import 'package:uresax_invoice_sys/models/credit.note.product.dart';
import 'package:uresax_invoice_sys/models/credit.note.service.dart';
import 'package:uresax_invoice_sys/models/ncf.secuencia.dart';
import 'package:uresax_invoice_sys/models/ncfList.dart';
import 'package:uresax_invoice_sys/models/ncftype.dart';
import 'package:uresax_invoice_sys/models/product.dart';
import 'package:uresax_invoice_sys/models/retention.isr.dart';
import 'package:uresax_invoice_sys/models/retention.tax.dart';
import 'package:uresax_invoice_sys/models/sale.abs.dart';
import 'package:uresax_invoice_sys/models/sale.item.abs.dart';
import 'package:uresax_invoice_sys/models/sale.item.product.dart';
import 'package:uresax_invoice_sys/models/sale.item.service.dart';
import 'package:uresax_invoice_sys/models/sale.product.dart';
import 'package:uresax_invoice_sys/models/sale.service.dart';
import 'package:uresax_invoice_sys/models/taxes.dart';
import 'package:uresax_invoice_sys/models/taxpayer.dart';
import 'package:uresax_invoice_sys/pages/printers_page.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/extensions.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';
import 'package:uresax_invoice_sys/utils/invoices.functions.dart';
import 'package:uresax_invoice_sys/widgets/content.error.widget.dart';
import 'package:uresax_invoice_sys/widgets/invoice_item_generator_widget.dart';
import 'package:uresax_invoice_sys/widgets/listen.code.widget.dart';
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
  String? currentNcfTypeId;
  int? currentPaymentMethodId;
  int? currentBankId;
  int? currentCurrencyId;
  String? currentTypeIncomeId;
  int? currentOverrideCode;
  int? currentPaymentType;
  TaxPayer? taxPayer;
  TextEditingController description = TextEditingController();
  TextEditingController issueDateController = TextEditingController();
  TextEditingController retentionDateController = TextEditingController();
  TextEditingController fechaVencimientoController = TextEditingController();
  DateTime issueDate = DateTime.now();
  DateTime? retentionDate;
  DateTime fechaVencimiento = DateTime.now().endOfYear();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AmountInputFormatter amountInputFormatter =
      AmountInputFormatter(fractionalDigits: 2);
  TextEditingController amount = TextEditingController();
  TextEditingController rncOrId = TextEditingController();
  TextEditingController clientName = TextEditingController();
  TextEditingController transfRef = TextEditingController();
  TextEditingController rate = TextEditingController();

  bool isValid = false;

  bool loading = true;

  Future? future;

  List<NcfType> _ncfs = [];

  List<FormaDePago> formasDePagos = [];

  Sale? _currentSale;

  final FocusNode _focusNode = FocusNode();

  bool get esGubernamental {
    return currentNcfTypeId == '45' || currentNcfTypeId == '15';
  }

  bool get esNotaCredito {
    return currentNcfTypeId == '34' || currentNcfTypeId == '04';
  }

  bool get onlyEcommerce {
    return (eCommerceMode && widget.sale is SaleProduct);
  }

  _onScanCode(String code) async {
    try {
      if (widget.sale is SaleProduct) {
        var product = await Products.findByCode(code: code);

        var selectedItem = widget.items.firstWhere(
            (e) => e.productId == product?.id,
            orElse: () => SaleItemProduct());

        if (selectedItem.productId == null) {
          if (product != null) {
            _focusNode.requestFocus();
            if (widget.items.length == 1 && widget.items[0].productId == null) {
              setState(() {
                widget.items = [];
              });
            }

            widget.items.add(SaleItemProduct(
                quantity: 1,
                productId: product.id,
                productName: product.name,
                taxId: product.taxId,
                net: product.price));
          } else {
            throw 'NO SE ENCONTRO EL PRODUCTO';
          }
        } else {
          int index = widget.items
              .indexWhere((e) => e.productId == selectedItem.productId);
          var item = widget.items[index];
          item.quantity = item.quantity! + 1;

          widget.items[index] = SaleItemProduct(
            id: item.id,
            quantity: item.quantity!,
            productId: item.productId,
            productName: item.productName,
            taxId: item.taxId,
            net: item.net,
          );

          widget.items = List.from(widget.items);
        }

        setState(() {});
      }
    } catch (e) {
      showTopSnackBar(context, message: e.toString(), color: Colors.red);
    }
  }

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
        widget.sale.createdAt = issueDate;
        widget.sale.tipoPago = currentPaymentType;
        widget.sale.expirationDate = fechaVencimiento;
        widget.sale.rate = 1;
        widget.sale.net18 = totalGravado18;
        widget.sale.net16 = totalGravado16;
        widget.sale.net3 = totalGravado3;
        widget.sale.tax18 = itbisGravado18;
        widget.sale.tax16 = itbisGravado16;
        widget.sale.tax3 = itbisGravado3;
        widget.sale.exemptAmount = montoExento;
        widget.sale.authorId = currentUser?.id;
        widget.sale.ncfAffectedCreatedAt = _currentSale?.createdAt;

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
        if (currentNcfTypeId != null &&
            (currentNcfTypeId!.startsWith('3') ||
                currentNcfTypeId!.startsWith('4'))) {
          widget.sale.prefix = 'E';
          widget.sale.maxSequence = 10;
        } else if (currentNcfTypeId != null && currentNcfTypeId == '50') {
          widget.sale.prefix = 'P';
          widget.sale.maxSequence = 8;
        } else {
          widget.sale.prefix = 'B';
          widget.sale.maxSequence = 8;
        }

        showLoader(context);

        if (widget.sale.prefix == 'E') {
          var xhas = await hasInternet();
          if (!xhas) {
            throw 'NO PUEDE GENERAR FACTURAS ELECTRONICAS SIN INTERNET';
          }
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

          await LogHandler.printEvent(
              '${sale?.ncfTypeName} ${sale?.ncf} FUE CREADA, RNC/CEDULA: ${sale?.clientId}, EL CLIENTE: ${sale?.clientName}');
        } else {
          sale = await widget.sale.update();
          await LogHandler.printEvent(
              '${sale?.ncfTypeName} ${sale?.ncf} FUE ACTUALIZADA, RNC/CEDULA: ${sale?.clientId}, EL CLIENTE: ${sale?.clientName}');
        }

        if (!widget.editing &&
            electronicNcfEnabled &&
            widget.sale.prefix == 'E' &&
            sale != null) {
          await _enviarDgii(sale);

          await LogHandler.printEvent(
              '${sale.ncfTypeName} ${sale.ncf} FUE ENVIADA A DGII, RNC/CEDULA: ${sale.clientId}, EL CLIENTE: ${sale.clientName}');
        }

        if (eCommerceMode && widget.sale is SaleProduct) {
          var printer = localStorage.getItem('printer') ?? '';

          var bytes = await createDefaultTicket(sale: sale!);

          Navigator.pop(context);

          await PrinterHandler.printBytes(printer, bytes);
        } else {
          var doc = createDefaultInvoice(sale!);

          Navigator.pop(context);

          var fileName = '${sale.ncf}_${company?.name}.PDF';

          var dir = await getUresaxInvoiceDir();
          var filePath = path.join(
              dir.path,
              esNotaCredito ? 'NOTAS DE CREDITO' : 'VENTAS',
              sale.createdAt!.format(payload: 'YYYYMM'),
              'PDFS',
              fileName);
          var file = File(filePath);
          await file.create(recursive: true);
          await LogHandler.printEvent('SE CREO EL ARCHIVO: ${file.path}');
          await file.writeAsBytes(await doc.save());
          await LogHandler.printEvent('SE ESCRIBIO EL ARCHIVO: ${file.path}');
          await OpenFile.open(file.path);

          await LogHandler.printEvent('SE ABRIO EL ARCHIVO: ${file.path}');
        }

        showLoader(context);

        await NcfsList(ncfTypeId: currentNcfTypeId)
            .updateFinish(currentNcf: sale.ncfSeq!);

        Navigator.pop(context);

        Navigator.pop(context, widget.editing ? 'UPDATE' : null);

        showTopSnackBar(context,
            message: widget.editing ? 'FACTURA EDITADA' : 'FACTURA CREADA',
            color: Colors.green);
      } catch (e) {
        print(e);
        await LogHandler.printEvent(e.toString());
        Navigator.pop(context);
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

      if (esGubernamental) {
        retentionDate = null;
        retentionDateController.value = TextEditingValue.empty;

        for (int i = 0; i < widget.items.length; i++) {
          var item = widget.items[i];
          item.retentionIsrId = null;
          item.retentionIsr = 0;
          item.retentionTaxId = null;
          item.retentionTax = 0;
        }
        setState(() {});
      } else {
        setState(() {});
      }
    }
    try {
      int umbral = 1;
      var checkObj =
          await NcfSecuencia(id: currentNcfTypeId).checkNcfs(umbral: umbral);

      if (checkObj != null) {
        for (var item in checkObj) {
          int dif = item['dif'];
          String name = item['name'];
          throw 'QUEDAN $dif $name';
        }
      }

      var ncfList = await NcfsList(ncfTypeId: currentNcfTypeId).findNcf();

      if (ncfList != null) {
        fechaVencimiento = ncfList.expirationDate!;
        fechaVencimientoController.value = TextEditingValue(
            text: fechaVencimiento.format(payload: 'DD/MM/YYYY'));
      }
    } catch (e) {
      showTopSnackBar(context, message: e.toString(), color: Colors.red);
    }
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

  bool get canOverrideTaxes {
    if (_currentSale == null) return false;
    var days = DateTime.now().difference(_currentSale!.createdAt!).inDays;
    return days > 30;
  }

  List<double> get calcs {
    double subtotal = 0;
    double discount = 0;
    double tax = 0;
    double total = 0;
    double retentionTax = 0;
    double retentionIsr = 0;
    double tax18 = 0;
    double tax16 = 0;
    double tax3 = 0;
    double net18 = 0;
    double net16 = 0;
    double net3 = 0;
    double exemptAmount = 0;

    for (int i = 0; i < widget.items.length; i++) {
      var item = widget.items[i];

      subtotal += item.enabled == true ? widget.items[i].net ?? 0 : 0;
      discount += item.enabled == true ? widget.items[i].discount ?? 0 : 0;

      if (!canOverrideTaxes) {
        tax += item.enabled == true ? widget.items[i].tax ?? 0 : 0;
      }
      total += item.enabled == true ? widget.items[i].total ?? 0 : 0;
      retentionIsr +=
          item.enabled == true ? widget.items[i].retentionIsr ?? 0 : 0;
      retentionTax +=
          item.enabled == true ? widget.items[i].retentionTax ?? 0 : 0;

      if (!canOverrideTaxes) {
        tax18 += item.enabled == true ? widget.items[i].tax18 ?? 0 : 0;

        tax16 += item.enabled == true ? widget.items[i].tax16 ?? 0 : 0;

        tax3 += item.enabled == true ? widget.items[i].tax3 ?? 0 : 0;
      }

      net18 += item.enabled == true ? widget.items[i].net18 ?? 0 : 0;

      net16 += item.enabled == true ? widget.items[i].net16 ?? 0 : 0;

      net3 += item.enabled == true ? widget.items[i].net3 ?? 0 : 0;

      exemptAmount +=
          item.enabled == true ? widget.items[i].exemptAmount ?? 0 : 0;
    }

    return [
      subtotal,
      discount,
      tax,
      total,
      retentionIsr,
      retentionTax,
      (total - (retentionIsr + retentionTax)),
      tax18,
      tax16,
      tax3,
      net18,
      net16,
      net3,
      exemptAmount
    ];
  }

  double get xrate {
    double xrate = 1;

    double? calcRate = double.tryParse(rate.text);
    if (calcRate != null) {
      xrate = calcRate;
    }
    return xrate;
  }

  List<double> get calcsDollarsToDop {
    return [
      calcs[0] * xrate,
      calcs[1] * xrate,
      calcs[2] * xrate,
      calcs[3] * xrate,
      calcs[4] * xrate,
      calcs[5] * xrate,
      calcs[6] * xrate,
      calcs[7] * xrate,
      calcs[8] * xrate,
      calcs[9] * xrate,
      calcs[10] * xrate,
      calcs[11] * xrate,
      calcs[12] * xrate,
      calcs[13] * xrate
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

  double get montoAPagar {
    if (currentCurrencyId == 2) {
      return calcsDollarsToDop[6];
    }
    return calcs[6];
  }

  double get totalFacturado {
    if (currentCurrencyId == 2) {
      return calcsDollarsToDop[3];
    }
    return calcs[3];
  }

  double get itbisGravado {
    if (currentCurrencyId == 2) {
      return calcsDollarsToDop[2];
    }
    return calcs[2];
  }

  double get itbisGravado18 {
    if (currentCurrencyId == 2) {
      return calcsDollarsToDop[7];
    }
    return calcs[7];
  }

  double get itbisGravado16 {
    if (currentCurrencyId == 2) {
      return calcsDollarsToDop[8];
    }
    return calcs[8];
  }

  double get itbisGravado3 {
    if (currentCurrencyId == 2) {
      return calcsDollarsToDop[9];
    }
    return calcs[9];
  }

  double get totalGravado {
    if (currentCurrencyId == 2) {
      return calcsDollarsToDop[0];
    }

    return calcs[0];
  }

  double get totalGravado18 {
    if (currentCurrencyId == 2) {
      return calcsDollarsToDop[10];
    }
    return calcs[10];
  }

  double get totalGravado16 {
    if (currentCurrencyId == 2) {
      return calcsDollarsToDop[11];
    }
    return calcs[11];
  }

  double get totalGravado3 {
    if (currentCurrencyId == 2) {
      return calcsDollarsToDop[12];
    }
    return calcs[12];
  }

  double get totalRetencionIsr {
    if (currentCurrencyId == 2) {
      return calcsDollarsToDop[4];
    }
    return calcs[4];
  }

  double get totalRetencionItbis {
    if (currentCurrencyId == 2) {
      return calcsDollarsToDop[5];
    }
    return calcs[5];
  }

  double get montoExento {
    if (currentCurrencyId == 2) {
      return calcsDollarsToDop[13];
    }
    return calcs[13];
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

  _showDatePicker2() async {
    var result = await showDatePicker(
        context: context,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365 * 25)));

    if (result != null) {
      issueDate = result;
      issueDateController.value =
          TextEditingValue(text: issueDate.format(payload: 'DD/MM/YYYY'));
    }
  }

  _showDatePicker3() async {
    var result = await showDatePicker(
        context: context,
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365 * 25)));

    if (result != null) {
      fechaVencimiento = result;
      fechaVencimientoController.value = TextEditingValue(
          text: fechaVencimiento.format(payload: 'DD/MM/YYYY'));
    }
  }

  bool get isSale {
    return widget.sale is SaleService || widget.sale is SaleProduct;
  }

  double get paidAmount {
    return double.parse(calcs[6].toStringAsFixed(2));
  }

  double get debt {
    if (widget.sale.amountPaid != null && widget.editing) {
      return (paidAmount - (widget.sale.amountPaid!));
    }

    return (paidAmount - (amountInputFormatter.doubleValue));
  }

  String calcularCodigoModificacion(
      DateTime fechaNcfModificado, DateTime fechaEmisionActual) {
    final diferencia = fechaEmisionActual.difference(fechaNcfModificado).inDays;
    return diferencia > 30 ? '1' : '0';
  }

  NcfType? currentNcfType;
  String currentPrefix = 'P';
  int maxSequence = 8;

  String ncfLabel = '';

  String getItbisCode({
    required bool esNotaCredito,
    required bool canOverrideTaxes,
    required double gravado18,
    required double gravado16,
    required double originalGravado18,
    required double originalGravado16,
  }) {
    if (esNotaCredito) {
      if (!canOverrideTaxes) {
        return originalGravado18 > 0
            ? '18'
            : originalGravado16 > 0
                ? '16'
                : '';
      } else {
        return originalGravado18 > 0
            ? '0'
            : originalGravado16 > 0
                ? '0'
                : '';
      }
    }
    return gravado18 > 0
        ? '18'
        : gravado16 > 0
            ? '16'
            : '';
  }

  Future<void> _enviarDgii(Sale sale) async {
    try {
      bool enabledEcfProduction = bool.parse(
          Platform.environment['URESAX_INVOICE_ENABLED_ECF_PRODUCTION'] ??
              'false');

      String endPointApi = '';

      if (enabledEcfProduction) {
        GeneratorEndPoint.envEcfType = EnvEcfType.ecf;
        endPointApi =
            'https://api.uresax.com/produccion/fe/facturaselectronicas/api/ecf';
      } else {
        GeneratorEndPoint.envEcfType = EnvEcfType.testEcf;
        endPointApi =
            'https://api.uresax.com/prueba/fe/facturaselectronicas/api/ecf';
      }
      final cert = certFile;

      String password = localStorage.getItem('certPassword') ?? '';

      EcfType ecfType = EcfType.e31;

      if (currentNcfTypeId == '31') {
        ecfType = EcfType.e31;
      }
      if (currentNcfTypeId == '32') {
        ecfType = EcfType.e32;
      }

      if (currentNcfTypeId == '33') {
        ecfType = EcfType.e33;
      }

      if (currentNcfTypeId == '34') {
        ecfType = EcfType.e34;
      }

      if (currentNcfTypeId == '41') {
        ecfType = EcfType.e41;
      }

      if (currentNcfTypeId == '45') {
        ecfType = EcfType.e45;
      }

      if (currentNcfTypeId == '46') {
        ecfType = EcfType.e46;
      }
      if (currentNcfTypeId == '47') {
        ecfType = EcfType.e47;
      }

      bool esNotaCredito = ecfType == EcfType.e34;

      bool esConsumo = ecfType == EcfType.e32;

      bool esEcf45 = ecfType == EcfType.e45;

      bool esEspecial = esConsumo || esEcf45;

      AuthCertModel authModel =
          await getAuthP12(cert: cert!, password: password);

      final now = DateTime.now().toLocal();
      final dateFormat = DateFormat('dd-MM-yyyy');

      final fechaEmision = dateFormat.format(now);

      String rncEmisor = company?.rncOrId?.trim().replaceAll('-', '') ?? '';

      String rncComprador = rncOrId.text.replaceAll('-', '');
      List<EcfDetailsModel> items = [];

      items = sale.items.map((item) {
        return EcfDetailsModel(
            cantidad: item.quantity?.toStringAsFixed(2) ?? '',
            unidadMedida: '',
            indicadorFacturacion: item.indicadorFacturacion.toString(),
            indicadorBienOServ:
                item is SaleItemService || item is CreditNoteService
                    ? '2'
                    : '1',
            nombreItem: item.serviceName != null && item.serviceName!.isNotEmpty
                ? item.serviceName ?? ''
                : item.productName ?? '',
            descripcionItem: '',
            precioUnitario: (item.precio * xrate).toStringAsFixed(2),
            descuentoMonto: '',
            subDescuentos: [],
            impuestosAdicionales: [],
            retencion: esEspecial
                ? null
                : item.retentionTax != 0 || item.retentionIsr != 0
                    ? Retencion(
                        indicadorAgenteRetencionoPercepcion:
                            item.indicadorAgentePercepcion.toString(),
                        montoITBISRetenido: item.retentionTax != null
                            ? (item.retentionTax! * xrate).toStringAsFixed(2)
                            : '',
                        montoISRRetenido: item.retentionIsr != null
                            ? (item.retentionIsr! * xrate).toStringAsFixed(2)
                            : '')
                    : null,
            otraMonedaDetalles: [],
            montoItem:
                item.net != null ? (item.net! * xrate).toStringAsFixed(2) : '');
      }).toList();

      EcfModel ecf = EcfModel(
          tipoEcf: ecfType,
          tempDirName: 'temp_7',
          indicadorMontoGravado: '0',
          indicadorNotaCredito: esNotaCredito
              ? calcularCodigoModificacion(
                  _currentSale!.createdAt!, widget.sale.createdAt!)
              : '',
          numeroComprobante: sale.ncf ?? '',
          numeroComprobanteModificado: _currentSale?.ncf ?? '',
          rncOtroContribuyente: '',
          codigoModificacion:
              esNotaCredito ? currentOverrideCode.toString() : '',
          fechaEmision: fechaEmision,
          fechaVencimiento: esNotaCredito || esConsumo
              ? ''
              : fechaVencimiento.format(payload: 'DD-MM-YYYY'),
          fechaEmisionNcfModificado: esNotaCredito
              ? _currentSale?.createdAt?.format(payload: 'DD-MM-YYYY') ?? ''
              : '',
          fechaLimitePago: currentPaymentType == 1
              ? ''
              : fechaVencimiento.format(payload: 'DD-MM-YYYY'),
          razonModificacion: '',
          tipoIngreso: currentTypeIncomeId.toString(),
          tipoPago: currentPaymentType.toString(),
          formasDePagos: esNotaCredito ? [] : formasDePagos,
          sucursal: '',
          direccionEmisor: company?.address ?? '',
          municipio: '',
          provincia: '',
          telefonoEmisor1: '',
          telefonoEmisor2: '',
          telefonoEmisor3: '',
          totalPaginas: '',
          rncEmisor: rncEmisor,
          razonSocialEmisor: company?.name ?? '',
          nombreComercial: '',
          correoEmisor: company?.email ?? '',
          website: '',
          actividadEconomica: '',
          codigoVendedor: '',
          informacionAdicionalEmisor: '',
          rncComprador: rncComprador,
          identificadorExtranjero: '',
          razonSocialComprador: clientName.text.trim(),
          nombreComprador: '',
          contactoComprador: '',
          correoComprador: '',
          telefonoAdicional: '',
          direccionComprador: '',
          municipioComprador: '',
          provinciaComprador: '',
          codigoInternoComprador: '',
          fechaEntrega: '',
          fechaOrdenCompra: '',
          numeroOrdenCompra: '',
          numeroFacturaInterna: '',
          numeroPedidoInterno: '',
          zonaVenta: '',
          rutaVenta: '',
          paisDestino: '',
          conductor: '',
          documentoTransporte: '',
          ficha: '',
          placa: '',
          rutaTransporte: '',
          zonaTransporte: '',
          numeroAlbaran: '',
          totalGravado: totalGravado > 0 ? totalGravado.toStringAsFixed(2) : '',
          totalGravado18:
              totalGravado18 > 0 ? totalGravado18.toStringAsFixed(2) : '',
          totalGravado16:
              totalGravado16 > 0 ? totalGravado16.toStringAsFixed(2) : '',
          totalGravadoTasa0: '',
          montoExento: montoExento > 0 ? montoExento.toStringAsFixed(2) : '',
          totalItbis: itbisGravado > 0 ? itbisGravado.toStringAsFixed(2) : '',
          totalItbis18:
              itbisGravado18 > 0 ? itbisGravado18.toStringAsFixed(2) : '',
          totalItbis16:
              itbisGravado16 > 0 ? itbisGravado16.toStringAsFixed(2) : '',
          totalItbisTasa0: '',
          itbis1: getItbisCode(
            esNotaCredito: esNotaCredito,
            canOverrideTaxes: canOverrideTaxes,
            gravado18: itbisGravado18,
            gravado16: 0,
            originalGravado18: _currentSale?.tax18 ?? 0,
            originalGravado16: 0,
          ),
          itbis2: getItbisCode(
            esNotaCredito: esNotaCredito,
            canOverrideTaxes: canOverrideTaxes,
            gravado18: 0,
            gravado16: itbisGravado16,
            originalGravado18: 0,
            originalGravado16: _currentSale?.tax16 ?? 0,
          ),
          itbis3: '',
          montoTotal:
              totalFacturado > 0 ? totalFacturado.toStringAsFixed(2) : '',
          montoPeriodo: '',
          montoAvancePago: '',
          valorPagar: esEcf45 ? totalFacturado.toStringAsFixed(2) : '',
          tipoMoneda: '',
          tipoCambio: '',
          montoGravadoTotalOtraMoneda: '',
          montoGravadoTotalOtraMoneda1: '',
          montoGravadoTotalOtraMoneda2: '',
          montoGravadoTotalOtraMoneda3: '',
          totalItbisOtraMoneda: '',
          totalItbis1OtraMoneda: '',
          totalItbis2OtraMoneda: '',
          totalItbis3OtraMoneda: '',
          montoExentoOtraMoneda: '',
          montoTotalOtraMoneda: '',
          totalItbisRetencion: esEspecial
              ? ''
              : totalRetencionItbis > 0
                  ? totalRetencionItbis.toStringAsFixed(2)
                  : '0.00',
          totalIsrRetencion: esEspecial
              ? ''
              : totalRetencionIsr > 0
                  ? totalRetencionIsr.toStringAsFixed(2)
                  : '0.00',
          montoImpuestoAdicional: '',
          impuestosAdicionales: [],
          terminoPago: '',
          bancoPago: '',
          paginas: [],
          items: items,
          privateKey: authModel.privateKey,
          certBase64: authModel.certBase64);

      await ecf.descargarSemilla();
      await ecf.validarSemilla();
      await ecf.firmar();
      dynamic estado;

      final request = http.MultipartRequest('POST', Uri.parse(endPointApi))
        ..headers['accept'] = 'application/json'
        ..headers['Authorization'] = 'Bearer ${ecf.token}'
        ..files.add(await http.MultipartFile.fromPath(
          'xml',
          ecf.ecfFile!.path,
          contentType: MediaType('text', 'xml'),
          filename: path.basename(ecf.ecfFile!.path),
        ));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      print(body);

      estado = jsonDecode(body);

      ecf.trackId = estado['trackId'] ?? '';

      await LogHandler.printEvent(estado.toString());

      print(ecf.trackId);
      print(ecf.token);

      if (ecf.trackId != '') {
        await Future.delayed(const Duration(milliseconds: 600));
        estado = await ecf.obtenerEcfEstadoDatos();
        await LogHandler.printEvent(estado.toString());
      }

      DateFormat xdateFormat = DateFormat('dd-MM-yyyy HH:mm:ss');
      var fechaFirma = xdateFormat.parse(ecf.fechaHoraFirma);
      sale.dgiiURL = ecf.uriEcf.toString();
      sale.signatureDate = fechaFirma;
      sale.securityCode = ecf.codigoSeguridad;
      sale.ecfXmlFirmado = ecf.ecfSignXml;
      await sale.updateEcfInfo();

      if (estado != null) {
        var codigo = estado['codigo'] is int
            ? estado['codigo']
            : int.parse(estado['codigo']);

        sale.estadoDgii = codigo;

        await sale.updateEcfInfo();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _initAsync() async {
    taxes = [Taxes(name: 'ITBIS'), ...await Taxes.get()];
    retentionsTaxes = [
      RetentionTax(name: 'RETENCION ITBIS'),
      ...await RetentionTax.get()
    ];
    retentionsIsrs = [
      RetentionIsr(name: 'RETENCION ISR'),
      ...await RetentionIsr.get()
    ];

    if (currentNcfTypeId != null) {
      int umbral = 1;
      var checkObj =
          await NcfSecuencia(id: currentNcfTypeId).checkNcfs(umbral: umbral);

      if (checkObj != null) {
        for (var item in checkObj) {
          int dif = item['dif'];
          String name = item['name'];
          showTopSnackBar(context,
              message: 'QUEDAN $dif $name', color: Colors.red);
        }
      }

      var ncfList = await NcfsList(ncfTypeId: currentNcfTypeId).findNcf();

      if (ncfList != null) {
        fechaVencimiento = ncfList.expirationDate!;
        fechaVencimientoController.text =
            fechaVencimiento.format(payload: 'DD/MM/YYYY');
      }
    }

    setState(() {});
  }

  @override
  void initState() {
    if (!mounted) return;
    _ncfs = [...ncfs];

    if (electronicNcfEnabled) {
      _ncfs.removeWhere(
          (e) => e.id == '01' || e.id == '02' || e.id == '15' || e.id == '04');
    }

    if (!isSale) {
      _ncfs.removeWhere((e) =>
          e.id == '01' ||
          e.id == '02' ||
          e.id == '15' ||
          e.id == '31' ||
          e.id == '32' ||
          e.id == '45' ||
          e.id == '50');
    }

    if (isSale) {
      _ncfs.removeWhere((e) => e.id == '34' || e.id == '04');
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

    issueDate = widget.sale.createdAt ?? DateTime.now();

    issueDateController.value =
        TextEditingValue(text: issueDate.format(payload: 'DD/MM/YYYY'));

    fechaVencimientoController.value =
        TextEditingValue(text: fechaVencimiento.format(payload: 'DD/MM/YYYY'));

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

    setState(() {
      future = _initAsync();
    });

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

  Widget get contentFilled {
    return GestureDetector(
      onTap: () {
        if (widget.sale is SaleProduct && eCommerceMode) {
          _focusNode.requestFocus();
        }
      },
      child: Scaffold(
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
                              widget.sale.createdAt = res.createdAt;
                              widget.sale.expirationDate = res.expirationDate;

                              currentCurrencyId = _currentSale?.currencyId;

                              currentPaymentType = res.tipoPago;

                              if (_currentSale?.rate != null) {
                                rate.value = TextEditingValue(
                                    text:
                                        widget.sale.rate?.toStringAsFixed(2) ??
                                            '');
                              }

                              rncOrId.value = TextEditingValue(
                                  text:
                                      res.clientId?.replaceAll('-', '') ?? '');

                              var items = await res.getSaleData();
                              items = items
                                  .map((e) => e is SaleItemService
                                      ? CreditNoteService(
                                          serviceId: e.serviceId,
                                          serviceName: e.serviceName,
                                          saleId: e.saleId,
                                          productId: e.productId,
                                          productName: e.productName,
                                          discount: e.discount,
                                          discountId: e.discountId,
                                          discountName: e.discountName,
                                          price: e.price,
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
                                          returnQuantity: e.returnQuantity,
                                          tax18: e.tax18,
                                          tax16: e.tax16,
                                          tax3: e.tax3,
                                          net18: e.net18,
                                          net16: e.net16,
                                          net3: e.net3,
                                          exemptAmount: e.exemptAmount,
                                          indicadorFacturacion:
                                              e.indicadorFacturacion,
                                          indicadorAgentePercepcion:
                                              e.indicadorAgentePercepcion)
                                      : CreditNoteProduct(
                                          serviceId: e.serviceId,
                                          saleId: e.saleId,
                                          productId: e.productId,
                                          productName: e.productName,
                                          discount: e.discount,
                                          discountId: e.discountId,
                                          discountName: e.discountName,
                                          price: e.price,
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
                                          returnQuantity: e.returnQuantity,
                                          tax18: e.tax18,
                                          tax16: e.tax16,
                                          tax3: e.tax3,
                                          net18: e.net18,
                                          net16: e.net16,
                                          net3: e.net3,
                                          exemptAmount: e.exemptAmount,
                                          indicadorFacturacion:
                                              e.indicadorFacturacion,
                                          indicadorAgentePercepcion:
                                              e.indicadorAgentePercepcion))
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
                  ),
                  eCommerceMode
                      ? IconButton(
                          onPressed: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (ctx) => PrintersPage()));
                          },
                          icon: Icon(Icons.print))
                      : SizedBox(
                          width: kDefaultPadding,
                        ),
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
                                onChanged:
                                    widget.editing ? null : _onSelectedNcf),
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
                            Container(
                              margin: EdgeInsets.only(bottom: kDefaultPadding),
                              child: DropdownButtonFormField(
                                  initialValue: currentTypeIncomeId,
                                  isExpanded: true,
                                  validator: (val) =>
                                      val == null ? 'CAMPO OBLIGATORIO' : null,
                                  decoration: InputDecoration(
                                      labelText: 'TIPO DE INGRESO'),
                                  items: typesIncomes
                                      .map((e) => DropdownMenuItem(
                                          value: e.id,
                                          child: Text(e.name ?? '')))
                                      .toList(),
                                  onChanged: (option) {
                                    currentTypeIncomeId = option;
                                  }),
                            ),
                            !isSale
                                ? Container(
                                    margin: EdgeInsets.only(
                                        bottom: kDefaultPadding),
                                    child: DropdownButtonFormField(
                                        value: currentOverrideCode,
                                        isExpanded: true,
                                        validator: (val) => val == null
                                            ? 'CAMPO OBLIGATORIO'
                                            : null,
                                        decoration: InputDecoration(
                                            labelText: 'CODIGO MODIFICACION'),
                                        items: overrideCodes
                                            .map((e) => DropdownMenuItem(
                                                value: e.id,
                                                child: Text(e.name ?? '')))
                                            .toList(),
                                        onChanged: (option) {
                                          currentOverrideCode = option;
                                        }),
                                  )
                                : SizedBox(),
                            Container(
                              margin: EdgeInsets.only(bottom: kDefaultPadding),
                              child: TextFormField(
                                controller: issueDateController,
                                readOnly: true,
                                style: Theme.of(context).textTheme.bodyMedium,
                                decoration: InputDecoration(
                                    labelText: 'FECHA DE EMISION',
                                    hintText: 'DD/MM/YYYY',
                                    suffixIcon: IconButton(
                                        onPressed: null,
                                        icon: Icon(Icons.calendar_month))),
                              ),
                            ),
                            esGubernamental || onlyEcommerce
                                ? SizedBox()
                                : Container(
                                    margin: EdgeInsets.only(
                                        bottom: kDefaultPadding),
                                    child: TextFormField(
                                      controller: retentionDateController,
                                      readOnly: true,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                      decoration: InputDecoration(
                                          labelText: 'FECHA DE RETENCION',
                                          hintText: 'DD/MM/YYYY',
                                          suffixIcon: IconButton(
                                              onPressed: _showDatePicker,
                                              icon:
                                                  Icon(Icons.calendar_month))),
                                    ),
                                  ),
                            TextFormField(
                              controller: fechaVencimientoController,
                              readOnly: true,
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: InputDecoration(
                                  labelText: 'FECHA DE VENCIMIENTO',
                                  hintText: 'DD/MM/YYYY',
                                  suffixIcon: IconButton(
                                      onPressed: null,
                                      icon: Icon(Icons.calendar_month))),
                            )
                          ],
                        ))
                      ],
                    ),
                    SizedBox(
                      height: kDefaultPadding,
                    ),
                    ListenCodeWidget(
                      enabled: widget.sale is SaleProduct && eCommerceMode,
                      focusNode: _focusNode,
                      onScan: _onScanCode,
                      child: Container(),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 100.00 * (widget.items.length),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [
                            ...widget.items.map((item) {
                              var index = widget.items.indexOf(item);

                              return InvoiceItemGeneratorWidget(
                                saleItem: item,
                                index: index,
                                saleItems: widget.items,
                                editing: widget.editing,
                                esGubernamental: esGubernamental,
                                enableds: widget.items
                                    .where((e) => e.enabled == true)
                                    .toList(),
                                onChanged: (saleItem) {
                                  setState(() {});
                                },
                              );
                            })
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: kDefaultPadding),
                    Row(
                      children: [
                        !isSale || widget.editing || onlyEcommerce
                            ? SizedBox()
                            : Container(
                                width: 150,
                                height: 50,
                                margin: EdgeInsets.only(right: kDefaultPadding),
                                child: ElevatedButton(
                                    onPressed: _addSaleItem,
                                    child: Text('AGREGAR')),
                              ),
                        widget.items.isNotEmpty
                            ? SizedBox(
                                width: 150,
                                height: 50,
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            const Color.fromARGB(
                                                244, 213, 224, 250))),
                                    onPressed: () async {
                                      clientName.text = '';
                                      rncOrId.text = '';
                                      currentTypeIncomeId = null;
                                      currentNcfTypeId = null;
                                      currentCurrencyId = null;
                                      currentOverrideCode = null;
                                      currentPaymentMethodId = null;
                                      currentPaymentType = null;
                                      amount.text = '';
                                      amountInputFormatter.clear();
                                      widget.sale.amountPaid = 0;
                                      description.text = '';
                                      retentionDate = null;
                                      retentionDateController.text = '';
                                      _currentSale = null;

                                      setState(() {
                                        widget.items = [];
                                      });

                                      await Future.delayed(
                                          const Duration(milliseconds: 90));
                                      if (widget.sale is SaleProduct) {
                                        setState(() {
                                          widget.sale = SaleProduct(items: []);

                                          widget.items.add(SaleItemProduct());
                                        });
                                      }
                                      if (widget.sale is SaleService) {
                                        setState(() {
                                          widget.sale = SaleService(items: []);

                                          widget.items.add(SaleItemService());
                                        });
                                      }
                                      setState(() {});
                                    },
                                    child: Text(
                                      'REINICIAR',
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                    )),
                              )
                            : SizedBox(),
                      ],
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
                            flex: 2,
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
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
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
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
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
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
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
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
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
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
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
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
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
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                            textAlign: TextAlign.right))
                                  ],
                                ),
                                const Divider(),
                                SizedBox(
                                  height: kDefaultPadding,
                                ),
                                DropdownButtonFormField(
                                    value: currentCurrencyId,
                                    validator: (val) => val == null
                                        ? 'CAMPO OBLIGATORIO'
                                        : null,
                                    decoration:
                                        InputDecoration(labelText: 'MONEDA'),
                                    items: List.generate(currencies.length,
                                        (index) {
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                    : Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: kDefaultPadding / 2),
                                        child: DropdownButtonFormField(
                                            value: currentPaymentMethodId,
                                            validator: (val) => val == null
                                                ? 'CAMPO OBLIGATORIO'
                                                : null,
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
                                              formasDePagos = [
                                                FormaDePago(
                                                    currentPaymentMethodId
                                                        .toString(),
                                                    montoAPagar
                                                        .toStringAsFixed(2))
                                              ];
                                              setState(() {});
                                            }),
                                      ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: kDefaultPadding / 2),
                                  child: DropdownButtonFormField(
                                      value: currentPaymentType,
                                      isExpanded: true,
                                      validator: (val) => val == null
                                          ? 'CAMPO OBLIGATORIO'
                                          : null,
                                      decoration: InputDecoration(
                                          labelText: 'TIPO DE PAGO'),
                                      items: paymentsTypes
                                          .map((e) => DropdownMenuItem(
                                              value: e.id,
                                              child: Text(e.name ?? '')))
                                          .toList(),
                                      onChanged: (option) {
                                        currentPaymentType = option;
                                      }),
                                ),
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
                                                    child:
                                                        Text(bank.name ?? ''));
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
                                                          color: Theme.of(
                                                                  context)
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
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                        onChanged: (_) {
                                          setState(() {});
                                        },
                                        validator: (val) => val!.isEmpty
                                            ? 'CAMPO OBLIGATORIO'
                                            : !isSale &&
                                                    amountInputFormatter
                                                            .doubleValue !=
                                                        paidAmount
                                                ? 'EL MONTO DEBE SER IGUAL'
                                                : !widget.editing &&
                                                        amountInputFormatter
                                                                .doubleValue >
                                                            paidAmount
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
                                            labelText: 'MONTO',
                                            hintText: '0.00'),
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
              ))),
    );
  }

  Widget get contentLoading {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget get contentEmpty {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
          if (taxes.isNotEmpty &&
              retentionsTaxes.isNotEmpty &&
              retentionsIsrs.isNotEmpty) {
            return contentFilled;
          }
          return contentEmpty;
        });
  }
}
