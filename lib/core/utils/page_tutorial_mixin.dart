import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../app_controller.dart';

mixin PageTutorialMixin<T extends StatefulWidget> on State<T> {
  bool _autoTutorialScheduled = false;

  String get tutorialId;
  String get tutorialScope => tutorialId;
  List<GlobalKey<State<StatefulWidget>>> get tutorialKeys;
  bool get enableAutoTutorial => true;
  double get tutorialBlurValue => 1;

  @override
  void initState() {
    super.initState();
    ShowcaseView.register(
      scope: tutorialScope,
      blurValue: tutorialBlurValue,
      onFinish: _markTutorialAsSeen,
      onDismiss: (_) => _markTutorialAsSeen(),
    );
  }

  @override
  void dispose() {
    ShowcaseView.getNamed(tutorialScope).unregister();
    super.dispose();
  }

  void maybeStartTutorialOnFirstView() {
    if (!enableAutoTutorial || _autoTutorialScheduled || !mounted) return;
    if (context.read<AppController>().hasSeenTutorial(tutorialId)) return;

    _autoTutorialScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ShowcaseView.getNamed(tutorialScope).startShowCase(tutorialKeys);
    });
  }

  void startTutorial({bool force = false}) {
    if (!mounted) return;

    final seen = context.read<AppController>().hasSeenTutorial(tutorialId);
    if (!force && seen) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ShowcaseView.getNamed(tutorialScope).startShowCase(tutorialKeys);
    });
  }

  void _markTutorialAsSeen() {
    if (!mounted) return;
    context.read<AppController>().setTutorialSeen(tutorialId);
  }
}
