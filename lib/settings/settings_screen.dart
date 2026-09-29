import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/routes.dart';
import 'settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Playback'),
          SwitchListTile(
            title: const Text('Autoplay'),
            value: settings.autoplay,
            onChanged: (val) => settings.update(autoplay: val),
          ),
          SwitchListTile(
            title: const Text('Loop Queue'),
            value: settings.loopQueue,
            onChanged: (val) => settings.update(loopQueue: val),
          ),
          ListTile(
            title: const Text('Video Fit'),
            trailing: DropdownButton<String>(
              value: settings.videoFit,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'fit', child: Text('Fit')),
                DropdownMenuItem(value: 'fill', child: Text('Fill')),
                DropdownMenuItem(value: 'original', child: Text('Original')),
              ],
              onChanged: (val) {
                if (val != null) settings.update(videoFit: val);
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Remember Position'),
            value: settings.rememberPosition,
            onChanged: (val) => settings.update(rememberPosition: val),
          ),
          ListTile(
            title: const Text('Default Volume'),
            subtitle: Slider(
              value: settings.defaultVolume,
              min: 0.0,
              max: 1.0,
              onChanged: (val) => settings.update(defaultVolume: val),
            ),
            trailing: Text('${(settings.defaultVolume * 100).round()}%'),
          ),
          
          _buildSectionHeader('Shuffle'),
          SwitchListTile(
            title: const Text('Reshuffle After Round'),
            value: settings.loopQueue,
            onChanged: (val) => settings.update(loopQueue: val),
          ),
          
          _buildSectionHeader('Storage'),
          ListTile(
            title: const Text('Manage Sources'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.sources),
          ),
          SwitchListTile(
            title: const Text('Recursive Scan'),
            value: settings.recursiveScan,
            onChanged: (val) => settings.update(recursiveScan: val),
          ),
          
          _buildSectionHeader('Interface'),
          SwitchListTile(
            title: const Text('Show Filename'),
            value: settings.showFilename,
            onChanged: (val) => settings.update(showFilename: val),
          ),
          SwitchListTile(
            title: const Text('Show Folder'),
            value: settings.showFolder,
            onChanged: (val) => settings.update(showFolder: val),
          ),
          
          _buildSectionHeader('About'),
          const ListTile(
            title: Text('ReelDeck'),
            subtitle: Text('Local video random player'),
            trailing: Text('v0.1.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.deepPurpleAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
