import 'data_column_model.dart';
import 'data_filter_model.dart';

class DataSetModel {
  const DataSetModel({
    required this.id,
    required this.fileName,
    required this.sourceType,
    required this.importedAt,
    required this.columns,
    required this.rows,
    this.sourcePath,
    this.filters = const [],
  });

  final String id;
  final String fileName;
  final String sourceType;
  final String? sourcePath;
  final DateTime importedAt;
  final List<DataColumnModel> columns;
  final List<Map<String, dynamic>> rows;
  final List<DataFilterModel> filters;

  int get columnCount => columns.where((column) => !column.ignored).length;

  List<DataColumnModel> get visibleColumns {
    return columns.where((column) => !column.ignored).toList();
  }

  DataSetModel copyWith({
    String? id,
    String? fileName,
    String? sourceType,
    String? sourcePath,
    DateTime? importedAt,
    List<DataColumnModel>? columns,
    List<Map<String, dynamic>>? rows,
    List<DataFilterModel>? filters,
  }) {
    return DataSetModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      sourceType: sourceType ?? this.sourceType,
      sourcePath: sourcePath ?? this.sourcePath,
      importedAt: importedAt ?? this.importedAt,
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      filters: filters ?? this.filters,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'sourceType': sourceType,
      'sourcePath': sourcePath,
      'importedAt': importedAt.toIso8601String(),
      'columns': columns.map((column) => column.toJson()).toList(),
      'rows': rows,
      'filters': filters.map((filter) => filter.toJson()).toList(),
    };
  }

  factory DataSetModel.fromJson(Map<String, dynamic> json) {
    return DataSetModel(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      sourceType: json['sourceType'] as String,
      sourcePath: json['sourcePath'] as String?,
      importedAt: DateTime.parse(json['importedAt'] as String),
      columns: (json['columns'] as List<dynamic>)
          .map(
            (entry) => DataColumnModel.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList(),
      rows: (json['rows'] as List<dynamic>)
          .map((entry) => Map<String, dynamic>.from(entry as Map))
          .toList(),
      filters: (json['filters'] as List<dynamic>? ?? const [])
          .map(
            (entry) => DataFilterModel.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList(),
    );
  }
}
