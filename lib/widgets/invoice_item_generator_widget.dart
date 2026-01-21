import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:uresax_invoice_sys/models/credit.note.item.product.dart';
import 'package:uresax_invoice_sys/models/credit.note.item.service.dart';
import 'package:uresax_invoice_sys/models/discount.dart';
import 'package:uresax_invoice_sys/models/product.dart';
import 'package:uresax_invoice_sys/models/retention.isr.dart';
import 'package:uresax_invoice_sys/models/retention.tax.dart';
import 'package:uresax_invoice_sys/models/sale.element.abs.dart';
import 'package:uresax_invoice_sys/models/sale.item.abs.dart';
import 'package:uresax_invoice_sys/models/sale.item.product.dart';
import 'package:uresax_invoice_sys/models/sale.item.service.dart';
import 'package:uresax_invoice_sys/models/service.dart';
import 'package:uresax_invoice_sys/models/taxes.dart';
import 'package:uresax_invoice_sys/pages/discounts_page.dart';
import 'package:uresax_invoice_sys/pages/products_page.dart';
import 'package:uresax_invoice_sys/pages/services_page.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/widgets/selector.item.widget.dart';

class InvoiceItemGeneratorWidget extends StatefulWidget {
  SaleItem saleItem;

  List<SaleItem> saleItems;

  List<SaleItem> enableds;

  bool editing;

  bool esGubernamental;

  int index;

  Function(SaleItem) onChanged;

  InvoiceItemGeneratorWidget(
      {super.key,
      this.editing = false,
      this.esGubernamental = false,
      required this.saleItem,
      required this.saleItems,
      required this.enableds,
      required this.onChanged,
      required this.index});

  @override
  State<InvoiceItemGeneratorWidget> createState() =>
      _InvoiceItemGeneratorWidgetState();
}

class _InvoiceItemGeneratorWidgetState
    extends State<InvoiceItemGeneratorWidget> {
  TextEditingController net = TextEditingController();
  TextEditingController tax = TextEditingController();
  TextEditingController total = TextEditingController();
  TextEditingController totalToPay = TextEditingController();
  TextEditingController quantity = TextEditingController();

  int? currenId;
  int? currentTaxId;
  int? currentRetentionTaxId;
  String? currentRetentionIsrId;
  int? discountId;

  SaleElement? el;
  RetentionTax? retentionTax;
  RetentionIsr? retentionIsr;
  Discount? discountEl;
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

  _onSelected(SaleElement? element) {
    currenId = element?.id;

    if (widget.saleItem is SaleItemService) {
      widget.saleItem.serviceId = currenId;
    }

    if (widget.saleItem is SaleItemProduct) {
      widget.saleItem.productId = currenId;
    }

    el = element;

    currentTaxId = el?.taxId;

    currentTax = taxes.firstWhere((e) => e.id == currentTaxId);

    widget.saleItem.taxId = currentTaxId;

    widget.saleItem.productName = el?.name;

    if (currenId != null) {
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
    widget.saleItem.quantity = int.tryParse(value);
    _calc();
  }

  _calc() {
    widget.saleItem.net =
        (el?.price ?? widget.saleItem.net!) * (widget.saleItem.quantity ?? 1);
    double d = 0;

    if (widget.saleItem is SaleItemService ||
        widget.saleItem is SaleItemProduct) {
      widget.saleItem.discount = 0;
      if (discountEl?.id != null) {
        if (discountEl?.symbolId == 1) {
          d = (discountEl!.rate! / 100) * widget.saleItem.net!;
        }

        if (discountEl?.symbolId == 2) {
          d = discountEl!.rate!;
        }

        widget.saleItem.discount = d;
        widget.saleItem.net = widget.saleItem.net! - d;
      } else {
        d = 0;
        widget.saleItem.discount = d;
      }
    }

    widget.saleItem.tax18 = 0;
    widget.saleItem.tax16 = 0;
    widget.saleItem.tax3 = 0;

    widget.saleItem.net18 = 0;
    widget.saleItem.net16 = 0;
    widget.saleItem.net3 = 0;
    widget.saleItem.exemptAmount = 0;

    if (currentTaxId != null) {
      currentTax = taxes.firstWhere((e) => e.id == currentTaxId);
      widget.saleItem.taxId = currentTaxId;
    }

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

    if (currentTaxId == 1) {
      widget.saleItem.indicadorFacturacion = 2;
      widget.saleItem.tax16 = widget.saleItem.tax;
      widget.saleItem.net16 = widget.saleItem.net;
    }

    if (currentTaxId == 2) {
      widget.saleItem.indicadorFacturacion = 1;
      widget.saleItem.tax18 = widget.saleItem.tax;
      widget.saleItem.net18 = widget.saleItem.net;
    }

    if (currentTaxId == null) {
      widget.saleItem.indicadorFacturacion = 4;
      widget.saleItem.exemptAmount = widget.saleItem.net;
      widget.saleItem.net18 = 0;
      widget.saleItem.tax18 = 0;
      widget.saleItem.net16 = 0;
      widget.saleItem.tax16 = 0;
    }
    if (widget.saleItem.retentionIsrId != null ||
        widget.saleItem.retentionTaxId != null) {
      widget.saleItem.indicadorAgentePercepcion = 1;
    }

    quantity.value = TextEditingValue(
      text: widget.saleItem.quantity?.toString() ?? '',
      selection: TextSelection.collapsed(
        offset: (widget.saleItem.quantity?.toString() ?? '').length,
      ),
    );

    net.text = widget.saleItem.net?.toStringAsFixed(2) ?? '';
    tax.text = widget.saleItem.tax?.toStringAsFixed(2) ?? '';
    total.text = widget.saleItem.total?.toStringAsFixed(2) ?? '';

    totalToPay.text = amountPaid.toStringAsFixed(2);

    widget.saleItem.productName = el?.name;
    widget.saleItem.serviceName = el?.name;

    widget.onChanged(widget.saleItem);
  }

  double get amountPaid {
    if (widget.saleItem.total == null || widget.saleItem.total == 0) {
      return 0;
    }

    return widget.saleItem.total! -
        (widget.saleItem.retentionTax ?? 0) -
        (widget.saleItem.retentionIsr ?? 0);
  }

  bool get enabledOnlyEcommerce {
    return (eCommerceMode ||
        (widget.saleItem is SaleItemProduct ||
            widget.saleItem is CreditNoteProduct));
  }

  @override
  void initState() {
    startQuantity = widget.saleItem.quantity ?? 1;
    widget.saleItem.returnQuantity = widget.saleItem.quantity ?? 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncControllersWithSaleItem();
      }
    });

    super.initState();
  }

  void _syncControllersWithSaleItem() {
    currenId = widget.saleItem.serviceId ?? widget.saleItem.productId;

    el = widget.saleItem is SaleItemService ||
            widget.saleItem is CreditNoteService
        ? Services(
            id: widget.saleItem.serviceId,
            name: widget.saleItem.serviceName,
            price: widget.saleItem.price)
        : Products(
            id: widget.saleItem.productId,
            name: widget.saleItem.productName,
            price: widget.saleItem.price);
    widget.saleItem.productName = el?.name;
    widget.saleItem.serviceName = el?.name;

    discountId = widget.saleItem.discountId;

    discountEl = Discount(
        id: widget.saleItem.discountId, name: widget.saleItem.discountName);

    currentTaxId = widget.saleItem.taxId;
    currentRetentionIsrId = widget.saleItem.retentionIsrId;
    currentRetentionTaxId = widget.saleItem.retentionTaxId;

    if (currentRetentionTaxId != null) {
      retentionTax =
          retentionsTaxes.firstWhere((e) => e.id == currentRetentionTaxId);
    }
    if (currentRetentionIsrId != null) {
      retentionIsr =
          retentionsIsrs.firstWhere((e) => e.id == currentRetentionIsrId);
    }

    _calc();
  }

  @override
  void didUpdateWidget(covariant InvoiceItemGeneratorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.saleItem != widget.saleItem) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _syncControllersWithSaleItem();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          Row(
            children: [
              widget.saleItem is CreditNoteProduct ||
                      widget.saleItem is CreditNoteService
                  ? Container(
                      margin: EdgeInsets.only(right: kDefaultPadding),
                      child: GestureDetector(
                        onTap: () {
                          if (widget.saleItem is CreditNoteProduct ||
                              widget.saleItem is CreditNoteService) {
                            if (widget.saleItem.enabled == true) {
                              if (widget.enableds.length > 1) {
                                widget.saleItem.enabled = false;
                              }
                            } else {
                              widget.saleItem.enabled = true;
                            }
                            widget.onChanged(widget.saleItem);
                          }
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
                    )
                  : SizedBox(),
            ],
          ),
          SizedBox(
            width: 150,
            child: TextFormField(
              controller: quantity,
              readOnly: widget.saleItem is CreditNoteProduct ||
                  widget.saleItem is CreditNoteService ||
                  widget.editing ||
                  eCommerceMode,
              validator: (val) => val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
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
                                  if (widget.saleItem.quantity! ==
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
            width: 250,
            child: SelectorItemWidget<SaleElement>(
                context: context,
                title: title,
                initialValue: el,
                enabled: !widget.editing &&
                    (widget.saleItem is SaleItemProduct ||
                        widget.saleItem is SaleItemService),
                validator: (val) {
                  return el?.id == null ? 'CAMPO OBLIGATORIO' : null;
                },
                screen: widget.saleItem is SaleItemService
                    ? ServicesPage(selectedMode: true)
                    : ProductsPage(selectedMode: true),
                onChanged: (element) {
                  el = element;
                  _onSelected(el);
                }),
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
            width: 250,
            child: SelectorItemWidget<Discount>(
                context: context,
                initialValue: discountEl,
                title: 'DESCUENTO',
                enabled: !widget.editing &&
                    (widget.saleItem is SaleItemProduct ||
                        widget.saleItem is SaleItemService),
                screen: DiscountsPage(selectorMode: true),
                onChanged: widget.saleItem is CreditNoteProduct ||
                        widget.saleItem is CreditNoteService
                    ? null
                    : (xdiscount) {
                        discountEl = xdiscount;
                        discountId = xdiscount?.id;
                        widget.saleItem.discountId = discountEl?.id;
                        _calc();
                      }),
          ),
          SizedBox(
            width: kDefaultPadding,
          ),
          SizedBox(
            width: 150,
            child: DropdownButtonFormField(
                initialValue: currentTaxId,
                decoration: InputDecoration(labelText: 'ITBIS'),
                items: taxes
                    .map((e) => DropdownMenuItem(
                        value: e.id, child: Text(e.name ?? '')))
                    .toList(),
                onChanged: widget.saleItem is CreditNoteProduct ||
                        widget.saleItem is CreditNoteService ||
                        widget.editing ||
                        enabledOnlyEcommerce
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
          Container(
            width: 200,
            margin: EdgeInsets.only(left: kDefaultPadding),
            child: DropdownButtonFormField(
                isExpanded: true,
                value: currentRetentionTaxId,
                decoration: InputDecoration(labelText: 'RETENCION ITBIS'),
                items: retentionsTaxes
                    .map((e) => DropdownMenuItem(
                        value: e.id, child: Text(e.name ?? '')))
                    .toList(),
                onChanged: widget.esGubernamental ||
                        widget.saleItem is CreditNoteProduct ||
                        widget.saleItem is CreditNoteService ||
                        (widget.editing &&
                            widget.saleItem.retentionTaxId != null) ||
                        enabledOnlyEcommerce
                    ? null
                    : _onSelectedRetentionTax),
          ),
          Container(
            width: 200,
            margin: EdgeInsets.only(left: kDefaultPadding),
            child: DropdownButtonFormField(
                value: currentRetentionIsrId,
                isExpanded: true,
                decoration: InputDecoration(labelText: 'RETENCION ISR'),
                items: retentionsIsrs
                    .map((e) => DropdownMenuItem(
                        value: e.id, child: Text(e.name ?? '')))
                    .toList(),
                onChanged: widget.esGubernamental ||
                        widget.saleItem is CreditNoteProduct ||
                        widget.saleItem is CreditNoteService ||
                        (widget.editing &&
                            widget.saleItem.retentionIsrId != null) ||
                        enabledOnlyEcommerce
                    ? null
                    : _onSelectedRetentionIsr),
          ),
          Container(
            width: 150,
            margin: EdgeInsets.only(left: kDefaultPadding),
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

class CustomDropdownFormField extends FormField<int> {
  CustomDropdownFormField({
    super.key,
    required String title,
    required SaleItem saleItem,
    required List<SaleElement> elements,
    required void Function(SaleElement, int? option) onChanged,
    super.enabled,
    super.initialValue,
    super.validator,
    super.autovalidateMode = AutovalidateMode.disabled,
  }) : super(
          builder: (FormFieldState<int> state) {
            var value = initialValue ?? state.value;

            return _CustomDropdownButton(
              title: title,
              saleItem: saleItem,
              elements: elements,
              currentValue: value,
              enabled: enabled,
              errorText: state.errorText,
              onChanged: (element, id) {
                state.didChange(element.id);
                state.save();
                state.validate();
                onChanged(element, id);
              },
            );
          },
        );
}

class _CustomDropdownButton extends StatefulWidget {
  final String title;
  final SaleItem saleItem;
  List<SaleElement> elements;
  final Function(SaleElement, int? option) onChanged;
  int? currentValue;
  bool enabled;
  final String? errorText;

  _CustomDropdownButton({
    required this.title,
    required this.saleItem,
    required this.elements,
    required this.onChanged,
    this.currentValue,
    this.enabled = false,
    this.errorText,
  });

  @override
  State<_CustomDropdownButton> createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<_CustomDropdownButton>
    with TickerProviderStateMixin {
  final GlobalKey _targetKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  final LayerLink _layerLink = LayerLink();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  SaleElement? _saleElement;

  List<SaleElement> _elements = [];

  TextEditingController search = TextEditingController();

  _removeOverlay() async {
    Navigator.pop(context);
    search.clear();
    await _fadeController.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showContextMenu() {
    if (!widget.enabled) return;

    _elements = widget.elements;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox =
          _targetKey.currentContext!.findRenderObject() as RenderBox;

      final Size size = renderBox.size;

      showElements() async {
        if (widget.saleItem is SaleItemService) {
          var service = await showDialog(
              context: context,
              builder: (ctx) => ServicesPage(selectedMode: true));
          _saleElement = service;
          if (service != null) {
            if (!_elements.any((e) => e.id == service.id)) {
              _elements.add(service);
              int index = _elements.indexWhere((e) => e.id == service.id);
              _elements[index] = _saleElement!;
            } else {
              int index = _elements.indexWhere((e) => e.id == service.id);
              _elements[index] = _saleElement!;
            }

            widget.currentValue = _saleElement?.id;

            widget.onChanged(_saleElement!, widget.currentValue);
          }
        }
        if (widget.saleItem is SaleItemProduct) {
          var product = await showDialog(
              context: context,
              builder: (ctx) => ProductsPage(selectedMode: true));

          _saleElement = product;

          if (product != null) {
            if (!_elements.any((e) => e.id == product.id)) {
              _elements.add(product);
              int index = _elements.indexWhere((e) => e.id == product.id);
              _elements[index] = _saleElement!;
            } else {
              int index = _elements.indexWhere((e) => e.id == product.id);
              _elements[index] = _saleElement!;
            }
          }
          widget.currentValue = _saleElement?.id;
          widget.onChanged(_saleElement!, widget.currentValue);
        }
      }

      _overlayEntry = OverlayEntry(
        builder: (context) => StatefulBuilder(
          builder: (context, localSetState) => Stack(
            children: [
              GestureDetector(
                onTap: _removeOverlay,
                behavior: HitTestBehavior.translucent,
              ),
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + (kDefaultPadding + 10)),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(10),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: size.width + (kDefaultPadding * 2),
                        maxHeight: 300,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(kDefaultPadding),
                            child: TextFormField(
                              controller: search,
                              decoration: InputDecoration(
                                labelText: 'Buscar',
                                hintText: 'Escribir algo...',
                              ),
                              onChanged: (value) async {
                                List<SaleElement> results = [];
                                if (widget.saleItem is SaleItemService) {
                                  results = [
                                    Services(name: 'SERVICIO'),
                                    ...await Services.get(search: value)
                                  ];
                                } else if (widget.saleItem is SaleItemProduct) {
                                  results = [
                                    Products(name: 'PRODUCTO'),
                                    ...await Products.get(search: value)
                                  ];
                                }
                                localSetState(() {
                                  _elements = results;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: [
                                ..._elements.map((item) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          title: Text(item.name ?? ''),
                                          onTap: () {
                                            widget.currentValue = item.id;
                                            widget.onChanged(item, item.id);
                                            _removeOverlay();
                                            setState(() {});
                                          },
                                        ),
                                        const Divider(),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          _buildMenuItem(
                            widget.saleItem is SaleItemService
                                ? 'Agregar Servicio'
                                : 'Agregar Producto',
                            Icons.add,
                            showElements,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (_, __, ___) => Material(
            color: Colors.transparent,
            child: Overlay(
              initialEntries: [_overlayEntry!],
            ),
          ),
        ),
      );

      // Overlay.of(context).insert(_overlayEntry!);
      _fadeController.forward();
    });
  }

  Widget _buildMenuItem(String text, IconData icon, Function onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(text),
      onTap: () {
        _removeOverlay();
        onTap();
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    search.clear();
    _fadeController.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentValue != null) {
      _saleElement = widget.elements
          .firstWhere((e) => e.id == widget.currentValue, orElse: () {
        return Services();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onChanged(_saleElement!, widget.currentValue);
        }
      });
    }
    return CompositedTransformTarget(
        link: _layerLink,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              key: _targetKey,
              width: 250,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: widget.saleItem is CreditNoteService ||
                          widget.saleItem is CreditNoteProduct
                      ? null
                      : () {
                          _showContextMenu();
                        },
                  child: IgnorePointer(
                    child: TextFormField(
                      readOnly: true,
                      mouseCursor: SystemMouseCursors.click,
                      controller: TextEditingController(
                        text: _saleElement != null
                            ? _saleElement!.name!
                            : widget.title,
                      ),
                      decoration: InputDecoration(
                        labelText: widget.title,
                        hintText: 'Selecciona algo...',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            widget.errorText != null
                ? Padding(
                    padding: const EdgeInsets.only(
                        top: kDefaultPadding / 3, left: 12),
                    child: Text(
                      widget.errorText!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 15),
                    ),
                  )
                : SizedBox()
          ],
        ));
  }
}
