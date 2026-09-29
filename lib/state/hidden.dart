import 'package:flutter/foundation.dart';

class HiddenRule {
  final int id;
  final int sourceId;
  final String relativePath;
  final bool recursive;

  const HiddenRule({
    required this.id,
    required this.sourceId,
    required this.relativePath,
    this.recursive = true,
  });
}

class HiddenManager extends ChangeNotifier {
  final Set<int> _hiddenMediaIds = {};
  final List<HiddenRule> _rules = [];

  void hideMedia(int mediaId) {
    _hiddenMediaIds.add(mediaId);
    notifyListeners();
  }

  void hideFolder(int sourceId, String relativePath, {bool recursive = true}) {
    final rule = HiddenRule(
      id: _rules.length + 1,
      sourceId: sourceId,
      relativePath: relativePath,
      recursive: recursive,
    );
    _rules.add(rule);
    notifyListeners();
  }

  bool isHidden(int mediaId) => _hiddenMediaIds.contains(mediaId);

  List<HiddenRule> get rules => List.unmodifiable(_rules);
}
