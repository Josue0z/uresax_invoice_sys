import 'dart:io';

import 'package:postgres/postgres.dart';

class SqlConector {
  static Connection? connection;
  static bool loading = true;
  static Future<void> initialize() async {
    connection = await Connection.open(
        Endpoint(
          host: Platform.environment['URESAX_INVOICE_DATABASE_HOSTNAME']!,
          database: Platform.environment['URESAX_INVOICE_DATABASE_NAME']!,
          username: Platform.environment['URESAX_INVOICE_DATABASE_USERNAME'],
          password: Platform.environment['URESAX_INVOICE_DATABASE_PASSWORD'],
        ),
        settings: ConnectionSettings(sslMode: SslMode.disable));
    loading = false;
  }
}
