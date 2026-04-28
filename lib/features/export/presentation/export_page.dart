import 'dart:io';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/app_controller.dart';
import '../../../core/utils/app_illustrations.dart';
import '../../../core/utils/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_panel.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key, required this.args});

  final ExportArgs args;

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  bool _loading = false;
  File? _lastFile;

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
            ),
          ),
        ),
      );
    }

    final dataSet = controller.dataSetById(dashboard.dataSetId);

    return Scaffold(
      appBar: AppBar(title: const Text('Exportação')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          SectionPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dashboard.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('Base: ${dataSet?.fileName ?? 'N/A'}'),
                const SizedBox(height: 4),
                Text('Widgets: ${dashboard.widgets.length}'),
                const SizedBox(height: 4),
                Text('Data: ${Formatters.dateTime(DateTime.now())}'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loading
                ? null
                : () async {
                    setState(() => _loading = true);
                    try {
                      final bytes = await controller.buildDashboardPdf(
                        dashboard,
                      );
                      await Printing.layoutPdf(onLayout: (_) async => bytes);
                    } catch (e) {
                      _showMessage(e.toString());
                    } finally {
                      if (mounted) setState(() => _loading = false);
                    }
                  },
            icon: const Icon(Icons.print_outlined),
            label: const Text('Abrir impressão / PDF'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _loading
                ? null
                : () async {
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
            icon: const Icon(Icons.save_alt_rounded),
            label: const Text('Salvar no dispositivo'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _loading
                ? null
                : () async {
                    setState(() => _loading = true);
                    try {
                      final file =
                          _lastFile ??
                          await controller.saveDashboardPdf(dashboard);
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
            icon: const Icon(Icons.share_outlined),
            label: const Text('Compartilhar / E-mail'),
          ),
          if (_lastFile != null) ...[
            const SizedBox(height: 14),
            SectionPanel(child: Text('Último arquivo: ${_lastFile!.path}')),
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
