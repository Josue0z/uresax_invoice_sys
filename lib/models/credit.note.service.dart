import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';
import 'package:uresax_invoice_sys/models/credit.note.item.service.dart';

import 'package:uresax_invoice_sys/models/sale.abs.dart';
import 'package:uresax_invoice_sys/models/sale.item.abs.dart';
import 'package:uuid/uuid.dart';

class CreditNoteAsService implements Sale {
  @override
  double? checkOrTransf;

  @override
  String? clientId;

  @override
  String? clientName;

  @override
  int? clientType;

  @override
  DateTime? createdAt;

  @override
  double? creditCard;

  @override
  String? description;

  @override
  double? discount;

  @override
  double? effective;

  @override
  String? id;

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
  double? net;

  @override
  int? paymentMethodId;

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
  CreditNoteAsService(
      {this.checkOrTransf,
      this.clientId,
      this.clientName,
      this.clientType,
      this.createdAt,
      this.creditCard,
      this.description,
      this.discount,
      this.effective,
      this.id,
      this.items = const [],
      this.law10,
      this.ncf,
      this.ncfAffected,
      this.ncfTypeId,
      this.net,
      this.paymentMethodId,
      this.prefix,
      this.retentionDate,
      this.retentionIsr,
      this.retentionTax,
      this.saleId,
      this.saleToCredit,
      this.tax,
      this.total,
      this.typeIncomeId,
      this.ncfTypeName,
      this.paymentMethodName,
      this.clientTypeName,
      this.typeIncomeName,
      this.invoiceTypeId,
      this.paid,
      this.amountPaid,
      this.currencyId,
      this.rate,
      this.maxSequence});

  @override
  Future<CreditNoteAsService?> create() async {
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
	       id,"saleId", "clientId", ncf, discount, net, tax, total, effective, "creditCard", "checkOrTransf", "saleToCredit", law10, "typeIncomeId", "clientType", "retentionTax", "retentionIsr", "ncfTypeId", description, prefix,"invoiceTypeId","currencyId", rate, "maxSequence")
	       VALUES (@id, @saleId, @clientId, $seqParams, @discount, @net, @tax, @total, @effective, @creditCard, @checkOrTransf, @saleToCredit, @law10, @typeIncomeId, @clientType, @retentionTax, @retentionIsr, @ncfTypeId, @description, @prefix,@invoiceTypeId, @currencyId, @rate, @maxSequence);

      '''), parameters: map);

        for (int i = 0; i < items.length; i++) {
          var item = items[i];
          if (item.enabled == true) {
            var subMap = item.toMap();
            var xid = Uuid().v4();
            subMap['id'] = xid;
            subMap['creditNoteId'] = id;
            await conne.execute(
                Sql.named('''INSERT INTO public."CreditNoteService"(
	       id,"creditNoteId", "serviceId", discount, net, tax, total, "retentionTax", "retentionIsr", quantity, "taxId", "discountId", "retentionTaxId", "retentionIsrId")
	       VALUES (@id, @creditNoteId, @serviceId, @discount, @net, @tax, @total, @retentionTax, @retentionIsr, @quantity, @taxId, @discountId, @retentionTaxId, @retentionIsrId); '''),
                parameters: subMap);
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
              ''' select  * from public."CreditNotesServicesView" WHERE "creditNoteId" = @id '''),
          parameters: {'id': id});

      if (invoicesRows != null && invoicesRows.isNotEmpty) {
        var firstRow = invoicesRows.first;
        var sale = CreditNoteAsService.fromMap(firstRow.toColumnMap());

        var xitems = rows
                ?.map((e) => CreditNoteService.fromMap(e.toColumnMap()))
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
  Future<Sale?> findById(String id) {
    // TODO: implement findById
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'checkOrTransf': checkOrTransf,
      'clientId': clientId,
      'clientName': clientName,
      'clientType': clientType,
      'createdAt': createdAt,
      'creditCard': creditCard,
      'description': description,
      'discount': discount,
      'effective': effective,
      'id': id,
      'items': items.map((x) => x).toList(),
      'law10': law10,
      'ncf': ncf,
      'ncfAffected': ncfAffected,
      'ncfTypeId': ncfTypeId,
      'net': net,
      'paymentMethodId': paymentMethodId,
      'prefix': prefix,
      'retentionDate': retentionDate,
      'retentionIsr': retentionIsr,
      'retentionTax': retentionTax,
      'saleId': saleId,
      'saleToCredit': saleToCredit,
      'tax': tax,
      'total': total,
      'typeIncomeId': typeIncomeId,
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

  CreditNoteAsService copyWith({
    double? checkOrTransf,
    String? clientId,
    String? clientName,
    int? clientType,
    DateTime? createdAt,
    double? creditCard,
    String? description,
    double? discount,
    double? effective,
    String? id,
    List<SaleItem>? items,
    double? law10,
    String? ncf,
    String? ncfAffected,
    String? ncfTypeId,
    double? net,
    int? paymentMethodId,
    String? prefix,
    DateTime? retentionDate,
    double? retentionIsr,
    double? retentionTax,
    String? saleId,
    double? saleToCredit,
    double? tax,
    double? total,
    String? typeIncomeId,
  }) {
    return CreditNoteAsService(
      checkOrTransf: checkOrTransf ?? this.checkOrTransf,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientType: clientType ?? this.clientType,
      createdAt: createdAt ?? this.createdAt,
      creditCard: creditCard ?? this.creditCard,
      description: description ?? this.description,
      discount: discount ?? this.discount,
      effective: effective ?? this.effective,
      id: id ?? this.id,
      items: items ?? this.items,
      law10: law10 ?? this.law10,
      ncf: ncf ?? this.ncf,
      ncfAffected: ncfAffected ?? this.ncfAffected,
      ncfTypeId: ncfTypeId ?? this.ncfTypeId,
      net: net ?? this.net,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      prefix: prefix ?? this.prefix,
      retentionDate: retentionDate ?? this.retentionDate,
      retentionIsr: retentionIsr ?? this.retentionIsr,
      retentionTax: retentionTax ?? this.retentionTax,
      saleId: saleId ?? this.saleId,
      saleToCredit: saleToCredit ?? this.saleToCredit,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      typeIncomeId: typeIncomeId ?? this.typeIncomeId,
    );
  }

  factory CreditNoteAsService.fromMap(Map<String, dynamic> map) {
    return CreditNoteAsService(
        id: map['id'],
        clientId: map['clientId'],
        clientName: map['clientName'],
        clientType: map['clientType'],
        creditCard: double.parse(map['creditCard']),
        description: map['description'],
        discount: double.parse(map['discount']),
        effective: double.parse(map['effective']),
        checkOrTransf: double.parse(map['checkOrTransf']),
        items: [],
        law10: double.parse(map['law10']),
        ncf: map['ncf'],
        ncfAffected: map['ncfAffected'],
        ncfTypeId: map['ncfTypeId'],
        net: double.parse(map['net']),
        paymentMethodId: map['paymentMethodId'],
        prefix: map['prefix'],
        retentionDate: map['retentionDate'],
        retentionIsr: double.parse(map['retentionIsr']),
        retentionTax: double.parse(map['retentionTax']),
        saleId: map['saleId'],
        saleToCredit: double.parse(map['saleToCredit']),
        tax: double.parse(map['tax']),
        total: double.parse(map['total']),
        typeIncomeId: map['typeIncomeId'],
        typeIncomeName: map['typeIncomeName'],
        paymentMethodName: map['paymentMethodName'],
        clientTypeName: map['clientTypeName'],
        ncfTypeName: map['ncfTypeName'],
        amountPaid:
            map['amountPaid'] != null ? double.parse(map['amountPaid']) : null,
        createdAt: map['createdAt'],
        invoiceTypeId: map['invoiceTypeId'],
        currencyId: map['currencyId'],
        rate: map['rate'] != null ? double.parse(map['rate']) : null);
  }

  String toJson() => json.encode(toMap());

  factory CreditNoteAsService.fromJson(String source) =>
      CreditNoteAsService.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CreditNote(checkOrTransf: $checkOrTransf, clientId: $clientId, clientName: $clientName, clientType: $clientType, createdAt: $createdAt, creditCard: $creditCard, description: $description, discount: $discount, effective: $effective, id: $id, items: $items, law10: $law10, ncf: $ncf, ncfAffected: $ncfAffected, ncfTypeId: $ncfTypeId, net: $net, paymentMethodId: $paymentMethodId, prefix: $prefix, retentionDate: $retentionDate, retentionIsr: $retentionIsr, retentionTax: $retentionTax, saleId: $saleId, saleToCredit: $saleToCredit, tax: $tax, total: $total, typeIncomeId: $typeIncomeId)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is CreditNoteAsService &&
        o.checkOrTransf == checkOrTransf &&
        o.clientId == clientId &&
        o.clientName == clientName &&
        o.clientType == clientType &&
        o.createdAt == createdAt &&
        o.creditCard == creditCard &&
        o.description == description &&
        o.discount == discount &&
        o.effective == effective &&
        o.id == id &&
        listEquals(o.items, items) &&
        o.law10 == law10 &&
        o.ncf == ncf &&
        o.ncfAffected == ncfAffected &&
        o.ncfTypeId == ncfTypeId &&
        o.net == net &&
        o.paymentMethodId == paymentMethodId &&
        o.prefix == prefix &&
        o.retentionDate == retentionDate &&
        o.retentionIsr == retentionIsr &&
        o.retentionTax == retentionTax &&
        o.saleId == saleId &&
        o.saleToCredit == saleToCredit &&
        o.tax == tax &&
        o.total == total &&
        o.typeIncomeId == typeIncomeId;
  }

  @override
  int get hashCode {
    return checkOrTransf.hashCode ^
        clientId.hashCode ^
        clientName.hashCode ^
        clientType.hashCode ^
        createdAt.hashCode ^
        creditCard.hashCode ^
        description.hashCode ^
        discount.hashCode ^
        effective.hashCode ^
        id.hashCode ^
        items.hashCode ^
        law10.hashCode ^
        ncf.hashCode ^
        ncfAffected.hashCode ^
        ncfTypeId.hashCode ^
        net.hashCode ^
        paymentMethodId.hashCode ^
        prefix.hashCode ^
        retentionDate.hashCode ^
        retentionIsr.hashCode ^
        retentionTax.hashCode ^
        saleId.hashCode ^
        saleToCredit.hashCode ^
        tax.hashCode ^
        total.hashCode ^
        typeIncomeId.hashCode;
  }

  @override
  String? clientTypeName;

  @override
  String? ncfTypeName;

  @override
  String? paymentMethodName;

  @override
  String? typeIncomeName;

  @override
  Map<String, dynamic> toDisplay() {
    // TODO: implement toDisplay
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> to607() {
    // TODO: implement to607
    throw UnimplementedError();
  }

  @override
  int? invoiceTypeId;

  @override
  String? chassis;

  @override
  String? licensePlate;

  @override
  double? paid;

  @override
  double? amountPaid;

  @override
  double? debt;

  @override
  bool get isPaid => throw UnimplementedError();

  @override
  // TODO: implement color
  Color get color => throw UnimplementedError();

  @override
  // TODO: implement paidLabel
  String get paidLabel => throw UnimplementedError();

  @override
  Future<Sale?> paySale(double amount) {
    // TODO: implement paySale
    throw UnimplementedError();
  }

  @override
  Future<List<CreditNoteService>> getSaleData() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute(
          Sql.named(
              'select * from public."CreditNotesServicesView" where "creditNoteId" = @id'),
          parameters: {'id': id});
      return result
              ?.map((e) => CreditNoteService.fromMap(e.toColumnMap()))
              .toList()
              .cast<CreditNoteService>() ??
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
