enum DataValueType { numeric, text, date, boolean, empty }

class DataColumnModel {
  const DataColumnModel({
    required this.key,
    required this.label,
    required this.type,
    this.ignored = false,
  });

  final String key;
  final String label;
  final DataValueType type;
  final bool ignored;

  DataColumnModel copyWith({
    String? key,
    String? label,
    DataValueType? type,
    bool? ignored,
  }) {
    return DataColumnModel(
      key: key ?? this.key,
      label: label ?? this.label,
      type: type ?? this.type,
      ignored: ignored ?? this.ignored,
    );
  }

  Map<String, dynamic> toJson() {
    return {'key': key, 'label': label, 'type': type.name, 'ignored': ignored};
  }

  factory DataColumnModel.fromJson(Map<String, dynamic> json) {
    return DataColumnModel(
      key: json['key'] as String,
      label: json['label'] as String,
      type: DataValueType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => DataValueType.text,
      ),
      ignored: json['ignored'] as bool? ?? false,
    );
  }
}
