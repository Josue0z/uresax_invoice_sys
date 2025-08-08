import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/modals/product.editor.modal.dart';
import 'package:uresax_invoice_sys/models/product.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/extensions.dart';

class ProductsPage extends StatefulWidget {
  bool selectedMode;
  ProductsPage({super.key, this.selectedMode = false});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Products> products = [];

  _showModal({bool editing = false, required Products product}) async {
    var res = await showDialog(
        context: context,
        builder: (ctx) => ProductEditorModal(
              editing: editing,
              product: product,
            ));

    if (res == 'CREATE') {
      products = await Products.get();
      setState(() {});
    }

    if (res == 'UPDATE') {
      products = await Products.get();
      setState(() {});
    }
  }

  _initAsync() async {
    try {
      products = await Products.get();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    _initAsync();
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
                    products = await Products.get(search: words);
                    setState(() {});
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
      body: ListView.separated(
          separatorBuilder: (ctx, i) => const Divider(),
          itemCount: products.length,
          itemBuilder: (ctx, index) {
            var product = products[index];
            return ListTile(
              minVerticalPadding: kDefaultPadding,
              onTap: widget.selectedMode
                  ? () {
                      Navigator.pop(context, product);
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
              subtitle:
                  Text('${product.wareHouseName} - ${product.price?.toCoin()}'),
              trailing: Wrap(
                runAlignment: WrapAlignment.center,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Total: ${product.total?.toCoin()}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(width: kDefaultPadding),
                  Text(
                    product.quantity.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
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
          }),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showModal(product: Products());
          },
          child: Icon(Icons.add)),
    );
  }
}
