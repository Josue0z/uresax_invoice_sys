import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uresax_invoice_sys/modals/discount.editor.modal.dart';
import 'package:uresax_invoice_sys/models/discount.dart';

class DiscountsPage extends StatefulWidget {
  bool selectorMode;
  DiscountsPage({super.key, this.selectorMode = false});

  @override
  State<DiscountsPage> createState() => _DiscountsPageState();
}

class _DiscountsPageState extends State<DiscountsPage> {
  List<Discount> discounts = [];

  _showModal({bool editing = false, required Discount discount}) async {
    var res = await showDialog(
        context: context,
        builder: (ctx) =>
            DiscountEditorModal(editing: editing, discount: discount));

    if (res == 'CREATE') {
      discounts = await Discount.get();
      setState(() {});
    }

    if (res == 'UPDATE') {
      discounts = await Discount.get();
      setState(() {});
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

  Widget get content {
    if (discounts.isEmpty) return contentEmpty;
    return contentFilled;
  }

  _initAsync() async {
    discounts = await Discount.get();
    setState(() {});
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
        title: Text('DESCUENTOS (${discounts.length})'),
      ),
      body: content,
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showModal(discount: Discount());
          },
          child: Icon(Icons.add)),
    );
  }
}
