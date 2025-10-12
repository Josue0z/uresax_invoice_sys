import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uresax_invoice_sys/modals/discount.editor.modal.dart';
import 'package:uresax_invoice_sys/models/discount.dart';
import 'package:uresax_invoice_sys/widgets/content.error.widget.dart';

class DiscountsPage extends StatefulWidget {
  bool selectorMode;
  DiscountsPage({super.key, this.selectorMode = false});

  @override
  State<DiscountsPage> createState() => _DiscountsPageState();
}

class _DiscountsPageState extends State<DiscountsPage> {
  List<Discount> discounts = [];
  Future? future;

  _showModal({bool editing = false, required Discount discount}) async {
    var res = await showDialog(
        context: context,
        builder: (ctx) =>
            DiscountEditorModal(editing: editing, discount: discount));

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

  _onSelected(Discount discount) {
    Navigator.pop(context, discount);
  }

  Widget get contentFilled {
    return ListView.separated(
        itemBuilder: (ctx, index) {
          var discount = discounts[index];
          return ListTile(
            onTap: widget.selectorMode
                ? () {
                    _onSelected(discount);
                  }
                : null,
            title: Text(discount.name ?? ''),
            trailing: Wrap(
              children: [
                widget.selectorMode
                    ? IconButton(
                        onPressed: () {
                          _onSelected(discount);
                        },
                        icon: Icon(Icons.arrow_right))
                    : SizedBox(),
                IconButton(
                    onPressed: () {
                      _showModal(discount: discount, editing: true);
                    },
                    icon: Icon(Icons.edit))
              ],
            ),
          );
        },
        separatorBuilder: (ctx, i) => const Divider(),
        itemCount: discounts.length);
  }

  Widget get contentEmpty {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/svgs/undraw_statistic-chart_6s7z.svg',
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

  _initAsync([String? words]) async {
    discounts = [
      Discount(
        name: 'DESCUENTO',
      ),
      ...await Discount.get()
    ];
    setState(() {});
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
        title: Text('DESCUENTOS (${discounts.length})'),
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
                discounts.isNotEmpty) {
              return contentFilled;
            }

            return contentEmpty;
          }),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showModal(discount: Discount());
          },
          child: Icon(Icons.add)),
    );
  }
}
