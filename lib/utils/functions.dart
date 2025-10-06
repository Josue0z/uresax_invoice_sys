import 'dart:io';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path/path.dart' as path;
import 'package:uresax_invoice_sys/apis/electronic.ncf.api.request.dart';
import 'package:uresax_invoice_sys/apis/log.handler.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:http/http.dart' as http;

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
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    message,
                    style: TextStyle(color: fontColor, fontSize: 16),
                  )),
                  IconButton(
                      onPressed: () {
                        animationController.reverse().then((_) {
                          overlayEntry.remove();
                          animationController.dispose();
                        });
                      },
                      icon: Icon(Icons.close, color: Colors.white))
                ],
              )),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // Iniciar la animación
  animationController.forward();

  // Remover el SnackBar después de unos segundos

  Future.delayed(Duration(seconds: 5), () {
    if (animationController.isForwardOrCompleted) {
      animationController.reverse().then((_) {
        overlayEntry.remove();
        animationController.dispose();
      });
    }
  });
}

Future<Directory> getUresaxInvoiceDir() async {
  var dir = Directory(path.join(
      Platform.environment['URESAX_INVOICE_STATIC_LOCAL_SERVER_PATH'] ?? 'x',
      'URESAX-INVOICE'));

  print(dir.path);
  return await dir.create(recursive: true);
}

Future<bool> isValidCertFilePath() async {
  try {
    var filePath =
        certFile?.path ?? localStorage.getItem('certFilePath')?.trim();
    var password = certPassword.text;

    certFile = File(filePath ?? '');

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
      electronicNcfEnabled = true;
      return true;
    } else {
      return false;
    }
  } catch (e) {
    await LogHandler.printError(e.toString());    
    isValid = false;
    currentElectronicNcfOption = 2;
    electronicNcfEnabled = false;
    return false;
  }
}

Future<bool> hasInternet() async {
  try {
    final result = await http
        .get(Uri.parse('https://www.google.com'))
        .timeout(Duration(seconds: 5));
    return result.statusCode == 200;
  } catch (_) {
    return false;
  }
}

showLoader(BuildContext context) async {
  return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(30)),
          content: SizedBox(
            width: 150,
            height: 150,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      });
}
