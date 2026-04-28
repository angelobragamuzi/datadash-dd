import 'dart:io';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../core/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_illustrations.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/page_tutorial_mixin.dart';
import '../../../core/utils/tutorial_ids.dart';
import '../../../shared/widgets/app_page_background.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_panel.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key, required this.args});

  final ExportArgs args;

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage>
    with PageTutorialMixin<ExportPage> {
  final GlobalKey<State<StatefulWidget>> _summaryShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _printShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _saveShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _shareShowcaseKey = GlobalKey();

  bool _loading = false;
  File? _lastFile;

  @override
  String get tutorialId => TutorialIds.exportPage;

  @override
  List<GlobalKey<State<StatefulWidget>>> get tutorialKeys => [
    _summaryShowcaseKey,
    _printShowcaseKey,
    _saveShowcaseKey,
    _shareShowcaseKey,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final dashboard = controller.dashboardById(widget.args.dashboardId);

    if (dashboard == null) {
      return const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: EmptyState(
              title: 'Dashboard não encontrado',
              subtitle:
                  'Não foi possível localizar esse dashboard para exportação.',
              illustrationAsset: AppIllustrations.error,
              withCard: true,
            ),
          ),
        ),
      );
    }

    final dataSet = controller.dataSetById(dashboard.dataSetId);
    maybeStartTutorialOnFirstView();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportação'),
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
          Showcase(
            key: _summaryShowcaseKey,
            title: 'Resumo para exportação',
            description:
                'Confira o dashboard, base e total de widgets antes de gerar o PDF.',
            tooltipPosition: TooltipPosition.bottom,
            child: SectionPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dashboard.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _MetaRow(
                    icon: Icons.storage_outlined,
                    label: 'Base',
                    value: dataSet?.fileName ?? 'N/A',
                  ),
                  const SizedBox(height: 6),
                  _MetaRow(
                    icon: Icons.widgets_outlined,
                    label: 'Widgets',
                    value: '${dashboard.widgets.length}',
                  ),
                  const SizedBox(height: 6),
                  _MetaRow(
                    icon: Icons.schedule_outlined,
                    label: 'Data',
                    value: Formatters.dateTime(DateTime.now()),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Showcase(
            key: _printShowcaseKey,
            title: 'Gerar PDF',
            description:
                'Abra visualização de impressão e gere o arquivo PDF do dashboard.',
            tooltipPosition: TooltipPosition.bottom,
            child: _ActionButton(
              loading: _loading,
              icon: Icons.print_outlined,
              label: 'Abrir impressão / PDF',
              onTap: () async {
                setState(() => _loading = true);
                try {
                  final bytes = await controller.buildDashboardPdf(dashboard);
                  await Printing.layoutPdf(onLayout: (_) async => bytes);
                } catch (e) {
                  _showMessage(e.toString());
                } finally {
                  if (mounted) setState(() => _loading = false);
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          Showcase(
            key: _saveShowcaseKey,
            title: 'Salvar no dispositivo',
            description:
                'Baixe o PDF localmente para enviar depois ou arquivar.',
            tooltipPosition: TooltipPosition.bottom,
            child: _ActionButton(
              loading: _loading,
              outlined: true,
              icon: Icons.save_alt_rounded,
              label: 'Salvar no dispositivo',
              onTap: () async {
                setState(() => _loading = true);
                try {
                  final file = await controller.saveDashboardPdf(dashboard);
                  setState(() => _lastFile = file);
                  _showMessage('PDF salvo em ${file.path}');
                } catch (e) {
                  _showMessage(e.toString());
                } finally {
                  if (mounted) setState(() => _loading = false);
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          Showcase(
            key: _shareShowcaseKey,
            title: 'Compartilhar PDF',
            description: 'Envie o dashboard por e-mail ou outros aplicativos.',
            tooltipPosition: TooltipPosition.top,
            child: _ActionButton(
              loading: _loading,
              outlined: true,
              icon: Icons.share_outlined,
              label: 'Compartilhar / E-mail',
              onTap: () async {
                setState(() => _loading = true);
                try {
                  final file =
                      _lastFile ?? await controller.saveDashboardPdf(dashboard);
                  setState(() => _lastFile = file);
                  await SharePlus.instance.share(
                    ShareParams(
                      files: [XFile(file.path)],
                      subject: 'Dashboard ${dashboard.name}',
                      text: 'Dashboard exportado pelo DataDash',
                    ),
                  );
                } catch (e) {
                  _showMessage(e.toString());
                } finally {
                  if (mounted) setState(() => _loading = false);
                }
              },
            ),
          ),
          if (_lastFile != null) ...[
            const SizedBox(height: 14),
            SectionPanel(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.14),
                    child: const Icon(
                      Icons.description_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _lastFile!.path,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text.replaceFirst('Exception: ', ''))),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.loading,
    required this.icon,
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  final bool loading;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final button = outlined
        ? OutlinedButton.icon(
            onPressed: loading ? null : onTap,
            icon: Icon(icon),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              alignment: Alignment.centerLeft,
            ),
          )
        : ElevatedButton.icon(
            onPressed: loading ? null : onTap,
            icon: Icon(icon),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              alignment: Alignment.centerLeft,
            ),
          );

    return SizedBox(width: double.infinity, child: button);
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.mutedText),
        const SizedBox(width: 8),
        Text('$label: ', style: Theme.of(context).textTheme.bodySmall),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
