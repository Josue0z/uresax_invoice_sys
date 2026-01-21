import 'dart:io';

import 'package:amount_input_formatter/amount_input_formatter.dart';
import 'package:ecf_dgii/ecf_dgii.dart';
import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:open_file/open_file.dart';
import 'package:uresax_invoice_sys/apis/log.handler.dart';
import 'package:uresax_invoice_sys/apis/printers.handler.dart';
import 'package:uresax_invoice_sys/models/ncf.secuencia.dart';
import 'package:uresax_invoice_sys/models/ncfList.dart';
import 'package:uresax_invoice_sys/models/ncftype.dart';
import 'package:uresax_invoice_sys/models/product.dart';
import 'package:uresax_invoice_sys/models/sale.abs.dart';
import 'package:uresax_invoice_sys/models/sale.item.abs.dart';
import 'package:uresax_invoice_sys/models/sale.item.product.dart';
import 'package:uresax_invoice_sys/models/sale.product.dart';
import 'package:uresax_invoice_sys/models/sale.service.dart';
import 'package:uresax_invoice_sys/models/taxpayer.dart';
import 'package:uresax_invoice_sys/pages/login_page.dart';
import 'package:uresax_invoice_sys/pages/printers_page.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/extensions.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';
import 'package:uresax_invoice_sys/utils/invoices.functions.dart';
import 'package:uresax_invoice_sys/widgets/listen.code.widget.dart';
import 'package:uresax_invoice_sys/widgets/rnc.query.widget.dart';
import 'package:path/path.dart' as path;

class PosScreenPage extends StatefulWidget {
  Sale sale;
  List<SaleItem> items;
  bool editing;
  PosScreenPage(
      {super.key,
      required this.sale,
      required this.items,
      this.editing = false});

  @override
  State<PosScreenPage> createState() => _PosScreenPageState();
}

class _PosScreenPageState extends State<PosScreenPage> {
  TextEditingController clientName = TextEditingController();
  TextEditingController rncOrId = TextEditingController();
  TaxPayer? taxPayer;
  String? currentTypeIncomeId = '01';
  int? currentPaymentMethodId;
  int? currentPaymentType;
  int? currentOverrideCode;
  String? currentNcfTypeId;
  String? currentPrefix;
  int? maxSequence;
  List<NcfType> _ncfs = [];
  List<SaleItem> _items = [];

  TextEditingController description = TextEditingController();
  TextEditingController issueDateController = TextEditingController();
  TextEditingController retentionDateController = TextEditingController();
  TextEditingController fechaVencimientoController = TextEditingController();
  TextEditingController transfRef = TextEditingController();
  DateTime issueDate = DateTime.now();
  DateTime? retentionDate;
  DateTime fechaVencimiento = DateTime.now().endOfYear();

  AmountInputFormatter amountInputFormatter =
      AmountInputFormatter(fractionalDigits: 2);
  TextEditingController amount = TextEditingController();
  Sale? _currentSale;
  final FocusNode _focusNode = FocusNode();
  TextEditingController rate = TextEditingController();
  int currentCurrencyId = 1;
  int? currentBankId;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<FormaDePago> formasDePagos = [];

  int get quantity {
    int q = 0;
    for (var item in _items) {
      q += item.quantity ?? 0;
    }
    return q;
  }

  bool get isSale {
    return widget.sale is SaleService || widget.sale is SaleProduct;
  }

  double get debt {
    if (widget.sale.amountPaid != null && widget.editing) {
      return (paidAmount - (widget.sale.amountPaid!));
    }

    return (paidAmount - (amountInputFormatter.doubleValue));
  }

  bool get canOverrideTaxes {
    if (_currentSale == null) return false;
    var days = DateTime.now().difference(_currentSale!.createdAt!).inDays;
    return days > 30;
  }

  bool get esGubernamental {
    return currentNcfTypeId == '45' || currentNcfTypeId == '15';
  }

  bool get esNotaCredito {
    return currentNcfTypeId == '34' || currentNcfTypeId == '04';
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

    for (int i = 0; i < _items.length; i++) {
      var item = _items[i];

      subtotal += item.enabled == true ? _items[i].net ?? 0 : 0;
      discount += item.enabled == true ? _items[i].discount ?? 0 : 0;

      if (!canOverrideTaxes) {
        tax += item.enabled == true ? _items[i].tax ?? 0 : 0;
      }
      total += item.enabled == true ? _items[i].total ?? 0 : 0;
      retentionIsr += item.enabled == true ? _items[i].retentionIsr ?? 0 : 0;
      retentionTax += item.enabled == true ? _items[i].retentionTax ?? 0 : 0;

      if (!canOverrideTaxes) {
        tax18 += item.enabled == true ? _items[i].tax18 ?? 0 : 0;

        tax16 += item.enabled == true ? _items[i].tax16 ?? 0 : 0;

        tax3 += item.enabled == true ? _items[i].tax3 ?? 0 : 0;
      }

      net18 += item.enabled == true ? _items[i].net18 ?? 0 : 0;

      net16 += item.enabled == true ? _items[i].net16 ?? 0 : 0;

      net3 += item.enabled == true ? _items[i].net3 ?? 0 : 0;

      exemptAmount += item.enabled == true ? _items[i].exemptAmount ?? 0 : 0;
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
      return calcsDollarsToDop[0] - montoExento;
    }

    return calcs[0] - montoExento;
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

  double get paidAmount {
    return double.parse(calcs[6].toStringAsFixed(2));
  }

  double get returnCoinOrDebt {
    if (currentPaymentType == 1) {
      if (amountInputFormatter.doubleValue == 0) return 0;
    }
    if (currentCurrencyId == 2) {
      return ((amountInputFormatter.doubleValue - totalFacturado) * xrate)
          .abs();
    }
    return (amountInputFormatter.doubleValue - totalFacturado).abs();
  }

  _onScanCode(String code) async {
    try {
      if (widget.sale is SaleProduct) {
        var product = await Products.findByCode(code: code);

        var selectedItem = _items.firstWhere((e) => e.productId == product?.id,
            orElse: () => SaleItemProduct());

        if (selectedItem.productId == null) {
          if (product != null) {
            product.quantity = 1;
            int? indicadorFacturacion = 1;
            double net18 = 0;
            double net16 = 0;
            double tax18 = 0;

            double tax16 = 0;

            double priceAmount = product.price! * product.quantity!;

            if (product.taxId == 1) {
              net16 = priceAmount;
            }

            if (product.taxId == 2) {
              net18 = priceAmount;
            }

            double? exemptAmount = product.taxId == null ? priceAmount : 0;

            if (product.taxId != null) {
              indicadorFacturacion = product.taxId == 1 ? 2 : 1;
              tax18 = product.taxId == 2 ? priceAmount * 0.18 : 0;
              tax16 = product.taxId == 1 ? priceAmount * 0.16 : 0;
            } else {
              indicadorFacturacion = 4;
            }
            double? tax = tax18 + tax16;
            double? total = priceAmount + tax;

            _focusNode.requestFocus();
            if (_items.length == 1 && _items[0].productId == null) {
              setState(() {
                _items = [];
              });
            }

            _items.insert(
                0,
                SaleItemProduct(
                    quantity: 1,
                    productId: product.id,
                    productName: product.name,
                    indicadorFacturacion: indicadorFacturacion,
                    price: product.price,
                    taxId: product.taxId,
                    net: priceAmount,
                    net16: net16,
                    net18: net18,
                    net3: 0,
                    exemptAmount: exemptAmount,
                    tax: tax,
                    tax18: tax18,
                    tax16: tax16,
                    tax3: 0,
                    discount: 0,
                    total: total));
          } else {
            throw 'NO SE ENCONTRO EL PRODUCTO';
          }
        } else {
          int index =
              _items.indexWhere((e) => e.productId == selectedItem.productId);
          var item = _items[index];
          item.quantity = item.quantity! + 1;

          int? indicadorFacturacion = 1;
          double priceAmount = item.price! * item.quantity!;
          double net18 = 0;
          double net16 = 0;
          double? exemptAmount = item.taxId == null ? priceAmount : 0;
          double tax18 = 0;
          double tax16 = 0;

          if (item.taxId == 1) {
            net16 = priceAmount;
          }

          if (item.taxId == 2) {
            net18 = priceAmount;
          }

          if (item.taxId != null) {
            indicadorFacturacion = item.taxId == 1 ? 2 : 1;
            tax18 = item.taxId == 2 ? priceAmount * 0.18 : 0;
            tax16 = item.taxId == 1 ? priceAmount * 0.16 : 0;
          } else {
            indicadorFacturacion = 4;
          }
          double? tax = tax18 + tax16;
          double? total = priceAmount + tax;

          _items[index] = SaleItemProduct(
              id: item.id,
              indicadorFacturacion: indicadorFacturacion,
              quantity: item.quantity!,
              productId: item.productId,
              productName: item.productName,
              price: item.price,
              taxId: item.taxId,
              net: priceAmount,
              net16: net16,
              net18: net18,
              net3: 0,
              exemptAmount: exemptAmount,
              tax: tax,
              tax18: tax18,
              tax16: tax16,
              tax3: 0,
              discount: 0,
              total: total);

          _items = List.from(_items);
        }

        setState(() {});
      }
    } catch (e) {
      showTopSnackBar(context, message: e.toString(), color: Colors.red);
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
        print(fechaVencimiento);
      }
    } catch (e) {
      showTopSnackBar(context, message: e.toString(), color: Colors.red);
    }
  }

  Future<void> _initAsync() async {
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

  _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        if (eCommerceMode) {
          if (devicePos == null) {
            throw 'EL DISPOSITIVO DE PUNTO DE VENTA NO ESTA CONFIGURADO (CONTACTE CON EL ADMINISTRADOR DEL SISTEMA)';
          }
        }

        widget.sale.ncfTypeId = currentNcfTypeId;
        widget.sale.items = _items;
        widget.sale.net = calcs[0];
        widget.sale.discount = calcs[1];
        widget.sale.tax = calcs[2];
        widget.sale.total = calcs[3];
        widget.sale.retentionIsr = calcs[4];
        widget.sale.retentionTax = calcs[5];
        widget.sale.paymentMethodId = currentPaymentMethodId;
        widget.sale.clientId = rncOrId.text;
        widget.sale.typeIncomeId = '01';
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
        widget.sale.paidInvoice = 0;

        widget.sale.bankId = currentBankId;
        widget.sale.transfRef = transfRef.text;
        if (currentNcfTypeId != null &&
            (currentNcfTypeId!.startsWith('3') ||
                currentNcfTypeId!.startsWith('4'))) {
          widget.sale.prefix = 'E';
          widget.sale.maxSequence = 10;

          if (!electronicNcfEnabled) {
            throw 'ESTAS INTENTANDO GENERAR UNA FACTURA ELECTRONICA SIN CERTIFICADO ACTIVO (CONTACTE CON EL ADMINISTRADOR DEL SISTEMA)';
          }
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
            throw 'NO PUEDE GENERAR FACTURAS ELECTRONICAS YA QUE NO TIENES ACCESO AL SERVICIO EN LA NUBE (CONTACTE CON EL ADMINISTRADOR DEL SISTEMA)';
          }
        }
        double paid = montoAPagar;
        if (currentPaymentType == 1) {
          widget.sale.paid = amountInputFormatter.doubleValue;
          widget.sale.coinBack = returnCoinOrDebt;
          widget.sale.paidInvoice = montoAPagar;
        }

        if (currentPaymentType == 2) {
          paid = amountInputFormatter.doubleValue;
          widget.sale.paidInvoice = amountInputFormatter.doubleValue;
        }

        if (!widget.editing &&
            (widget.sale.debt == 0 || widget.sale.debt == null)) {
          if (currentPaymentMethodId == 1) {
            widget.sale.effective = paid;
          }

          if (currentPaymentMethodId == 2) {
            widget.sale.creditCard = paid;
          }

          if (currentPaymentMethodId == 3) {
            widget.sale.checkOrTransf = paid;
          }

          if (currentPaymentMethodId == 4) {
            widget.sale.saleToCredit = paid;
          }
        } else {
          if (currentPaymentMethodId == 1) {
            widget.sale.effective = widget.sale.effective! + paid;
          }

          if (currentPaymentMethodId == 2) {
            widget.sale.creditCard = widget.sale.creditCard! + paid;
          }

          if (currentPaymentMethodId == 3) {
            widget.sale.checkOrTransf = widget.sale.checkOrTransf! + paid;
          }

          if (currentPaymentMethodId == 4) {
            widget.sale.saleToCredit = widget.sale.saleToCredit! + paid;
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
          await enviarDgii(
              sale: sale,
              instanceSale: widget.sale,
              currentSale: _currentSale,
              currentNcfTypeId: currentNcfTypeId,
              clientName: clientName,
              rncOrId: rncOrId,
              xrate: xrate,
              formasDePagos: formasDePagos,
              totalGravado: totalGravado,
              totalGravado18: totalGravado18,
              totalGravado16: totalGravado16,
              montoExento: montoExento,
              itbisGravado: itbisGravado,
              itbisGravado18: itbisGravado18,
              itbisGravado16: itbisGravado16,
              totalRetencionItbis: totalRetencionItbis,
              totalRetencionIsr: totalRetencionIsr,
              totalFacturado: totalFacturado,
              fechaVencimiento: fechaVencimiento,
              currentPaymentMethodId: currentPaymentMethodId,
              currentPaymentType: currentPaymentType,
              currentTypeIncomeId: currentTypeIncomeId,
              currentOverrideCode: currentOverrideCode,
              canOverrideTaxes: canOverrideTaxes);

          await LogHandler.printEvent(
              '${sale.ncfTypeName} ${sale.ncf} FUE ENVIADA A DGII, RNC/CEDULA: ${sale.clientId}, EL CLIENTE: ${sale.clientName}');
        }

        if (eCommerceMode) {
          if (devicePos != null) {
            var bytes = await createDefaultTicket(sale: sale!);

            Navigator.pop(context);

            await PrinterHandler.printBytes(devicePos!, bytes);
            await LogHandler.printEvent('SE IMPRIMIO LA FACTURA ${sale.ncf}');
          }
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
            .updateFinish(currentNcf: sale!.ncfSeq!);

        Navigator.pop(context);

        _reset();

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

  _reset() {
    setState(() {
      _items = [];
      currentPaymentMethodId = null;
      currentPaymentType = null;
      amount.clear();
      amountInputFormatter.clear();
      currentNcfTypeId = null;
      rncOrId.clear();
      clientName.clear();
    });
  }

  @override
  void initState() {
    if (!mounted) return;
    _focusNode.requestFocus();
    _items = [...widget.items];
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
          e.id == '44' ||
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
    setState(() {
      _initAsync();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('FACTURANDO...'),
            actions: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: IconButton(
                    onPressed: () async {
                      devicePos = await Navigator.push<String?>(context,
                          MaterialPageRoute(builder: (ctx) => PrintersPage()));
                    },
                    icon: Icon(Icons.print)),
              ),
              CircleAvatar(
                child: IconButton(
                    tooltip: 'CERRAR CUENTA',
                    onPressed: () async {
                      await LogHandler.printEvent(
                          '${currentUser?.name} CERRO SESION');
                      currentUser = null;

                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (ctx) => LoginPage()),
                          (_) => false);
                    },
                    icon: Icon(Icons.power_settings_new_outlined)),
              ),
              SizedBox(
                width: kDefaultPadding,
              )
            ],
          ),
          body: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                child: Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Container(
                            color: const Color(0xFFEFEEEE),
                            padding: EdgeInsets.all(kDefaultPadding),
                            height: MediaQuery.of(context).size.height,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListenCodeWidget(
                                  enabled: widget.sale is SaleProduct &&
                                      eCommerceMode,
                                  focusNode: _focusNode,
                                  onScan: _onScanCode,
                                  child: Container(),
                                ),
                                _items.isNotEmpty
                                    ? Text('ARTICULOS ($quantity)',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium
                                            ?.copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.w500))
                                    : SizedBox(),
                                SizedBox(
                                  height: kDefaultPadding,
                                ),
                                Expanded(
                                    child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      ...List.generate(_items.length, (index) {
                                        var item = _items[index];
                                        double total =
                                            (item.price! * item.quantity!);
                                        return Container(
                                          padding:
                                              EdgeInsets.all(kDefaultPadding),
                                          margin: EdgeInsets.symmetric(
                                              vertical: index == 0
                                                  ? 0
                                                  : kDefaultPadding / 2),
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFDCD9D9),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 100,
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    child: Center(
                                                      child: Icon(
                                                          Icons.inventory,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: kDefaultPadding / 2,
                                                  ),
                                                  Text(item.productName ?? '')
                                                ],
                                              ),
                                              Spacer(),
                                              Column(
                                                children: [
                                                  Text(
                                                      '${item.quantity} x ${item.price?.toStringAsFixed(2)} = $total')
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      })
                                    ],
                                  ),
                                ))
                              ],
                            ))),
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.all(kDefaultPadding),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: kDefaultPadding),
                                    child: DropdownButtonFormField(
                                        initialValue: currentNcfTypeId,
                                        isExpanded: true,
                                        validator: (val) => val == null
                                            ? 'CAMPO OBLIGATORIO'
                                            : null,
                                        decoration: InputDecoration(
                                            labelText: 'TIPO DE COMPROBANTE'),
                                        items: _ncfs
                                            .map((e) => DropdownMenuItem(
                                                value: e.id,
                                                child: Text(e.name ?? '')))
                                            .toList(),
                                        onChanged: _onSelectedNcf),
                                  ),
                                  RncQueryWidget(
                                    clientName: clientName,
                                    editingController: rncOrId,
                                    onChanged: (xtaxPayer, xisValid) {
                                      taxPayer = xtaxPayer;
                                      isValid = xisValid;
                                    },
                                  ),
                                  SizedBox(height: kDefaultPadding),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text('TOTAL NETO',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium
                                                  ?.copyWith(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.w500))),
                                      Expanded(
                                          child: Text(net,
                                              textAlign: TextAlign.right,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500)))
                                    ],
                                  ),
                                  const Divider(),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text('DESCUENTO',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium
                                                  ?.copyWith(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.w500))),
                                      Expanded(
                                          child: Text(discount,
                                              textAlign: TextAlign.right,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500)))
                                    ],
                                  ),
                                  const Divider(),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text('TOTAL ITBIS',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium
                                                  ?.copyWith(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.w500))),
                                      Expanded(
                                          child: Text(tax,
                                              textAlign: TextAlign.right,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500)))
                                    ],
                                  ),
                                  const Divider(),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text('TOTAL FACTURADO',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium
                                                  ?.copyWith(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.w500))),
                                      Expanded(
                                          child: Text(total,
                                              textAlign: TextAlign.right,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500)))
                                    ],
                                  ),
                                  const Divider(),
                                  Row(
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Text('TOTAL A PAGAR',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium
                                                  ?.copyWith(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.w500))),
                                      Expanded(
                                          child: Text(amountPaid,
                                              textAlign: TextAlign.right,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w500)))
                                    ],
                                  ),
                                  const Divider(),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: kDefaultPadding / 2),
                                    child: DropdownButtonFormField(
                                        initialValue: currentPaymentMethodId,
                                        validator: (val) => val == null
                                            ? 'CAMPO OBLIGATORIO'
                                            : null,
                                        decoration: InputDecoration(
                                            labelText: 'METODO DE PAGO'),
                                        items: paymentsMethods
                                            .map((e) => DropdownMenuItem(
                                                value: e.id,
                                                child: Text(e.name ?? '')))
                                            .toList(),
                                        onChanged: (option) {
                                          currentPaymentMethodId = option;

                                          setState(() {});
                                        }),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: kDefaultPadding / 2),
                                    child: DropdownButtonFormField(
                                        initialValue: currentPaymentType,
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
                                          if (currentPaymentMethodId != 1) {
                                            amount.clear();
                                            amountInputFormatter.clear();
                                          }
                                          setState(() {});
                                        }),
                                  ),
                                  currentPaymentMethodId == 2 &&
                                          currentPaymentType == 1
                                      ? SizedBox()
                                      : Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: kDefaultPadding),
                                          child: TextFormField(
                                            controller: amount,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                            onChanged: (_) {
                                              setState(() {});
                                            },
                                            validator: (val) {
                                              if (val == null || val.isEmpty) {
                                                return 'CAMPO OBLIGATORIO';
                                              }

                                              if (currentPaymentType == 1) {
                                                if (amountInputFormatter
                                                        .doubleValue <
                                                    totalFacturado) {
                                                  return 'EL MONTO PAGADO NO PUEDE SER MENOR AL TOTAL A PAGAR';
                                                }
                                              }

                                              if (currentPaymentType == 2) {
                                                if (amountInputFormatter
                                                        .doubleValue >
                                                    totalFacturado) {
                                                  return 'EL MONTO PAGADO NO PUEDE SER MAYOR AL TOTAL A PAGAR';
                                                }
                                              }

                                              return null;
                                            },
                                            inputFormatters: [
                                              amountInputFormatter
                                            ],
                                            decoration: InputDecoration(
                                                labelText: 'MONTO PAGADO',
                                                hintText: '0.00'),
                                          ),
                                        ),
                                  currentPaymentMethodId == 2 &&
                                          currentPaymentType == 1
                                      ? SizedBox()
                                      : Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: kDefaultPadding),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Text('DEVUELTA/DEUDA',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .displayMedium
                                                          ?.copyWith(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500))),
                                              Text(returnCoinOrDebt.toDop(),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .displayMedium
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w500))
                                            ],
                                          ),
                                        ),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: kDefaultPadding),
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                        onPressed: _onSubmit,
                                        child: Text('CREAR FACTURA')),
                                  )
                                ],
                              ),
                            )))
                  ],
                ),
              ))),
    );
  }
}
