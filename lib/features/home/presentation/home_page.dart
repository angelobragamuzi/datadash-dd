import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../core/app_controller.dart';
import '../../../core/utils/page_tutorial_mixin.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_illustrations.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/tutorial_ids.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../shared/widgets/empty_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.onImportTap,
    required this.onNewDashboardTap,
    required this.onFilesTap,
    required this.onExportsTap,
    required this.onOpenStaticExample,
    required this.onOpenDashboard,
    required this.onOpenDashboards,
  });

  final VoidCallback onImportTap;
  final VoidCallback onNewDashboardTap;
  final VoidCallback onFilesTap;
  final VoidCallback onExportsTap;
  final VoidCallback onOpenStaticExample;
  final ValueChanged<String> onOpenDashboard;
  final VoidCallback onOpenDashboards;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with PageTutorialMixin<HomePage> {
  final GlobalKey<State<StatefulWidget>> _importShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _newDashboardShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _exampleShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _filesShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _exportsShowcaseKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> _recentShowcaseKey = GlobalKey();

  @override
  String get tutorialId => TutorialIds.home;

  @override
  List<GlobalKey<State<StatefulWidget>>> get tutorialKeys => [
    _importShowcaseKey,
    _newDashboardShowcaseKey,
    _exampleShowcaseKey,
    _filesShowcaseKey,
    _exportsShowcaseKey,
    _recentShowcaseKey,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final recentDashboards = controller.dashboards.take(2).toList();
    maybeStartTutorialOnFirstView();

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactHeight = constraints.maxHeight < 720;
        final wideLayout = constraints.maxWidth >= 720;
        final spacing = compactHeight ? 10.0 : 14.0;

        return Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _HomeBackgroundPainter(
                    primary: AppColors.primary,
                    accent: AppColors.accent,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  SizedBox(
                    height: compactHeight ? 154 : 172,
                    child: _HeroPanel(
                      showcaseKey: _importShowcaseKey,
                      onImportTap: widget.onImportTap,
                      compact: compactHeight,
                    ),
                  ),
                  SizedBox(height: spacing),
                  Expanded(
                    child: wideLayout
                        ? Row(
                            children: [
                              Expanded(
                                child: _QuickActionsGrid(
                                  compact: compactHeight,
                                  onNewDashboardTap: widget.onNewDashboardTap,
                                  onOpenStaticExample:
                                      widget.onOpenStaticExample,
                                  onFilesTap: widget.onFilesTap,
                                  onExportsTap: widget.onExportsTap,
                                  newDashboardShowcaseKey:
                                      _newDashboardShowcaseKey,
                                  exampleShowcaseKey: _exampleShowcaseKey,
                                  filesShowcaseKey: _filesShowcaseKey,
                                  exportsShowcaseKey: _exportsShowcaseKey,
                                ),
                              ),
                              SizedBox(width: spacing),
                              Expanded(
                                child: _RecentDashboardsPanel(
                                  showcaseKey: _recentShowcaseKey,
                                  compact: compactHeight,
                                  recentDashboards: recentDashboards,
                                  totalDashboards: controller.dashboards.length,
                                  onOpenDashboard: widget.onOpenDashboard,
                                  onOpenDashboards: widget.onOpenDashboards,
                                  onNewDashboardTap: widget.onNewDashboardTap,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(
                                flex: compactHeight ? 7 : 6,
                                child: _QuickActionsGrid(
                                  compact: compactHeight,
                                  onNewDashboardTap: widget.onNewDashboardTap,
                                  onOpenStaticExample:
                                      widget.onOpenStaticExample,
                                  onFilesTap: widget.onFilesTap,
                                  onExportsTap: widget.onExportsTap,
                                  newDashboardShowcaseKey:
                                      _newDashboardShowcaseKey,
                                  exampleShowcaseKey: _exampleShowcaseKey,
                                  filesShowcaseKey: _filesShowcaseKey,
                                  exportsShowcaseKey: _exportsShowcaseKey,
                                ),
                              ),
                              SizedBox(height: spacing),
                              Expanded(
                                flex: compactHeight ? 8 : 7,
                                child: _RecentDashboardsPanel(
                                  showcaseKey: _recentShowcaseKey,
                                  compact: compactHeight,
                                  recentDashboards: recentDashboards,
                                  totalDashboards: controller.dashboards.length,
                                  onOpenDashboard: widget.onOpenDashboard,
                                  onOpenDashboards: widget.onOpenDashboards,
                                  onNewDashboardTap: widget.onNewDashboardTap,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.showcaseKey,
    required this.onImportTap,
    required this.compact,
  });

  final GlobalKey<State<StatefulWidget>> showcaseKey;
  final VoidCallback onImportTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final panelStart = isDark
        ? AppColors.darkSurfaceAlt.withValues(alpha: 0.98)
        : AppColors.primaryDark.withValues(alpha: 0.96);
    final panelEnd = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.98)
        : AppColors.primary.withValues(alpha: 0.94);
    final titleColor = isDark ? AppColors.darkTitleText : Colors.white;
    final subtitleColor = isDark
        ? AppColors.darkMutedText.withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.82);
    final iconBackground = isDark
        ? scheme.primary.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.18);
    final iconBorder = isDark
        ? scheme.primary.withValues(alpha: 0.28)
        : Colors.white.withValues(alpha: 0.22);
    final iconColor = isDark ? scheme.primary : AppColors.accent;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [panelStart, panelEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark
              ? scheme.primary.withValues(alpha: 0.24)
              : Colors.transparent,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -20,
            child: Container(
              width: compact ? 96 : 116,
              height: compact ? 96 : 116,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.16),
              ),
            ),
          ),
          Positioned(
            left: -14,
            bottom: -24,
            child: Container(
              width: compact ? 84 : 100,
              height: compact ? 84 : 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Showcase(
            key: showcaseKey,
            title: 'Importar arquivo',
            description:
                'Comece por aqui para carregar CSV, Excel ou outros dados locais.',
            tooltipPosition: TooltipPosition.bottom,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onImportTap,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, compact ? 10 : 14, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        width: compact ? 56 : 64,
                        height: compact ? 56 : 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: iconBackground,
                          border: Border.all(color: iconBorder),
                        ),
                        child: Icon(
                          Icons.upload_file_rounded,
                          color: iconColor,
                          size: compact ? 30 : 34,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Importar arquivo',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: titleColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Toque para selecionar sua base de dados',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: subtitleColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: titleColor.withValues(alpha: 0.88),
                        size: 26,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({
    required this.compact,
    required this.onNewDashboardTap,
    required this.onOpenStaticExample,
    required this.onFilesTap,
    required this.onExportsTap,
    required this.newDashboardShowcaseKey,
    required this.exampleShowcaseKey,
    required this.filesShowcaseKey,
    required this.exportsShowcaseKey,
  });

  final bool compact;
  final VoidCallback onNewDashboardTap;
  final VoidCallback onOpenStaticExample;
  final VoidCallback onFilesTap;
  final VoidCallback onExportsTap;
  final GlobalKey<State<StatefulWidget>> newDashboardShowcaseKey;
  final GlobalKey<State<StatefulWidget>> exampleShowcaseKey;
  final GlobalKey<State<StatefulWidget>> filesShowcaseKey;
  final GlobalKey<State<StatefulWidget>> exportsShowcaseKey;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _HomeAction(
        showcaseKey: newDashboardShowcaseKey,
        showcaseTitle: 'Novo dashboard',
        showcaseDescription:
            'Crie um novo dashboard usando uma base já importada.',
        title: 'Novo dashboard',
        subtitle: 'Comece com sua base atual',
        icon: Icons.add_chart_rounded,
        tint: AppColors.primary,
        onTap: onNewDashboardTap,
      ),
      _HomeAction(
        showcaseKey: exampleShowcaseKey,
        showcaseTitle: 'Dashboard exemplo',
        showcaseDescription:
            'Abra um modelo pronto para entender a estrutura dos gráficos.',
        title: 'Dashboard exemplo',
        subtitle: 'Veja um modelo pronto',
        icon: Icons.auto_graph_rounded,
        tint: AppColors.accentDark,
        onTap: onOpenStaticExample,
      ),
      _HomeAction(
        showcaseKey: filesShowcaseKey,
        showcaseTitle: 'Arquivos importados',
        showcaseDescription:
            'Revise e gerencie os dados que você já trouxe para o app.',
        title: 'Arquivos importados',
        subtitle: 'Gerencie suas bases',
        icon: Icons.folder_open_rounded,
        tint: AppColors.primaryDark,
        onTap: onFilesTap,
      ),
      _HomeAction(
        showcaseKey: exportsShowcaseKey,
        showcaseTitle: 'Exportações',
        showcaseDescription:
            'Escolha um dashboard e exporte para compartilhar resultados.',
        title: 'Exportações',
        subtitle: 'Compartilhe resultados',
        icon: Icons.ios_share_rounded,
        tint: AppColors.accent,
        onTap: onExportsTap,
      ),
    ];

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _ActionShortcut(action: actions[0], compact: compact),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionShortcut(action: actions[1], compact: compact),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _ActionShortcut(action: actions[2], compact: compact),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionShortcut(action: actions[3], compact: compact),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionShortcut extends StatelessWidget {
  const _ActionShortcut({required this.action, required this.compact});

  final _HomeAction action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: action.onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: isDark ? 0.84 : 0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: scheme.outlineVariant.withValues(
                alpha: isDark ? 0.8 : 0.7,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(14, compact ? 12 : 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: compact ? 40 : 46,
                  height: compact ? 40 : 46,
                  decoration: BoxDecoration(
                    color: action.tint.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    action.icon,
                    size: compact ? 22 : 26,
                    color: action.tint,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title,
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        action.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurface.withValues(alpha: 0.52),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Showcase(
      key: action.showcaseKey,
      title: action.showcaseTitle,
      description: action.showcaseDescription,
      tooltipPosition: TooltipPosition.bottom,
      child: button,
    );
  }
}

class _RecentDashboardsPanel extends StatelessWidget {
  const _RecentDashboardsPanel({
    required this.showcaseKey,
    required this.compact,
    required this.recentDashboards,
    required this.totalDashboards,
    required this.onOpenDashboard,
    required this.onOpenDashboards,
    required this.onNewDashboardTap,
  });

  final GlobalKey<State<StatefulWidget>> showcaseKey;
  final bool compact;
  final List<DashboardModel> recentDashboards;
  final int totalDashboards;
  final ValueChanged<String> onOpenDashboard;
  final VoidCallback onOpenDashboards;
  final VoidCallback onNewDashboardTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final panel = Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, compact ? 12 : 14, 16, 14),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: isDark ? 0.84 : 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: isDark ? 0.85 : 0.75),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Dashboards recentes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: onOpenDashboards,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                child: const Text('Ver todos'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: recentDashboards.isEmpty
                ? _NoDashboardState(onNewDashboardTap: onNewDashboardTap)
                : Column(
                    children: [
                      for (var i = 0; i < recentDashboards.length; i++) ...[
                        _RecentDashboardTile(
                          dashboard: recentDashboards[i],
                          onTap: () => onOpenDashboard(recentDashboards[i].id),
                        ),
                        if (i != recentDashboards.length - 1)
                          const SizedBox(height: 8),
                      ],
                      const Spacer(),
                      if (totalDashboards > recentDashboards.length)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '+${totalDashboards - recentDashboards.length} dashboard(s) disponível(is)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );

    return Showcase(
      key: showcaseKey,
      title: 'Dashboards recentes',
      description:
          'Acesse rapidamente os últimos dashboards editados ou veja todos.',
      tooltipPosition: TooltipPosition.top,
      child: panel,
    );
  }
}

class _RecentDashboardTile extends StatelessWidget {
  const _RecentDashboardTile({required this.dashboard, required this.onTap});

  final DashboardModel dashboard;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 13, 10, 13),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.14),
                  child: const Icon(
                    Icons.dashboard_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dashboard.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Atualizado ${Formatters.dateTime(dashboard.updatedAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoDashboardState extends StatelessWidget {
  const _NoDashboardState({required this.onNewDashboardTap});

  final VoidCallback onNewDashboardTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final veryCompact = constraints.maxHeight < 230;
        final compact = constraints.maxHeight < 280;
        final illustrationHeight = compact
            ? (constraints.maxHeight * 0.32).clamp(78.0, 114.0)
            : 138.0;

        return Center(
          child: EmptyState(
            title: 'Nenhum dashboard criado',
            subtitle: veryCompact
                ? 'Crie seu primeiro dashboard.'
                : 'Use sua base importada para criar o primeiro.',
            illustrationAsset: AppIllustrations.empty,
            illustrationHeight: illustrationHeight,
            maxWidth: 300,
            action: veryCompact
                ? null
                : OutlinedButton.icon(
                    onPressed: onNewDashboardTap,
                    icon: const Icon(Icons.add, size: 17),
                    label: const Text('Criar agora'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _HomeAction {
  const _HomeAction({
    required this.showcaseKey,
    required this.showcaseTitle,
    required this.showcaseDescription,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final GlobalKey<State<StatefulWidget>> showcaseKey;
  final String showcaseTitle;
  final String showcaseDescription;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;
}

class _HomeBackgroundPainter extends CustomPainter {
  const _HomeBackgroundPainter({
    required this.primary,
    required this.accent,
    required this.isDark,
  });

  final Color primary;
  final Color accent;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final topCircle = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.13 : 0.08);
    canvas.drawCircle(
      Offset(size.width * 0.90, size.height * 0.12),
      size.width * 0.22,
      topCircle,
    );

    final bottomCircle = Paint()
      ..color = accent.withValues(alpha: isDark ? 0.12 : 0.08);
    canvas.drawCircle(
      Offset(size.width * 0.14, size.height * 0.84),
      size.width * 0.25,
      bottomCircle,
    );

    final pathPaint = Paint()
      ..color = primary.withValues(alpha: isDark ? 0.24 : 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final topLine = Path()
      ..moveTo(-28, size.height * 0.20)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.06,
        size.width * 0.58,
        size.height * 0.18,
      )
      ..quadraticBezierTo(
        size.width * 0.84,
        size.height * 0.30,
        size.width + 24,
        size.height * 0.16,
      );
    canvas.drawPath(topLine, pathPaint);

    final midLine = Path()
      ..moveTo(-24, size.height * 0.56)
      ..quadraticBezierTo(
        size.width * 0.20,
        size.height * 0.44,
        size.width * 0.46,
        size.height * 0.56,
      )
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height * 0.70,
        size.width + 22,
        size.height * 0.58,
      );
    canvas.drawPath(midLine, pathPaint);

    final diagonalPaint = Paint()
      ..color = accent.withValues(alpha: isDark ? 0.18 : 0.12)
      ..strokeWidth = 1;
    final startX = size.width * 0.62;
    for (var i = 0; i < 8; i++) {
      final x = startX + (i * 22);
      canvas.drawLine(
        Offset(x, size.height * 0.70),
        Offset(x - 70, size.height + 36),
        diagonalPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HomeBackgroundPainter oldDelegate) {
    return oldDelegate.primary != primary ||
        oldDelegate.accent != accent ||
        oldDelegate.isDark != isDark;
  }
}
