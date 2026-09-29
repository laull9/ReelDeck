import 'package:flutter/foundation.dart';

class AppSettings extends ChangeNotifier {
  bool autoplay = true;
  bool loopQueue = true;
  String videoFit = 'fit';
  bool rememberPosition = false;
  double defaultVolume = 1.0;
  bool recursiveScan = true;
  bool showFilename = true;
  bool showFolder = true;

  void update({
    bool? autoplay,
    bool? loopQueue,
    String? videoFit,
    bool? rememberPosition,
    double? defaultVolume,
    bool? recursiveScan,
    bool? showFilename,
    bool? showFolder,
  }) {
    if (autoplay != null) this.autoplay = autoplay;
    if (loopQueue != null) this.loopQueue = loopQueue;
    if (videoFit != null) this.videoFit = videoFit;
    if (rememberPosition != null) this.rememberPosition = rememberPosition;
    if (defaultVolume != null) this.defaultVolume = defaultVolume;
    if (recursiveScan != null) this.recursiveScan = recursiveScan;
    if (showFilename != null) this.showFilename = showFilename;
    if (showFolder != null) this.showFolder = showFolder;
    notifyListeners();
  }
}
