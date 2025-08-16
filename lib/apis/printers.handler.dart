import 'dart:convert';
import 'dart:io';

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
}
