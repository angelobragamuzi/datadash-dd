import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_illustrations.dart';
import '../../../core/utils/app_routes.dart';
import '../../../data/models/data_filter_model.dart';
import '../../../data/models/data_set_model.dart';
import '../../../data/services/data_processing_service.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_panel.dart';

class DataPreviewPage extends StatefulWidget {
  const DataPreviewPage({super.key, required this.args});

  final DataPreviewArgs args;

  @override
  State<DataPreviewPage> createState() => _DataPreviewPageState();
}

class _DataPreviewPageState extends State<DataPreviewPage> {
  DataSetModel? _dataSet;
  String? _selectedFilterColumn;
  FilterOperator _selectedOperator = FilterOperator.contains;
  final TextEditingController _filterValueController = TextEditingController();

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

    return Scaffold(
      appBar: AppBar(title: const Text('Prévia dos dados')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          SectionPanel(
            child: Wrap(
              runSpacing: 8,
              spacing: 12,
              children: [
                _InfoChip(label: 'Arquivo', value: dataSet.fileName),
                _InfoChip(label: 'Linhas', value: '${dataSet.rows.length}'),
                _InfoChip(label: 'Colunas', value: '${dataSet.columnCount}'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text('Colunas', style: Theme.of(context).textTheme.titleMedium),
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
                        const Text(
                          'Ignorar',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.mutedText,
                          ),
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
          SectionPanel(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
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
                        decoration: const InputDecoration(labelText: 'Coluna'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<FilterOperator>(
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
                        decoration: const InputDecoration(labelText: 'Regra'),
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
                      child: const Text('Adicionar'),
                    ),
                  ],
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
                              _dataSet = processing.removeFilterAt(dataSet, i);
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ],
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
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saveChanges,
                child: const Text('Salvar ajustes'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _createDashboard,
                child: const Text('Criar dashboard'),
              ),
            ),
          ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.mutedText),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
