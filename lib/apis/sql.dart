
import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/settings.dart';

class SqlConector {
  static Connection? connection;
  static bool loading = true;
  static Future<void> initialize() async {
    connection = await Connection.open(
        Endpoint(
          port: int.parse(
              port ?? '5432'),
          host: hostname!,
          database: databaseName!,
          username: dbUsername,
          password: dbPassword,
        ),
        settings: ConnectionSettings(sslMode: SslMode.disable));
    loading = false;
  }
}
