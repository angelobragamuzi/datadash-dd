import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_controller.dart';
import '../../../core/utils/app_illustrations.dart';
import '../../../core/utils/app_routes.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../data/models/data_filter_model.dart';
import '../../../data/services/dashboard_metrics_service.dart';
import '../../../shared/widgets/dashboard_widget_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_panel.dart';

class DashboardViewPage extends StatefulWidget {
  const DashboardViewPage({super.key, required this.args});

  final DashboardViewArgs args;

  @override
  State<DashboardViewPage> createState() => _DashboardViewPageState();
}

class _DashboardViewPageState extends State<DashboardViewPage> {
  DashboardModel? _dashboard;

  final TextEditingController _filterValueController = TextEditingController();
  String? _filterColumn;
  FilterOperator _filterOperator = FilterOperator.contains;
  final List<DataFilterModel> _globalFilters = [];

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
            ),
          ),
        ),
      );
    }

    _filterColumn ??= dataSet.visibleColumns.isEmpty
        ? null
        : dataSet.visibleColumns.first.key;

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
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.export,
                arguments: ExportArgs(dashboard.id),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          children: [
            SectionPanel(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
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
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<FilterOperator>(
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _filterValueController,
                          decoration: const InputDecoration(labelText: 'Valor'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
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
                        child: const Text('Aplicar'),
                      ),
                    ],
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
            const SizedBox(height: 12),
            Expanded(
              child: dashboard.widgets.isEmpty
                  ? const EmptyState(
                      title: 'Sem widgets',
                      subtitle:
                          'Volte ao editor e adicione widgets para visualização.',
                      illustrationAsset: AppIllustrations.empty,
                    )
                  : LayoutBuilder(
                      builder: (_, constraints) {
                        final wide = constraints.maxWidth > 760;
                        final crossAxisCount = wide ? 2 : 1;

                        return GridView.builder(
                          itemCount: dashboard.widgets.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: wide ? 1.15 : 1.05,
                              ),
                          itemBuilder: (_, index) {
                            final widgetModel = dashboard.widgets[index];
                            return DashboardWidgetCard(
                              widgetModel: widgetModel,
                              dataSet: dataSet,
                              metricsService: metrics,
                              compact: true,
                              globalFilters: _globalFilters,
                            );
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
