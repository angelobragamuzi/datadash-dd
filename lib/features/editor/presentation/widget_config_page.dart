import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/app_controller.dart';
import '../../../core/utils/app_illustrations.dart';
import '../../../core/utils/app_routes.dart';
import '../../../data/models/dashboard_widget_model.dart';
import '../../../data/models/data_filter_model.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_panel.dart';

class WidgetConfigPage extends StatefulWidget {
  const WidgetConfigPage({super.key, required this.args});

  final WidgetConfigArgs args;

  @override
  State<WidgetConfigPage> createState() => _WidgetConfigPageState();
}

class _WidgetConfigPageState extends State<WidgetConfigPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _filterValueController = TextEditingController();
  final Uuid _uuid = const Uuid();

  DashboardWidgetType _widgetType = DashboardWidgetType.indicator;
  AggregationType _aggregation = AggregationType.sum;
  String? _columnKey;

  bool _filterEnabled = false;
  String? _filterColumn;
  FilterOperator _filterOperator = FilterOperator.contains;

  DashboardWidgetModel? _editingWidget;

  @override
  void initState() {
    super.initState();

    final appController = context.read<AppController>();
    final args = widget.args;

    final dashboard = appController.dashboardById(args.dashboardId);
    final dataSet = dashboard == null
        ? null
        : appController.dataSetById(dashboard.dataSetId);

    if (dashboard == null ||
        dataSet == null ||
        dataSet.visibleColumns.isEmpty) {
      return;
    }

    _columnKey = dataSet.visibleColumns.first.key;
    _filterColumn = dataSet.visibleColumns.first.key;

    if (args.widgetId != null) {
      _editingWidget = dashboard.widgets.firstWhereOrNull(
        (widget) => widget.id == args.widgetId,
      );

      if (_editingWidget != null) {
        _titleController.text = _editingWidget!.title;
        _widgetType = _editingWidget!.type;
        _aggregation = _editingWidget!.aggregation;
        _columnKey = _editingWidget!.columnKey;

        if (_editingWidget!.filter != null) {
          _filterEnabled = true;
          _filterColumn = _editingWidget!.filter!.columnKey;
          _filterOperator = _editingWidget!.filter!.operator;
          _filterValueController.text = _editingWidget!.filter!.value;
        }
      }
    } else {
      _titleController.text = 'Novo widget';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _filterValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appController = context.read<AppController>();
    final args = widget.args;
    final dashboard = appController.dashboardById(args.dashboardId);
    final dataSet = dashboard == null
        ? null
        : appController.dataSetById(dashboard.dataSetId);

    if (dashboard == null ||
        dataSet == null ||
        dataSet.visibleColumns.isEmpty) {
      return const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: EmptyState(
              title: 'Não foi possível configurar o widget',
              subtitle: 'Verifique a base de dados e tente novamente.',
              illustrationAsset: AppIllustrations.error,
            ),
          ),
        ),
      );
    }

    final visibleColumns = dataSet.visibleColumns;
    final visibleKeys = visibleColumns.map((column) => column.key).toSet();
    final safeColumnKey = visibleKeys.contains(_columnKey)
        ? _columnKey
        : visibleColumns.first.key;
    final safeFilterColumn = visibleKeys.contains(_filterColumn)
        ? _filterColumn
        : visibleColumns.first.key;

    if (safeColumnKey != _columnKey || safeFilterColumn != _filterColumn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _columnKey = safeColumnKey;
          _filterColumn = safeFilterColumn;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_editingWidget == null ? 'Novo widget' : 'Editar widget'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          SectionPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título do widget',
                    hintText: 'Ex.: Receita total',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tipo de visualização',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Escolha o formato mais claro para mostrar seu dado.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (_, constraints) {
                    final cardWidth = (constraints.maxWidth - 10) / 2;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: DashboardWidgetType.values.map((type) {
                        return SizedBox(
                          width: cardWidth,
                          child: _WidgetTypeCard(
                            type: type,
                            label: _typeLabel(type),
                            description: _typeDescription(type),
                            selected: _widgetType == type,
                            onTap: () => setState(() => _widgetType = type),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: safeColumnKey,
                  decoration: const InputDecoration(
                    labelText: 'Qual dado você quer analisar?',
                  ),
                  items: [
                    for (final column in visibleColumns)
                      DropdownMenuItem(
                        value: column.key,
                        child: Text(column.label),
                      ),
                  ],
                  onChanged: (value) => setState(() => _columnKey = value),
                ),
                const SizedBox(height: 12),
                Text(
                  'Como resumir esse dado?',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AggregationType.values.map((type) {
                    return ChoiceChip(
                      label: Text(_aggregationLabel(type)),
                      selected: _aggregation == type,
                      onSelected: (_) => setState(() => _aggregation = type),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  _aggregationDescription(_aggregation),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _filterEnabled,
                  onChanged: (value) => setState(() => _filterEnabled = value),
                  title: const Text('Aplicar filtro neste widget'),
                  subtitle: const Text(
                    'Opcional. Use quando quiser mostrar apenas um recorte.',
                  ),
                ),
                if (_filterEnabled) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: safeFilterColumn,
                    decoration: const InputDecoration(
                      labelText: 'Campo do filtro',
                    ),
                    items: [
                      for (final column in visibleColumns)
                        DropdownMenuItem(
                          value: column.key,
                          child: Text(column.label),
                        ),
                    ],
                    onChanged: (value) => setState(() => _filterColumn = value),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<FilterOperator>(
                    initialValue: _filterOperator,
                    decoration: const InputDecoration(labelText: 'Condição'),
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
                  const SizedBox(height: 10),
                  TextField(
                    controller: _filterValueController,
                    decoration: const InputDecoration(
                      labelText: 'Valor do filtro',
                      hintText: 'Ex.: Sul, 2026 ou 1000',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ElevatedButton(
          onPressed: _save,
          child: const Text('Salvar widget'),
        ),
      ),
    );
  }

  void _save() {
    if (_columnKey == null) return;

    final widget = DashboardWidgetModel(
      id: _editingWidget?.id ?? _uuid.v4(),
      title: _titleController.text.trim().isEmpty
          ? 'Widget'
          : _titleController.text.trim(),
      type: _widgetType,
      columnKey: _columnKey!,
      aggregation: _aggregation,
      filter: _filterEnabled && _filterColumn != null
          ? DataFilterModel(
              columnKey: _filterColumn!,
              operator: _filterOperator,
              value: _filterValueController.text,
            )
          : null,
    );

    Navigator.pop(context, widget);
  }

  String _typeLabel(DashboardWidgetType type) {
    switch (type) {
      case DashboardWidgetType.indicator:
        return 'Indicador';
      case DashboardWidgetType.barChart:
        return 'Gráfico de barras';
      case DashboardWidgetType.lineChart:
        return 'Gráfico de linhas';
      case DashboardWidgetType.pieChart:
        return 'Gráfico de pizza';
      case DashboardWidgetType.summaryTable:
        return 'Tabela resumida';
    }
  }

  String _typeDescription(DashboardWidgetType type) {
    switch (type) {
      case DashboardWidgetType.indicator:
        return 'Mostra um número principal';
      case DashboardWidgetType.barChart:
        return 'Compara categorias';
      case DashboardWidgetType.lineChart:
        return 'Mostra evolução no tempo';
      case DashboardWidgetType.pieChart:
        return 'Mostra participação percentual';
      case DashboardWidgetType.summaryTable:
        return 'Exibe linhas resumidas';
    }
  }

  String _aggregationLabel(AggregationType type) {
    switch (type) {
      case AggregationType.sum:
        return 'Soma';
      case AggregationType.average:
        return 'Média';
      case AggregationType.count:
        return 'Contagem';
      case AggregationType.min:
        return 'Mínimo';
      case AggregationType.max:
        return 'Máximo';
    }
  }

  String _aggregationDescription(AggregationType type) {
    switch (type) {
      case AggregationType.sum:
        return 'Soma todos os valores da coluna selecionada.';
      case AggregationType.average:
        return 'Calcula a média dos valores da coluna.';
      case AggregationType.count:
        return 'Conta quantos registros existem no recorte.';
      case AggregationType.min:
        return 'Mostra o menor valor encontrado.';
      case AggregationType.max:
        return 'Mostra o maior valor encontrado.';
    }
  }

  String _operatorLabel(FilterOperator operator) {
    switch (operator) {
      case FilterOperator.contains:
        return 'Contém';
      case FilterOperator.equals:
        return 'É igual a';
      case FilterOperator.greaterThan:
        return 'Maior que';
      case FilterOperator.lessThan:
        return 'Menor que';
    }
  }
}

class _WidgetTypeCard extends StatelessWidget {
  const _WidgetTypeCard({
    required this.type,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final DashboardWidgetType type;
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primaryContainer.withValues(alpha: 0.45)
              : scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 72,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primaryContainer.withValues(alpha: 0.68)
                    : scheme.surfaceContainerHighest.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _WidgetTypePreview(type: type, selected: selected),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              description,
              style: textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _WidgetTypePreview extends StatelessWidget {
  const _WidgetTypePreview({required this.type, required this.selected});

  final DashboardWidgetType type;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    switch (type) {
      case DashboardWidgetType.indicator:
        return Center(
          child: Text(
            '124.500',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
        );
      case DashboardWidgetType.barChart:
        return BarChart(
          BarChartData(
            barTouchData: BarTouchData(enabled: false),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            barGroups: [
              for (var i = 0; i < 4; i++)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: [4.5, 7.2, 5.8, 8.6][i],
                      width: 8,
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
            ],
          ),
        );
      case DashboardWidgetType.lineChart:
        return LineChart(
          LineChartData(
            lineTouchData: LineTouchData(enabled: false),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: scheme.secondary,
                barWidth: 2,
                dotData: const FlDotData(show: false),
                spots: const [
                  FlSpot(0, 3),
                  FlSpot(1, 5),
                  FlSpot(2, 4.2),
                  FlSpot(3, 6.4),
                  FlSpot(4, 5.6),
                ],
              ),
            ],
          ),
        );
      case DashboardWidgetType.pieChart:
        return PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 16,
            sections: [
              PieChartSectionData(
                value: 40,
                color: scheme.primary,
                title: '',
                radius: 20,
              ),
              PieChartSectionData(
                value: 28,
                color: scheme.secondary,
                title: '',
                radius: 20,
              ),
              PieChartSectionData(
                value: 20,
                color: scheme.tertiary,
                title: '',
                radius: 20,
              ),
              PieChartSectionData(
                value: 12,
                color: scheme.primaryContainer,
                title: '',
                radius: 20,
              ),
            ],
          ),
        );
      case DashboardWidgetType.summaryTable:
        return Column(
          children: [
            _previewRow(context, selected: true),
            const SizedBox(height: 4),
            _previewRow(context),
            const SizedBox(height: 4),
            _previewRow(context),
          ],
        );
    }
  }

  Widget _previewRow(BuildContext context, {bool selected = false}) {
    final scheme = Theme.of(context).colorScheme;
    final selectedColor = scheme.primaryContainer.withValues(alpha: 0.72);
    final defaultColor = scheme.surfaceContainerHighest.withValues(alpha: 0.82);

    return Expanded(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: selected ? selectedColor : defaultColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: selected ? selectedColor : defaultColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: selected ? selectedColor : defaultColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
