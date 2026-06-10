import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late int _interval;
  late bool _dark;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsController>().value;
    _interval = s.checkIntervalSeconds;
    _dark = s.useDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            value: _dark,
            onChanged: (v) => setState(() => _dark = v),
            title: const Text('Dark mode'),
            subtitle: const Text('Use the dark theme'),
          ),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Check interval'),
            subtitle: Text('Every $_interval seconds'),
            trailing: DropdownButton<int>(
              value: _interval,
              items: const [5, 10, 15, 30, 60]
                  .map((e) => DropdownMenuItem(value: e, child: Text('$e s')))
                  .toList(),
              onChanged: (v) => setState(() => _interval = v ?? _interval),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              await context.read<SettingsController>().update(
                intervalSeconds: _interval,
                useDarkMode: _dark,
              );
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
