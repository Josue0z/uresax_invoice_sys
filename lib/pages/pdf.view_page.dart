import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:uresax_invoice_sys/apis/printers.handler.dart';
import 'package:uresax_invoice_sys/pages/printers_page.dart';
import 'package:uresax_invoice_sys/settings.dart';

class PDFScreen extends StatefulWidget {
  final List<int> bytes;
  final String fileName;

  PDFScreen({Key? key, required this.bytes, required this.fileName})
      : super(key: key);

  @override
  PDFScreenState createState() => PDFScreenState();
}

class PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 231, 229, 229),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(widget.fileName),
          actions: [
            IconButton(
                onPressed: () async {
                  var printerName = await Navigator.push(context,
                      MaterialPageRoute(builder: (ctx) => PrintersPage()));
                  await PrinterHandler.printPdfBytes(printerName, widget.bytes);
                },
                icon: Icon(Icons.print)),
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close)),
            SizedBox(
              width: kDefaultPadding,
            )
          ],
        ),
        body: Center(
          child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              child: PdfViewer.data(Uint8List.fromList(widget.bytes),
                  params: PdfViewerParams(
                      backgroundColor: Colors.transparent, scaleEnabled: true),
                  sourceName: widget.fileName)),
        ));
  }
}
