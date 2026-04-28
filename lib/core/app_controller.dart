import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/models/dashboard_model.dart';
import '../data/models/dashboard_widget_model.dart';
import '../data/models/data_set_model.dart';
import '../data/repositories/dashboard_repository.dart';
import '../data/repositories/import_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/services/dashboard_pdf_service.dart';
import '../data/services/file_import_service.dart';
import '../data/services/sample_data_service.dart';

class AppController extends ChangeNotifier {
  AppController({
    required ImportRepository importRepository,
    required DashboardRepository dashboardRepository,
    required SettingsRepository settingsRepository,
    required FileImportService fileImportService,
    required SampleDataService sampleDataService,
    required DashboardPdfService dashboardPdfService,
  }) : _importRepository = importRepository,
       _dashboardRepository = dashboardRepository,
       _settingsRepository = settingsRepository,
       _fileImportService = fileImportService,
       _sampleDataService = sampleDataService,
       _dashboardPdfService = dashboardPdfService;

  final ImportRepository _importRepository;
  final DashboardRepository _dashboardRepository;
  final SettingsRepository _settingsRepository;
  final FileImportService _fileImportService;
  final SampleDataService _sampleDataService;
  final DashboardPdfService _dashboardPdfService;
  final Uuid _uuid = const Uuid();

  bool isLoading = false;
  String? error;
  ThemeMode themeMode = ThemeMode.light;
  Set<String> _seenTutorials = <String>{};

  List<DataSetModel> imports = const [];
  List<DashboardModel> dashboards = const [];

  bool hasSeenTutorial(String tutorialId) {
    return _seenTutorials.contains(tutorialId);
  }

  Future<void> bootstrap() async {
    isLoading = true;
    notifyListeners();

    try {
      themeMode = _settingsRepository.getThemeMode();
      _seenTutorials = _settingsRepository.getSeenTutorials();
      imports = _importRepository.getAll();
      dashboards = _dashboardRepository.getAll();

      if (imports.isEmpty) {
        final sample = _sampleDataService.build();
        await _importRepository.save(sample);
        imports = _importRepository.getAll();
      }
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
    await _settingsRepository.saveThemeMode(mode);
  }

  Future<void> setTutorialSeen(String tutorialId) async {
    final id = tutorialId.trim();
    if (id.isEmpty || _seenTutorials.contains(id)) return;

    _seenTutorials = {..._seenTutorials, id};
    notifyListeners();
    await _settingsRepository.saveSeenTutorials(_seenTutorials);
  }

  Future<DataSetModel> importFile() async {
    try {
      final dataSet = await _fileImportService.pickAndParseFile();
      await _importRepository.save(dataSet);
      imports = _importRepository.getAll();
      notifyListeners();
      return dataSet;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> saveImportedDataSet(DataSetModel dataSet) async {
    await _importRepository.save(dataSet);
    imports = _importRepository.getAll();
    notifyListeners();
  }

  Future<void> deleteImportedDataSet(String id) async {
    await _importRepository.delete(id);
    imports = _importRepository.getAll();

    final relatedDashboards = dashboards
        .where((dash) => dash.dataSetId == id)
        .toList();
    for (final dashboard in relatedDashboards) {
      await _dashboardRepository.delete(dashboard.id);
    }

    dashboards = _dashboardRepository.getAll();
    notifyListeners();
  }

  DataSetModel? dataSetById(String id) {
    return imports.firstWhereOrNull((item) => item.id == id) ??
        _importRepository.getById(id);
  }

  Future<DashboardModel> createDashboard({
    required String dataSetId,
    String? name,
  }) async {
    final dashboard = DashboardModel(
      id: _uuid.v4(),
      name: name?.trim().isEmpty == false
          ? name!.trim()
          : 'Dashboard ${dashboards.length + 1}',
      dataSetId: dataSetId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      widgets: const [],
    );

    await _dashboardRepository.save(dashboard);
    dashboards = _dashboardRepository.getAll();
    notifyListeners();
    return dashboard;
  }

  Future<void> saveDashboard(DashboardModel dashboard) async {
    final updated = dashboard.copyWith(updatedAt: DateTime.now());
    await _dashboardRepository.save(updated);
    dashboards = _dashboardRepository.getAll();
    notifyListeners();
  }

  Future<void> deleteDashboard(String id) async {
    await _dashboardRepository.delete(id);
    dashboards = _dashboardRepository.getAll();
    notifyListeners();
  }

  DashboardModel? dashboardById(String id) {
    return dashboards.firstWhereOrNull((item) => item.id == id) ??
        _dashboardRepository.getById(id);
  }

  Future<Uint8List> buildDashboardPdf(DashboardModel dashboard) async {
    final dataSet = dataSetById(dashboard.dataSetId);
    if (dataSet == null) {
      throw StateError('Dataset do dashboard não encontrado.');
    }

    return _dashboardPdfService.buildPdf(
      dashboard: dashboard,
      dataSet: dataSet,
    );
  }

  Future<File> saveDashboardPdf(DashboardModel dashboard) async {
    final bytes = await buildDashboardPdf(dashboard);
    return _dashboardPdfService.savePdf(bytes, dashboard.name);
  }

  Future<DashboardModel> upsertWidget({
    required DashboardModel dashboard,
    required DashboardWidgetModel widget,
  }) async {
    final widgets = List<DashboardWidgetModel>.from(dashboard.widgets);
    final index = widgets.indexWhere((item) => item.id == widget.id);

    if (index == -1) {
      widgets.add(widget);
    } else {
      widgets[index] = widget;
    }

    final updated = dashboard.copyWith(
      widgets: widgets,
      updatedAt: DateTime.now(),
    );
    await saveDashboard(updated);
    return updated;
  }

  Future<DashboardModel> removeWidget({
    required DashboardModel dashboard,
    required String widgetId,
  }) async {
    final widgets = dashboard.widgets
        .where((widget) => widget.id != widgetId)
        .toList();
    final updated = dashboard.copyWith(
      widgets: widgets,
      updatedAt: DateTime.now(),
    );
    await saveDashboard(updated);
    return updated;
  }

  Future<DashboardModel> reorderWidgets({
    required DashboardModel dashboard,
    required int oldIndex,
    required int newIndex,
  }) async {
    final widgets = List<DashboardWidgetModel>.from(dashboard.widgets);

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = widgets.removeAt(oldIndex);
    widgets.insert(newIndex, item);

    final updated = dashboard.copyWith(
      widgets: widgets,
      updatedAt: DateTime.now(),
    );
    await saveDashboard(updated);
    return updated;
  }
}
