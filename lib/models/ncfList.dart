import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:uresax_invoice_sys/apis/sql.dart';

class NcfsList {
  int? id;
  String? ncfTypeId;
  String? ncfTypeName;
  int? start;
  int? end;
  DateTime? expirationDate;
  DateTime? createdAt;
  bool? finish;
  NcfsList(
      {this.id,
      this.ncfTypeId,
      this.ncfTypeName,
      this.start,
      this.end,
      this.expirationDate,
      this.createdAt,
      this.finish = false});

  static Future<List<NcfsList>> get() async {
    try {
      final conne = SqlConector.connection;
      var result = await conne?.execute('select * from public."NcfsListView"');
      return result?.map((e) => NcfsList.fromMap(e.toColumnMap())).toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> create() async {
    try {
      final conne = SqlConector.connection;

      int s = start! + 1;

      final resTraslape = await conne?.execute(Sql.named('''
SELECT *
FROM public."NcfsList"
WHERE "ncfTypeId" = @ncfTypeId
  AND NOT ("end" <= @start OR "start" > @end);
'''), parameters: {'ncfTypeId': ncfTypeId, 'start': s, 'end': end});

      if (resTraslape != null && resTraslape.isNotEmpty) {
        throw '⛔ Conflicto de traslape: ya existe un rango que interfiere con $start - $end para $ncfTypeName';
      }

      final resContenido = await conne?.execute(Sql.named('''
SELECT *
FROM public."NcfsList"
WHERE "ncfTypeId" = @ncfTypeId
  AND "start" <= @start AND "end" >= @end;
'''), parameters: {'ncfTypeId': ncfTypeId, 'start': start, 'end': end});

      if (resContenido != null && resContenido.isNotEmpty) {
        throw '⛔ Rango contenido: el rango $start - $end ya está cubierto completamente por otro de tipo $ncfTypeName';
      }

      final resInicioDentro = await conne?.execute(Sql.named('''
SELECT *
FROM public."NcfsList"
WHERE "ncfTypeId" = @ncfTypeId
  AND "start" > @start AND "start" <= @end;
'''), parameters: {'ncfTypeId': ncfTypeId, 'start': start, 'end': end});

      if (resInicioDentro != null && resInicioDentro.isNotEmpty) {
        throw '⛔ Inicio dentro: ya existe un rango de tipo $ncfTypeName que comienza dentro de $start - $end';
      }

      final resFinalDentro = await conne?.execute(Sql.named('''
SELECT *
FROM public."NcfsList"
WHERE "ncfTypeId" = @ncfTypeId
  AND "end" >= @start AND "end" < @end;
'''), parameters: {'ncfTypeId': ncfTypeId, 'start': s, 'end': end});

      if (resFinalDentro != null && resFinalDentro.isNotEmpty) {
        throw '⛔ Final dentro: ya existe un rango de tipo $ncfTypeName que termina dentro de $start - $end';
      }
      var res = await conne?.execute(
          Sql.named(
              '''select * from public."NcfsList" where "ncfTypeId" = @ncfTypeId and finish = false'''),
          parameters: {'ncfTypeId': ncfTypeId});

      if (res != null && res.isNotEmpty) {
        throw 'LAS SECUENCIAS DE LAS $ncfTypeName NO ESTAN FINALIZADAS';
      }

      await conne?.execute(Sql.named('''
  INSERT INTO public."NcfsList"(
	"ncfTypeId", start, "end", "expirationDate")
	VALUES (@ncfTypeId, @start, @end, @expirationDate);
        '''), parameters: toMapInsert());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateFinish({int currentNcf = 1}) async {
    try {
      final conne = SqlConector.connection;
      await conne?.execute('''
UPDATE public."NcfsList"
	SET   finish = true
	WHERE "ncfTypeId" = @ncfTypeId and end = $currentNcf
        ''', parameters: {'ncfTypeId': ncfTypeId});
    } catch (e) {
      rethrow;
    }
  }

  NcfsList copyWith({
    int? id,
    String? ncfTypeId,
    int? start,
    int? end,
    DateTime? expirationDate,
    DateTime? createdAt,
  }) {
    return NcfsList(
      id: id ?? this.id,
      ncfTypeId: ncfTypeId ?? this.ncfTypeId,
      start: start ?? this.start,
      end: end ?? this.end,
      expirationDate: expirationDate ?? this.expirationDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ncfTypeId': ncfTypeId,
      'start': start,
      'end': end,
      'expirationDate': expirationDate,
      'createdAt': createdAt
    };
  }

  Map<String, dynamic> toMapInsert() {
    return {
      'ncfTypeId': ncfTypeId,
      'start': start,
      'end': end,
      'expirationDate': expirationDate
    };
  }

  factory NcfsList.fromMap(Map<String, dynamic> map) {
    return NcfsList(
        id: map['id'],
        ncfTypeId: map['ncfTypeId'],
        ncfTypeName: map['ncfTypeName'],
        start: map['start'],
        end: map['end'],
        expirationDate: map['expirationDate'],
        createdAt: map['createdAt'],
        finish: map['finish']);
  }

  String toJson() => json.encode(toMap());

  factory NcfsList.fromJson(String source) =>
      NcfsList.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'NcfsList(id: $id, ncfTypeId: $ncfTypeId, start: $start, end: $end, expirationDate: $expirationDate, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is NcfsList &&
        o.id == id &&
        o.ncfTypeId == ncfTypeId &&
        o.start == start &&
        o.end == end &&
        o.expirationDate == expirationDate &&
        o.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        ncfTypeId.hashCode ^
        start.hashCode ^
        end.hashCode ^
        expirationDate.hashCode ^
        createdAt.hashCode;
  }
}
