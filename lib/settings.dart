import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uresax_invoice_sys/models/bank.dart';
import 'package:uresax_invoice_sys/models/company.dart';
import 'package:uresax_invoice_sys/models/currency.dart';
import 'package:uresax_invoice_sys/models/discount.dart';
import 'package:uresax_invoice_sys/models/ncftype.dart';
import 'package:uresax_invoice_sys/models/override.codes.dart';
import 'package:uresax_invoice_sys/models/payment.method.dart';
import 'package:uresax_invoice_sys/models/payment.type.dart';
import 'package:uresax_invoice_sys/models/permission.dart';
import 'package:uresax_invoice_sys/models/provider.dart';
import 'package:uresax_invoice_sys/models/retention.isr.dart';
import 'package:uresax_invoice_sys/models/retention.tax.dart';
import 'package:uresax_invoice_sys/models/role.dart';
import 'package:uresax_invoice_sys/models/sale.element.abs.dart';
import 'package:uresax_invoice_sys/models/taxes.dart';
import 'package:uresax_invoice_sys/models/type.income.dart';
import 'package:uresax_invoice_sys/models/user.dart';
import 'package:uresax_invoice_sys/models/warehouse.dart';

Company? company;

List<NcfType> ncfs = [];

List<PaymentMethod> paymentsMethods = [];

List<TypeIncome> typesIncomes = [];

List<Role> roles = [];

List<Bank> banks = [];

List<Permission> permissions = [];

List<Taxes> taxes = [];

List<Currency> currencies = [];

List<PaymentType> paymentsTypes = [];

List<OverrideCode> overrideCodes = [];

List<Providers> providers = [];

List<WareHouses> wareHouses = [];

List<Discount> discounts = [];

const double kDefaultPadding = 20;

enum SaleMode { service, product }

enum SaleStatus { all, paid, notPaid }

User? currentUser;

bool electronicNcfEnabled = false;

int? currentElectronicNcfOption = 2;

File? certFile;

bool isValid = false;

TextEditingController certPath = TextEditingController();

TextEditingController certPassword = TextEditingController();

bool eCommerceMode = false;

List<SaleElement> elements = [];

List<RetentionTax> retentionsTaxes = [];

List<RetentionIsr> retentionsIsrs = [];
