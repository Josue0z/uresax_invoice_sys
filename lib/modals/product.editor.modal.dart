import 'package:amount_input_formatter/amount_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/apis/log.handler.dart';
import 'package:uresax_invoice_sys/models/categorie.dart';
import 'package:uresax_invoice_sys/models/product.dart';
import 'package:uresax_invoice_sys/models/provider.dart';
import 'package:uresax_invoice_sys/pages/categories_page.dart';
import 'package:uresax_invoice_sys/pages/providers_page.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';
import 'package:uresax_invoice_sys/widgets/selector.item.widget.dart';

class ProductEditorModal extends StatefulWidget {
  bool editing;
  Products product;

  ProductEditorModal({super.key, this.editing = false, required this.product});

  @override
  State<ProductEditorModal> createState() => _ProductEditorModalState();
}

class _ProductEditorModalState extends State<ProductEditorModal> {
  TextEditingController name = TextEditingController();
  TextEditingController cost = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController factor = TextEditingController();
  TextEditingController quantityResult = TextEditingController();
  TextEditingController chassis = TextEditingController();
  TextEditingController code = TextEditingController();
  TextEditingController licensePlate = TextEditingController();
  AmountInputFormatter amountInputFormatter =
      AmountInputFormatter(fractionalDigits: 2);

  AmountInputFormatter costInputFormatter =
      AmountInputFormatter(fractionalDigits: 2);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int? currentTaxId;
  int? currentWareHouseId;
  int? currentCategoryId;
  Providers? currentProvider;
  Category? currentCategory;
  int? currentProviderId;
  int? xxquantity = 1;

  _calcUnits() {
    int xquantity = widget.product.quantity ?? 0;
    double xfactor = widget.product.factor ?? 0.0;

    if (factor.text.isNotEmpty && xfactor >= 1) {
      xxquantity = (xquantity * xfactor).toInt();
      quantityResult.value = TextEditingValue(text: xxquantity.toString());
    } else {
      quantityResult.value = TextEditingValue.empty;
    }
  }

  _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        widget.product.name = name.text.trim();
        widget.product.price = amountInputFormatter.doubleValue;
        widget.product.cost = costInputFormatter.doubleValue;
        widget.product.quantity = xxquantity;
        widget.product.chassis = chassis.text.trim();
        widget.product.licensePlate = licensePlate.text.trim();
        widget.product.taxId = currentTaxId;
        widget.product.wareHouseId = currentWareHouseId;
        widget.product.providerId = currentProviderId;
        widget.product.code = code.text.trim();
        widget.product.categoryId = currentCategoryId;
        if (!widget.editing) {
          await widget.product.create();
          await LogHandler.printEvent(
              'PRODUCTO: ${widget.product.name} CREADO');
          Navigator.pop(context, 'CREATE');
        } else {
          await widget.product.update();
          await LogHandler.printEvent(
              'PRODUCTO: ${widget.product.name} ACTUALIZADO');
          Navigator.pop(context, 'UPDATE');
          showTopSnackBar(context,
              message: widget.editing ? 'PRODUCTO EDITADO' : 'PRODUCTO CREADO',
              color: Colors.green);
        }
      } catch (e) {
        await LogHandler.printError(e.toString());
        showTopSnackBar(context, message: e.toString(), color: Colors.red);
      }
    }
  }

  String get title {
    return widget.editing ? 'EDITANDO PRODUCTO' : 'AGREGANDO PRODUCTO';
  }

  String get btnTitle {
    return widget.editing ? 'EDITAR PRODUCTO' : 'AGREGAR PRODUCTO';
  }

  @override
  void initState() {
    name.value = TextEditingValue(text: widget.product.name ?? '');

    currentWareHouseId = widget.product.wareHouseId;

    currentProviderId = widget.product.providerId;
    currentProvider =
        Providers(id: currentProviderId, name: widget.product.providerName);

    currentCategoryId = widget.product.categoryId;
    currentCategory = Category(
        id: widget.product.categoryId, name: widget.product.categoryName);

    if (widget.editing) {
      xxquantity = widget.product.quantity;
      amount.value = amountInputFormatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.product.price?.toStringAsFixed(2) ?? ''));

      cost.value = costInputFormatter.formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(
              text: widget.product.cost?.toStringAsFixed(2) ?? ''));
    }
    code.value = TextEditingValue(text: widget.product.code ?? '');

    quantity.value = TextEditingValue(text: xxquantity.toString());
    chassis.value = TextEditingValue(text: widget.product.chassis ?? '');
    licensePlate.value =
        TextEditingValue(text: widget.product.licensePlate ?? '');

    currentTaxId = widget.product.taxId;

    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
          key: _formKey,
          child: Container(
              width: 350,
              height: 550,
              padding: EdgeInsets.all(kDefaultPadding),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(title,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                      color: Theme.of(context).primaryColor))),
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close))
                    ],
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin:
                              EdgeInsets.symmetric(vertical: kDefaultPadding),
                          child: DropdownButtonFormField<int>(
                              initialValue: currentWareHouseId,
                              validator: (val) =>
                                  val == null ? 'CAMPO OBLIGATORIO' : null,
                              items: List.generate(wareHouses.length, (index) {
                                var wareHouse = wareHouses[index];
                                return DropdownMenuItem(
                                    value: wareHouse.id,
                                    child: Text(wareHouse.name ?? ''));
                              }),
                              onChanged: (id) {
                                currentWareHouseId = id;
                              }),
                        ),
                        Container(
                            margin: EdgeInsets.only(bottom: kDefaultPadding),
                            child: SelectorItemWidget<Providers>(
                              context: context,
                              initialValue: currentProvider,
                              validator: (val) =>
                                  val?.id == null ? 'CAMPO OBLIGATORIO' : null,
                              onChanged: (xprovider) {
                                currentProvider = xprovider;
                                currentProviderId = xprovider?.id;
                              },
                              screen: ProvidersPage(selectorMode: true),
                              title: 'SELECCIONA PROVEEDOR',
                            )),
                        Container(
                            margin: EdgeInsets.only(bottom: kDefaultPadding),
                            child: SelectorItemWidget<Category>(
                              context: context,
                              initialValue: currentCategory,
                              validator: (val) =>
                                  val?.id == null ? 'CAMPO OBLIGATORIO' : null,
                              onChanged: (xcategory) {
                                currentCategory = xcategory;
                                currentCategoryId = xcategory?.id;
                              },
                              screen: CategoriesPage(selectorMode: true),
                              title: 'SELECCIONA CATEGORIA',
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: kDefaultPadding),
                          child: TextFormField(
                            controller: name,
                            validator: (val) =>
                                val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                            decoration: InputDecoration(
                                labelText: 'NOMBRE',
                                hintText: 'Escribir nombre...'),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: kDefaultPadding),
                          child: TextFormField(
                            controller: cost,
                            validator: (val) =>
                                val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                            inputFormatters: [costInputFormatter],
                            decoration: InputDecoration(
                                labelText: 'COSTO', hintText: '0.00'),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: kDefaultPadding),
                          child: TextFormField(
                            controller: amount,
                            validator: (val) =>
                                val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                            inputFormatters: [amountInputFormatter],
                            decoration: InputDecoration(
                                labelText: 'PRECIO', hintText: '0.00'),
                          ),
                        ),
                        eCommerceMode
                            ? Container(
                                margin:
                                    EdgeInsets.only(bottom: kDefaultPadding),
                                child: TextFormField(
                                  controller: code,
                                  decoration: InputDecoration(
                                      labelText: 'CODIGO PRODUCTO',
                                      hintText: 'Escribir...'),
                                ),
                              )
                            : Container(
                                margin:
                                    EdgeInsets.only(bottom: kDefaultPadding),
                                child: TextFormField(
                                  controller: chassis,
                                  validator: (val) =>
                                      val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                                  decoration: InputDecoration(
                                      labelText: 'CHASIS',
                                      hintText: 'Escribir...'),
                                ),
                              ),
                        !eCommerceMode
                            ? Container(
                                margin:
                                    EdgeInsets.only(bottom: kDefaultPadding),
                                child: TextFormField(
                                  controller: licensePlate,
                                  validator: (val) =>
                                      val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                                  decoration: InputDecoration(
                                      labelText: 'PLACA',
                                      hintText: 'Escribir...'),
                                ),
                              )
                            : SizedBox(),
                        Container(
                          margin: EdgeInsets.only(bottom: kDefaultPadding),
                          child: DropdownButtonFormField<int>(
                              initialValue: currentTaxId,
                              items: List.generate(taxes.length, (index) {
                                var tax = taxes[index];
                                return DropdownMenuItem(
                                    value: tax.id, child: Text(tax.name ?? ''));
                              }),
                              onChanged: (option) {
                                currentTaxId = option;
                              }),
                        ),
                        !widget.editing
                            ? Container(
                                margin:
                                    EdgeInsets.only(bottom: kDefaultPadding),
                                child: TextFormField(
                                  controller: quantity,
                                  readOnly: !eCommerceMode,
                                  onChanged: (val) {
                                    widget.product.quantity =
                                        int.tryParse(quantity.text) ?? 0;
                                    _calcUnits();
                                  },
                                  validator: (val) =>
                                      val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      labelText: 'CANTIDAD', hintText: '0'),
                                ),
                              )
                            : SizedBox(),
                        eCommerceMode && !widget.editing
                            ? Container(
                                margin:
                                    EdgeInsets.only(bottom: kDefaultPadding),
                                child: TextFormField(
                                  controller: factor,
                                  onChanged: (_) {
                                    widget.product.factor =
                                        double.tryParse(factor.text) ?? 1;
                                    _calcUnits();
                                  },
                                  validator: (val) =>
                                      val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      labelText: 'FACTOR', hintText: '0.00'),
                                ),
                              )
                            : SizedBox(),
                        eCommerceMode && !widget.editing
                            ? Container(
                                margin:
                                    EdgeInsets.only(bottom: kDefaultPadding),
                                child: TextFormField(
                                  controller: quantityResult,
                                  onChanged: (_) {},
                                  validator: (val) =>
                                      val!.isEmpty ? 'CAMPO OBLIGATORIO' : null,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      labelText: 'UNIDADES', hintText: '0'),
                                ),
                              )
                            : SizedBox()
                      ],
                    ),
                  )),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                        onPressed: _onSubmit, child: Text(btnTitle)),
                  )
                ],
              ))),
    );
  }
}
