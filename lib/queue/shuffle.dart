import 'dart:math';

/// Performs an in-place Fisher-Yates shuffle on [items] and returns the list.
List<T> fisherYatesShuffle<T>(List<T> items, {Random? random}) {
  final rng = random ?? Random();
  for (var i = items.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final temp = items[i];
    items[i] = items[j];
    items[j] = temp;
  }
  return items;
}
