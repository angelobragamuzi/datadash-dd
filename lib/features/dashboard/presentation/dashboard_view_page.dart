import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../core/app_controller.dart';
import '../../../core/utils/app_illustrations.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/utils/page_tutorial_mixin.dart';
import '../../../core/utils/tutorial_ids.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/models/data_filter_model.dart';
import '../../../data/services/dashboard_metrics_service.dart';
import '../../../shared/widgets/app_page_background.dart';
import '../../../shared/widgets/dashboard_widget_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_panel.dart';

class DashboardViewPage extends StatefulWidget {
  const DashboardViewPage({super.key, required this.args});

  final DashboardViewArgs args;

  @override
  State<DashboardViewPage> createState() => _DashboardViewPageState();
}

class _DashboardViewPageState extends State<DashboardViewPage>
    with PageTutorialMixin<DashboardViewPage> {
  final GlobalKey<State<StatefulWidget>> _filtersShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _widgetsShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _emptyWidgetsShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _exportShowcaseKey = GlobalKey();

  DashboardModel? _dashboard;

  final TextEditingController _filterValueController = TextEditingController();
  String? _filterColumn;
  FilterOperator _filterOperator = FilterOperator.contains;
  final List<DataFilterModel> _globalFilters = [];
  bool _hasWidgets = false;

  @override
  String get tutorialId => TutorialIds.dashboardView;

  @override
  List<GlobalKey<State<StatefulWidget>>> get tutorialKeys => [
    _filtersShowcaseKey,
    _hasWidgets ? _widgetsShowcaseKey : _emptyWidgetsShowcaseKey,
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
  void dispose() {
    _filterValueController.dispose();
    super.dispose();
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
              subtitle: 'Reimporte o arquivo para atualizar a visualização.',
              illustrationAsset: AppIllustrations.error,
              withCard: true,
            ),
          ),
        ),
      );
    }

    _filterColumn ??= dataSet.visibleColumns.isEmpty
        ? null
        : dataSet.visibleColumns.first.key;
    _hasWidgets = dashboard.widgets.isNotEmpty;
    maybeStartTutorialOnFirstView();

    return Scaffold(
      appBar: AppBar(
        title: Text(dashboard.name),
        actions: [
          IconButton(
            tooltip: 'Atualizar dados',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() {}),
          ),
          IconButton(
            tooltip: 'Exportar',
            icon: Showcase(
              key: _exportShowcaseKey,
              title: 'Exportar relatório',
              description:
                  'Gere PDF da visualização atual para compartilhar os resultados.',
              tooltipPosition: TooltipPosition.bottom,
              child: const Icon(Icons.picture_as_pdf_outlined),
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.export,
                arguments: ExportArgs(dashboard.id),
              );
            },
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
              key: _filtersShowcaseKey,
              title: 'Filtros globais',
              description:
                  'Aplique filtros para atualizar todos os widgets desta visualização.',
              tooltipPosition: TooltipPosition.bottom,
              child: SectionPanel(
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (_, constraints) {
                        final compact = constraints.maxWidth < 620;

                        final columnField = DropdownButtonFormField<String>(
                          initialValue: _filterColumn,
                          decoration: const InputDecoration(
                            labelText: 'Filtro global',
                          ),
                          items: [
                            for (final column in dataSet.visibleColumns)
                              DropdownMenuItem(
                                value: column.key,
                                child: Text(column.label),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _filterColumn = value),
                        );

                        final operatorField =
                            DropdownButtonFormField<FilterOperator>(
                              initialValue: _filterOperator,
                              decoration: const InputDecoration(
                                labelText: 'Operador',
                              ),
                              items: FilterOperator.values
                                  .map(
                                    (operator) => DropdownMenuItem(
                                      value: operator,
                                      child: Text(_operatorLabel(operator)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _filterOperator = value);
                              },
                            );

                        if (compact) {
                          return Column(
                            children: [
                              columnField,
                              const SizedBox(height: 8),
                              operatorField,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: columnField),
                            const SizedBox(width: 8),
                            Expanded(child: operatorField),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (_, constraints) {
                        final compact = constraints.maxWidth < 620;

                        final valueField = TextField(
                          controller: _filterValueController,
                          decoration: const InputDecoration(labelText: 'Valor'),
                        );

                        final applyButton = ElevatedButton.icon(
                          onPressed: () {
                            if (_filterColumn == null) return;
                            if (_filterValueController.text.trim().isEmpty) {
                              return;
                            }

                            setState(() {
                              _globalFilters.add(
                                DataFilterModel(
                                  columnKey: _filterColumn!,
                                  operator: _filterOperator,
                                  value: _filterValueController.text,
                                ),
                              );
                              _filterValueController.clear();
                            });
                          },
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Aplicar'),
                        );

                        if (compact) {
                          return Column(
                            children: [
                              valueField,
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: applyButton,
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: valueField),
                            const SizedBox(width: 8),
                            applyButton,
                          ],
                        );
                      },
                    ),
                    if (_globalFilters.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var i = 0; i < _globalFilters.length; i++)
                            InputChip(
                              label: Text(
                                '${_globalFilters[i].columnKey} ${_operatorLabel(_globalFilters[i].operator)} ${_globalFilters[i].value}',
                              ),
                              onDeleted: () =>
                                  setState(() => _globalFilters.removeAt(i)),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: dashboard.widgets.isEmpty
                  ? Showcase(
                      key: _emptyWidgetsShowcaseKey,
                      title: 'Sem widgets para visualizar',
                      description:
                          'Volte ao editor para adicionar widgets e montar seu painel.',
                      tooltipPosition: TooltipPosition.top,
                      child: const EmptyState(
                        title: 'Sem widgets',
                        subtitle:
                            'Volte ao editor e adicione widgets para visualização.',
                        illustrationAsset: AppIllustrations.empty,
                      ),
                    )
                  : LayoutBuilder(
                      builder: (_, constraints) {
                        final width = constraints.maxWidth;
                        final crossAxisCount = width > 1050
                            ? 3
                            : width > 720
                            ? 2
                            : 1;

                        return GridView.builder(
                          itemCount: dashboard.widgets.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: crossAxisCount == 1
                                    ? 1.05
                                    : 1.12,
                              ),
                          itemBuilder: (_, index) {
                            final widgetModel = dashboard.widgets[index];
                            final card = DashboardWidgetCard(
                              widgetModel: widgetModel,
                              dataSet: dataSet,
                              metricsService: metrics,
                              compact: true,
                              globalFilters: _globalFilters,
                            );

                            if (index == 0) {
                              return Showcase(
                                key: _widgetsShowcaseKey,
                                title: 'Widgets em tempo real',
                                description:
                                    'Cada card representa uma métrica calculada com os filtros atuais.',
                                tooltipPosition: TooltipPosition.top,
                                child: card,
                              );
                            }

                            return card;
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _operatorLabel(FilterOperator operator) {
    switch (operator) {
      case FilterOperator.contains:
        return 'contém';
      case FilterOperator.equals:
        return '=';
      case FilterOperator.greaterThan:
        return '>';
      case FilterOperator.lessThan:
        return '<';
    }
  }
}
