import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/app_controller.dart';
import '../../../core/utils/app_illustrations.dart';
import '../../../core/utils/app_routes.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/models/dashboard_widget_model.dart';
import '../../../data/services/dashboard_metrics_service.dart';
import '../../../shared/widgets/dashboard_widget_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_panel.dart';

class DashboardEditorPage extends StatefulWidget {
  const DashboardEditorPage({super.key, required this.args});

  final DashboardEditorArgs args;

  @override
  State<DashboardEditorPage> createState() => _DashboardEditorPageState();
}

class _DashboardEditorPageState extends State<DashboardEditorPage> {
  DashboardModel? _dashboard;

  @override
  void initState() {
    super.initState();
    _dashboard = context.read<AppController>().dashboardById(
      widget.args.dashboardId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final metrics = context.read<DashboardMetricsService>();
    final dashboard =
        _dashboard ?? controller.dashboardById(widget.args.dashboardId);

    if (dashboard == null) {
      return const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: EmptyState(
              title: 'Dashboard não encontrado',
              subtitle: 'Esse dashboard pode ter sido removido.',
              illustrationAsset: AppIllustrations.error,
            ),
          ),
        ),
      );
    }

    _dashboard = dashboard;
    final dataSet = controller.dataSetById(dashboard.dataSetId);

    if (dataSet == null) {
      return const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: EmptyState(
              title: 'Base de dados não encontrada',
              subtitle: 'Reimporte o arquivo e tente novamente.',
              illustrationAsset: AppIllustrations.error,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(dashboard.name),
        actions: [
          IconButton(
            onPressed: _renameDashboard,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          children: [
            SectionPanel(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Base: ${dataSet.fileName}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text('${dashboard.widgets.length} widgets'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: dashboard.widgets.isEmpty
                  ? const _DashboardEditorEmpty()
                  : ReorderableListView.builder(
                      onReorder: (oldIndex, newIndex) async {
                        final updated = await controller.reorderWidgets(
                          dashboard: dashboard,
                          oldIndex: oldIndex,
                          newIndex: newIndex,
                        );
                        setState(() => _dashboard = updated);
                      },
                      itemCount: dashboard.widgets.length,
                      itemBuilder: (_, index) {
                        final item = dashboard.widgets[index];
                        return Padding(
                          key: ValueKey(item.id),
                          padding: const EdgeInsets.only(bottom: 8),
                          child: DashboardWidgetCard(
                            widgetModel: item,
                            dataSet: dataSet,
                            metricsService: metrics,
                            compact: true,
                            onTap: () => _configureWidget(widgetId: item.id),
                            onDelete: () async {
                              final updated = await controller.removeWidget(
                                dashboard: dashboard,
                                widgetId: item.id,
                              );
                              setState(() => _dashboard = updated);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _configureWidget(),
        icon: const Icon(Icons.add),
        label: const Text('Widget'),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.dashboardView,
                    arguments: DashboardViewArgs(dashboard.id),
                  );
                },
                child: const Text('Visualizar'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.export,
                    arguments: ExportArgs(dashboard.id),
                  );
                },
                child: const Text('Exportar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _renameDashboard() async {
    final dashboard = _dashboard;
    if (dashboard == null) return;

    final controller = TextEditingController(text: dashboard.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Renomear dashboard'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (newName == null || newName.trim().isEmpty || !mounted) return;

    final updated = dashboard.copyWith(
      name: newName.trim(),
      updatedAt: DateTime.now(),
    );
    await context.read<AppController>().saveDashboard(updated);
    setState(() => _dashboard = updated);
  }

  Future<void> _configureWidget({String? widgetId}) async {
    final dashboard = _dashboard;
    if (dashboard == null) return;

    final result = await Navigator.pushNamed(
      context,
      AppRoutes.widgetConfig,
      arguments: WidgetConfigArgs(
        dashboardId: dashboard.id,
        widgetId: widgetId,
      ),
    );

    if (result == null || result is! DashboardWidgetModel || !mounted) {
      return;
    }

    final updated = await context.read<AppController>().upsertWidget(
      dashboard: dashboard,
      widget: result,
    );

    setState(() => _dashboard = updated);
  }
}

class _DashboardEditorEmpty extends StatelessWidget {
  const _DashboardEditorEmpty();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 220,
              child: SvgPicture.asset(
                AppIllustrations.empty,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Sem widgets no dashboard',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione indicadores e gráficos para começar sua análise.',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
