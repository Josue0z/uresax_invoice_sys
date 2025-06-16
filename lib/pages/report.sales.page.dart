import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uresax_invoice_sys/settings.dart';

class ReportSalesPage extends StatefulWidget {
  String title;

  List<Map<String, dynamic>> data;

  ReportSalesPage({super.key, required this.title, required this.data});

  @override
  State<ReportSalesPage> createState() => _ReportSalesPageState();
}

class _ReportSalesPageState extends State<ReportSalesPage> {
  List<String> get columns {
    if (widget.data.isEmpty) return [];
    var items = widget.data[0].keys.toList();
    return items;
  }

  Widget get contentEmpty {
    return Expanded(
        child: Center(
      child: Column(
        children: [
          SvgPicture.asset('assets/svgs/undraw_printing-invoices_osgs.svg',
              width: 320)
        ],
      ),
    ));
  }

  Widget get contentFilled {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Table(
                      defaultColumnWidth: FixedColumnWidth(150),
                      children: [
                        TableRow(
                            children: List.generate(columns.length, (index) {
                          var col = columns[index];
                          return Padding(
                              padding: EdgeInsets.all(kDefaultPadding),
                              child: Text(col,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(context).primaryColor)));
                        }))
                      ],
                    ),
                    Table(
                      defaultColumnWidth: FixedColumnWidth(150),
                      children: [
                        ...List.generate(widget.data.length, (index) {
                          var item = widget.data[index];
                          var values = item.values.toList();
                          return TableRow(
                              children: List.generate(values.length, (i) {
                            var val = values[i];
                            return Padding(
                                padding: EdgeInsets.all(kDefaultPadding),
                                child: Text(val.toString(),
                                    style:
                                        Theme.of(context).textTheme.bodySmall));
                          }));
                        })
                      ],
                    )
                  ],
                ),
              )),
        )
      ],
    );
  }

  Widget get content {
    if (widget.data.isEmpty) return contentEmpty;
    return contentFilled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('${company?.name} - ${widget.title}'),
        ),
        body: SelectableRegion(
            focusNode: FocusNode(),
            selectionControls: DesktopTextSelectionControls(),
            child: Padding(
                padding: EdgeInsets.all(kDefaultPadding), child: content)));
  }
}
