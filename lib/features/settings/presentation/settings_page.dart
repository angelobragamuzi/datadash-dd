import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_controller.dart';
import '../../../shared/widgets/section_panel.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final isDark = controller.themeMode == ThemeMode.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        SectionPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configurações',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: isDark,
                title: Text('Tema escuro'),
                subtitle: Text(
                  'Ativa um visual com menos brilho para o aplicativo.',
                ),
                onChanged: (value) {
                  context.read<AppController>().setThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
              ),
              SizedBox(height: 10),
              Text('Mais opções de personalização serão adicionadas em breve.'),
            ],
          ),
        ),
      ],
    );
  }
}
