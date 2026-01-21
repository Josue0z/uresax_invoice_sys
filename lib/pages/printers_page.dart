
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:uresax_invoice_sys/apis/printers.handler.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';


class PrintersPage extends StatefulWidget {
  const PrintersPage({super.key});

  @override
  State<PrintersPage> createState() => _PrintersPageState();
}

class _PrintersPageState extends State<PrintersPage> {



  void startScan() async {
    printers = (await PrinterHandler.listPrinters());
    printers.sort((a,b) => a.compareTo(b));
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
        title: Text('DISPOSITIVOS (${printers.length})'),
      ),
      body: ListView.separated(
          itemBuilder: (ctx, index) {
            final printer = printers[index];
          
            return ListTile(
              title: Text(printer),
       
              onTap: () async {
                try {
                  localStorage.setItem('devicePos', printer);
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
