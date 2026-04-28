import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_controller.dart';
import '../../../core/utils/app_routes.dart';
import '../../../shared/widgets/datadash_logo.dart';
import '../../dashboard/presentation/dashboard_list_page.dart';
import '../../import/presentation/imported_files_page.dart';
import '../../settings/presentation/settings_page.dart';
import 'home_page.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        onImportTap: _openImport,
        onNewDashboardTap: _createDashboard,
        onFilesTap: () => setState(() => _index = 2),
        onExportsTap: _openExportPicker,
        onOpenStaticExample: _openStaticExample,
        onOpenDashboard: _openEditor,
      ),
      DashboardListPage(
        onOpenEditor: _openEditor,
        onOpenView: _openView,
        onOpenExport: _openExport,
        onCreate: _createDashboard,
      ),
      ImportedFilesPage(onImport: _openImport, onOpenPreview: _openPreview),
      const SettingsPage(),
    ];

    const titles = ['Início', 'Dashboards', 'Arquivos', 'Configurações'];

    return Scaffold(
      appBar: AppBar(
        title: _index == 0
            ? const DataDashLogo(size: 42, withGlow: false)
            : Text(titles[_index]),
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboards',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            label: 'Arquivos',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }

  void _openImport() {
    Navigator.pushNamed(context, AppRoutes.importFile);
  }

  void _openPreview(String dataSetId) {
    Navigator.pushNamed(
      context,
      AppRoutes.dataPreview,
      arguments: DataPreviewArgs(dataSetId),
    );
  }

  void _openEditor(String dashboardId) {
    Navigator.pushNamed(
      context,
      AppRoutes.dashboardEditor,
      arguments: DashboardEditorArgs(dashboardId),
    );
  }

  void _openView(String dashboardId) {
    Navigator.pushNamed(
      context,
      AppRoutes.dashboardView,
      arguments: DashboardViewArgs(dashboardId),
    );
  }

  void _openExport(String dashboardId) {
    Navigator.pushNamed(
      context,
      AppRoutes.export,
      arguments: ExportArgs(dashboardId),
    );
  }

  void _openStaticExample() {
    Navigator.pushNamed(context, AppRoutes.staticExample);
  }

  Future<void> _openExportPicker() async {
    final dashboards = context.read<AppController>().dashboards;
    if (dashboards.isEmpty) {
      _showMessage('Nenhum dashboard disponível para exportação.');
      return;
    }

    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: ListView(
            children: [
              for (final dashboard in dashboards)
                ListTile(
                  title: Text(dashboard.name),
                  onTap: () => Navigator.pop(context, dashboard.id),
                ),
            ],
          ),
        );
      },
    );

    if (!mounted || selected == null) return;
    _openExport(selected);
  }

  Future<void> _createDashboard() async {
    final controller = context.read<AppController>();
    if (controller.imports.isEmpty) {
      _showMessage('Importe um arquivo antes de criar dashboard.');
      return;
    }

    String selectedDataSetId = controller.imports.first.id;
    final nameController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Novo dashboard'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedDataSetId,
                    decoration: const InputDecoration(
                      labelText: 'Base de dados',
                    ),
                    items: [
                      for (final item in controller.imports)
                        DropdownMenuItem(
                          value: item.id,
                          child: Text(
                            item.fileName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setStateDialog(() => selectedDataSetId = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome (opcional)',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Criar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final dashboard = await controller.createDashboard(
      dataSetId: selectedDataSetId,
      name: nameController.text,
    );

    if (!mounted) return;
    _openEditor(dashboard.id);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}
