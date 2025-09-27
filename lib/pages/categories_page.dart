import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/modals/category.editor.modal.dart';
import 'package:uresax_invoice_sys/models/categorie.dart';
import 'package:uresax_invoice_sys/settings.dart';

class CategoriesPage extends StatefulWidget {
  bool selectorMode;
  CategoriesPage({super.key, this.selectorMode = false});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Category> categories = [];

  _onSelected(Category? category) {
    Navigator.pop(context, category);
  }

  _showModal({bool editing = false, required Category category}) async {
    var res = await showDialog(
        context: context,
        builder: (ctx) =>
            CategoryEditorModal(editing: editing, category: category));

    if (res == 'CREATE') {
      categories = await Category.get();
      setState(() {});
    }

    if (res == 'UPDATE') {
      categories = await Category.get();
      setState(() {});
    }
  }

  _initAsync() async {
    try {
      categories = await Category.get();

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
        title: Text('CATEGORIAS (${categories.length})'),
      ),
      body: ListView.separated(
          itemBuilder: (ctx, index) {
            var category = categories[index];
            return ListTile(
              minVerticalPadding: kDefaultPadding,
              leading: Container(
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(90),
                  color: Theme.of(context).primaryColor.withOpacity(0.04),
                ),
                child: Center(
                  child: Icon(
                    Icons.category_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
              ),
              title: Text(category.name ?? ''),
              onTap: widget.selectorMode
                  ? () {
                      _onSelected(category);
                    }
                  : null,
              trailing: Wrap(
                children: [
                  widget.selectorMode
                      ? IconButton(
                          onPressed: () {
                            _onSelected(category);
                          },
                          icon: Icon(Icons.arrow_right))
                      : SizedBox(),
                  IconButton(
                      onPressed: () async {
                        var res = await showDialog(
                            context: context,
                            builder: (ctx) => CategoryEditorModal(
                                category: category, editing: true));
                        if (res != null) {
                          categories = await Category.get();
                          setState(() {});
                        }
                      },
                      icon: Icon(Icons.edit))
                ],
              ),
            );
          },
          separatorBuilder: (ctx, i) => const Divider(),
          itemCount: categories.length),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showModal(category: Category());
          },
          child: Icon(Icons.add)),
    );
  }
}
