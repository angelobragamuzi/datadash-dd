import 'dart:math';

import 'package:collection/collection.dart';

import '../models/chart_point_model.dart';
import '../models/dashboard_widget_model.dart';
import '../models/data_column_model.dart';
import '../models/data_filter_model.dart';
import '../models/data_set_model.dart';

class DataProcessingService {
  DataSetModel buildDataSet({
    required String id,
    required String fileName,
    required String sourceType,
    String? sourcePath,
    required List<String> rawHeaders,
    required List<List<dynamic>> rawRows,
  }) {
    final normalizedHeaders = _normalizeHeaders(rawHeaders);
    final columns = <DataColumnModel>[];

    for (var index = 0; index < normalizedHeaders.length; index++) {
      final label = normalizedHeaders[index];
      final key = _toKey(label, index);
      final type = _inferColumnType(index, rawRows);
      columns.add(DataColumnModel(key: key, label: label, type: type));
    }

    final rows = <Map<String, dynamic>>[];
    for (final rawRow in rawRows) {
      final rowMap = <String, dynamic>{};
      for (var index = 0; index < columns.length; index++) {
        final rawValue = index < rawRow.length ? rawRow[index] : null;
        rowMap[columns[index].key] = _parseByType(
          rawValue,
          columns[index].type,
        );
      }
      rows.add(rowMap);
    }

    return DataSetModel(
      id: id,
      fileName: fileName,
      sourceType: sourceType,
      sourcePath: sourcePath,
      importedAt: DateTime.now(),
      columns: columns,
      rows: rows,
    );
  }

  DataSetModel renameColumn(
    DataSetModel dataSet,
    String columnKey,
    String newName,
  ) {
    final updatedColumns = dataSet.columns
        .map(
          (column) => column.key == columnKey
              ? column.copyWith(
                  label: newName.trim().isEmpty ? column.label : newName.trim(),
                )
              : column,
        )
        .toList();

    return dataSet.copyWith(columns: updatedColumns);
  }

  DataSetModel toggleIgnoredColumn(
    DataSetModel dataSet,
    String columnKey,
    bool ignored,
  ) {
    final updatedColumns = dataSet.columns
        .map(
          (column) => column.key == columnKey
              ? column.copyWith(ignored: ignored)
              : column,
        )
        .toList();

    return dataSet.copyWith(columns: updatedColumns);
  }

  DataSetModel addFilter(DataSetModel dataSet, DataFilterModel filter) {
    final filters = List<DataFilterModel>.from(dataSet.filters)..add(filter);
    return dataSet.copyWith(filters: filters);
  }

  DataSetModel removeFilterAt(DataSetModel dataSet, int index) {
    if (index < 0 || index >= dataSet.filters.length) {
      return dataSet;
    }
    final filters = List<DataFilterModel>.from(dataSet.filters)
      ..removeAt(index);
    return dataSet.copyWith(filters: filters);
  }

  List<Map<String, dynamic>> applyFilters(
    DataSetModel dataSet, {
    List<DataFilterModel>? extraFilters,
  }) {
    final filters = [...dataSet.filters, ...?extraFilters];

    if (filters.isEmpty) {
      return dataSet.rows;
    }

    return dataSet.rows.where((row) {
      return filters.every(
        (filter) => _matchFilter(row[filter.columnKey], filter),
      );
    }).toList();
  }

  double aggregate(
    DataSetModel dataSet, {
    required String columnKey,
    required AggregationType aggregation,
    DataFilterModel? filter,
    List<DataFilterModel>? globalFilters,
  }) {
    final filters = <DataFilterModel>[...?globalFilters, ?filter];

    final filteredRows = applyFilters(dataSet, extraFilters: filters);
    final values = filteredRows
        .map((row) => _toDouble(row[columnKey]))
        .whereType<double>()
        .toList();

    switch (aggregation) {
      case AggregationType.sum:
        return values.fold<double>(0, (acc, value) => acc + value);
      case AggregationType.average:
        if (values.isEmpty) return 0;
        final total = values.fold<double>(0, (acc, value) => acc + value);
        return total / values.length;
      case AggregationType.count:
        return filteredRows.length.toDouble();
      case AggregationType.min:
        return values.isEmpty ? 0 : values.reduce(min);
      case AggregationType.max:
        return values.isEmpty ? 0 : values.reduce(max);
    }
  }

  List<ChartPointModel> groupedAggregation({
    required DataSetModel dataSet,
    required String valueColumnKey,
    required AggregationType aggregation,
    DataFilterModel? filter,
    List<DataFilterModel>? globalFilters,
  }) {
    final dimensionColumn = _bestDimensionColumn(dataSet, valueColumnKey);
    if (dimensionColumn == null) {
      return const [];
    }

    final filters = <DataFilterModel>[...?globalFilters, ?filter];

    final rows = applyFilters(dataSet, extraFilters: filters);
    final grouped = <String, List<double>>{};

    for (final row in rows) {
      final label =
          (row[dimensionColumn.key]?.toString().trim().isNotEmpty ?? false)
          ? row[dimensionColumn.key].toString()
          : 'Sem valor';

      grouped.putIfAbsent(label, () => <double>[]);
      final value = _toDouble(row[valueColumnKey]);
      if (value != null) {
        grouped[label]!.add(value);
      }
    }

    final result = grouped.entries.map((entry) {
      final values = entry.value;
      if (aggregation == AggregationType.count) {
        return ChartPointModel(
          label: entry.key,
          value: values.isEmpty ? 0 : values.length.toDouble(),
        );
      }
      if (values.isEmpty) {
        return ChartPointModel(label: entry.key, value: 0);
      }

      final sum = values.fold<double>(0, (acc, value) => acc + value);
      switch (aggregation) {
        case AggregationType.sum:
          return ChartPointModel(label: entry.key, value: sum);
        case AggregationType.average:
          return ChartPointModel(label: entry.key, value: sum / values.length);
        case AggregationType.count:
          return ChartPointModel(
            label: entry.key,
            value: values.length.toDouble(),
          );
        case AggregationType.min:
          return ChartPointModel(label: entry.key, value: values.reduce(min));
        case AggregationType.max:
          return ChartPointModel(label: entry.key, value: values.reduce(max));
      }
    }).toList();

    result.sort((a, b) => b.value.compareTo(a.value));
    return result.take(8).toList();
  }

  List<Map<String, dynamic>> summaryRows(
    DataSetModel dataSet, {
    int maxRows = 8,
    List<DataFilterModel>? extraFilters,
  }) {
    final visibleColumnKeys = dataSet.visibleColumns
        .map((column) => column.key)
        .toSet();
    final rows = applyFilters(dataSet, extraFilters: extraFilters);

    return rows.take(maxRows).map((row) {
      final compact = <String, dynamic>{};
      for (final key in visibleColumnKeys) {
        compact[key] = row[key];
      }
      return compact;
    }).toList();
  }

  DataColumnModel? _bestDimensionColumn(
    DataSetModel dataSet,
    String valueColumnKey,
  ) {
    return dataSet.visibleColumns.firstWhereOrNull(
      (column) =>
          column.key != valueColumnKey &&
          (column.type == DataValueType.text ||
              column.type == DataValueType.date),
    );
  }

  DataValueType _inferColumnType(int index, List<List<dynamic>> rows) {
    final samples = rows
        .where((row) => index < row.length)
        .map((row) => row[index])
        .where((value) => value != null && value.toString().trim().isNotEmpty)
        .take(30)
        .toList();

    if (samples.isEmpty) return DataValueType.empty;

    var numericMatches = 0;
    var dateMatches = 0;
    var boolMatches = 0;

    for (final sample in samples) {
      final text = sample.toString().trim();
      if (_toDouble(text) != null) {
        numericMatches++;
      }
      if (_tryParseDate(text) != null) {
        dateMatches++;
      }
      if (_tryParseBool(text) != null) {
        boolMatches++;
      }
    }

    if (numericMatches == samples.length) return DataValueType.numeric;
    if (dateMatches >= (samples.length * 0.8)) return DataValueType.date;
    if (boolMatches == samples.length) return DataValueType.boolean;
    return DataValueType.text;
  }

  dynamic _parseByType(dynamic rawValue, DataValueType type) {
    if (rawValue == null) return null;

    final text = rawValue.toString().trim();
    if (text.isEmpty) return null;

    switch (type) {
      case DataValueType.numeric:
        return _toDouble(text);
      case DataValueType.date:
        return _tryParseDate(text)?.toIso8601String() ?? text;
      case DataValueType.boolean:
        return _tryParseBool(text);
      case DataValueType.text:
      case DataValueType.empty:
        return text;
    }
  }

  bool _matchFilter(dynamic rowValue, DataFilterModel filter) {
    final candidate = rowValue?.toString() ?? '';
    final expected = filter.value.trim();
    if (expected.isEmpty) return true;

    switch (filter.operator) {
      case FilterOperator.contains:
        return candidate.toLowerCase().contains(expected.toLowerCase());
      case FilterOperator.equals:
        return candidate.toLowerCase() == expected.toLowerCase();
      case FilterOperator.greaterThan:
        final left = _toDouble(candidate);
        final right = _toDouble(expected);
        if (left == null || right == null) return false;
        return left > right;
      case FilterOperator.lessThan:
        final left = _toDouble(candidate);
        final right = _toDouble(expected);
        if (left == null || right == null) return false;
        return left < right;
    }
  }

  List<String> _normalizeHeaders(List<String> headers) {
    if (headers.isEmpty) {
      return const ['Coluna 1'];
    }

    final normalized = <String>[];
    for (var index = 0; index < headers.length; index++) {
      final text = headers[index].trim();
      normalized.add(text.isEmpty ? 'Coluna ${index + 1}' : text);
    }
    return normalized;
  }

  String _toKey(String label, int index) {
    final sanitized = label
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    if (sanitized.isEmpty) {
      return 'col_${index + 1}';
    }
    return '${sanitized}_${index + 1}';
  }

  DateTime? _tryParseDate(String text) {
    final direct = DateTime.tryParse(text);
    if (direct != null) return direct;

    final normalized = text.replaceAll('/', '-');
    final parts = normalized.split('-');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  bool? _tryParseBool(String text) {
    const trueValues = {'true', '1', 'sim', 'yes'};
    const falseValues = {'false', '0', 'nao', 'não', 'no'};
    final value = text.toLowerCase();
    if (trueValues.contains(value)) return true;
    if (falseValues.contains(value)) return false;
    return null;
  }

  double? _toDouble(dynamic input) {
    if (input == null) return null;
    if (input is num) return input.toDouble();

    final text = input.toString().trim();
    if (text.isEmpty) return null;

    final hasComma = text.contains(',');
    final hasDot = text.contains('.');

    if (hasComma && hasDot) {
      if (text.lastIndexOf(',') > text.lastIndexOf('.')) {
        final normalized = text.replaceAll('.', '').replaceAll(',', '.');
        return double.tryParse(normalized);
      }
      final normalized = text.replaceAll(',', '');
      return double.tryParse(normalized);
    }

    if (hasComma) {
      return double.tryParse(text.replaceAll(',', '.'));
    }

    return double.tryParse(text);
  }
}
