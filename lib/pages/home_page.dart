import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:uresax_invoice_sys/modals/company.editor.modal.dart';
import 'package:uresax_invoice_sys/modals/electronic.ncf.settings.modal.dart';
import 'package:uresax_invoice_sys/models/credit.note.item.product.dart';
import 'package:uresax_invoice_sys/models/credit.note.item.service.dart';
import 'package:uresax_invoice_sys/models/credit.note.product.dart';
import 'package:uresax_invoice_sys/models/credit.note.service.dart';
import 'package:uresax_invoice_sys/models/sale.abs.dart';
import 'package:uresax_invoice_sys/models/sale.item.abs.dart';
import 'package:uresax_invoice_sys/models/sale.item.product.dart';
import 'package:uresax_invoice_sys/models/sale.item.service.dart';
import 'package:uresax_invoice_sys/models/sale.product.dart';
import 'package:uresax_invoice_sys/models/sale.service.dart';
import 'package:uresax_invoice_sys/pages/clients_page.dart';
import 'package:uresax_invoice_sys/pages/credit.notes_page.dart';
import 'package:uresax_invoice_sys/pages/invoice_generator_page.dart';
import 'package:uresax_invoice_sys/pages/login_page.dart';
import 'package:uresax_invoice_sys/pages/products_page.dart';
import 'package:uresax_invoice_sys/pages/sales.607.form_page.dart';
import 'package:uresax_invoice_sys/pages/sales_page.dart';
import 'package:uresax_invoice_sys/pages/services_page.dart';
import 'package:uresax_invoice_sys/pages/users_page.dart';
import 'package:uresax_invoice_sys/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> options = [
    {
      'id': 1,
      'title': 'GENERAR FACTURA DE SERVICIO',
      'svg': 'assets/svgs/undraw_files-uploading_qf8u.svg'
    },
    {
      'id': 2,
      'title': 'GENERAR FACTURA DE PRODUCTO',
      'svg': 'assets/svgs/undraw_product-iteration_r2wg.svg'
    },
    {
      'id': 8,
      'title': 'GENERAR NOTA DE CREDITO DE SERVICIO',
      'svg': 'assets/svgs/undraw_statistic-chart_6s7z.svg'
    },
    {
      'id': 9,
      'title': 'GENERAR NOTA DE CREDITO DE PRODUCTO',
      'svg': 'assets/svgs/undraw_printing-invoices_osgs.svg'
    },
    {
      'id': 3,
      'title': 'MANEJAR SERVICIOS',
      'svg': 'assets/svgs/undraw_services_dhxj.svg'
    },
    {
      'id': 4,
      'title': 'MANEJAR PRODUCTOS',
      'svg': 'assets/svgs/undraw_groceries_4via.svg'
    },
    {
      'id': 5,
      'title': 'TUS FACTURAS',
      'svg': 'assets/svgs/undraw_receipt_tzi0.svg'
    },
    {
      'id': 10,
      'title': 'TUS NOTAS DE CREDITO',
      'svg': 'assets/svgs/undraw_receipt_tzi0.svg'
    },
    {
      'id': 6,
      'title': 'TUS CLIENTES',
      'svg': 'assets/svgs/undraw_interview_yz52.svg'
    },
    {
      'id': 7,
      'title': 'GENERADOR DE FORMULARIO 607',
      'svg': 'assets/svgs/undraw_complete-form_aarh.svg'
    }
  ];

  _showInvoiceGenerator(SaleMode mode, List<SaleItem> items, Sale sale) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
      return InvoiceGeneratorPage(mode: mode, items: items, sale: sale);
    }));
  }

  _showServicesPage() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => ServicesPage()));
  }

  _showSales() async {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) => SalesPage()));
  }

  _show607FormPage() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => Sales607FormPage()));
  }

  _showProductsPage() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => ProductsPage()));
  }

  _showClientsPage() async {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) => ClientsPage()));
  }

  _showCreditNotes() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => CreditNotesPage()));
  }

  _showUsersPage() async {
    var res = await Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => UsersPage()));
    setState(() {});
  }

  _showCompanyDetailsPage() async {
    var res = await showDialog(
        context: context, builder: (ctx) => CompanyEditorModal());
    if (res == 'UPDATE') {
      setState(() {});
    }
  }

  _showElectronicNcfSettingsPage() async {
    await showDialog(
        context: context, builder: (ctx) => ElectronicNcfSettingsModal());
  }

  _showPage(int id) {
    switch (id) {
      case 1:
        _showInvoiceGenerator(
            SaleMode.service, [SaleItemService()], SaleService());
        break;

      case 2:
        _showInvoiceGenerator(
            SaleMode.product, [SaleItemProduct()], SaleProduct());
        break;
      case 3:
        _showServicesPage();
      case 5:
        _showSales();
        break;
      case 6:
        _showClientsPage();
        break;
      case 7:
        _show607FormPage();
        break;
      case 4:
        _showProductsPage();
        break;
      case 8:
        _showInvoiceGenerator(SaleMode.service, [], CreditNoteAsService());
        break;
      case 9:
        _showInvoiceGenerator(SaleMode.product, [], CreditNoteAsProduct());
        break;
      case 10:
        _showCreditNotes();
        break;
      default:
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(electronicNcfEnabled);
    if (!currentUser!.permissions!.contains('ALLOW_VIEW_CREATE_SALE_SERVICE')) {
      options.removeWhere((e) => e['id'] == 1);
    }
    if (!currentUser!.permissions!.contains('ALLOW_VIEW_CREATE_SALE_PRODUCT')) {
      options.removeWhere((e) => e['id'] == 2);
    }
    if (!currentUser!.permissions!
        .contains('ALLOW_VIEW_CREATE_CREDIT_NOTE_SERVICE')) {
      options.removeWhere((e) => e['id'] == 8);
    }

    if (!currentUser!.permissions!
        .contains('ALLOW_VIEW_CREATE_CREDIT_NOTE_PRODUCT')) {
      options.removeWhere((e) => e['id'] == 9);
    }

    if (!currentUser!.permissions!.contains('ALLOW_VIEW_SERVICES')) {
      options.removeWhere((e) => e['id'] == 3);
    }
    if (!currentUser!.permissions!.contains('ALLOW_VIEW_PRODUCTS')) {
      options.removeWhere((e) => e['id'] == 4);
    }

    if (!currentUser!.permissions!.contains('ALLOW_VIEW_SALES')) {
      options.removeWhere((e) => e['id'] == 5);
    }
    if (!currentUser!.permissions!.contains('ALLOW_VIEW_CREDIT_NOTES')) {
      options.removeWhere((e) => e['id'] == 10);
    }
    if (!currentUser!.permissions!.contains('ALLOW_VIEW_CLIENTS')) {
      options.removeWhere((e) => e['id'] == 6);
    }

    if (!currentUser!.permissions!.contains('ALLOW_VIEW_CREATE_FORM_607')) {
      options.removeWhere((e) => e['id'] == 7);
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TABLERO -  BIENVENIDO ${company?.name}!'),
            SizedBox(height: kDefaultPadding / 2),
            Container(
              padding: EdgeInsets.all(kDefaultPadding / 2),
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10)),
              child: Text(currentUser?.username ?? '',
                  textAlign: TextAlign.right,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white)),
            )
          ],
        ),
        actions: [
          Wrap(
            runAlignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              currentUser!.permissions!
                      .contains('ALLOW_VIEW_ELECTRONIC_SETTINGS')
                  ? CircleAvatar(
                      child: IconButton(
                          tooltip: 'CONFIGURACION DE FACTURACION ELECTRONICA',
                          onPressed: _showElectronicNcfSettingsPage,
                          icon: Icon(Icons.receipt_long)),
                    )
                  : SizedBox(),
              SizedBox(
                width: kDefaultPadding,
              ),
              currentUser!.permissions!.contains('ALLOW_EDIT_COMPANY')
                  ? CircleAvatar(
                      child: IconButton(
                          tooltip: 'EDITAR DATOS DE EMPRESA',
                          onPressed: _showCompanyDetailsPage,
                          icon: Icon(Icons.store_outlined)),
                    )
                  : SizedBox(),
              SizedBox(
                width: kDefaultPadding,
              ),
              currentUser!.permissions!.contains('ALLOW_VIEW_USERS')
                  ? CircleAvatar(
                      child: IconButton(
                          tooltip: 'VER USUARIOS',
                          onPressed: _showUsersPage,
                          icon: Icon(Icons.people_alt_outlined)),
                    )
                  : SizedBox(),
              SizedBox(
                width: kDefaultPadding,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(currentUser?.name ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(color: Colors.white),
                      textAlign: TextAlign.right),
                  SizedBox(height: kDefaultPadding / 2),
                  Container(
                    padding: EdgeInsets.all(kDefaultPadding / 2),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(currentUser?.roleName ?? '',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Theme.of(context).primaryColor)),
                  ),
                  SizedBox(height: kDefaultPadding / 2),
                ],
              ),
              SizedBox(
                width: kDefaultPadding,
              ),
              CircleAvatar(
                child: IconButton(
                    tooltip: 'CERRAR CUENTA',
                    onPressed: () {
                      currentUser = null;
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (ctx) => LoginPage()),
                          (_) => false);
                    },
                    icon: Icon(Icons.power_settings_new_outlined)),
              ),
              SizedBox(
                width: kDefaultPadding * 2,
              )
            ],
          )
        ],
      ),
      body: GridView.builder(
          itemCount: options.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
          itemBuilder: (ctx, i) {
            var option = options[i];
            return GestureDetector(
              onTap: () {
                _showPage(option['id']);
              },
              child: Card(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(style: BorderStyle.none)),
                child: Center(
                    child: Padding(
                        padding: EdgeInsets.all(kDefaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(option['svg'], width: 100),
                            SizedBox(height: kDefaultPadding),
                            Text(option['title'],
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center)
                          ],
                        ))),
              ),
            );
          }),
    );
  }
}
