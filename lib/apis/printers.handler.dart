import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart';
import 'package:uresax_invoice_sys/models/sale.abs.dart';
import 'package:uresax_invoice_sys/pages/pdf.view_page.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';


class PrinterHandler {
  /// Detecta la plataforma actual
  static bool get isWindows => Platform.isWindows;
  static bool get isMacOS => Platform.isMacOS;

  /// Lista las impresoras disponibles
  static Future<List<String>> listPrinters() async {
    if (isWindows) {
      final result = await Process.run('powershell',
          ['-Command', 'Get-Printer | Select-Object -ExpandProperty Name']);
      return LineSplitter.split(result.stdout.toString())
          .where((line) => line.trim().isNotEmpty)
          .toList();
    } else if (isMacOS) {
      final result = await Process.run('lpstat', ['-p']);

      final printers = LineSplitter.split(result.stdout.toString())
          .map((line) {
            return line.split(' ')[2];
          })
          .whereType<String>()
          .toList();
      return printers;
    } else {
      throw UnsupportedError('Plataforma no soportada');
    }
  }


static Future<List<Map<String, String>>> listSerialDevices() async {
  if (Platform.isWindows) {
    final result = await Process.run('powershell', [
      '-Command',
      '''
      Get-WmiObject Win32_SerialPort | Where-Object { \$_.PNPDeviceID -like "USB*" } | ForEach-Object { "\$(\$_.Name)|\$(\$_.DeviceID)" }
      '''
    ]);

    print(result.stdout); // Para depurar

    return LineSplitter.split(result.stdout.toString())
        .where((line) => line.contains('|'))
        .map((line) {
          final parts = line.split('|');
          return {
            'name': parts[0].trim(),
            'deviceId': parts[1].trim(),
          };
        }).toList();
  } else {
    throw UnsupportedError('Solo compatible con Windows');
  }
}




  /// Imprime un PDF desde bytes en Windows, macOS o Linux
  static Future<void> printPdfBytes(
      String printerName, List<int> pdfBytes) async {
    // Guarda los bytes en un archivo temporal
    final tempDir = Directory.systemTemp;
    final tempFile =
        File('${tempDir.path}${Platform.pathSeparator}temp_print.pdf');
    await tempFile.writeAsBytes(pdfBytes);

    if (Platform.isMacOS || Platform.isLinux) {
      // Usa el comando 'lp' para enviar el archivo al spool de impresión
      final result =
          await Process.run('lp', ['-d', printerName, tempFile.path]);
      if (result.exitCode != 0) {
        stderr.writeln('Error al imprimir en macOS/Linux: ${result.stderr}');
      }
    } else if (Platform.isWindows) {
      // Usa Adobe Reader si está disponible
      final adobePath =
          Platform.environment['URESAX_INVOICE_ADOBE_READER_PATH'] ?? 'C:\\xxx.txt';
      if (await File(adobePath).exists()) {
        final result =
            await Process.run(adobePath, ['/p', tempFile.path]);
        if (result.exitCode != 0) {
          stderr
              .writeln('Error al imprimir con Adobe Reader: ${result.stderr}');
        }
      } else {
        // Alternativa: usar el comando 'print' (solo para archivos de texto)
        final result = await Process.run(
            'cmd', ['/c', 'print /d:"$printerName" "${tempFile.path}"']);
        if (result.exitCode != 0) {
          stderr.writeln('Error al imprimir con cmd: ${result.stderr}');
        }
      }
    } else {
      throw UnsupportedError('Plataforma no soportada');
    }

    // Limpieza opcional
    await tempFile.delete();
  }

  /// Imprime los bytes ESC/POS en la impresora seleccionada
  static Future<void> printBytes(
      String printerName, List<int> escPosBytes) async {
    if (isWindows) {
          final printerNamePtr = printerName.toNativeUtf16();
  final docInfo = calloc<DOC_INFO_1>();
docInfo.ref.pDocName = 'Flutter POS'.toNativeUtf16();
docInfo.ref.pOutputFile = nullptr;
docInfo.ref.pDatatype = 'RAW'.toNativeUtf16();


  final hPrinter = calloc<HANDLE>();
  final success = OpenPrinter(printerNamePtr, hPrinter, nullptr);

  if (success == 0) {
    print('No se pudo abrir la impresora');
    calloc.free(printerNamePtr);
    calloc.free(hPrinter);
    free(docInfo);
    return;
  }

  StartDocPrinter(hPrinter.value, 1, docInfo);
  StartPagePrinter(hPrinter.value);

  final dataPtr = calloc<Uint8>(escPosBytes.length);
  final byteList = dataPtr.asTypedList(escPosBytes.length);
  byteList.setAll(0, escPosBytes);

  int bytesWritten = 0;
  WritePrinter(hPrinter.value, dataPtr, escPosBytes.length, calloc<Uint32>()..value = bytesWritten);

  EndPagePrinter(hPrinter.value);
  EndDocPrinter(hPrinter.value);
  ClosePrinter(hPrinter.value);

  calloc.free(printerNamePtr);
  calloc.free(dataPtr);
  calloc.free(hPrinter);
  free(docInfo);

    } else if (isMacOS) {
      final process = await Process.start('lp', ['-d', printerName]);
      process.stdin.add(escPosBytes);
      await process.stdin.close();
      await process.exitCode;
    } else {
      throw UnsupportedError('Plataforma no soportada');
    }
  }

  static Future<void> showPdfView(
      {required BuildContext context,
      required List<int> bytes,
      required Document document,
      required Sale sale}) async {
    try {
    
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (ctx) => PDFScreen(
                    bytes: bytes,
                    document: document,
                    fileName: '${sale.ncf}_${company?.name}.PDF',
                  )));
    } catch (e) {
      throw UnsupportedError('No se puede mostrar el pdf');
    }
  }
}
