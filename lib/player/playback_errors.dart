import 'package:media_kit/media_kit.dart';

/// vd/ad 的 error 包括损坏单帧与硬解回退；是否停滞交给进度监测判断。
bool isFatalPlaybackLog(PlayerLog log) =>
    log.level == 'fatal' ||
    (log.level == 'error' &&
        const {'file', 'stream', 'cplayer'}.contains(log.prefix));
