import 'dart:math';

import 'package:path/path.dart' as p;

import '../sources/source.dart';
import 'shuffle.dart';

/// 纯随机保持均匀洗牌；智能随机尽量交错父目录。
List<int> orderMedia(
  List<int> ids,
  Map<int, Media> media,
  String mode,
  Random random,
) {
  final result = ids.toSet().toList();
  if (mode == 'newest' || mode == 'oldest') {
    result.sort((a, b) {
      final left = media[a]!, right = media[b]!;
      var comparison = left.modifiedAt.compareTo(right.modifiedAt);
      if (mode == 'newest') comparison = -comparison;
      if (comparison != 0) return comparison;
      comparison = left.sourceId.compareTo(right.sourceId);
      return comparison != 0
          ? comparison
          : left.relativePath.compareTo(right.relativePath);
    });
    return result;
  }
  fisherYatesShuffle(result, random: random);
  if (mode != 'smart') return result;
  final groups = <String, List<int>>{};
  for (final id in result) {
    final item = media[id]!;
    final key =
        '${item.sourceId}:${p.posix.dirname(item.relativePath.replaceAll('\\', '/'))}';
    groups.putIfAbsent(key, () => []).add(id);
  }
  final ordered = <int>[];
  String? previous;
  while (groups.isNotEmpty) {
    var candidates = groups.keys.where((key) => key != previous).toList();
    if (candidates.isEmpty) candidates = groups.keys.toList();
    // 优先大组，避免末尾积下一个目录；同样大小随机打破平局。
    fisherYatesShuffle(candidates, random: random);
    candidates.sort((a, b) => groups[b]!.length.compareTo(groups[a]!.length));
    final selected = candidates.first;
    ordered.add(groups[selected]!.removeLast());
    if (groups[selected]!.isEmpty) groups.remove(selected);
    previous = selected;
  }
  return ordered;
}
