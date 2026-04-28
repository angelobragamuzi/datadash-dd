import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/dashboard_widget_model.dart';
import '../../data/models/data_filter_model.dart';
import '../../data/models/data_set_model.dart';
import '../../data/services/dashboard_metrics_service.dart';
import 'section_panel.dart';

class DashboardWidgetCard extends StatelessWidget {
  const DashboardWidgetCard({
    super.key,
    required this.widgetModel,
    required this.dataSet,
    required this.metricsService,
    this.onTap,
    this.onDelete,
    this.compact = false,
    this.globalFilters = const [],
  });

  final DashboardWidgetModel widgetModel;
  final DataSetModel dataSet;
  final DashboardMetricsService metricsService;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool compact;
  final List<DataFilterModel> globalFilters;

  @override
  Widget build(BuildContext context) {
    final content = _buildByType(context);

    return SectionPanel(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widgetModel.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onDelete,
                    icon: const Icon(Icons.close, size: 18),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildByType(BuildContext context) {
    switch (widgetModel.type) {
      case DashboardWidgetType.indicator:
        final value = metricsService.indicatorValue(
          dataSet,
          widgetModel,
          globalFilters: globalFilters,
        );
        return Align(
          alignment: Alignment.centerLeft,
          child: Text(
            Formatters.number(value),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        );
      case DashboardWidgetType.barChart:
        final points = metricsService.chartPoints(
          dataSet,
          widgetModel,
          globalFilters: globalFilters,
        );
        if (points.isEmpty) return const _NoData();
        return SizedBox(
          height: compact ? 150 : 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(enabled: false),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index < 0 || index >= points.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          points[index].label,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.mutedText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < points.length; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: points[i].value,
                        width: 14,
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      case DashboardWidgetType.lineChart:
        final points = metricsService.chartPoints(
          dataSet,
          widgetModel,
          globalFilters: globalFilters,
        );
        if (points.isEmpty) return const _NoData();
        final spots = [
          for (var i = 0; i < points.length; i++)
            FlSpot(i.toDouble(), points[i].value),
        ];
        return SizedBox(
          height: compact ? 150 : 180,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: null,
                getDrawingHorizontalLine: (value) =>
                    const FlLine(color: AppColors.border, strokeWidth: 0.8),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(enabled: false),
              titlesData: const FlTitlesData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.accent,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.accent.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),
        );
      case DashboardWidgetType.pieChart:
        final points = metricsService.chartPoints(
          dataSet,
          widgetModel,
          globalFilters: globalFilters,
        );
        if (points.isEmpty) return const _NoData();
        final total = points.fold<double>(0, (acc, point) => acc + point.value);
        final colors = [
          AppColors.primary,
          AppColors.accent,
          AppColors.primaryMuted,
          AppColors.accentSoft,
          AppColors.primarySoft,
        ];

        return SizedBox(
          height: compact ? 160 : 190,
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 24,
                    sectionsSpace: 2,
                    sections: [
                      for (var i = 0; i < points.length; i++)
                        PieChartSectionData(
                          value: points[i].value,
                          color: colors[i % colors.length],
                          radius: 44,
                          title: total == 0
                              ? '0%'
                              : '${((points[i].value / total) * 100).toStringAsFixed(0)}%',
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 110,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < points.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colors[i % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                points[i].label,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.mutedText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      case DashboardWidgetType.summaryTable:
        final rows = metricsService
            .summaryRows(dataSet, globalFilters: globalFilters)
            .take(5)
            .toList();
        final columns = dataSet.visibleColumns.take(4).toList();
        if (rows.isEmpty || columns.isEmpty) return const _NoData();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 30,
            dataRowMinHeight: 30,
            dataRowMaxHeight: 34,
            horizontalMargin: 8,
            columnSpacing: 12,
            columns: columns
                .map(
                  (column) => DataColumn(
                    label: Text(
                      column.label,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                )
                .toList(),
            rows: rows
                .map(
                  (row) => DataRow(
                    cells: columns
                        .map(
                          (column) => DataCell(
                            Text(
                              row[column.key]?.toString() ?? '-',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        );
    }
  }
}

class _NoData extends StatelessWidget {
  const _NoData();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 90,
      child: Center(
        child: Text('Sem dados', style: TextStyle(color: AppColors.mutedText)),
      ),
    );
  }
}
