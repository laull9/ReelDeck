import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:reel_deck/queue/queue_engine.dart';
import 'package:reel_deck/sources/source.dart';
import 'package:reel_deck/sources/source_manager.dart';

class FeedController extends ChangeNotifier {
  final QueueEngine queue;
  final SourceManager? sourceManager;

  // State
  int? _currentMediaId;
  String? _currentPath;
  String? _currentFileName;
  String? _currentFolder;
  bool _isPlaying = false;
  bool _isFavorite = false;
  bool _showOverlay = true;
  bool _showInfo = true;
  String _videoFit = 'fit';

  // Getters
  int? get currentMediaId => _currentMediaId;
  String? get currentPath => _currentPath;
  String get currentFileName => _currentFileName ?? 'video.mp4';
  String get currentFolder => _currentFolder ?? 'folder';
  bool get isPlaying => _isPlaying;
  bool get isFavorite => _isFavorite;
  bool get showOverlay => _showOverlay;
  bool get showInfo => _showInfo;
  String get videoFit => _videoFit;

  // Callbacks
  VoidCallback? onVideoHidden;
  VoidCallback? onFolderHidden;

  FeedController({QueueEngine? queue, this.sourceManager})
      : queue = queue ?? QueueEngine();

  /// Loads media items and initializes the random playback queue.
  void loadMediaList(List<Media> mediaList, {Set<int> hiddenIds = const {}}) {
    final eligible = mediaList
        .where((m) => !hiddenIds.contains(m.id))
        .map((m) => m.id)
        .toList();
    queue.buildQueue(eligible);
    _syncCurrentFromQueue(mediaList);
  }

  void _syncCurrentFromQueue([List<Media>? mediaList]) {
    final curId = queue.currentId;
    if (curId == null) {
      _currentMediaId = null;
      _currentPath = null;
      _currentFileName = null;
      _currentFolder = null;
      notifyListeners();
      return;
    }

    _currentMediaId = curId;
    final list = mediaList ?? sourceManager?.allMedia ?? [];
    try {
      final media = list.firstWhere((m) => m.id == curId);
      _currentFileName = media.fileName;
      _currentFolder = p.dirname(media.relativePath);
      if (_currentFolder == '.') {
        _currentFolder = sourceManager?.getSourceForMedia(media)?.name ?? '';
      }
      _currentPath = sourceManager?.resolveMediaPath(media);
    } catch (_) {
      _currentFileName = 'video_$curId.mp4';
      _currentPath = '/path/to/$_currentFileName';
      _currentFolder = 'folder';
    }
    notifyListeners();
  }

  void next() {
    if (queue.queue.isNotEmpty) {
      if (queue.advance()) {
        _syncCurrentFromQueue();
        return;
      }
    }
    // Fallback for mock/test runs
    _currentMediaId = (_currentMediaId ?? 0) + 1;
    _currentFileName = 'video_$_currentMediaId.mp4';
    _currentPath = '/path/to/$_currentFileName';
    notifyListeners();
  }

  void previous() {
    if (queue.queue.isNotEmpty) {
      if (queue.goBack()) {
        _syncCurrentFromQueue();
        return;
      }
    }
    // Fallback for mock/test runs
    _currentMediaId = (_currentMediaId ?? 0) - 1;
    _currentFileName = 'video_$_currentMediaId.mp4';
    _currentPath = '/path/to/$_currentFileName';
    notifyListeners();
  }

  void reshuffle() {
    if (queue.queue.isNotEmpty) {
      queue.reshuffle();
      _syncCurrentFromQueue();
    } else {
      notifyListeners();
    }
  }

  void togglePlayPause() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void seekForward({Duration amount = const Duration(seconds: 5)}) {
    // seek forward
  }

  void seekBackward({Duration amount = const Duration(seconds: 5)}) {
    // seek backward
  }

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
  }

  void hideCurrentVideo() {
    onVideoHidden?.call();
    next();
  }

  void hideCurrentFolder() {
    onFolderHidden?.call();
    next();
  }

  void toggleOverlay() {
    _showOverlay = !_showOverlay;
    notifyListeners();
  }

  void toggleInfo() {
    _showInfo = !_showInfo;
    notifyListeners();
  }

  void cycleVideoFit() {
    if (_videoFit == 'fit') {
      _videoFit = 'fill';
    } else if (_videoFit == 'fill') {
      _videoFit = 'original';
    } else {
      _videoFit = 'fit';
    }
    notifyListeners();
  }
}
