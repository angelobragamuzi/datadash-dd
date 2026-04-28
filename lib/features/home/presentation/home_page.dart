import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_illustrations.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_panel.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.onImportTap,
    required this.onNewDashboardTap,
    required this.onFilesTap,
    required this.onExportsTap,
    required this.onOpenStaticExample,
    required this.onOpenDashboard,
  });

  final VoidCallback onImportTap;
  final VoidCallback onNewDashboardTap;
  final VoidCallback onFilesTap;
  final VoidCallback onExportsTap;
  final VoidCallback onOpenStaticExample;
  final ValueChanged<String> onOpenDashboard;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final recent = controller.dashboards.take(4).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        SectionPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Análises rápidas no celular',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onImportTap,
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Importar arquivo'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onNewDashboardTap,
                icon: const Icon(Icons.add_chart_rounded, size: 18),
                label: const Text('Novo dashboard'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onOpenStaticExample,
            icon: const Icon(Icons.auto_graph_rounded, size: 18),
            label: const Text('Dashboard de exemplo'),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onFilesTap,
                icon: const Icon(Icons.folder_open_rounded, size: 18),
                label: const Text('Arquivos importados'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onExportsTap,
                icon: const Icon(Icons.ios_share_rounded, size: 18),
                label: const Text('Exportações'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              'Dashboards recentes',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (recent.isEmpty)
          const EmptyState(
            title: 'Sem dashboards',
            subtitle: 'Crie um dashboard a partir de um arquivo importado.',
            illustrationAsset: AppIllustrations.analysis,
          )
        else
          ...recent.map(
            (dashboard) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SectionPanel(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 17,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.14),
                    child: const Icon(
                      Icons.dashboard_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  title: Text(dashboard.name),
                  subtitle: Text(
                    'Atualizado ${Formatters.dateTime(dashboard.updatedAt)}',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => onOpenDashboard(dashboard.id),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
