import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/app_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_routes.dart';
import 'core/utils/storage_keys.dart';
import 'data/repositories/dashboard_repository.dart';
import 'data/repositories/import_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/services/dashboard_metrics_service.dart';
import 'data/services/dashboard_pdf_service.dart';
import 'data/services/data_processing_service.dart';
import 'data/services/file_import_service.dart';
import 'data/services/sample_data_service.dart';
import 'features/dashboard/presentation/dashboard_view_page.dart';
import 'features/dashboard/presentation/static_dashboard_example_page.dart';
import 'features/editor/presentation/dashboard_editor_page.dart';
import 'features/editor/presentation/widget_config_page.dart';
import 'features/export/presentation/export_page.dart';
import 'features/home/presentation/home_shell_page.dart';
import 'features/import/presentation/data_preview_page.dart';
import 'features/import/presentation/import_page.dart';
import 'features/splash/presentation/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  final importsBox = await Hive.openBox<String>(StorageKeys.importsBox);
  final dashboardsBox = await Hive.openBox<String>(StorageKeys.dashboardsBox);
  final settingsBox = await Hive.openBox<dynamic>(StorageKeys.settingsBox);

  final dataProcessingService = DataProcessingService();
  final dashboardMetricsService = DashboardMetricsService(
    dataProcessingService,
  );

  final appController = AppController(
    importRepository: ImportRepository(importsBox),
    dashboardRepository: DashboardRepository(dashboardsBox),
    settingsRepository: SettingsRepository(settingsBox),
    fileImportService: FileImportService(dataProcessingService),
    sampleDataService: SampleDataService(dataProcessingService),
    dashboardPdfService: DashboardPdfService(dataProcessingService),
  );

  runApp(
    DataDashApp(
      appController: appController,
      dataProcessingService: dataProcessingService,
      dashboardMetricsService: dashboardMetricsService,
    ),
  );
}

class DataDashApp extends StatelessWidget {
  const DataDashApp({
    super.key,
    required this.appController,
    required this.dataProcessingService,
    required this.dashboardMetricsService,
  });

  final AppController appController;
  final DataProcessingService dataProcessingService;
  final DashboardMetricsService dashboardMetricsService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appController),
        Provider.value(value: dataProcessingService),
        Provider.value(value: dashboardMetricsService),
      ],
      child: Consumer<AppController>(
        builder: (context, controller, _) => MaterialApp(
          title: 'DataDash',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: controller.themeMode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case AppRoutes.splash:
                return MaterialPageRoute(builder: (_) => const SplashPage());
              case AppRoutes.shell:
                return MaterialPageRoute(builder: (_) => const HomeShellPage());
              case AppRoutes.importFile:
                return MaterialPageRoute(builder: (_) => const ImportPage());
              case AppRoutes.dataPreview:
                final args = settings.arguments as DataPreviewArgs;
                return MaterialPageRoute(
                  builder: (_) => DataPreviewPage(args: args),
                );
              case AppRoutes.dashboardEditor:
                final args = settings.arguments as DashboardEditorArgs;
                return MaterialPageRoute(
                  builder: (_) => DashboardEditorPage(args: args),
                );
              case AppRoutes.widgetConfig:
                final args = settings.arguments as WidgetConfigArgs;
                return MaterialPageRoute(
                  builder: (_) => WidgetConfigPage(args: args),
                );
              case AppRoutes.dashboardView:
                final args = settings.arguments as DashboardViewArgs;
                return MaterialPageRoute(
                  builder: (_) => DashboardViewPage(args: args),
                );
              case AppRoutes.export:
                final args = settings.arguments as ExportArgs;
                return MaterialPageRoute(
                  builder: (_) => ExportPage(args: args),
                );
              case AppRoutes.staticExample:
                return MaterialPageRoute(
                  builder: (_) => const StaticDashboardExamplePage(),
                );
              default:
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(
                    body: Center(child: Text('Rota não encontrada.')),
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}
