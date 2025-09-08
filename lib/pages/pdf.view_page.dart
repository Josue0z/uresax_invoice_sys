import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.fileName),
        actions: [
          IconButton(
              onPressed: () async {
                var printName = await Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => PrintersPage()));
                print(printName);
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
      body: PdfViewer.data(Uint8List.fromList(widget.bytes),
          params: PdfViewerParams(
              backgroundColor: Colors.black12,
              maxScale: 5.0,
              scaleEnabled: true),
          sourceName: widget.fileName),
    );
  }
}
