import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../core/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_illustrations.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/utils/page_tutorial_mixin.dart';
import '../../../core/utils/tutorial_ids.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/models/dashboard_widget_model.dart';
import '../../../data/services/dashboard_metrics_service.dart';
import '../../../shared/widgets/app_page_background.dart';
import '../../../shared/widgets/dashboard_widget_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_panel.dart';

class DashboardEditorPage extends StatefulWidget {
  const DashboardEditorPage({super.key, required this.args});

  final DashboardEditorArgs args;

  @override
  State<DashboardEditorPage> createState() => _DashboardEditorPageState();
}

class _DashboardEditorPageState extends State<DashboardEditorPage>
    with PageTutorialMixin<DashboardEditorPage> {
  final GlobalKey<State<StatefulWidget>> _dataSetShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _widgetsShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _emptyWidgetsShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _addWidgetShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _exportShowcaseKey = GlobalKey();

  DashboardModel? _dashboard;
  bool _hasWidgets = false;

  @override
  String get tutorialId => TutorialIds.dashboardEditor;

  @override
  List<GlobalKey<State<StatefulWidget>>> get tutorialKeys => [
    _dataSetShowcaseKey,
    _hasWidgets ? _widgetsShowcaseKey : _emptyWidgetsShowcaseKey,
    _addWidgetShowcaseKey,
    _exportShowcaseKey,
  ];

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
              withCard: true,
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
              withCard: true,
            ),
          ),
        ),
      );
    }
    _hasWidgets = dashboard.widgets.isNotEmpty;
    maybeStartTutorialOnFirstView();

    return Scaffold(
      appBar: AppBar(
        title: Text(dashboard.name),
        actions: [
          IconButton(
            onPressed: _renameDashboard,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Iniciar tutorial',
            onPressed: () => startTutorial(force: true),
            icon: const Icon(Icons.help_outline_rounded),
          ),
        ],
      ),
      body: AppPageBackground(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          children: [
            Showcase(
              key: _dataSetShowcaseKey,
              title: 'Base vinculada',
              description:
                  'Aqui você vê qual base está ligada ao dashboard e quantos widgets existem.',
              tooltipPosition: TooltipPosition.bottom,
              child: SectionPanel(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.14,
                      ),
                      child: const Icon(
                        Icons.storage_outlined,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Base: ${dataSet.fileName}',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${dashboard.widgets.length} widgets',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: dashboard.widgets.isEmpty
                  ? Showcase(
                      key: _emptyWidgetsShowcaseKey,
                      title: 'Sem widgets',
                      description:
                          'Use o botão de adicionar para criar indicadores e gráficos.',
                      tooltipPosition: TooltipPosition.top,
                      child: const _DashboardEditorEmpty(),
                    )
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
                        final card = Padding(
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

                        if (index == 0) {
                          return Showcase(
                            key: _widgetsShowcaseKey,
                            title: 'Widgets do dashboard',
                            description:
                                'Toque para editar, arraste para reordenar e remova quando necessário.',
                            tooltipPosition: TooltipPosition.top,
                            child: card,
                          );
                        }

                        return card;
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Showcase(
        key: _addWidgetShowcaseKey,
        title: 'Adicionar widget',
        description:
            'Crie novos indicadores e gráficos para montar seu dashboard.',
        tooltipPosition: TooltipPosition.top,
        child: FloatingActionButton.extended(
          onPressed: () => _configureWidget(),
          icon: const Icon(Icons.add),
          label: const Text('Widget'),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: LayoutBuilder(
          builder: (_, constraints) {
            final compact = constraints.maxWidth < 500;
            if (compact) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
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
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Showcase(
                      key: _exportShowcaseKey,
                      title: 'Exportar dashboard',
                      description:
                          'Gere PDF do painel para imprimir, salvar ou compartilhar.',
                      tooltipPosition: TooltipPosition.top,
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
                  ),
                ],
              );
            }

            return Row(
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
                  child: Showcase(
                    key: _exportShowcaseKey,
                    title: 'Exportar dashboard',
                    description:
                        'Gere PDF do painel para imprimir, salvar ou compartilhar.',
                    tooltipPosition: TooltipPosition.top,
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
                ),
              ],
            );
          },
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
    return Center(
      child: EmptyState(
        title: 'Sem widgets no dashboard',
        subtitle: 'Adicione indicadores e gráficos para começar sua análise.',
        illustrationAsset: AppIllustrations.empty,
        illustrationHeight: 160,
      ),
    );
  }
}
