import 'package:postgres/postgres.dart';

class SqlConector {
  static Connection? connection;
  static bool loading = true;
  static Future<void> initialize() async {
    connection = await Connection.open(
        Endpoint(
          host: 'localhost',
          database: 'uresax-invoice',
          username: 'root',
          password: '827ccb0eea8a706c4c34a16891f84e7b',
        ),
        settings: ConnectionSettings(sslMode: SslMode.disable));
    loading = false;
  }
}
