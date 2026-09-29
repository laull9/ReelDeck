/// Filters media IDs to exclude hidden items or folders.
class MediaFilter {
  /// Filters [allMediaIds] excluding [hiddenIds] and [hiddenFolderMediaIds].
  List<int> apply(
    List<int> allMediaIds, {
    Set<int> hiddenIds = const {},
    Set<int> hiddenFolderMediaIds = const {},
  }) {
    if (hiddenIds.isEmpty && hiddenFolderMediaIds.isEmpty) {
      return List<int>.from(allMediaIds);
    }
    return allMediaIds.where((id) {
      return !hiddenIds.contains(id) && !hiddenFolderMediaIds.contains(id);
    }).toList();
  }
}
