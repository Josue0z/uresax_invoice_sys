import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uresax_invoice_sys/apis/log.handler.dart';
import 'package:uresax_invoice_sys/modals/product.editor.modal.dart';
import 'package:uresax_invoice_sys/models/product.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/extensions.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';
import 'package:uresax_invoice_sys/widgets/content.error.widget.dart';
import 'package:uresax_invoice_sys/widgets/scrollmove.event.widget.dart';

class ProductsPage extends StatefulWidget {
  bool selectedMode;
  bool isOrdenGenerator;
  ProductsPage(
      {super.key, this.selectedMode = false, this.isOrdenGenerator = false});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Products> products = [];
  Future? future;
  final TextEditingController _searchController = TextEditingController();
  ScrollController scrollControllerY = ScrollController();

  _showModal({bool editing = false, required Products product}) async {
    var res = await showDialog(
        context: context,
        builder: (ctx) => ProductEditorModal(
              editing: editing,
              product: product,
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

  _deleteProduct(Products product) async {
    try {
      var isConfirm =
          await showConfirm(context, title: 'DESEAS ELIMINAR PRODUCTO?');
      if (isConfirm == true) {
        showLoader(context);
        await product.delete();
        setState(() {
          future = _initAsync();
        });
        showTopSnackBar(context,
            message: 'PRODUCTO ELIMINADO!', color: Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      showTopSnackBar(context, message: e.toString(), color: Colors.red);
      await LogHandler.printError(e.toString());
    }
  }

  _initAsync([String? words]) async {
    try {
      products = await Products.get(search: words);
    } catch (e) {
      print(e);
    } finally {
      setState(() {});
    }
  }

  Widget get contentFilled {
    return ScrollMoveEventWidget(
        scrollControllerY: scrollControllerY,
        child: ListView.separated(
            controller: scrollControllerY,
            separatorBuilder: (ctx, i) => const Divider(),
            itemCount: products.length,
            itemBuilder: (ctx, index) {
              var product = products[index];
              return ListTile(
                minVerticalPadding: kDefaultPadding,
                onTap: widget.selectedMode
                    ? () {
                        try {
                          if (product.quantity == 0 &&
                              !widget.isOrdenGenerator) {
                            throw 'NO EXISTEN ${product.name} EN EL INVENTARIO';
                          }
                          Navigator.pop(context, product);
                        } catch (e) {
                          showTopSnackBar(context,
                              message: e.toString(), color: Colors.red);
                        }
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
                      Icons.inventory_2_outlined,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                ),
                title: Text(
                  product.name ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                subtitle: Text(
                    '${product.wareHouseName} - ${product.providerName} - ${product.categoryName} / ${product.price?.toCoin()}'),
                trailing: Wrap(
                  runAlignment: WrapAlignment.center,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(kDefaultPadding / 2),
                      decoration: BoxDecoration(
                          color: product.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50)),
                      child: Text(
                        product.quantity == 0
                            ? 'AGOTADO'
                            : product.quantity.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: product.color),
                      ),
                    ),
                    SizedBox(width: kDefaultPadding),
                    IconButton(
                        onPressed: () {
                          _showModal(product: product, editing: true);
                        },
                        icon: Icon(Icons.edit)),
                    SizedBox(width: kDefaultPadding),
                    IconButton(
                        onPressed: () {
                          _deleteProduct(product);
                        },
                        icon: Icon(Icons.delete))
                  ],
                ),
              );
            }));
  }

  Widget get contentEmpty {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/svgs/undraw_product-iteration_r2wg.svg',
              width: 250)
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
        title: Text('TUS PRODUCTOS (${products.length})'),
        actions: [
          Wrap(
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 50,
                child: TextFormField(
                  controller: _searchController,
                  onFieldSubmitted: (words) async {
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
              SizedBox(width: kDefaultPadding),
              CircleAvatar(
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        future = _initAsync();
                      });
                    },
                    icon: Icon(Icons.restore)),
              ),
              SizedBox(width: kDefaultPadding),
              CircleAvatar(
                  child: IconButton(
                      tooltip: 'AGREGAR PRODUCTO',
                      onPressed: () {
                        _showModal(product: Products());
                      },
                      icon: Icon(Icons.add))),
              SizedBox(width: kDefaultPadding),
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
                products.isNotEmpty) {
              return contentFilled;
            }

            return contentEmpty;
          }),
    );
  }
}
