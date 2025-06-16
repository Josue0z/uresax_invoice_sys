import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';
import 'package:uresax_invoice_sys/models/credit.note.item.product.dart';
import 'package:uresax_invoice_sys/models/credit.note.service.dart';

import 'package:uresax_invoice_sys/models/sale.abs.dart';
import 'package:uresax_invoice_sys/models/sale.item.abs.dart';
import 'package:uuid/uuid.dart';

class CreditNoteAsProduct implements Sale {
  @override
  double? amountPaid;

  @override
  double? checkOrTransf;

  @override
  String? clientId;

  @override
  String? clientName;

  @override
  int? clientType;

  @override
  String? clientTypeName;

  @override
  DateTime? createdAt;

  @override
  double? creditCard;

  @override
  double? debt;

  @override
  String? description;

  @override
  double? discount;

  @override
  double? effective;

  @override
  String? id;

  @override
  int? invoiceTypeId;

  @override
  List<SaleItem> items;

  @override
  double? law10;

  @override
  String? ncf;

  @override
  String? ncfAffected;

  @override
  String? ncfTypeId;

  @override
  String? ncfTypeName;

  @override
  double? net;

  @override
  double? paid;

  @override
  int? paymentMethodId;

  @override
  String? paymentMethodName;

  @override
  String? prefix;

  @override
  DateTime? retentionDate;

  @override
  double? retentionIsr;

  @override
  double? retentionTax;

  @override
  String? saleId;

  @override
  double? saleToCredit;

  @override
  double? tax;

  @override
  double? total;

  @override
  String? typeIncomeId;

  @override
  String? typeIncomeName;
  CreditNoteAsProduct(
      {this.amountPaid,
      this.checkOrTransf,
      this.clientId,
      this.clientName,
      this.clientType,
      this.clientTypeName,
      this.createdAt,
      this.creditCard,
      this.debt,
      this.description,
      this.discount,
      this.effective,
      this.id,
      this.invoiceTypeId,
      this.items = const [],
      this.law10,
      this.ncf,
      this.ncfAffected,
      this.ncfTypeId,
      this.ncfTypeName,
      this.net,
      this.paid,
      this.paymentMethodId,
      this.paymentMethodName,
      this.prefix,
      this.retentionDate,
      this.retentionIsr,
      this.retentionTax,
      this.saleId,
      this.saleToCredit,
      this.tax,
      this.total,
      this.typeIncomeId,
      this.typeIncomeName,
      this.currencyId,
      this.rate,
      this.maxSequence});

  @override
  // TODO: implement color
  Color get color => throw UnimplementedError();

  @override
  Future<CreditNoteAsProduct?> create() async {
    try {
      var map = toMapInsert();
      var id = Uuid().v4();
      map['id'] = id;
      var seqParams = '';
      final conne = SqlConector.connection;

      await calcDifOfNetsNcfs(ncf ?? '');

      if (ncfTypeId == '04') {
        seqParams = '''nextval('04_seq')''';
      }

      if (ncfTypeId == '34') {
        seqParams = '''nextval('34_seq')''';
      }

      if (items.isEmpty) {
        throw 'No existe elementos agregados';
      }

      var clientID = Uuid().v4();

      await conne?.runTx((conne) async {
        await conne.execute(
            Sql.named('''INSERT INTO public."Clients"(id,identification,name) 
      VALUES (@clientId,@identification,@name) 
       ON CONFLICT (identification) DO NOTHING;
      '''),
            parameters: {
              'clientId': clientID,
              'identification': clientId,
              'name': clientName
            });

        await conne.execute(Sql.named('''
         INSERT INTO public."CreditNote"(
	       id,
         "saleId", 
         "clientId", 
         ncf, 
         discount, 
         net, 
         tax, 
         total, 
         effective, 
         "creditCard", 
         "checkOrTransf", 
         "saleToCredit", 
         law10, 
         "typeIncomeId", 
         "clientType", 
         "retentionTax", 
         "retentionIsr", 
         "ncfTypeId", 
         description, 
         prefix,
         "invoiceTypeId",
         "currencyId", 
         rate, 
         "maxSequence")
	       VALUES (
         @id, 
         @saleId, 
         @clientId, 
         $seqParams, 
         @discount, 
         @net, 
         @tax, 
         @total, 
         @effective, 
         @creditCard, 
         @checkOrTransf, 
         @saleToCredit, 
         @law10, 
         @typeIncomeId, 
         @clientType, 
         @retentionTax, 
         @retentionIsr, 
         @ncfTypeId, 
         @description, 
         @prefix, 
         @invoiceTypeId, 
         @currencyId, 
         @rate, 
         @maxSequence);

      '''), parameters: map);

        for (int i = 0; i < items.length; i++) {
          var item = items[i];
          if (item.enabled == true) {
            var subMap = item.toMap();
            var xid = Uuid().v4();
            subMap['id'] = xid;
            subMap['creditNoteId'] = id;
            await conne.execute(
                Sql.named('''INSERT INTO public."CreditNoteProduct"(
	       id,"creditNoteId", "productId", discount, net, tax, total, "retentionTax", "retentionIsr", quantity, "taxId", "discountId", "retentionTaxId", "retentionIsrId")
	       VALUES (@id, @creditNoteId, @productId, @discount, @net, @tax, @total, @retentionTax, @retentionIsr, @quantity, @taxId, @discountId, @retentionTaxId, @retentionIsrId); '''),
                parameters: subMap);

            await conne.execute(
                Sql.named(
                    ''' update public."Products" set quantity = quantity + @quantity where id = @id'''),
                parameters: {
                  'id': item.productId,
                  'quantity': item.returnQuantity
                });
          }
        }

        if (paid != null && paid! > 0) {
          await conne.execute(
              Sql.named(
                  'insert into public."Returns"(id,"creditNoteId","paymentMethodId", amount) values(@id,@creditNoteId,@paymentMethodId,@amount)'),
              parameters: {
                'id': Uuid().v4(),
                'creditNoteId': id,
                'paymentMethodId': paymentMethodId,
                'amount': paid
              });
        }
      });

      var invoicesRows = await conne?.execute(
          Sql.named(
              '''select * from public."CreditNotesView" where id = @id '''),
          parameters: {'id': id});

      var rows = await conne?.execute(
          Sql.named(
              ''' select  * from public."CreditNotesProductsView" WHERE "creditNoteId" = @id '''),
          parameters: {'id': id});

      if (invoicesRows != null && invoicesRows.isNotEmpty) {
        var firstRow = invoicesRows.first;
        var sale = CreditNoteAsProduct.fromMap(firstRow.toColumnMap());

        var xitems = rows
                ?.map((e) => CreditNoteProduct.fromMap(e.toColumnMap()))
                .toList() ??
            [];

        sale.items = xitems;

        return sale;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Sale?> delete() {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  // TODO: implement isPaid
  bool get isPaid => throw UnimplementedError();

  @override
  // TODO: implement paidLabel
  String get paidLabel => throw UnimplementedError();

  @override
  Future<Sale?> paySale(double amount) {
    // TODO: implement paySale
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> to607() {
    // TODO: implement to607
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toDisplay() {
    // TODO: implement toDisplay
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'amountPaid': amountPaid,
      'checkOrTransf': checkOrTransf,
      'clientId': clientId,
      'clientName': clientName,
      'clientType': clientType,
      'clientTypeName': clientTypeName,
      'createdAt': createdAt,
      'creditCard': creditCard,
      'debt': debt,
      'description': description,
      'discount': discount,
      'effective': effective,
      'id': id,
      'invoiceTypeId': invoiceTypeId,
      'items': items?.map((x) => x)?.toList(),
      'law10': law10,
      'ncf': ncf,
      'ncfAffected': ncfAffected,
      'ncfTypeId': ncfTypeId,
      'ncfTypeName': ncfTypeName,
      'net': net,
      'paid': paid,
      'paymentMethodId': paymentMethodId,
      'paymentMethodName': paymentMethodName,
      'prefix': prefix,
      'retentionDate': retentionDate,
      'retentionIsr': retentionIsr,
      'retentionTax': retentionTax,
      'saleId': saleId,
      'saleToCredit': saleToCredit,
      'tax': tax,
      'total': total,
      'typeIncomeId': typeIncomeId,
      'typeIncomeName': typeIncomeName,
      'currencyId': currencyId,
      'rate': rate,
      'maxSequence': maxSequence
    };
  }

  @override
  Map<String, dynamic> toMapInsert() {
    return {
      'id': id,
      'clientId': clientId,
      'discount': discount,
      'net': net,
      'tax': tax,
      'total': total,
      'effective': effective,
      'creditCard': creditCard,
      'checkOrTransf': checkOrTransf,
      'saleToCredit': saleToCredit,
      'law10': law10,
      'typeIncomeId': typeIncomeId,
      'clientType': clientType,
      'retentionTax': retentionTax,
      'retentionIsr': retentionIsr,
      'ncfTypeId': ncfTypeId,
      'description': description,
      'prefix': prefix,
      'invoiceTypeId': invoiceTypeId,
      'saleId': saleId,
      'currencyId': currencyId,
      'rate': rate,
      'maxSequence': maxSequence
    };
  }

  @override
  Future<Sale?> update() {
    // TODO: implement update
    throw UnimplementedError();
  }

  CreditNoteAsProduct copyWith({
    double? amountPaid,
    double? checkOrTransf,
    String? clientId,
    String? clientName,
    int? clientType,
    String? clientTypeName,
    DateTime? createdAt,
    double? creditCard,
    double? debt,
    String? description,
    double? discount,
    double? effective,
    String? id,
    int? invoiceTypeId,
    List<SaleItem> items = const [],
    double? law10,
    String? ncf,
    String? ncfAffected,
    String? ncfTypeId,
    String? ncfTypeName,
    double? net,
    double? paid,
    int? paymentMethodId,
    String? paymentMethodName,
    String? prefix,
    DateTime? retentionDate,
    double? retentionIsr,
    double? retentionTax,
    String? saleId,
    double? saleToCredit,
    double? tax,
    double? total,
    String? typeIncomeId,
    String? typeIncomeName,
  }) {
    return CreditNoteAsProduct(
      amountPaid: amountPaid ?? this.amountPaid,
      checkOrTransf: checkOrTransf ?? this.checkOrTransf,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientType: clientType ?? this.clientType,
      clientTypeName: clientTypeName ?? this.clientTypeName,
      createdAt: createdAt ?? this.createdAt,
      creditCard: creditCard ?? this.creditCard,
      debt: debt ?? this.debt,
      description: description ?? this.description,
      discount: discount ?? this.discount,
      effective: effective ?? this.effective,
      id: id ?? this.id,
      invoiceTypeId: invoiceTypeId ?? this.invoiceTypeId,
      items: items ?? this.items,
      law10: law10 ?? this.law10,
      ncf: ncf ?? this.ncf,
      ncfAffected: ncfAffected ?? this.ncfAffected,
      ncfTypeId: ncfTypeId ?? this.ncfTypeId,
      ncfTypeName: ncfTypeName ?? this.ncfTypeName,
      net: net ?? this.net,
      paid: paid ?? this.paid,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      prefix: prefix ?? this.prefix,
      retentionDate: retentionDate ?? this.retentionDate,
      retentionIsr: retentionIsr ?? this.retentionIsr,
      retentionTax: retentionTax ?? this.retentionTax,
      saleId: saleId ?? this.saleId,
      saleToCredit: saleToCredit ?? this.saleToCredit,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      typeIncomeId: typeIncomeId ?? this.typeIncomeId,
      typeIncomeName: typeIncomeName ?? this.typeIncomeName,
    );
  }

  factory CreditNoteAsProduct.fromMap(Map<String, dynamic> map) {
    return CreditNoteAsProduct(
      amountPaid: double.tryParse(map['amountPaid']?.toString() ?? '0') ?? 0,
      checkOrTransf:
          double.tryParse(map['checkOrTransf']?.toString() ?? '0') ?? 0,
      clientId: map['clientId']?.toString(),
      clientName: map['clientName']?.toString(),
      clientType: int.tryParse(map['clientType']?.toString() ?? '0') ?? 0,
      clientTypeName: map['clientTypeName']?.toString(),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? ''),
      creditCard: double.tryParse(map['creditCard']?.toString() ?? '0') ?? 0,
      debt: double.tryParse(map['debt']?.toString() ?? '0') ?? 0,
      description: map['description']?.toString(),
      discount: double.tryParse(map['discount']?.toString() ?? '0') ?? 0,
      effective: double.tryParse(map['effective']?.toString() ?? '0') ?? 0,
      id: map['id']?.toString(),
      invoiceTypeId: int.tryParse(map['invoiceTypeId']?.toString() ?? '0') ?? 0,
      items: [],
      law10: double.tryParse(map['law10']?.toString() ?? '0') ?? 0,
      ncf: map['ncf']?.toString(),
      ncfAffected: map['ncfAffected']?.toString(),
      ncfTypeId: map['ncfTypeId']?.toString(),
      ncfTypeName: map['ncfTypeName']?.toString(),
      net: double.tryParse(map['net']?.toString() ?? '0') ?? 0,
      paid: double.tryParse(map['paid']?.toString() ?? '0') ?? 0,
      paymentMethodId:
          int.tryParse(map['paymentMethodId']?.toString() ?? '0') ?? 0,
      paymentMethodName: map['paymentMethodName']?.toString(),
      prefix: map['prefix']?.toString(),
      retentionDate: DateTime.tryParse(map['retentionDate']?.toString() ?? ''),
      retentionIsr:
          double.tryParse(map['retentionIsr']?.toString() ?? '0') ?? 0,
      retentionTax:
          double.tryParse(map['retentionTax']?.toString() ?? '0') ?? 0,
      saleId: map['saleId']?.toString(),
      saleToCredit:
          double.tryParse(map['saleToCredit']?.toString() ?? '0') ?? 0,
      tax: double.tryParse(map['tax']?.toString() ?? '0') ?? 0,
      total: double.tryParse(map['total']?.toString() ?? '0') ?? 0,
      typeIncomeId: map['typeIncomeId']?.toString(),
      typeIncomeName: map['typeIncomeName']?.toString(),
      currencyId: map['currencyId'],
      rate: map['rate'] != null ? double.parse(map['rate']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CreditNoteAsProduct.fromJson(String source) =>
      CreditNoteAsProduct.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CreditNoteAsProduct(amountPaid: $amountPaid, checkOrTransf: $checkOrTransf, clientId: $clientId, clientName: $clientName, clientType: $clientType, clientTypeName: $clientTypeName, createdAt: $createdAt, creditCard: $creditCard, debt: $debt, description: $description, discount: $discount, effective: $effective, id: $id, invoiceTypeId: $invoiceTypeId, items: $items, law10: $law10, ncf: $ncf, ncfAffected: $ncfAffected, ncfTypeId: $ncfTypeId, ncfTypeName: $ncfTypeName, net: $net, paid: $paid, paymentMethodId: $paymentMethodId, paymentMethodName: $paymentMethodName, prefix: $prefix, retentionDate: $retentionDate, retentionIsr: $retentionIsr, retentionTax: $retentionTax, saleId: $saleId, saleToCredit: $saleToCredit, tax: $tax, total: $total, typeIncomeId: $typeIncomeId, typeIncomeName: $typeIncomeName)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is CreditNoteAsProduct &&
        o.amountPaid == amountPaid &&
        o.checkOrTransf == checkOrTransf &&
        o.clientId == clientId &&
        o.clientName == clientName &&
        o.clientType == clientType &&
        o.clientTypeName == clientTypeName &&
        o.createdAt == createdAt &&
        o.creditCard == creditCard &&
        o.debt == debt &&
        o.description == description &&
        o.discount == discount &&
        o.effective == effective &&
        o.id == id &&
        o.invoiceTypeId == invoiceTypeId &&
        listEquals(o.items, items) &&
        o.law10 == law10 &&
        o.ncf == ncf &&
        o.ncfAffected == ncfAffected &&
        o.ncfTypeId == ncfTypeId &&
        o.ncfTypeName == ncfTypeName &&
        o.net == net &&
        o.paid == paid &&
        o.paymentMethodId == paymentMethodId &&
        o.paymentMethodName == paymentMethodName &&
        o.prefix == prefix &&
        o.retentionDate == retentionDate &&
        o.retentionIsr == retentionIsr &&
        o.retentionTax == retentionTax &&
        o.saleId == saleId &&
        o.saleToCredit == saleToCredit &&
        o.tax == tax &&
        o.total == total &&
        o.typeIncomeId == typeIncomeId &&
        o.typeIncomeName == typeIncomeName;
  }

  @override
  int get hashCode {
    return amountPaid.hashCode ^
        checkOrTransf.hashCode ^
        clientId.hashCode ^
        clientName.hashCode ^
        clientType.hashCode ^
        clientTypeName.hashCode ^
        createdAt.hashCode ^
        creditCard.hashCode ^
        debt.hashCode ^
        description.hashCode ^
        discount.hashCode ^
        effective.hashCode ^
        id.hashCode ^
        invoiceTypeId.hashCode ^
        items.hashCode ^
        law10.hashCode ^
        ncf.hashCode ^
        ncfAffected.hashCode ^
        ncfTypeId.hashCode ^
        ncfTypeName.hashCode ^
        net.hashCode ^
        paid.hashCode ^
        paymentMethodId.hashCode ^
        paymentMethodName.hashCode ^
        prefix.hashCode ^
        retentionDate.hashCode ^
        retentionIsr.hashCode ^
        retentionTax.hashCode ^
        saleId.hashCode ^
        saleToCredit.hashCode ^
        tax.hashCode ^
        total.hashCode ^
        typeIncomeId.hashCode ^
        typeIncomeName.hashCode;
  }

  @override
  Future<List<CreditNoteProduct>> getSaleData() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute(
          Sql.named(
              'select * from public."CreditNotesProductsView" where "creditNoteId" = @id'),
          parameters: {'id': id});
      return result
              ?.map((e) => CreditNoteProduct.fromMap(e.toColumnMap()))
              .toList()
              .cast<CreditNoteProduct>() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  int? bankId;

  @override
  String? transfRef;

  @override
  int? currencyId;

  @override
  double? rate;

  @override
  int? maxSequence;
}
