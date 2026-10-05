import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/routes.dart';
import '../feed/feed_controller.dart';
import '../feed/widgets/playback_errors.dart';
import '../l10n/app_localizations.dart';
import 'choice_tile.dart';
import 'settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          _buildSectionHeader(l10n.sectionPlayback),
          SwitchListTile(
            title: Text(l10n.autoplay),
            value: settings.autoplay,
            onChanged: (val) => settings.update(autoplay: val),
          ),
          SwitchListTile(
            title: Text(l10n.loopQueue),
            value: settings.loopQueue,
            onChanged: (val) => settings.update(loopQueue: val),
          ),
          ChoiceTile<String>(
            title: l10n.videoFit,
            value: settings.videoFit,
            items: [
              DropdownMenuItem(value: 'fit', child: Text(l10n.fitContain)),
              DropdownMenuItem(value: 'fill', child: Text(l10n.fitCover)),
              DropdownMenuItem(
                value: 'original',
                child: Text(l10n.fitOriginal),
              ),
            ],
            onChanged: (val) {
              if (val != null) settings.update(videoFit: val);
            },
          ),
          SwitchListTile(
            title: Text(l10n.rememberPosition),
            value: settings.rememberPosition,
            onChanged: (val) => settings.update(rememberPosition: val),
          ),
          ListTile(
            title: Text(l10n.defaultVolume),
            subtitle: Slider(
              value: settings.defaultVolume,
              min: 0.0,
              max: 1.0,
              onChanged: (val) => settings.update(defaultVolume: val),
            ),
            trailing: Text('${(settings.defaultVolume * 100).round()}%'),
          ),

          _buildSectionHeader(l10n.decoderSection),
          ChoiceTile<String>(
            title: l10n.decoderMode,
            value: settings.decoderMode,
            items: [
              DropdownMenuItem(value: 'auto', child: Text(l10n.decoderAuto)),
              DropdownMenuItem(
                value: 'auto-safe',
                child: Text(l10n.decoderAutoSafe),
              ),
              DropdownMenuItem(value: 'no', child: Text(l10n.decoderSoftware)),
            ],
            onChanged: (val) {
              if (val != null) settings.update(decoderMode: val);
            },
          ),

          _buildSectionHeader(l10n.sectionQueue),
          ChoiceTile<String>(
            title: l10n.queueOrder,
            subtitle: l10n.queueOrderDesc,
            value: settings.queueOrder,
            items: [
              DropdownMenuItem(
                value: 'shuffle',
                child: Text(l10n.orderShuffle),
              ),
              DropdownMenuItem(value: 'smart', child: Text(l10n.orderSmart)),
              DropdownMenuItem(value: 'newest', child: Text(l10n.orderNewest)),
              DropdownMenuItem(value: 'oldest', child: Text(l10n.orderOldest)),
            ],
            onChanged: (value) => settings.update(queueOrder: value),
          ),
          SwitchListTile(
            title: Text(l10n.reshuffleAfterRound),
            subtitle: Text(l10n.reshuffleDesc),
            value: settings.reshuffleAfterRound,
            onChanged: (value) => settings.update(reshuffleAfterRound: value),
          ),
          SwitchListTile(
            title: Text(l10n.includeImages),
            subtitle: Text(l10n.includeImagesDesc),
            value: settings.includeImages,
            onChanged: (value) => settings.update(includeImages: value),
          ),
          ListTile(
            title: Text(l10n.imageSeconds),
            subtitle: Slider(
              value: settings.imageSeconds.toDouble().clamp(1, 60),
              min: 1,
              max: 60,
              divisions: 59,
              onChanged: (value) =>
                  settings.update(imageSeconds: value.round()),
            ),
            trailing: Text('${settings.imageSeconds} ${l10n.secondsUnit}'),
          ),

          _buildSectionHeader(l10n.sectionSources),
          ListTile(
            title: Text(l10n.manageVideoSources),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.sources),
          ),
          SwitchListTile(
            title: Text(l10n.autoRefreshFolders),
            subtitle: Text(l10n.autoRefreshFoldersDesc),
            value: settings.autoRefreshFolders,
            onChanged: (val) => settings.update(autoRefreshFolders: val),
          ),
          SwitchListTile(
            title: Text(l10n.recursiveScan),
            value: settings.recursiveScan,
            onChanged: (val) => settings.update(recursiveScan: val),
          ),
          SwitchListTile(
            title: Text(l10n.preloadVideos),
            subtitle: Text(l10n.preloadVideosDesc),
            value: settings.preloadNext,
            onChanged: (value) => settings.update(preloadNext: value),
          ),
          SwitchListTile(
            title: Text(l10n.externalDriveOptimization),
            subtitle: Text(l10n.externalDriveDesc),
            value: settings.externalDriveOptimization,
            onChanged: (value) =>
                settings.update(externalDriveOptimization: value),
          ),

          _buildSectionHeader(l10n.sectionDisplay),
          ChoiceTile<String>(
            title: l10n.overlayMode,
            subtitle: l10n.overlayModeDesc,
            value: settings.overlayMode,
            items: [
              DropdownMenuItem(value: 'full', child: Text(l10n.overlayFull)),
              DropdownMenuItem(
                value: 'progress',
                child: Text(l10n.overlayProgress),
              ),
              DropdownMenuItem(value: 'none', child: Text(l10n.overlayNone)),
            ],
            onChanged: (value) => settings.update(overlayMode: value),
          ),
          SwitchListTile(
            title: Text(l10n.animations),
            value: settings.animations,
            onChanged: (value) => settings.update(animations: value),
          ),
          SwitchListTile(
            title: Text(l10n.doubleTapFavorite),
            value: settings.doubleTapFavorite,
            onChanged: (value) => settings.update(doubleTapFavorite: value),
          ),
          SwitchListTile(
            title: Text(l10n.showFilename),
            value: settings.showFilename,
            onChanged: (val) => settings.update(showFilename: val),
          ),
          SwitchListTile(
            title: Text(l10n.showFolder),
            value: settings.showFolder,
            onChanged: (val) => settings.update(showFolder: val),
          ),
          SwitchListTile(
            title: Text(l10n.showQueueProgress),
            subtitle: Text(l10n.showQueueProgressDesc),
            value: settings.showQueueProgress,
            onChanged: (val) => settings.update(showQueueProgress: val),
          ),
          SwitchListTile(
            title: Text(l10n.showFileSize),
            subtitle: Text(l10n.showFileSizeDesc),
            value: settings.showFileSize,
            onChanged: (val) => settings.update(showFileSize: val),
          ),
          SwitchListTile(
            title: Text(l10n.showVideoFormat),
            value: settings.showVideoFormat,
            onChanged: (val) => settings.update(showVideoFormat: val),
          ),

          _buildSectionHeader(l10n.sectionShortcuts),
          SwitchListTile(
            title: Text(l10n.enableShortcuts),
            value: settings.keyboardEnabled,
            onChanged: (value) => settings.update(keyboardEnabled: value),
          ),
          ListTile(
            title: Text(l10n.shortcutsSettings),
            subtitle: Text(l10n.shortcutsSettingsDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.shortcuts),
          ),

          _buildSectionHeader(l10n.sectionLanguage),
          ChoiceTile<String>(
            title: l10n.language,
            value: settings.locale,
            items: [
              DropdownMenuItem(
                value: 'system',
                child: Text(l10n.languageSystem),
              ),
              const DropdownMenuItem(value: 'en', child: Text('English')),
              const DropdownMenuItem(value: 'zh', child: Text('简体中文')),
              const DropdownMenuItem(value: 'ja', child: Text('日本語')),
              const DropdownMenuItem(value: 'es', child: Text('Español')),
              const DropdownMenuItem(value: 'fr', child: Text('Français')),
            ],
            onChanged: (val) {
              if (val != null) settings.update(locale: val);
            },
          ),

          ListTile(
            title: Text(l10n.playbackErrors),
            subtitle: const Text('100'),
            onTap: () =>
                showPlaybackErrors(context, context.read<FeedController>()),
          ),
          if (settings.error != null) ListTile(title: Text(settings.error!)),
          _buildSectionHeader(l10n.sectionAbout),
          ListTile(
            title: const Text('ReelDeck'),
            subtitle: Text(l10n.appDescription),
            trailing: const Text('v0.5.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: 8.0,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF23DFA1),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
