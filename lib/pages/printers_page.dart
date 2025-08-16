import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:uresax_invoice_sys/apis/printers.handler.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';

class PrintersPage extends StatefulWidget {
  const PrintersPage({super.key});

  @override
  State<PrintersPage> createState() => _PrintersPageState();
}

class _PrintersPageState extends State<PrintersPage> {
  List<String> printers = [];
  // Get Printer List
  void startScan() async {
    printers = await PrinterHandler.listPrinters();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startScan();
    });
  }

  stopScan() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IMPRESORAS (${printers.length})'),
      ),
      body: ListView.separated(
          itemBuilder: (ctx, index) {
            final printer = printers[index];

            return ListTile(
              title: Text(printer),
              onTap: () async {
                try {
                  localStorage.setItem('printer', printer);
                  Navigator.pop(context, printer);
                } catch (e) {
                  showTopSnackBar(context,
                      message: e.toString(), color: Colors.red);
                }
              },
            );
          },
          separatorBuilder: (ctx, index) => Divider(),
          itemCount: printers.length),
    );
  }
}
