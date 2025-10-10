import 'dart:convert';

import 'package:uresax_invoice_sys/apis/sql.dart';

class NcfSecuencia {
  String? id;
  String? name;
  int? lastValue;
  int? minValue;
  int? maxValue;
  NcfSecuencia({
    this.id,
    this.name,
    this.lastValue,
    this.minValue,
    this.maxValue,
  });
  static Future<List<NcfSecuencia>> get() async {
    try {
      final conne = SqlConector.connection;
      var result =
          await conne?.execute('select * from public."NcfsSecuencias"');
      return result
              ?.map((e) => NcfSecuencia.fromMap(e.toColumnMap()))
              .toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update() async {
    try {
      final conne = SqlConector.connection;
      int mm = lastValue! + 1;
      dynamic res;

      if (id == '04' || id == '34') {
        res = await conne?.execute(
            '''select * from public."CreditNote" where "ncfTypeId" = '$id' and (ncf between $mm and $maxValue) ''');
      } else {
        res = await conne?.execute(
            '''select * from public."Sale" where "ncfTypeId" = '$id' and (ncf between $mm and $maxValue) ''');
      }

      if (res != null && res.isNotEmpty) {
        throw 'YA EXISTE FACTURAS DE $name EN EL RANGO $mm - $maxValue';
      }
      await conne?.execute('''
        SELECT setval('public."${id}_seq"',$lastValue, false);
    ''');

      await conne?.execute('''
     ALTER SEQUENCE public."${id}_seq"
     MAXVALUE $maxValue      
     CYCLE;            
    ''');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>?> checkNcfs({int umbral = 10}) async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute('''
      SELECT id, name, ("maxValue" - "lastValue") AS dif
      FROM public."NcfsSecuencias"
      WHERE id = '$id' AND ("maxValue" - "lastValue") <= $umbral;
      ''');

      if (result!.isEmpty) {
        return null;
      }

      List<Map<String, dynamic>> events = [];

      for (var item in result) {
        var ob = item.toColumnMap();
        events.add({'dif': ob['dif'], 'name': ob['name']});
      }
      return events;
    } catch (e) {
      rethrow;
    }
  }

  NcfSecuencia copyWith({
    String? id,
    String? name,
    int? lastValue,
    int? minValue,
    int? maxValue,
  }) {
    return NcfSecuencia(
      id: id ?? this.id,
      name: name ?? this.name,
      lastValue: lastValue ?? this.lastValue,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'lastValue': lastValue,
      'minValue': minValue,
      'maxValue': maxValue
    };
  }

  factory NcfSecuencia.fromMap(Map<String, dynamic> map) {
    return NcfSecuencia(
        id: map['id'],
        name: map['name'],
        lastValue: map['lastValue'],
        minValue: map['minValue'],
        maxValue: map['maxValue']);
  }

  String toJson() => json.encode(toMap());

  factory NcfSecuencia.fromJson(String source) =>
      NcfSecuencia.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NcfSecuencia(id: $id, name: $name, lastValue: $lastValue, minValue: $minValue, maxValue: $maxValue)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is NcfSecuencia &&
        o.id == id &&
        o.name == name &&
        o.lastValue == lastValue &&
        o.minValue == minValue &&
        o.maxValue == maxValue;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        lastValue.hashCode ^
        minValue.hashCode ^
        maxValue.hashCode;
  }
}
