import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/entry_controller.dart';
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

  void _showGroupManager() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _GroupManagerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final groupCount = settings.value.groups.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.staatliches().copyWith(letterSpacing: 1.2),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            value: _dark,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              setState(() => _dark = v);
            },
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
          const Divider(height: 32),
          _SectionTitle('Groups'),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Manage groups'),
            subtitle: Text('$groupCount group${groupCount == 1 ? '' : 's'}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showGroupManager,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.staatliches().copyWith(
        fontSize: 14,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _GroupManagerSheet extends StatefulWidget {
  const _GroupManagerSheet();

  @override
  State<_GroupManagerSheet> createState() => _GroupManagerSheetState();
}

class _GroupManagerSheetState extends State<_GroupManagerSheet> {
  final TextEditingController _addCtrl = TextEditingController();
  String? _editingGroup;
  final TextEditingController _editCtrl = TextEditingController();

  @override
  void dispose() {
    _addCtrl.dispose();
    _editCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final entryController = context.watch<EntryController>();
    final groups = settings.value.groups;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Count entries per group for warning display
    final Map<String, int> entryCounts = {};
    for (final e in entryController.entries) {
      final g = e.group ?? '';
      if (g.isNotEmpty) {
        entryCounts[g] = (entryCounts[g] ?? 0) + 1;
      }
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Groups',
                    style: GoogleFonts.staatliches().copyWith(
                      fontSize: 20,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${groups.length}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _addCtrl,
                      decoration: InputDecoration(
                        hintText: 'New group name',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (v) async {
                        if (v.trim().isNotEmpty) {
                          await settings.addGroup(v.trim());
                          _addCtrl.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () async {
                      if (_addCtrl.text.trim().isNotEmpty) {
                        await settings.addGroup(_addCtrl.text.trim());
                        _addCtrl.clear();
                      }
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            if (groups.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No groups yet. Create one above.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: groups.length,
                  itemBuilder: (c, i) {
                    final g = groups[i];
                    final count = entryCounts[g] ?? 0;
                    final isEditing = _editingGroup == g;

                    if (isEditing) {
                      return ListTile(
                        leading: const Icon(Icons.edit_outlined, size: 20),
                        title: TextField(
                          controller: _editCtrl,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (v) async {
                            if (v.trim().isNotEmpty) {
                              await settings.renameGroup(g, v.trim());
                            }
                            setState(() => _editingGroup = null);
                          },
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, size: 20),
                              onPressed: () async {
                                if (_editCtrl.text.trim().isNotEmpty) {
                                  await settings.renameGroup(g, _editCtrl.text.trim());
                                }
                                setState(() => _editingGroup = null);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () => setState(() => _editingGroup = null),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListTile(
                      leading: const Icon(Icons.folder_outlined, size: 20),
                      title: Text(g),
                      subtitle: count > 0 ? Text('$count entr${count == 1 ? 'y' : 'ies'}') : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () {
                              _editCtrl.text = g;
                              setState(() => _editingGroup = g);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete group?'),
                                  content: count > 0
                                      ? Text('$count entr${count == 1 ? 'y' : 'ies'} in this group will become ungrouped.')
                                      : const Text('This group is empty.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await settings.deleteGroup(g);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
