import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';
import 'package:uresax_invoice_sys/models/sale.abs.dart';
import 'package:uresax_invoice_sys/models/sale.item.abs.dart';
import 'package:uresax_invoice_sys/models/sale.item.product.dart';
import 'package:uuid/uuid.dart';

class SaleProduct implements Sale {
  @override
  String? id;
  @override
  String? clientId;
  @override
  String? ncf;
  @override
  String? ncfAffected;
  @override
  double? discount;
  @override
  double? net;
  @override
  double? tax;
  @override
  double? total;
  @override
  double? effective;
  @override
  double? creditCard;
  @override
  double? checkOrTransf;
  @override
  double? saleToCredit;
  @override
  double? law10;
  @override
  String? typeIncomeId;
  @override
  int? clientType;
  @override
  DateTime? createdAt;
  @override
  double? retentionTax;
  @override
  double? retentionIsr;
  @override
  int? paymentMethodId;
  @override
  String? ncfTypeId;
  @override
  String? saleId;
  SaleProduct(
      {this.id,
      this.clientId,
      this.ncf,
      this.ncfAffected,
      this.discount,
      this.net,
      this.tax,
      this.total,
      this.effective,
      this.creditCard,
      this.checkOrTransf,
      this.saleToCredit,
      this.law10,
      this.typeIncomeId,
      this.clientType,
      this.createdAt,
      this.retentionTax,
      this.retentionIsr,
      this.paymentMethodId,
      this.ncfTypeId,
      this.saleId,
      this.items = const [],
      this.description,
      this.clientName,
      this.retentionDate,
      this.prefix,
      this.typeIncomeName,
      this.clientTypeName,
      this.ncfTypeName,
      this.paymentMethodName,
      this.invoiceTypeId,
      this.paid,
      this.amountPaid,
      this.debt,
      this.bankId,
      this.transfRef,
      this.currencyId,
      this.rate,
      this.maxSequence});

  SaleProduct copyWith({
    String? id,
    String? clientId,
    String? ncf,
    String? ncfAffected,
    double? discount,
    double? net,
    double? tax,
    double? total,
    double? effective,
    double? creditCard,
    double? checkOrTransf,
    double? saleToCredit,
    double? law10,
    String? typeIncomeId,
    int? clientType,
    DateTime? createdAt,
    double? retentionTax,
    double? retentionIsr,
    int? paymentMethodId,
    String? ncfTypeId,
    String? saleId,
  }) {
    return SaleProduct(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      ncf: ncf ?? this.ncf,
      ncfAffected: ncfAffected ?? this.ncfAffected,
      discount: discount ?? this.discount,
      net: net ?? this.net,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      effective: effective ?? this.effective,
      creditCard: creditCard ?? this.creditCard,
      checkOrTransf: checkOrTransf ?? this.checkOrTransf,
      saleToCredit: saleToCredit ?? this.saleToCredit,
      law10: law10 ?? this.law10,
      typeIncomeId: typeIncomeId ?? this.typeIncomeId,
      clientType: clientType ?? this.clientType,
      createdAt: createdAt ?? this.createdAt,
      retentionTax: retentionTax ?? this.retentionTax,
      retentionIsr: retentionIsr ?? this.retentionIsr,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      ncfTypeId: ncfTypeId ?? this.ncfTypeId,
      saleId: saleId ?? this.saleId,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'ncf': ncf,
      'ncfAffected': ncfAffected,
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
      'createdAt': createdAt,
      'retentionTax': retentionTax,
      'retentionIsr': retentionIsr,
      'ncfTypeId': ncfTypeId,
      'saleId': saleId,
      'items': items.map((e) => e.toMap()).toList(),
      'description': description,
      'retentionDate': retentionDate,
      'prefix': prefix,
      'invoiceTypeId': invoiceTypeId,
      'amountPaid': amountPaid,
      'debt': debt,
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
      'retentionDate': retentionDate,
      'prefix': prefix,
      "invoiceTypeId": invoiceTypeId,
      'currencyId': currencyId,
      'rate': rate,
      'maxSequence': maxSequence,
      'createdAt': createdAt
    };
  }

  factory SaleProduct.fromMap(Map<String, dynamic> map) {
    return SaleProduct(
        id: map['id'],
        clientId: map['clientId'],
        ncf: map['ncf'],
        ncfAffected: map['ncfAffected'],
        discount:
            map['discount'] != null ? double.parse(map['discount']) : null,
        net: double.parse(map['net']),
        tax: double.parse(map['tax']),
        total: map['total'] != null ? double.parse(map['total']) : null,
        effective: double.parse(map['effective']),
        creditCard: double.parse(map['creditCard']),
        checkOrTransf: double.parse(map['checkOrTransf']),
        saleToCredit: double.parse(map['saleToCredit']),
        law10: double.parse(map['law10']),
        typeIncomeId: map['typeIncomeId'],
        clientType: map['clientType'],
        createdAt: map['createdAt'],
        retentionTax: double.parse(map['retentionTax']),
        retentionIsr: double.parse(map['retentionIsr']),
        paymentMethodId: map['paymentMethodId'],
        ncfTypeId: map['ncfTypeId'],
        saleId: map['saleId'],
        description: map['description'],
        retentionDate: map['retentionDate'],
        prefix: map['prefix'],
        typeIncomeName: map['typeIncomeName'],
        paymentMethodName: map['paymentMethodName'],
        clientTypeName: map['clientTypeName'],
        ncfTypeName: map['ncfTypeName'],
        clientName: map['clientName'],
        invoiceTypeId: map['invoiceTypeId'],
        amountPaid:
            map['amountPaid'] != null ? double.parse(map['amountPaid']) : null,
        debt: map['debt'] != null ? double.parse(map['debt']) : null,
        currencyId: map['currencyId'],
        rate: map['rate'] != null ? double.parse(map['rate']) : null);
  }

  String toJson() => json.encode(toMap());

  factory SaleProduct.fromJson(String source) =>
      SaleProduct.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SaleProduct(id: $id, clientId: $clientId, ncf: $ncf, ncfAffected: $ncfAffected, discount: $discount, net: $net, tax: $tax, total: $total, effective: $effective, creditCard: $creditCard, checkOrTransf: $checkOrTransf, saleToCredit: $saleToCredit, law10: $law10, typeIncomeId: $typeIncomeId, clientType: $clientType, createdAt: $createdAt, retentionTax: $retentionTax, retentionIsr: $retentionIsr, paymentMethodId: $paymentMethodId, ncfTypeId: $ncfTypeId, saleId: $saleId)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is SaleProduct &&
        o.id == id &&
        o.clientId == clientId &&
        o.ncf == ncf &&
        o.ncfAffected == ncfAffected &&
        o.discount == discount &&
        o.net == net &&
        o.tax == tax &&
        o.total == total &&
        o.effective == effective &&
        o.creditCard == creditCard &&
        o.checkOrTransf == checkOrTransf &&
        o.saleToCredit == saleToCredit &&
        o.law10 == law10 &&
        o.typeIncomeId == typeIncomeId &&
        o.clientType == clientType &&
        o.createdAt == createdAt &&
        o.retentionTax == retentionTax &&
        o.retentionIsr == retentionIsr &&
        o.paymentMethodId == paymentMethodId &&
        o.ncfTypeId == ncfTypeId &&
        o.saleId == saleId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        clientId.hashCode ^
        ncf.hashCode ^
        ncfAffected.hashCode ^
        discount.hashCode ^
        net.hashCode ^
        tax.hashCode ^
        total.hashCode ^
        effective.hashCode ^
        creditCard.hashCode ^
        checkOrTransf.hashCode ^
        saleToCredit.hashCode ^
        law10.hashCode ^
        typeIncomeId.hashCode ^
        clientType.hashCode ^
        createdAt.hashCode ^
        retentionTax.hashCode ^
        retentionIsr.hashCode ^
        paymentMethodId.hashCode ^
        ncfTypeId.hashCode ^
        saleId.hashCode;
  }

  @override
  Future<SaleProduct?> create() async {
    try {
      var map = toMapInsert();
      var id = Uuid().v4();
      map['id'] = id;
      var seqParams = '';
      final conne = SqlConector.connection;

      for (int i = 0; i < items.length; i++) {
        var item = items[i];

        var result = await conne?.execute(
            Sql.named(
                '''select * from public."Products" where id = @id and quantity > 0'''),
            parameters: {'id': item.productId});

        if (result != null && result.isEmpty) {
          throw 'EL PRODUCTO ${item.productName} NO ESTA DISPONIBLE';
        }
      }

      if (ncfTypeId == '01') {
        seqParams = '''nextval('01_seq')''';
      }

      if (ncfTypeId == '02') {
        seqParams = '''nextval('02_seq')''';
      }

      if (ncfTypeId == '15') {
        seqParams = '''nextval('15_seq')''';
      }
      if (ncfTypeId == '31') {
        seqParams = '''nextval('31_seq')''';
      }

      if (ncfTypeId == '32') {
        seqParams = '''nextval('32_seq')''';
      }
      if (ncfTypeId == '315') {
        seqParams = '''nextval('315_seq')''';
      }

      if (ncfTypeId == '50') {
        seqParams = '''nextval('50_seq')''';
      }

      if (items.isEmpty) {
        throw 'No existe elementos agregados';
      }

      var clientID = Uuid().v4();

      await conne?.execute(
          Sql.named('''INSERT INTO public."Clients"(id,identification,name) 
      VALUES (@clientId,@identification,@name) 
       ON CONFLICT (identification) DO NOTHING;
      '''),
          parameters: {
            'clientId': clientID,
            'identification': clientId,
            'name': clientName
          });

      await conne?.runTx((conne) async {
        await conne.execute(Sql.named('''
         INSERT INTO public."Sale"(
	       id, "clientId", ncf, discount, net, tax, total, effective, "creditCard", "checkOrTransf", "saleToCredit", law10, "typeIncomeId", "clientType", "retentionTax", "retentionIsr", "ncfTypeId", description, "retentionDate", prefix,"invoiceTypeId", "currencyId", rate, "maxSequence","createdAt")
	       VALUES (@id, @clientId, $seqParams, @discount, @net, @tax, @total, @effective, @creditCard, @checkOrTransf, @saleToCredit, @law10, @typeIncomeId, @clientType, @retentionTax, @retentionIsr, @ncfTypeId, @description, @retentionDate, @prefix,@invoiceTypeId, @currencyId, @rate, @maxSequence, @createdAt);
       
      '''), parameters: map);

        for (int i = 0; i < items.length; i++) {
          var item = items[i];

          var subMap = item.toMap();
          var xid = Uuid().v4();
          subMap['id'] = xid;
          subMap['saleId'] = id;
          await conne.execute(Sql.named('''INSERT INTO public."SaleProduct"(
	       id, "productId", discount, net, tax, total, "retentionTax", "retentionIsr", "saleId", quantity, "taxId", "discountId", "retentionTaxId", "retentionIsrId")
	       VALUES (@id, @productId, @discount, @net, @tax, @total, @retentionTax, @retentionIsr, @saleId, @quantity, @taxId, @discountId, @retentionTaxId, @retentionIsrId); '''),
              parameters: subMap);

          if (ncfTypeId != '50') {
            await conne.execute(
                Sql.named(
                    '''update public."Products" set quantity = quantity - @quantity where id = @id'''),
                parameters: {'id': item.productId, 'quantity': item.quantity});
          }
        }

        if (paid != null && paid! > 0) {
          await conne.execute(
              Sql.named(
                  'insert into public."Payments"(id,"saleId","paymentMethodId", "bankId","transfRef", amount) values(@id,@saleId,@paymentMethodId, @bankId, @transfRef, @amount)'),
              parameters: {
                'id': Uuid().v4(),
                'saleId': id,
                'paymentMethodId': paymentMethodId,
                'bankId': bankId,
                'transfRef': transfRef,
                'amount': paid
              });
        }
      });

      var invoicesRows = await conne?.execute(
          Sql.named('''select * from public."SalesView" where id = @id '''),
          parameters: {'id': id});

      var rows = await conne?.execute(
          Sql.named(
              ''' select * from public."SalesProductsView" WHERE "saleId" = @id '''),
          parameters: {'id': id});

      if (invoicesRows != null && invoicesRows.isNotEmpty) {
        var firstRow = invoicesRows.first;
        var sale = SaleProduct.fromMap(firstRow.toColumnMap());

        var xitems = rows
                ?.map((e) => SaleItemProduct.fromMap(e.toColumnMap()))
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

  static Future<List<SaleProduct>> get(
      {required DateTime startDate, required DateTime endDate}) async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute(
          Sql.named(
              'select * from public."SalesView" where "createdAt" between @date1 and @date2'),
          parameters: {
            'date1': startDate.toIso8601String(),
            'date2': endDate.toIso8601String()
          });
      return result
              ?.map((e) => SaleProduct.fromMap(e.toColumnMap()))
              .toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SaleProduct?> update() async {
    try {
      final conne = SqlConector.connection;
      await conne?.runTx((conne) async {
        await conne.execute(Sql.named('''update public."Sale" 
                  set 
                  net = @net,
                  tax = @tax,
                  total = @total, 
                  "retentionTax" = @retentionTax,
                  "retentionIsr" = @retentionIsr, 
                  effective = @effective,
                  "creditCard" = @creditCard,
                  "checkOrTransf" = @checkOrTransf,
                  "saleToCredit" = @saleToCredit,
                   "retentionDate" = @retentionDate,
                   "currencyId" = @currencyId,
                   rate = @rate
                   where id = @id'''), parameters: {
          'id': id,
          'net': net,
          'tax': tax,
          'total': total,
          'retentionTax': retentionTax,
          'retentionIsr': retentionIsr,
          'effective': effective,
          'creditCard': creditCard,
          'checkOrTransf': checkOrTransf,
          'saleToCredit': saleToCredit,
          'retentionDate': retentionDate,
          'currencyId': currencyId,
          'rate': rate
        });

        for (int i = 0; i < items.length; i++) {
          var item = items[i];
          await conne.execute(Sql.named('''update public."SaleProduct" 
                  set "retentionTax" = @retentionTax, 
                  "retentionIsr" = @retentionIsr,
                  "retentionTaxId" = @retentionTaxId, 
                  "retentionIsrId" = @retentionIsrId, 
                  discount = @discount, 
                  "discountId" = @discountId 
                  where id = @id'''), parameters: {
            'id': item.id,
            'retentionTax': item.retentionTax,
            'retentionIsr': item.retentionIsr,
            'retentionTaxId': item.retentionTaxId,
            'retentionIsrId': item.retentionIsrId,
            'discount': item.discount,
            'discountId': item.discountId
          });
        }

        if (paid != null && paid! > 0) {
          await conne.execute(
              Sql.named(
                  'insert into public."Payments"(id,"saleId","paymentMethodId", "bankId", "transfRef", amount) values(@id,@saleId,@paymentMethodId, @bankId, @transfRef, @amount)'),
              parameters: {
                'id': Uuid().v4(),
                'saleId': id,
                'paymentMethodId': paymentMethodId,
                'bankId': bankId,
                'transfRef': transfRef,
                'amount': paid
              });
        }
      });
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Sale?> paySale(double amount) async {
    try {
      final conne = SqlConector.connection;
      await conne?.runTx((conne) async {
        DateTime paymentDate = DateTime.now();
        if (retentionDate != null) {
          paymentDate = retentionDate!;
        }
        await conne.execute(
            Sql.named(
                '''insert into public."Payments" (id,"saleId","paymentMethodId", "bankId", "transfRef", amount,"createdAt") values(@id,@saleId,@paymentMethodId,@bankId, @transfRef, @amount,@createdAt)'''),
            parameters: {
              'id': Uuid().v4(),
              'saleId': id,
              'paymentMethodId': paymentMethodId,
              'bankId': bankId,
              'transfRef': transfRef,
              'amount': amount,
              'createdAt': paymentDate
            });
        await conne.execute(Sql.named('''update public."Sale" set
      effective = @effective, 
      "creditCard" =  @creditCard, 
      "checkOrTransf" = @checkOrTransf,
      "saleToCredit" =  @saleToCredit
      where id = @id
      '''), parameters: {
          'id': id,
          'effective': effective,
          'creditCard': creditCard,
          'checkOrTransf': checkOrTransf,
          'saleToCredit': saleToCredit
        });
      });

      var res2 = await conne?.execute(
          Sql.named('select * from public."SalesView" where id = @id'),
          parameters: {'id': id});

      var el = res2?[0];
      if (el != null) {
        return SaleProduct.fromMap(el.toColumnMap());
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Sale?> findById(String id) {
    // TODO: implement findById
    throw UnimplementedError();
  }

  @override
  List<SaleItem> items;

  @override
  String? description;

  @override
  String? clientName;

  @override
  DateTime? retentionDate;

  @override
  String? prefix;

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
    return {
      'RNC/Cédula o Pasaporte': clientId,
      'Tipo Identificación': clientType.toString(),
      'Número Comprobante Fiscal': ncf,
      'Número Comprobante Fiscal Modificado': ncfAffected ?? 'S/N',
      'Tipo de Ingreso': typeIncomeId,
      'Fecha Comprobante': createdAt?.format(payload: 'YYYYMMDD'),
      'Fecha de Retención': retentionDate?.format(payload: 'YYYYMMDD') ?? 'S/N',
      'Monto Facturado': net?.toStringAsFixed(2) ?? '0.00',
      'ITBIS Facturado': tax?.toStringAsFixed(2) ?? '0.00',
      'ITBIS Retenido por Terceros': retentionTax?.toStringAsFixed(2) ?? '0.00',
      'ITBIS Percibido': '0.00',
      'Retención Renta por Terceros':
          retentionIsr?.toStringAsFixed(2) ?? '0.00',
      'ISR Percibido': '0.00',
      'Impuesto Selectivo al Consumo': '0.00',
      'Otros Impuestos/Tasas': '0.00',
      'Monto Propina Legal': law10?.toStringAsFixed(2) ?? '0.00',
      'Efectivo': effective?.toStringAsFixed(2) ?? '0.00',
      'Cheque/ Transferencia/ Depósito':
          checkOrTransf?.toStringAsFixed(2) ?? '0.00',
      'Tarjeta Débito/Crédito': creditCard?.toStringAsFixed(2) ?? '0.00',
      'Venta a Crédito': saleToCredit?.toStringAsFixed(2) ?? '0.00',
      'Bonos o Certificados de Regalo': '0.00',
      'Permuta': '0.00',
      'Otras Formas de Ventas': '0.00'
    };
  }

  @override
  Map<String, dynamic> to607() {
    return {
      'RNC/Cédula o Pasaporte': clientId,
      'Tipo Identificación': clientType.toString(),
      'Número Comprobante Fiscal': ncf,
      'Número Comprobante Fiscal Modificado': ncfAffected ?? '',
      'Tipo de Ingreso': typeIncomeId,
      'Fecha Comprobante': createdAt?.format(payload: 'YYYYMMDD'),
      'Fecha de Retención': retentionDate?.format(payload: 'YYYYMMDD') ?? '',
      'Monto Facturado': net?.toStringAsFixed(2) ?? '0.00',
      'ITBIS Facturado': tax?.toStringAsFixed(2) ?? '0.00',
      'ITBIS Retenido por Terceros': retentionTax?.toStringAsFixed(2) ?? '0.00',
      'ITBIS Percibido': '0.00',
      'Retención Renta por Terceros':
          retentionIsr?.toStringAsFixed(2) ?? '0.00',
      'ISR Percibido': '0.00',
      'Impuesto Selectivo al Consumo': '0.00',
      'Otros Impuestos/Tasas': '0.00',
      'Monto Propina Legal': law10?.toStringAsFixed(2) ?? '0.00',
      'Efectivo': effective?.toStringAsFixed(2) ?? '0.00',
      'Cheque/ Transferencia/ Depósito':
          checkOrTransf?.toStringAsFixed(2) ?? '0.00',
      'Tarjeta Débito/Crédito': creditCard?.toStringAsFixed(2) ?? '0.00',
      'Venta a Crédito': saleToCredit?.toStringAsFixed(2) ?? '0.00',
      'Bonos o Certificados de Regalo': '0.00',
      'Permuta': '0.00',
      'Otras Formas de Ventas': '0.00'
    };
  }

  @override
  int? invoiceTypeId;

  @override
  double? paid;

  @override
  double? amountPaid;

  @override
  double? debt;

  @override
  bool get isPaid {
    return debt == 0 ? true : false;
  }

  @override
  Color get color {
    if (isPaid) return Colors.green;
    return Colors.red;
  }

  @override
  String get paidLabel {
    if (isPaid) return 'PAGADO';
    return 'PENDIENTE';
  }

  @override
  Future<List<SaleItem>> getSaleData() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute(
          Sql.named(
              'select * from public."SalesProductsView" where "saleId" = @id'),
          parameters: {'id': id});
      return result
              ?.map((e) => SaleItemProduct.fromMap(e.toColumnMap()))
              .toList()
              .cast<SaleItemProduct>() ??
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
