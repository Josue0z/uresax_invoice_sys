import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uresax_invoice_sys/modals/product.editor.modal.dart';
import 'package:uresax_invoice_sys/models/product.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/extensions.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';

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
    return ListView.separated(
        separatorBuilder: (ctx, i) => const Divider(),
        itemCount: products.length,
        itemBuilder: (ctx, index) {
          var product = products[index];
          return ListTile(
            minVerticalPadding: kDefaultPadding,
            onTap: widget.selectedMode
                ? () {
                    try {
                      if (product.quantity == 0 && !widget.isOrdenGenerator) {
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
                    product.quantity.toString(),
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
                    icon: Icon(Icons.edit))
              ],
            ),
          );
        });
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

  Widget contentError(dynamic error) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(error.toString())],
      ),
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
                  onChanged: (words) async {
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
              return contentError(s.error);
            }
            if (s.connectionState == ConnectionState.done &&
                products.isNotEmpty) {
              return contentFilled;
            }

            return contentEmpty;
          }),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showModal(product: Products());
          },
          child: Icon(Icons.add)),
    );
  }
}
