import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_controller.dart';
import '../../../core/utils/app_illustrations.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_panel.dart';

class ImportedFilesPage extends StatelessWidget {
  const ImportedFilesPage({
    super.key,
    required this.onImport,
    required this.onOpenPreview,
  });

  final VoidCallback onImport;
  final ValueChanged<String> onOpenPreview;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: onImport,
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Importar'),
          ),
        ),
        const SizedBox(height: 10),
        if (controller.imports.isEmpty)
          const EmptyState(
            title: 'Sem arquivos',
            subtitle: 'Importe um CSV ou XLSX para começar.',
            illustrationAsset: AppIllustrations.empty,
          )
        else
          ...controller.imports.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SectionPanel(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.fileName),
                      subtitle: Text(
                        '${item.rows.length} linhas • ${item.columnCount} colunas • ${Formatters.dateTime(item.importedAt)}',
                      ),
                      onTap: () => onOpenPreview(item.id),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => onOpenPreview(item.id),
                          child: const Text('Prévia'),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Remover arquivo'),
                                content: const Text(
                                  'Dashboards ligados a este arquivo serão removidos.',
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
                                    child: const Text('Remover'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              await context
                                  .read<AppController>()
                                  .deleteImportedDataSet(item.id);
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
            ),
          ),
      ],
    );
  }
}
