import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../core/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_illustrations.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/page_tutorial_mixin.dart';
import '../../../core/utils/tutorial_ids.dart';
import '../../../shared/widgets/app_page_background.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_panel.dart';

class DashboardListPage extends StatefulWidget {
  const DashboardListPage({
    super.key,
    required this.onOpenEditor,
    required this.onOpenView,
    required this.onOpenExport,
    required this.onCreate,
  });

  final ValueChanged<String> onOpenEditor;
  final ValueChanged<String> onOpenView;
  final ValueChanged<String> onOpenExport;
  final VoidCallback onCreate;

  @override
  State<DashboardListPage> createState() => DashboardListPageState();
}

class DashboardListPageState extends State<DashboardListPage>
    with PageTutorialMixin<DashboardListPage> {
  final GlobalKey<State<StatefulWidget>> _createShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _firstDashboardShowcaseKey =
      GlobalKey();
  final GlobalKey<State<StatefulWidget>> _emptyShowcaseKey = GlobalKey();

  bool _hasDashboards = false;

  @override
  String get tutorialId => TutorialIds.dashboardsList;

  @override
  List<GlobalKey<State<StatefulWidget>>> get tutorialKeys => [
    _createShowcaseKey,
    _hasDashboards ? _firstDashboardShowcaseKey : _emptyShowcaseKey,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    _hasDashboards = controller.dashboards.isNotEmpty;
    maybeStartTutorialOnFirstView();

    final header = SectionPanel(
      child: LayoutBuilder(
        builder: (_, constraints) {
          final compact = constraints.maxWidth < 520;
          final createButton = Showcase(
            key: _createShowcaseKey,
            title: 'Novo dashboard',
            description: 'Crie um dashboard usando uma base importada.',
            tooltipPosition: TooltipPosition.bottom,
            child: ElevatedButton.icon(
              onPressed: widget.onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Novo dashboard'),
            ),
          );

          return compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboards',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Edite, visualize e exporte seus painéis.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: createButton),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dashboards',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Edite, visualize e exporte seus painéis.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    createButton,
                  ],
                );
        },
      ),
    );

    if (controller.dashboards.isEmpty) {
      return AppPageBackground(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final emptyAreaHeight = constraints.maxHeight.isFinite
                ? (constraints.maxHeight - 156).clamp(220.0, 560.0)
                : 360.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                const SizedBox(height: 12),
                SizedBox(
                  height: emptyAreaHeight,
                  child: Center(
                    child: Showcase(
                      key: _emptyShowcaseKey,
                      title: 'Lista de dashboards',
                      description:
                          'Quando você criar dashboards, eles aparecerão aqui para edição e exportação.',
                      tooltipPosition: TooltipPosition.top,
                      child: EmptyState(
                        title: 'Sem dashboards',
                        subtitle: 'Crie seu primeiro dashboard.',
                        illustrationAsset: AppIllustrations.analysis,
                        illustrationHeight: 196,
                        maxWidth: 360,
                        titleStyle: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                        subtitleStyle: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return AppPageScrollView(
      children: [
        header,
        const SizedBox(height: 12),
        ...controller.dashboards.asMap().entries.map((entry) {
          final index = entry.key;
          final dashboard = entry.value;
          final dataSet = controller.dataSetById(dashboard.dataSetId);

          final card = Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SectionPanel(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.14,
                        ),
                        child: const Icon(
                          Icons.dashboard_rounded,
                          color: AppColors.primary,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dashboard.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${dataSet?.fileName ?? 'Dataset removido'} • ${Formatters.dateTime(dashboard.updatedAt)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _confirmDelete(context, dashboard.id),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (_, constraints) {
                      final compact = constraints.maxWidth < 520;
                      if (compact) {
                        return Column(
                          children: [
                            _DashboardActionButton(
                              icon: Icons.edit_outlined,
                              label: 'Editar',
                              onTap: () => widget.onOpenEditor(dashboard.id),
                            ),
                            const SizedBox(height: 8),
                            _DashboardActionButton(
                              icon: Icons.visibility_outlined,
                              label: 'Visualizar',
                              onTap: () => widget.onOpenView(dashboard.id),
                            ),
                            const SizedBox(height: 8),
                            _DashboardActionButton(
                              icon: Icons.ios_share_rounded,
                              label: 'Exportar',
                              onTap: () => widget.onOpenExport(dashboard.id),
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: _DashboardActionButton(
                              icon: Icons.edit_outlined,
                              label: 'Editar',
                              onTap: () => widget.onOpenEditor(dashboard.id),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _DashboardActionButton(
                              icon: Icons.visibility_outlined,
                              label: 'Visualizar',
                              onTap: () => widget.onOpenView(dashboard.id),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _DashboardActionButton(
                              icon: Icons.ios_share_rounded,
                              label: 'Exportar',
                              onTap: () => widget.onOpenExport(dashboard.id),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );

          if (index == 0) {
            return Showcase(
              key: _firstDashboardShowcaseKey,
              title: 'Ações do dashboard',
              description:
                  'Use este card para editar, visualizar ou exportar seu dashboard.',
              tooltipPosition: TooltipPosition.top,
              child: card,
            );
          }

          return card;
        }),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, String dashboardId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover dashboard'),
        content: const Text('Esta ação não poderá ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<AppController>().deleteDashboard(dashboardId);
    }
  }
}

class _DashboardActionButton extends StatelessWidget {
  const _DashboardActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(42),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
