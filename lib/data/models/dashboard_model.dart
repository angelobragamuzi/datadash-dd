import 'dashboard_widget_model.dart';

class DashboardModel {
  const DashboardModel({
    required this.id,
    required this.name,
    required this.dataSetId,
    required this.createdAt,
    required this.updatedAt,
    required this.widgets,
  });

  final String id;
  final String name;
  final String dataSetId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<DashboardWidgetModel> widgets;

  DashboardModel copyWith({
    String? id,
    String? name,
    String? dataSetId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<DashboardWidgetModel>? widgets,
  }) {
    return DashboardModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dataSetId: dataSetId ?? this.dataSetId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      widgets: widgets ?? this.widgets,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dataSetId': dataSetId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'widgets': widgets.map((widget) => widget.toJson()).toList(),
    };
  }

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      id: json['id'] as String,
      name: json['name'] as String,
      dataSetId: json['dataSetId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      widgets: (json['widgets'] as List<dynamic>)
          .map(
            (entry) => DashboardWidgetModel.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList(),
    );
  }
}
