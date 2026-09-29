import 'package:flutter/foundation.dart';

// TODO: Implement persistence for favorite media items (e.g. SQLite/Drift or shared_preferences).
class FavoritesManager extends ChangeNotifier {
  final Set<int> _favoriteIds = {};

  bool isFavorite(int mediaId) => _favoriteIds.contains(mediaId);

  void toggle(int mediaId) {
    if (_favoriteIds.contains(mediaId)) {
      _favoriteIds.remove(mediaId);
    } else {
      _favoriteIds.add(mediaId);
    }
    notifyListeners();
  }

  Set<int> get all => Set.unmodifiable(_favoriteIds);
}
