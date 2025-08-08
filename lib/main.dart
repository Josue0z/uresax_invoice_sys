import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:localstorage/localstorage.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';
import 'package:uresax_invoice_sys/models/bank.dart';
import 'package:uresax_invoice_sys/models/company.dart';
import 'package:uresax_invoice_sys/models/currency.dart';
import 'package:uresax_invoice_sys/models/ncftype.dart';
import 'package:uresax_invoice_sys/models/override.codes.dart';
import 'package:uresax_invoice_sys/models/payment.method.dart';
import 'package:uresax_invoice_sys/models/payment.type.dart';
import 'package:uresax_invoice_sys/models/permission.dart';
import 'package:uresax_invoice_sys/models/provider.dart';
import 'package:uresax_invoice_sys/models/role.dart';
import 'package:uresax_invoice_sys/models/taxes.dart';
import 'package:uresax_invoice_sys/models/type.income.dart';
import 'package:uresax_invoice_sys/models/warehouse.dart';
import 'package:uresax_invoice_sys/pages/login_page.dart';
import 'package:uresax_invoice_sys/settings.dart';
import 'package:uresax_invoice_sys/utils/functions.dart';
import 'package:uresax_invoice_sys/widgets/startup-loader.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    var hostname = Platform.environment['URESAX_INVOICE_DATABASE_HOSTNAME'];
    var databaseName = Platform.environment['URESAX_INVOICE_DATABASE_NAME'];
    var dbUsername = Platform.environment['URESAX_INVOICE_DATABASE_USERNAME'];
    var dbPassword = Platform.environment['URESAX_INVOICE_DATABASE_PASSWORD'];

    eCommerceMode = bool.tryParse(
            Platform.environment['URESAX_INVOICE_ECOMMERCE_MODE'] ?? 'false') ??
        false;

    await initLocalStorage();

    await windowManager.ensureInitialized();

    Size sizeWindow = Size(1024, 700);

    WindowOptions windowOptions = WindowOptions(
      size: sizeWindow,
      minimumSize: sizeWindow,
      center: true,
      backgroundColor: Colors.transparent,
    );

    if (hostname == null ||
        databaseName == null ||
        dbUsername == null ||
        dbPassword == null) {
      throw 'NO ESTA CONFIGURADO LOS DATOS DEL SERVIDOR';
    }

    await SqlConector.initialize();

    runApp(MyApp());

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setMinimizable(true);
      await windowManager.setMaximizable(true);
    });
  } catch (e) {
    await FlutterPlatformAlert.playAlertSound();

    await FlutterPlatformAlert.showAlert(
      windowTitle: 'ALERTA',
      text: e.toString(),
      alertStyle: AlertButtonStyle.yesNoCancel,
      iconStyle: IconStyle.information,
    );

    await windowManager.close();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = true;
  _initAsync() async {
    company = await Company.get();
    ncfs = [NcfType(name: 'TIPO DE COMPROBANTE'), ...await NcfType.get()];
    paymentsMethods = [
      PaymentMethod(name: 'METODO DE PAGO'),
      ...await PaymentMethod.get()
    ];
    typesIncomes = [
      TypeIncome(name: 'TIPO DE INGRESO'),
      ...await TypeIncome.get()
    ];

    banks = [Bank(name: 'BANCO'), ...await Bank.get()];

    roles = [Role(name: 'ROL'), ...await Role.get()];

    permissions = await Permission.get();

    taxes = [Taxes(name: 'EXENTO'), ...await Taxes.get()];
    currencies = [Currency(name: 'MONEDA'), ...await Currency.get()];
    paymentsTypes = [
      PaymentType(name: 'TIPO DE PAGO'),
      ...await PaymentType.get()
    ];

    overrideCodes = [
      OverrideCode(name: 'TIPO DE PAGO'),
      ...await OverrideCode.get()
    ];

    wareHouses = [
      WareHouses(name: 'ELEGIR ALMACEN'),
      ...await WareHouses.get()
    ];

    await isValidCertFilePath();

    await Future.delayed(const Duration(seconds: 1));
    loading = false;
    setState(() {});
  }

  @override
  void initState() {
    _initAsync();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
        menus: [PlatformMenuItem(label: 'URESAX INVOICE SYS')],
        child: MaterialApp(
          title: 'URESAX INVOICE SYS',
          locale: Locale('es', 'ES'),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('es', 'ES'),
          ],
          debugShowCheckedModeBanner: false,
          scrollBehavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse}),
          theme: ThemeData(
              primaryColor: Colors.blue,
              primarySwatch: Colors.blue,
              useMaterial3: false,
              scrollbarTheme: ScrollbarThemeData(
                  trackVisibility: WidgetStatePropertyAll(false),
                  thumbVisibility: WidgetStatePropertyAll(false)),
              appBarTheme: AppBarTheme(
                centerTitle: false,
                toolbarHeight: kToolbarHeight * 2.4,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ButtonStyle(
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20))))),
              textTheme: TextTheme(
                  displayLarge: TextStyle(fontSize: 24),
                  displayMedium: TextStyle(fontSize: 20),
                  bodyLarge: TextStyle(fontSize: 20),
                  bodyMedium: TextStyle(fontSize: 18),
                  bodySmall: TextStyle(fontSize: 15)),
              inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)))),
          home: loading ? StartupLoader() : LoginPage(),
        ));
  }
}
