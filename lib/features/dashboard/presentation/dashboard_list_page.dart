import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_illustrations.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_panel.dart';

class DashboardListPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Novo'),
          ),
        ),
        const SizedBox(height: 10),
        if (controller.dashboards.isEmpty)
          const EmptyState(
            title: 'Sem dashboards',
            subtitle: 'Crie seu primeiro dashboard.',
            illustrationAsset: AppIllustrations.analysis,
          )
        else
          ...controller.dashboards.map((dashboard) {
            final dataSet = controller.dataSetById(dashboard.dataSetId);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SectionPanel(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(dashboard.name),
                      subtitle: Text(
                        '${dataSet?.fileName ?? 'Dataset removido'} • ${Formatters.dateTime(dashboard.updatedAt)}',
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => onOpenEditor(dashboard.id),
                          child: const Text('Editar'),
                        ),
                        TextButton(
                          onPressed: () => onOpenView(dashboard.id),
                          child: const Text('Visualizar'),
                        ),
                        TextButton(
                          onPressed: () => onOpenExport(dashboard.id),
                          child: const Text('Exportar'),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Remover dashboard'),
                                content: const Text(
                                  'Esta ação não poderá ser desfeita.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.danger,
                                    ),
                                    child: const Text('Remover'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              if (!context.mounted) return;
                              await context
                                  .read<AppController>()
                                  .deleteDashboard(dashboard.id);
                            }
                          },
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
