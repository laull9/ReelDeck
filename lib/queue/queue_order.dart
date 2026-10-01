import 'dart:collection';
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
  final available = SplayTreeSet<_MediaGroup>((a, b) {
    final size = b.ids.length.compareTo(a.ids.length);
    return size != 0 ? size : a.tie.compareTo(b.tie);
  });
  var tie = 0;
  for (final ids in groups.values) {
    available.add(_MediaGroup(ids, tie++));
  }
  final ordered = <int>[];
  _MediaGroup? previous;
  while (available.isNotEmpty || previous != null) {
    final selected = available.isEmpty ? previous! : available.first;
    if (identical(selected, previous)) {
      previous = null;
    } else {
      available.remove(selected);
    }
    // 上一目录暂时留在树外，先取别的目录；只有它剩下时允许连续。
    if (previous != null) available.add(previous);
    ordered.add(selected.ids.removeLast());
    previous = selected.ids.isEmpty ? null : selected;
  }
  return ordered;
}

class _MediaGroup {
  _MediaGroup(this.ids, this.tie);

  final List<int> ids;
  final int tie;
}
