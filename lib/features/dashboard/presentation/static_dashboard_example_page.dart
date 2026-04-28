import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/page_tutorial_mixin.dart';
import '../../../core/utils/tutorial_ids.dart';
import '../../../shared/widgets/app_page_background.dart';
import '../../../shared/widgets/section_panel.dart';

class StaticDashboardExamplePage extends StatefulWidget {
  const StaticDashboardExamplePage({super.key});

  @override
  State<StaticDashboardExamplePage> createState() =>
      _StaticDashboardExamplePageState();
}

class _StaticDashboardExamplePageState extends State<StaticDashboardExamplePage>
    with PageTutorialMixin<StaticDashboardExamplePage> {
  final GlobalKey<State<StatefulWidget>> _kpisShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _chartShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _tableShowcaseKey = GlobalKey();

  @override
  String get tutorialId => TutorialIds.staticDashboardExample;

  @override
  List<GlobalKey<State<StatefulWidget>>> get tutorialKeys => [
    _kpisShowcaseKey,
    _chartShowcaseKey,
    _tableShowcaseKey,
  ];

  @override
  Widget build(BuildContext context) {
    maybeStartTutorialOnFirstView();
    const monthlyRevenue = <double>[
      96,
      102,
      109,
      117,
      125,
      121,
      128,
      136,
      141,
      148,
      152,
      160,
    ];

    const regionData = <_CategoryPoint>[
      _CategoryPoint('Norte', 38),
      _CategoryPoint('Sul', 49),
      _CategoryPoint('Leste', 42),
      _CategoryPoint('Oeste', 31),
    ];

    const channelShare = <_CategoryPoint>[
      _CategoryPoint('E-commerce', 46),
      _CategoryPoint('App', 28),
      _CategoryPoint('Marketplace', 17),
      _CategoryPoint('Loja Física', 9),
    ];

    const topProducts = <List<String>>[
      ['A-102', 'Assinatura Pro', 'R\$ 248.300', '23,4%'],
      ['A-214', 'Módulo BI', 'R\$ 194.110', '18,3%'],
      ['A-109', 'Pacote Starter', 'R\$ 157.640', '14,8%'],
      ['A-301', 'Consultoria', 'R\$ 132.220', '12,4%'],
      ['A-187', 'Licença Time', 'R\$ 96.840', '9,1%'],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Exemplo'),
        actions: [
          IconButton(
            tooltip: 'Iniciar tutorial',
            onPressed: () => startTutorial(force: true),
            icon: const Icon(Icons.help_outline_rounded),
          ),
        ],
      ),
      body: AppPageScrollView(
        children: [
          const SectionPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumo Executivo de Vendas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Visão geral mensal com indicadores estratégicos.',
                  style: TextStyle(color: AppColors.mutedText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Showcase(
            key: _kpisShowcaseKey,
            title: 'Indicadores principais',
            description:
                'Estes cards resumem os KPIs mais importantes do dashboard.',
            tooltipPosition: TooltipPosition.bottom,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 650;
                final cardWidth = wide
                    ? (constraints.maxWidth - 12) / 2
                    : (constraints.maxWidth - 12) / 2;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      const [
                        _KpiCard(
                          title: 'Receita Total',
                          value: 'R\$ 1,88 Mi',
                          trend: '+12,4% vs mês anterior',
                          positive: true,
                        ),
                        _KpiCard(
                          title: 'Pedidos',
                          value: '12.430',
                          trend: '+6,1% no período',
                          positive: true,
                        ),
                        _KpiCard(
                          title: 'Ticket Médio',
                          value: 'R\$ 151,12',
                          trend: '-2,3% de variação',
                          positive: false,
                        ),
                        _KpiCard(
                          title: 'Conversão',
                          value: '3,8%',
                          trend: '+0,4 p.p.',
                          positive: true,
                        ),
                      ].map((card) {
                        return SizedBox(width: cardWidth, child: card);
                      }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Showcase(
            key: _chartShowcaseKey,
            title: 'Tendência de receita',
            description:
                'O gráfico de linha mostra a evolução mensal para facilitar análise de tendência.',
            tooltipPosition: TooltipPosition.bottom,
            child: SectionPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Evolução de Receita',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Jan - Dez (R\$ mil)',
                    style: TextStyle(color: AppColors.mutedText, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 190,
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: 11,
                        minY: 80,
                        maxY: 170,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) => const FlLine(
                            color: AppColors.border,
                            strokeWidth: 0.8,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineTouchData: LineTouchData(enabled: false),
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
                              reservedSize: 24,
                              getTitlesWidget: (value, _) {
                                const months = [
                                  'Jan',
                                  'Fev',
                                  'Mar',
                                  'Abr',
                                  'Mai',
                                  'Jun',
                                  'Jul',
                                  'Ago',
                                  'Set',
                                  'Out',
                                  'Nov',
                                  'Dez',
                                ];
                                final index = value.toInt();
                                if (index < 0 || index > 11) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    months[index],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.mutedText,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primary.withValues(alpha: 0.10),
                            ),
                            spots: [
                              for (var i = 0; i < monthlyRevenue.length; i++)
                                FlSpot(i.toDouble(), monthlyRevenue[i]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (_, constraints) {
              final wide = constraints.maxWidth > 720;
              if (!wide) {
                return Column(
                  children: [
                    _regionCard(regionData),
                    const SizedBox(height: 12),
                    _channelCard(channelShare),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _regionCard(regionData)),
                  const SizedBox(width: 12),
                  Expanded(child: _channelCard(channelShare)),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Showcase(
            key: _tableShowcaseKey,
            title: 'Tabela de produtos',
            description:
                'Detalhe final com ranking dos produtos para análise operacional.',
            tooltipPosition: TooltipPosition.top,
            child: SectionPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Principais Produtos',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 30,
                      dataRowMinHeight: 32,
                      dataRowMaxHeight: 36,
                      horizontalMargin: 8,
                      columnSpacing: 18,
                      columns: const [
                        DataColumn(
                          label: Text('SKU', style: TextStyle(fontSize: 11)),
                        ),
                        DataColumn(
                          label: Text(
                            'Produto',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Receita',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Participação',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                      rows: topProducts
                          .map(
                            (row) => DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    row[0],
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    row[1],
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    row[2],
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    row[3],
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _regionCard(List<_CategoryPoint> points) {
    final maxValue = points
        .map((point) => point.value)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return SectionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Receita por Região',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 190,
            child: BarChart(
              BarChartData(
                maxY: maxValue + 10,
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: false),
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
                      reservedSize: 24,
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
                          toY: points[i].value.toDouble(),
                          width: 18,
                          borderRadius: BorderRadius.circular(4),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _channelCard(List<_CategoryPoint> points) {
    final total = points.fold<double>(0, (acc, point) => acc + point.value);
    final colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.primaryMuted,
      AppColors.accentSoft,
    ];

    return SectionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mix de Canais',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 190,
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
                            value: points[i].value.toDouble(),
                            color: colors[i % colors.length],
                            radius: 44,
                            title: total == 0
                                ? '0%'
                                : '${((points[i].value / total) * 100).toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < points.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
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
                                  '${points[i].label} (${points[i].value.toStringAsFixed(0)}%)',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.mutedText,
                                  ),
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
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.positive,
  });

  final String title;
  final String value;
  final String trend;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return SectionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.bodySmall?.copyWith(fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                positive
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 14,
                color: positive ? const Color(0xFF067647) : AppColors.danger,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 11,
                    color: positive
                        ? const Color(0xFF067647)
                        : AppColors.danger,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryPoint {
  const _CategoryPoint(this.label, this.value);

  final String label;
  final double value;
}
