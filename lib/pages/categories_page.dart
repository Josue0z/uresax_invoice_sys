import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
  Future? future;

  _onSelected(Category? category) {
    Navigator.pop(context, category);
  }

  _showModal({bool editing = false, required Category category}) async {
    var res = await showDialog(
        context: context,
        builder: (ctx) =>
            CategoryEditorModal(editing: editing, category: category));

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

  Widget get contentFilled {
    return ListView.separated(
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
                        setState(() {
                          future = _initAsync();
                        });
                      }
                    },
                    icon: Icon(Icons.edit))
              ],
            ),
          );
        },
        separatorBuilder: (ctx, i) => const Divider(),
        itemCount: categories.length);
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

  _initAsync([String? words]) async {
    try {
      categories = await Category.get(search: words);
    } catch (e) {
      print(e);
    } finally {
      setState(() {});
    }
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
        title: Text('CATEGORIAS (${categories.length})'),
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
                categories.isNotEmpty) {
              return contentFilled;
            }

            return contentEmpty;
          }),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showModal(category: Category());
          },
          child: Icon(Icons.add)),
    );
  }
}
