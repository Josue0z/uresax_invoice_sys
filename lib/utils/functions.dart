import 'dart:io';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path/path.dart' as path;
import 'package:uresax_invoice_sys/apis/electronic.ncf.api.request.dart';
import 'package:uresax_invoice_sys/settings.dart';

void showTopSnackBar(BuildContext context,
    {required String message,
    Color color = Colors.black,
    Color fontColor = Colors.white}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;
  final animationController = AnimationController(
    vsync: Navigator.of(context),
    duration: Duration(milliseconds: 200),
  );
  final animation =
      Tween<double>(begin: -50, end: 50).animate(animationController);

  overlayEntry = OverlayEntry(
    builder: (context) => AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Positioned(
        top: animation.value,
        left: 20,
        right: 20,
        child: Material(
          elevation: 5.0,
          borderRadius: BorderRadius.circular(10),
          color: color,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: Text(
              message,
              style: TextStyle(color: fontColor, fontSize: 16),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // Iniciar la animación
  animationController.forward();

  // Remover el SnackBar después de unos segundos
  Future.delayed(Duration(seconds: 2), () {
    animationController.reverse().then((_) {
      overlayEntry.remove();
      animationController.dispose();
    });
  });
}

Future<Directory> getUresaxInvoiceDir() async {
  var dir = Directory(path.join(
      Platform.environment['URESAX_INVOICE_STATIC_LOCAL_SERVER_PATH'] ?? 'x',
      'URESAX-INVOICE'));
  return await dir.create(recursive: true);
}

Future<bool> isValidCertFilePath() async {
  try {
    var filePath =
        certFile?.path ?? localStorage.getItem('certFilePath')?.trim();
    var password = certPassword.text;

    var storePassword = localStorage.getItem('certPassword');

    if (password.isNotEmpty) {
      password = certPassword.text;
    } else {
      password = storePassword ?? '';
    }
 

    var data = await extraerInfoPfx(path: filePath ?? '', password: password);


    if (data.contains('VIAFIRMA DOMINICANA')) {
      isValid = true;
      currentElectronicNcfOption = 1;
      //electronicNcfEnabled = true;
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print(e);
    isValid = false;
    currentElectronicNcfOption = 2;
    //electronicNcfEnabled = false;
    return false;
  }
}
