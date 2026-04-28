import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../core/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_illustrations.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/utils/page_tutorial_mixin.dart';
import '../../../core/utils/tutorial_ids.dart';
import '../../../shared/widgets/app_page_background.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_panel.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage>
    with PageTutorialMixin<ImportPage> {
  final GlobalKey<State<StatefulWidget>> _importButtonShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _historyShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _emptyHistoryShowcaseKey = GlobalKey();

  bool _loading = false;
  bool _hasHistory = false;

  @override
  String get tutorialId => TutorialIds.importPage;

  @override
  List<GlobalKey<State<StatefulWidget>>> get tutorialKeys => [
    _importButtonShowcaseKey,
    _hasHistory ? _historyShowcaseKey : _emptyHistoryShowcaseKey,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    _hasHistory = controller.imports.isNotEmpty;
    maybeStartTutorialOnFirstView();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Importação de arquivo'),
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
          SectionPanel(
            child: LayoutBuilder(
              builder: (_, constraints) {
                final compact = constraints.maxWidth < 620;

                final actionButton = Showcase(
                  key: _importButtonShowcaseKey,
                  title: 'Importar base',
                  description:
                      'Selecione um CSV, XLS ou XLSX para carregar os dados no app.',
                  tooltipPosition: TooltipPosition.bottom,
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
                );

                final textBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Importe sua base local',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Formatos aceitos: .csv, .xls e .xlsx',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    compact
                        ? SizedBox(width: double.infinity, child: actionButton)
                        : actionButton,
                  ],
                );

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SizedBox(
                          height: 110,
                          child: SvgPicture.asset(
                            _loading
                                ? AppIllustrations.analysis
                                : AppIllustrations.import,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      textBlock,
                    ],
                  );
                }

                return Row(
                  children: [
                    SizedBox(
                      width: 132,
                      height: 120,
                      child: SvgPicture.asset(
                        _loading
                            ? AppIllustrations.analysis
                            : AppIllustrations.import,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: textBlock),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Text('Histórico', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (controller.imports.isEmpty)
            Showcase(
              key: _emptyHistoryShowcaseKey,
              title: 'Histórico de importações',
              description:
                  'Os arquivos importados aparecem aqui para abrir a prévia e reutilizar.',
              tooltipPosition: TooltipPosition.top,
              child: const EmptyState(
                title: 'Sem arquivos importados',
                subtitle: 'Escolha um arquivo CSV ou XLSX para começar.',
                illustrationAsset: AppIllustrations.empty,
              ),
            )
          else
            ...controller.imports.take(5).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final card = Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SectionPanel(
                  padding: const EdgeInsets.all(12),
                  child: Row(
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
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.rows.length} linhas • ${item.columnCount} colunas',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.dataPreview,
                            arguments: DataPreviewArgs(item.id),
                          );
                        },
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                ),
              );

              if (index == 0) {
                return Showcase(
                  key: _historyShowcaseKey,
                  title: 'Arquivo recente',
                  description:
                      'Abra a prévia para ajustar colunas e filtros antes de criar dashboards.',
                  tooltipPosition: TooltipPosition.top,
                  child: card,
                );
              }

              return card;
            }),
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
