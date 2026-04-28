class AppRoutes {
  static const String splash = '/';
  static const String shell = '/shell';
  static const String importFile = '/import';
  static const String dataPreview = '/data-preview';
  static const String dashboardEditor = '/dashboard-editor';
  static const String widgetConfig = '/widget-config';
  static const String dashboardView = '/dashboard-view';
  static const String export = '/export';
  static const String staticExample = '/static-example';
}

class DataPreviewArgs {
  const DataPreviewArgs(this.dataSetId);
  final String dataSetId;
}

class DashboardEditorArgs {
  const DashboardEditorArgs(this.dashboardId);
  final String dashboardId;
}

class WidgetConfigArgs {
  const WidgetConfigArgs({required this.dashboardId, this.widgetId});
  final String dashboardId;
  final String? widgetId;
}

class DashboardViewArgs {
  const DashboardViewArgs(this.dashboardId);
  final String dashboardId;
}

class ExportArgs {
  const ExportArgs(this.dashboardId);
  final String dashboardId;
}
