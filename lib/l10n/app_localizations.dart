import 'package:flutter/widgets.dart';

import 'messages_en.dart';
import 'messages_zh.dart';
import 'messages_ja.dart';
import 'messages_es.dart';
import 'messages_fr.dart';

class AppLocalizations {
  final Locale locale;
  final Map<String, String> _strings;

  AppLocalizations(this.locale) : _strings = _loadStrings(locale);

  static const supportedLocales = [
    Locale('en'),
    Locale('zh'),
    Locale('ja'),
    Locale('es'),
    Locale('fr'),
  ];

  static Map<String, String> _loadStrings(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return messagesZh;
      case 'ja':
        return messagesJa;
      case 'es':
        return messagesEs;
      case 'fr':
        return messagesFr;
      case 'en':
      default:
        return messagesEn;
    }
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('zh'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String get(String key) => _strings[key] ?? messagesEn[key] ?? key;

  // Feed Screen
  String get selectFolderToStart => get('selectFolderToStart');
  String get noVideosInRange => get('noVideosInRange');
  String get checkFoldersOrRescan => get('checkFoldersOrRescan');
  String get addFolder => get('addFolder');
  String get restoreHidden => get('restoreHidden');
  String get retry => get('retry');
  String get skip => get('skip');
  String get manageFolders => get('manageFolders');
  String get imageDecodeFailed => get('imageDecodeFailed');
  String get previous => get('previous');
  String get play => get('play');
  String get pause => get('pause');
  String get next => get('next');
  String get fullscreen => get('fullscreen');
  String get exitFullscreen => get('exitFullscreen');
  String get reshuffle => get('reshuffle');
  String get mute => get('mute');
  String get unmute => get('unmute');
  String get allVideos => get('allVideos');
  String get favorites => get('favorites');
  String get chooseFolderEllipsis => get('chooseFolderEllipsis');
  String get chooseFolder => get('chooseFolder');
  String get noMatchingFolders => get('noMatchingFolders');
  String get cancel => get('cancel');
  String get settings => get('settings');
  String get playbackErrors => get('playbackErrors');
  String get noPlaybackErrors => get('noPlaybackErrors');
  String get clearLog => get('clearLog');
  String get close => get('close');

  // Actions
  String get playFolderOnly => get('playFolderOnly');
  String get showInFileManager => get('showInFileManager');
  String get safNotice => get('safNotice');
  String get moveToTrash => get('moveToTrash');
  String get androidTrashNotice => get('androidTrashNotice');
  String get confirmMoveToTrash => get('confirmMoveToTrash');
  String get moreActions => get('moreActions');
  String get hideVideo => get('hideVideo');
  String get hideFolder => get('hideFolder');
  String get hiddenVideoHint => get('hiddenVideoHint');
  String get hiddenFolderHint => get('hiddenFolderHint');

  // Settings
  String get sectionPlayback => get('sectionPlayback');
  String get autoplay => get('autoplay');
  String get loopQueue => get('loopQueue');
  String get videoFit => get('videoFit');
  String get fitContain => get('fitContain');
  String get fitCover => get('fitCover');
  String get fitOriginal => get('fitOriginal');
  String get rememberPosition => get('rememberPosition');
  String get defaultVolume => get('defaultVolume');
  String get decoderSection => get('decoderSection');
  String get decoderMode => get('decoderMode');
  String get decoderAuto => get('decoderAuto');
  String get decoderAutoSafe => get('decoderAutoSafe');
  String get decoderSoftware => get('decoderSoftware');
  String get sectionQueue => get('sectionQueue');
  String get queueOrder => get('queueOrder');
  String get queueOrderDesc => get('queueOrderDesc');
  String get orderShuffle => get('orderShuffle');
  String get orderSmart => get('orderSmart');
  String get orderNewest => get('orderNewest');
  String get orderOldest => get('orderOldest');
  String get reshuffleAfterRound => get('reshuffleAfterRound');
  String get reshuffleDesc => get('reshuffleDesc');
  String get includeImages => get('includeImages');
  String get includeImagesDesc => get('includeImagesDesc');
  String get imageSeconds => get('imageSeconds');
  String get secondsUnit => get('secondsUnit');
  String get sectionSources => get('sectionSources');
  String get manageVideoSources => get('manageVideoSources');
  String get recursiveScan => get('recursiveScan');
  String get autoRefreshFolders => get('autoRefreshFolders');
  String get autoRefreshFoldersDesc => get('autoRefreshFoldersDesc');
  String get preloadVideos => get('preloadVideos');
  String get preloadVideosDesc => get('preloadVideosDesc');
  String get externalDriveOptimization => get('externalDriveOptimization');
  String get externalDriveDesc => get('externalDriveDesc');
  String get sectionDisplay => get('sectionDisplay');
  String get overlayMode => get('overlayMode');
  String get overlayModeDesc => get('overlayModeDesc');
  String get overlayFull => get('overlayFull');
  String get overlayProgress => get('overlayProgress');
  String get overlayNone => get('overlayNone');
  String get animations => get('animations');
  String get doubleTapFavorite => get('doubleTapFavorite');
  String get showFilename => get('showFilename');
  String get showFolder => get('showFolder');
  String get showQueueProgress => get('showQueueProgress');
  String get showQueueProgressDesc => get('showQueueProgressDesc');
  String get showFileSize => get('showFileSize');
  String get showFileSizeDesc => get('showFileSizeDesc');
  String get showVideoFormat => get('showVideoFormat');
  String get sectionShortcuts => get('sectionShortcuts');
  String get enableShortcuts => get('enableShortcuts');
  String get shortcutsSettings => get('shortcutsSettings');
  String get shortcutsSettingsDesc => get('shortcutsSettingsDesc');
  String get sectionLanguage => get('sectionLanguage');
  String get language => get('language');
  String get languageSystem => get('languageSystem');
  String get sectionAbout => get('sectionAbout');
  String get appDescription => get('appDescription');

  // Sources Screen
  String get videoSources => get('videoSources');
  String get rescanAll => get('rescanAll');
  String get emptySourcesHint => get('emptySourcesHint');
  String get scanning => get('scanning');
  String get items => get('items');
  String get itemsUnavailable => get('itemsUnavailable');
  String get includeSubfolders => get('includeSubfolders');
  String get rescan => get('rescan');
  String get remove => get('remove');
  String get confirmRemoveSource => get('confirmRemoveSource');
  String get confirm => get('confirm');

  String get resetDefaults => get('resetDefaults');
  String get resetShortcutsTitle => get('resetShortcutsTitle');
  String get resetShortcutsContent => get('resetShortcutsContent');
  String get confirmReset => get('confirmReset');
  String get save => get('save');
  String get editShortcut => get('editShortcut');
  String get keys => get('keys');
  String get addKey => get('addKey');
  String get clear => get('clear');
  String get pressKeyToRecord => get('pressKeyToRecord');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh', 'ja', 'es', 'fr'].contains(
    locale.languageCode,
  );

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
