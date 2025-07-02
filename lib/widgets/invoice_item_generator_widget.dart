import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:uresax_invoice_sys/pages/products_page.dart';
import 'package:uresax_invoice_sys/pages/services_page.dart';
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
          CustomDropdownFormField(
              title: title,
              initialValue: currenId,
              saleItem: widget.saleItem,
              elements: elements,
              validator: (val) {
                return val == null ? 'CAMPO OBLIGATORIO' : null;
              },
              onChanged: (element, option) {
                _onSelected(option);
              }),
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

class CustomDropdownFormField extends FormField<int> {
  CustomDropdownFormField({
    Key? key,
    required String title,
    required SaleItem saleItem,
    required List<SaleElement> elements,
    required void Function(SaleElement, int? option) onChanged,
    int? initialValue,
    FormFieldValidator<int>? validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
  }) : super(
          key: key,
          initialValue: initialValue,
          validator: validator,
          autovalidateMode: autovalidateMode,
          builder: (FormFieldState<int> state) {
            var value = initialValue ?? state.value;
            return _CustomDropdownButton(
              title: title,
              saleItem: saleItem,
              elements: elements,
              currentValue: value,
              errorText: state.errorText,
              onChanged: (element, id) {
                state.didChange(element.id);
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
  final String? errorText;

  _CustomDropdownButton({
    required this.title,
    required this.saleItem,
    required this.elements,
    required this.onChanged,
    this.currentValue,
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
    _elements = widget.elements;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox =
          _targetKey.currentContext!.findRenderObject() as RenderBox;

      final Size size = renderBox.size;

      _overlayEntry = OverlayEntry(
        builder: (context) => StatefulBuilder(
          builder: (context, localSetState){

     showElements() async {
   
           if (widget.saleItem is SaleItemService) {
      var service = await showDialog(context: context,builder: (ctx) => ServicesPage(selectedMode: true));

      if (service != null) {
        widget.currentValue = service.id;
        _saleElement = service;
       int index =  _elements.indexWhere((e)=> e.id == service.id);
       _elements[index] = _saleElement!;
      }
      widget.onChanged(_saleElement!, widget.currentValue);
    }
    if (widget.saleItem is SaleItemProduct) {
      var product = await showDialog(context: context, builder: (ctx) => ProductsPage(
                    selectedMode: true
                  ));

      if (product != null) {
        widget.currentValue = product.id;
        _saleElement = product;
      
        int index =  _elements.indexWhere((e)=> e.id == product.id);
       _elements[index] = _saleElement!;
     
       
      }
         widget.onChanged(_saleElement!, widget.currentValue);
    }
  }
            return  Stack(

            
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
          );
          }
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
    if (widget.elements.isNotEmpty) {
      _saleElement =
          widget.elements.firstWhere((e) => e.id == widget.currentValue);
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

class ServicePageWrapper<T> extends StatelessWidget {
  final Widget child;
  final void Function(T?) onClose;

  const ServicePageWrapper({super.key, required this.child, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return InheritedModalController<T>(
      onClose: onClose,
      child: child,
    );
  }
}



class InheritedModalController<T> extends InheritedWidget {
  final void Function(T?) onClose;

  const InheritedModalController({
    super.key,
    required super.child,
    required this.onClose,
  });

  static InheritedModalController<T>? of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedModalController<T>>();
  }

  @override
  bool updateShouldNotify(covariant InheritedModalController<T> oldWidget) => false;
}
