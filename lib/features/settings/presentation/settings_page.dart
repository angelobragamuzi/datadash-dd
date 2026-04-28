import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../core/app_controller.dart';
import '../../../core/utils/page_tutorial_mixin.dart';
import '../../../core/utils/tutorial_ids.dart';
import '../../../shared/widgets/app_page_background.dart';
import '../../../shared/widgets/section_panel.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage>
    with PageTutorialMixin<SettingsPage> {
  final GlobalKey<State<StatefulWidget>> _themeSwitchShowcaseKey = GlobalKey();

  @override
  String get tutorialId => TutorialIds.settings;

  @override
  List<GlobalKey<State<StatefulWidget>>> get tutorialKeys => [
    _themeSwitchShowcaseKey,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final isDark = controller.themeMode == ThemeMode.dark;
    maybeStartTutorialOnFirstView();

    return AppPageScrollView(
      children: [
        SectionPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Preferências',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Ajuste aparência e comportamento do aplicativo.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Showcase(
          key: _themeSwitchShowcaseKey,
          title: 'Tema do aplicativo',
          description:
              'Alterne entre tema claro e escuro. A interface inteira se adapta automaticamente.',
          tooltipPosition: TooltipPosition.top,
          child: SectionPanel(
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: isDark,
              title: const Text('Tema escuro'),
              subtitle: const Text(
                'Ativa um visual com menos brilho e maior contraste.',
              ),
              onChanged: (value) {
                context.read<AppController>().setThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        const SectionPanel(
          child: Text(
            'Mais opções de personalização serão adicionadas em breve.',
          ),
        ),
      ],
    );
  }
}
