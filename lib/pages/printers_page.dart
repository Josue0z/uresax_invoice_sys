import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';

class PrintersPage extends StatefulWidget {
  const PrintersPage({super.key});

  @override
  State<PrintersPage> createState() => _PrintersPageState();
}

class _PrintersPageState extends State<PrintersPage> {
  final _flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;

  List<Printer> printers = [];

  StreamSubscription<List<Printer>>? _devicesStreamSubscription;

  // Get Printer List
  void startScan() async {
    _devicesStreamSubscription?.cancel();
    await _flutterThermalPrinterPlugin.getPrinters(connectionTypes: [
      ConnectionType.USB,
      ConnectionType.NETWORK,
    ]);
    _devicesStreamSubscription = _flutterThermalPrinterPlugin.devicesStream
        .listen((List<Printer> event) {
      setState(() {
        printers = event;
        printers.removeWhere(
            (element) => element.name == null || element.name == '');
      });
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      startScan();
    });
  }

  stopScan() {
    _flutterThermalPrinterPlugin.stopScan();
  }

  Future<List<int>> _generateReceipt() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    bytes += generator.text(
      "Teste Network print",
      styles: const PosStyles(
        bold: true,
        height: PosTextSize.size3,
        width: PosTextSize.size3,
      ),
    );
    bytes += generator.cut();
    return bytes;
  }

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
              title: Text(printer.name ?? 'Desconocida'),
              subtitle: Text(printer.name ?? ''),
              trailing: Text(printer.address ?? 'Desconocida'),
              onTap: () async {
                try {
                  var bytes = await _generateReceipt();
                  await _flutterThermalPrinterPlugin.printData(printer, bytes);
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
