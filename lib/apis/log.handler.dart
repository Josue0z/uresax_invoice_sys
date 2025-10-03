import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';

class LogHandler {
  LogHandler._();

  static Future<void> printEvent(String message) async {
    var conne = SqlConector.connection;
    await conne?.execute(Sql.named('''
      INSERT INTO public."Logs"(message,"logTypeId")
      VALUES (@message,@logTypeId);
    '''), parameters: {'message': message, 'logTypeId': 1});
  }

  static Future<void> printError(String error) async {
    var conne = SqlConector.connection;
    await conne?.execute(Sql.named('''
      INSERT INTO public."Logs"(message,"logTypeId")
      VALUES (@message,@logTypeId);
    '''), parameters: {'message': error, 'logTypeId': 2});
  }
}
