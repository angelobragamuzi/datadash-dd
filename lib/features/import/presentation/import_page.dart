import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_illustrations.dart';
import '../../../core/utils/app_routes.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_panel.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Importação de arquivo')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          SectionPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    height: 120,
                    child: SvgPicture.asset(
                      _loading
                          ? AppIllustrations.analysis
                          : AppIllustrations.import,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Formatos aceitos: .csv, .xls, .xlsx'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _import,
                    icon: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.file_upload_outlined),
                    label: Text(
                      _loading ? 'Importando...' : 'Selecionar arquivo',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Histórico', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (controller.imports.isEmpty)
            const EmptyState(
              title: 'Sem arquivos importados',
              subtitle: 'Escolha um arquivo CSV ou XLSX para começar.',
              illustrationAsset: AppIllustrations.empty,
            )
          else
            ...controller.imports
                .take(5)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SectionPanel(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.insert_drive_file_outlined,
                          color: AppColors.primary,
                        ),
                        title: Text(
                          item.fileName,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${item.rows.length} linhas • ${item.columnCount} colunas',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.dataPreview,
                            arguments: DataPreviewArgs(item.id),
                          );
                        },
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _import() async {
    setState(() => _loading = true);

    try {
      final dataSet = await context.read<AppController>().importFile();
      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.dataPreview,
        arguments: DataPreviewArgs(dataSet.id),
      );
    } catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Falha na importação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 110,
                child: SvgPicture.asset(
                  AppIllustrations.error,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 10),
              Text(e.toString().replaceFirst('Exception: ', '')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendi'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
