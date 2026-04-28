import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../core/app_controller.dart';
import '../../../core/utils/app_illustrations.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/utils/page_tutorial_mixin.dart';
import '../../../core/utils/tutorial_ids.dart';
import '../../../data/models/data_filter_model.dart';
import '../../../data/models/data_set_model.dart';
import '../../../data/services/data_processing_service.dart';
import '../../../shared/widgets/app_page_background.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_panel.dart';

class DataPreviewPage extends StatefulWidget {
  const DataPreviewPage({super.key, required this.args});

  final DataPreviewArgs args;

  @override
  State<DataPreviewPage> createState() => _DataPreviewPageState();
}

class _DataPreviewPageState extends State<DataPreviewPage>
    with PageTutorialMixin<DataPreviewPage> {
  final GlobalKey<State<StatefulWidget>> _summaryShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _columnsShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _filtersShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _createDashboardShowcaseKey =
      GlobalKey();

  DataSetModel? _dataSet;
  String? _selectedFilterColumn;
  FilterOperator _selectedOperator = FilterOperator.contains;
  final TextEditingController _filterValueController = TextEditingController();

  @override
  String get tutorialId => TutorialIds.dataPreview;

  @override
  List<GlobalKey<State<StatefulWidget>>> get tutorialKeys => [
    _summaryShowcaseKey,
    _columnsShowcaseKey,
    _filtersShowcaseKey,
    _createDashboardShowcaseKey,
  ];

  @override
  void initState() {
    super.initState();
    final loaded = context.read<AppController>().dataSetById(
      widget.args.dataSetId,
    );
    _dataSet = loaded;
    _selectedFilterColumn = loaded?.visibleColumns.isNotEmpty == true
        ? loaded!.visibleColumns.first.key
        : null;
  }

  @override
  void dispose() {
    _filterValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataSet = _dataSet;
    final processing = context.read<DataProcessingService>();

    if (dataSet == null) {
      return const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: EmptyState(
              title: 'Arquivo não encontrado',
              subtitle:
                  'Selecione novamente o arquivo para visualizar os dados.',
              illustrationAsset: AppIllustrations.error,
              withCard: true,
            ),
          ),
        ),
      );
    }

    final filteredRows = processing.applyFilters(dataSet);
    final previewRows = filteredRows.take(12).toList();
    final visibleColumns = dataSet.visibleColumns;
    final visibleKeys = visibleColumns.map((column) => column.key).toSet();
    final safeSelectedFilterColumn = visibleKeys.contains(_selectedFilterColumn)
        ? _selectedFilterColumn
        : (visibleColumns.isNotEmpty ? visibleColumns.first.key : null);

    if (safeSelectedFilterColumn != _selectedFilterColumn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _selectedFilterColumn = safeSelectedFilterColumn);
      });
    }
    maybeStartTutorialOnFirstView();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prévia dos dados'),
        actions: [
          IconButton(
            tooltip: 'Iniciar tutorial',
            onPressed: () => startTutorial(force: true),
            icon: const Icon(Icons.help_outline_rounded),
          ),
        ],
      ),
      body: AppPageBackground(
        padding: EdgeInsets.zero,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            Showcase(
              key: _summaryShowcaseKey,
              title: 'Resumo da base',
              description:
                  'Veja rapidamente nome do arquivo, total de linhas e número de colunas.',
              tooltipPosition: TooltipPosition.bottom,
              child: SectionPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumo da base',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      runSpacing: 8,
                      spacing: 10,
                      children: [
                        _InfoChip(label: 'Arquivo', value: dataSet.fileName),
                        _InfoChip(
                          label: 'Linhas',
                          value: '${dataSet.rows.length}',
                        ),
                        _InfoChip(
                          label: 'Colunas',
                          value: '${dataSet.columnCount}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Showcase(
              key: _columnsShowcaseKey,
              title: 'Ajuste de colunas',
              description:
                  'Renomeie colunas e marque as que devem ser ignoradas na análise.',
              tooltipPosition: TooltipPosition.bottom,
              child: Text(
                'Colunas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            ...dataSet.columns.map(
              (column) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SectionPanel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: column.label,
                          decoration: const InputDecoration(
                            isDense: true,
                            labelText: 'Nome da coluna',
                          ),
                          onFieldSubmitted: (value) {
                            setState(() {
                              _dataSet = processing.renameColumn(
                                dataSet,
                                column.key,
                                value,
                              );
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          Text(
                            'Ignorar',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(fontSize: 11),
                          ),
                          Switch.adaptive(
                            value: column.ignored,
                            onChanged: (value) {
                              setState(() {
                                final updated = processing.toggleIgnoredColumn(
                                  dataSet,
                                  column.key,
                                  value,
                                );
                                _dataSet = updated;
                                final updatedVisible = updated.visibleColumns;
                                final hasCurrentSelection = updatedVisible.any(
                                  (item) => item.key == _selectedFilterColumn,
                                );
                                _selectedFilterColumn = hasCurrentSelection
                                    ? _selectedFilterColumn
                                    : (updatedVisible.isNotEmpty
                                          ? updatedVisible.first.key
                                          : null);
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('Filtros', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Showcase(
              key: _filtersShowcaseKey,
              title: 'Filtros da base',
              description:
                  'Crie regras para trabalhar apenas com o recorte de dados que você precisa.',
              tooltipPosition: TooltipPosition.bottom,
              child: SectionPanel(
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (_, constraints) {
                        final compact = constraints.maxWidth < 620;
                        final columnField = DropdownButtonFormField<String>(
                          initialValue: safeSelectedFilterColumn,
                          items: [
                            for (final column in dataSet.visibleColumns)
                              DropdownMenuItem(
                                value: column.key,
                                child: Text(column.label),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedFilterColumn = value),
                          decoration: const InputDecoration(
                            labelText: 'Coluna',
                          ),
                        );

                        final operatorField =
                            DropdownButtonFormField<FilterOperator>(
                              initialValue: _selectedOperator,
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
                                setState(() => _selectedOperator = value);
                              },
                              decoration: const InputDecoration(
                                labelText: 'Regra',
                              ),
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

                        final addButton = ElevatedButton.icon(
                          onPressed: () {
                            if (_selectedFilterColumn == null) return;
                            setState(() {
                              _dataSet = processing.addFilter(
                                dataSet,
                                DataFilterModel(
                                  columnKey: _selectedFilterColumn!,
                                  operator: _selectedOperator,
                                  value: _filterValueController.text,
                                ),
                              );
                              _filterValueController.clear();
                            });
                          },
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Adicionar'),
                        );

                        if (compact) {
                          return Column(
                            children: [
                              valueField,
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: addButton,
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: valueField),
                            const SizedBox(width: 8),
                            addButton,
                          ],
                        );
                      },
                    ),
                    if (dataSet.filters.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (var i = 0; i < dataSet.filters.length; i++)
                            InputChip(
                              label: Text(
                                '${dataSet.filters[i].columnKey} ${_operatorLabel(dataSet.filters[i].operator)} ${dataSet.filters[i].value}',
                              ),
                              onDeleted: () {
                                setState(() {
                                  _dataSet = processing.removeFilterAt(
                                    dataSet,
                                    i,
                                  );
                                });
                              },
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Prévia da tabela',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (previewRows.isEmpty || visibleColumns.isEmpty)
              const EmptyState(
                title: 'Sem linhas para exibir',
                subtitle: 'Ajuste filtros ou colunas.',
                illustrationAsset: AppIllustrations.empty,
              )
            else
              SectionPanel(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 30,
                    dataRowMinHeight: 32,
                    dataRowMaxHeight: 36,
                    horizontalMargin: 8,
                    columnSpacing: 10,
                    columns: visibleColumns
                        .map(
                          (column) => DataColumn(
                            label: Text(
                              column.label,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        )
                        .toList(),
                    rows: previewRows
                        .map(
                          (row) => DataRow(
                            cells: visibleColumns
                                .map(
                                  (column) => DataCell(
                                    SizedBox(
                                      width: 90,
                                      child: Text(
                                        row[column.key]?.toString() ?? '-',
                                        style: const TextStyle(fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
          ],
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
                      onPressed: _saveChanges,
                      child: const Text('Salvar ajustes'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: Showcase(
                      key: _createDashboardShowcaseKey,
                      title: 'Criar dashboard',
                      description:
                          'Depois dos ajustes, crie o dashboard para montar seus widgets.',
                      tooltipPosition: TooltipPosition.top,
                      child: ElevatedButton(
                        onPressed: _createDashboard,
                        child: const Text('Criar dashboard'),
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
                    onPressed: _saveChanges,
                    child: const Text('Salvar ajustes'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Showcase(
                    key: _createDashboardShowcaseKey,
                    title: 'Criar dashboard',
                    description:
                        'Depois dos ajustes, crie o dashboard para montar seus widgets.',
                    tooltipPosition: TooltipPosition.top,
                    child: ElevatedButton(
                      onPressed: _createDashboard,
                      child: const Text('Criar dashboard'),
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

  Future<void> _saveChanges() async {
    if (_dataSet == null) return;
    await context.read<AppController>().saveImportedDataSet(_dataSet!);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Ajustes salvos.')));
  }

  Future<void> _createDashboard() async {
    if (_dataSet == null) return;

    final controller = context.read<AppController>();
    await controller.saveImportedDataSet(_dataSet!);
    final dashboard = await controller.createDashboard(dataSetId: _dataSet!.id);
    if (!mounted) return;

    Navigator.pushNamed(
      context,
      AppRoutes.dashboardEditor,
      arguments: DashboardEditorArgs(dashboard.id),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.72),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
