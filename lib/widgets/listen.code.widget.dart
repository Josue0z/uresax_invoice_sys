import 'dart:async';

import 'package:flutter/material.dart';

class ListenCodeWidget extends StatefulWidget {
  Widget child;
  void Function(String) onScan;
  ListenCodeWidget({super.key, required this.child, required this.onScan});

  @override
  State<ListenCodeWidget> createState() => _ListenCodeWidgetState();
}

class _ListenCodeWidgetState extends State<ListenCodeWidget> {
  String code = '';
  Timer? _scanTimer;

  FocusNode focusNode = FocusNode();
  void _onScan(KeyEvent event) {
    if (event.logicalKey.keyLabel == 'Num Lock') {
      return;
    }

    final char = event.character ?? '';

    code += char;

    _scanTimer?.cancel();
    _scanTimer = Timer(const Duration(milliseconds: 500), () {
      _onScanComplete(code);
      code = '';
    });
  }

  void _onScanComplete(String scannedCode) {
    print('✅ Código escaneado: $scannedCode');
    widget.onScan(scannedCode);
    // Aquí puedes procesar el código, buscar el producto, etc.
  }

  @override
  void initState() {
    focusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        child: widget.child,
        onKeyEvent: (keyEvent) {
          _onScan(keyEvent);
        });
  }
}
