enum FilterOperator { contains, equals, greaterThan, lessThan }

class DataFilterModel {
  const DataFilterModel({
    required this.columnKey,
    required this.operator,
    required this.value,
  });

  final String columnKey;
  final FilterOperator operator;
  final String value;

  DataFilterModel copyWith({
    String? columnKey,
    FilterOperator? operator,
    String? value,
  }) {
    return DataFilterModel(
      columnKey: columnKey ?? this.columnKey,
      operator: operator ?? this.operator,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toJson() {
    return {'columnKey': columnKey, 'operator': operator.name, 'value': value};
  }

  factory DataFilterModel.fromJson(Map<String, dynamic> json) {
    return DataFilterModel(
      columnKey: json['columnKey'] as String,
      operator: FilterOperator.values.firstWhere(
        (value) => value.name == json['operator'],
        orElse: () => FilterOperator.contains,
      ),
      value: json['value'] as String,
    );
  }
}
