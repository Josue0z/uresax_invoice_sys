import 'dart:convert';

import 'package:uresax_invoice_sys/apis/sql.dart';

class TypeIncome {
  String? id;
  String? name;
  TypeIncome({
    this.id,
    this.name,
  });

  static Future<List<TypeIncome>> get() async {
    try {
      final conne = SqlConector.connection;
      var result =
          await conne?.execute('select id,name from public."TypesIncomes"');
      return result
              ?.map((e) => TypeIncome(
                    id: e[0] as String,
                    name: e[1] as String,
                  ))
              .toList() ??
          [];
    } catch (e) {
      rethrow;
    }
  }

  TypeIncome copyWith({
    String? id,
    String? name,
  }) {
    return TypeIncome(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory TypeIncome.fromMap(Map<String, dynamic> map) {
    return TypeIncome(
      id: map['id'],
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TypeIncome.fromJson(String source) =>
      TypeIncome.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'TypeIncome(id: $id, name: $name)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is TypeIncome && o.id == id && o.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
