import 'data_filter_model.dart';

enum DashboardWidgetType {
  indicator,
  barChart,
  lineChart,
  pieChart,
  summaryTable,
}

enum AggregationType { sum, average, count, min, max }

class DashboardWidgetModel {
  const DashboardWidgetModel({
    required this.id,
    required this.title,
    required this.type,
    required this.columnKey,
    required this.aggregation,
    this.filter,
  });

  final String id;
  final String title;
  final DashboardWidgetType type;
  final String columnKey;
  final AggregationType aggregation;
  final DataFilterModel? filter;

  DashboardWidgetModel copyWith({
    String? id,
    String? title,
    DashboardWidgetType? type,
    String? columnKey,
    AggregationType? aggregation,
    DataFilterModel? filter,
    bool clearFilter = false,
  }) {
    return DashboardWidgetModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      columnKey: columnKey ?? this.columnKey,
      aggregation: aggregation ?? this.aggregation,
      filter: clearFilter ? null : (filter ?? this.filter),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'columnKey': columnKey,
      'aggregation': aggregation.name,
      'filter': filter?.toJson(),
    };
  }

  factory DashboardWidgetModel.fromJson(Map<String, dynamic> json) {
    return DashboardWidgetModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: DashboardWidgetType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => DashboardWidgetType.indicator,
      ),
      columnKey: json['columnKey'] as String,
      aggregation: AggregationType.values.firstWhere(
        (value) => value.name == json['aggregation'],
        orElse: () => AggregationType.count,
      ),
      filter: json['filter'] == null
          ? null
          : DataFilterModel.fromJson(
              Map<String, dynamic>.from(json['filter'] as Map),
            ),
    );
  }
}
