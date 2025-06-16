import 'package:uresax_invoice_sys/models/bank.dart';
import 'package:uresax_invoice_sys/models/company.dart';
import 'package:uresax_invoice_sys/models/currency.dart';
import 'package:uresax_invoice_sys/models/ncftype.dart';
import 'package:uresax_invoice_sys/models/payment.method.dart';
import 'package:uresax_invoice_sys/models/permission.dart';
import 'package:uresax_invoice_sys/models/role.dart';
import 'package:uresax_invoice_sys/models/taxes.dart';
import 'package:uresax_invoice_sys/models/type.income.dart';
import 'package:uresax_invoice_sys/models/user.dart';

Company? company;

List<NcfType> ncfs = [];

List<PaymentMethod> paymentsMethods = [];

List<TypeIncome> typesIncomes = [];

List<Role> roles = [];

List<Bank> banks = [];

List<Permission> permissions = [];

List<Taxes> taxes = [];

List<Currency> currencies = [];

const double kDefaultPadding = 20;

enum SaleMode { service, product }

enum SaleStatus { all, paid, notPaid }

User? currentUser;

bool electronicNcfEnabled = false;
