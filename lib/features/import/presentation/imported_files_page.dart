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

class ImportedFilesPage extends StatefulWidget {
  const ImportedFilesPage({
    super.key,
    required this.onImport,
    required this.onOpenPreview,
  });

  final VoidCallback onImport;
  final ValueChanged<String> onOpenPreview;

  @override
  State<ImportedFilesPage> createState() => ImportedFilesPageState();
}

class ImportedFilesPageState extends State<ImportedFilesPage>
    with PageTutorialMixin<ImportedFilesPage> {
  final GlobalKey<State<StatefulWidget>> _importButtonShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _firstFileShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _emptyShowcaseKey = GlobalKey();

  bool _hasFiles = false;

  @override
  String get tutorialId => TutorialIds.importedFiles;

  @override
  List<GlobalKey<State<StatefulWidget>>> get tutorialKeys => [
    _importButtonShowcaseKey,
    _hasFiles ? _firstFileShowcaseKey : _emptyShowcaseKey,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    _hasFiles = controller.imports.isNotEmpty;
    maybeStartTutorialOnFirstView();

    return AppPageScrollView(
      children: [
        SectionPanel(
          child: LayoutBuilder(
            builder: (_, constraints) {
              final compact = constraints.maxWidth < 520;
              final importButton = Showcase(
                key: _importButtonShowcaseKey,
                title: 'Importar arquivo',
                description: 'Adicione novas bases locais para usar no app.',
                tooltipPosition: TooltipPosition.bottom,
                child: ElevatedButton.icon(
                  onPressed: widget.onImport,
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Importar arquivo'),
                ),
              );

              return compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Arquivos importados',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gerencie suas bases e abra prévias rapidamente.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(width: double.infinity, child: importButton),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Arquivos importados',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Gerencie suas bases e abra prévias rapidamente.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        importButton,
                      ],
                    );
            },
          ),
        ),
        const SizedBox(height: 12),
        if (controller.imports.isEmpty)
          Showcase(
            key: _emptyShowcaseKey,
            title: 'Lista de arquivos',
            description:
                'Depois de importar, seus arquivos aparecem aqui para abrir prévia e gerenciar.',
            tooltipPosition: TooltipPosition.top,
            child: const EmptyState(
              title: 'Sem arquivos',
              subtitle: 'Importe um CSV ou XLSX para começar.',
              illustrationAsset: AppIllustrations.empty,
            ),
          )
        else
          ...controller.imports.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final item = entry.value;

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
                              Icons.insert_drive_file_outlined,
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
                                  item.fileName,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${item.rows.length} linhas • ${item.columnCount} colunas • ${Formatters.dateTime(item.importedAt)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _confirmDelete(context, item.id),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => widget.onOpenPreview(item.id),
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('Abrir prévia'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(42),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ],
                  ),
                ),
              );

              if (index == 0) {
                return Showcase(
                  key: _firstFileShowcaseKey,
                  title: 'Arquivo importado',
                  description:
                      'Abra a prévia para ajustar colunas, filtros e criar dashboards.',
                  tooltipPosition: TooltipPosition.top,
                  child: card,
                );
              }

              return card;
            },
          ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, String dataSetId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover arquivo'),
        content: const Text(
          'Dashboards ligados a este arquivo também serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<AppController>().deleteImportedDataSet(dataSetId);
    }
  }
}
