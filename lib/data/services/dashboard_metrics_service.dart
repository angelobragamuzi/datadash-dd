import '../models/chart_point_model.dart';
import '../models/dashboard_widget_model.dart';
import '../models/data_filter_model.dart';
import '../models/data_set_model.dart';
import 'data_processing_service.dart';

class DashboardMetricsService {
  DashboardMetricsService(this._processingService);

  final DataProcessingService _processingService;

  double indicatorValue(
    DataSetModel dataSet,
    DashboardWidgetModel widget, {
    List<DataFilterModel>? globalFilters,
  }) {
    return _processingService.aggregate(
      dataSet,
      columnKey: widget.columnKey,
      aggregation: widget.aggregation,
      filter: widget.filter,
      globalFilters: globalFilters,
    );
  }

  List<ChartPointModel> chartPoints(
    DataSetModel dataSet,
    DashboardWidgetModel widget, {
    List<DataFilterModel>? globalFilters,
  }) {
    return _processingService.groupedAggregation(
      dataSet: dataSet,
      valueColumnKey: widget.columnKey,
      aggregation: widget.aggregation,
      filter: widget.filter,
      globalFilters: globalFilters,
    );
  }

  List<Map<String, dynamic>> summaryRows(
    DataSetModel dataSet, {
    List<DataFilterModel>? globalFilters,
  }) {
    return _processingService.summaryRows(dataSet, extraFilters: globalFilters);
  }
}
