import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/models/sale.abs.dart';
import 'package:uresax_invoice_sys/pages/pdf.view_page.dart';
import 'package:uresax_invoice_sys/settings.dart';

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
          Platform.environment['URESAX_INVOICE_ADOBE_READER_PATH'] ?? '</Path>';
      if (await File(adobePath).exists()) {
        final result =
            await Process.run(adobePath, ['/t', tempFile.path, printerName]);
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
      final tempFile = File('C:\\temp\\printjob.bin');
      await tempFile.writeAsBytes(escPosBytes);
      await Process.run(
          'cmd', ['/c', 'copy /b ${tempFile.path} "$printerName"']);
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
      required Sale sale}) async {
    try {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (ctx) => PDFScreen(
                    bytes: bytes,
                    fileName: '${sale.ncf}_${company?.name}.PDF',
                  )));
    } catch (e) {
      throw UnsupportedError('No se puede mostrar el pdf');
    }
  }
}
