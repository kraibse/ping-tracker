import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/settings_controller.dart';
import '../models/track_entry.dart';

class EntryDialog extends StatefulWidget {
  final TrackEntry? entry;
  final String? prefillTarget;
  final void Function({
    required String target,
    String? alias,
    String? group,
  }) onSave;

  const EntryDialog({
    super.key,
    this.entry,
    this.prefillTarget,
    required this.onSave,
  });

  @override
  State<EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<EntryDialog> {
  late final TextEditingController _targetCtrl;
  late final TextEditingController _aliasCtrl;
  String? _selectedGroup;
  bool _isNewGroup = false;
  final TextEditingController _newGroupCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _targetCtrl = TextEditingController(
      text: widget.prefillTarget ?? widget.entry?.target ?? '',
    );
    _aliasCtrl = TextEditingController(text: widget.entry?.alias ?? '');
    _selectedGroup = widget.entry?.group;
  }

  @override
  void dispose() {
    _targetCtrl.dispose();
    _aliasCtrl.dispose();
    _newGroupCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_targetCtrl.text.trim().isEmpty) return;
    final group = _isNewGroup
        ? (_newGroupCtrl.text.trim().isEmpty ? null : _newGroupCtrl.text.trim())
        : _selectedGroup;
    setState(() => _saving = true);
    widget.onSave(
      target: _targetCtrl.text.trim(),
      alias: _aliasCtrl.text.trim().isEmpty ? null : _aliasCtrl.text.trim(),
      group: group,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final groups = settings.value.groups;
    final isEditing = widget.entry != null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditing ? 'Edit entry' : 'New entry',
          style: GoogleFonts.staatliches().copyWith(letterSpacing: 1.2),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilledButton.icon(
              onPressed: _saving || _targetCtrl.text.trim().isEmpty ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check, size: 18),
              label: Text(isEditing ? 'Save' : 'Add'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            _SectionTitle('Target'),
            const SizedBox(height: 6),
            TextField(
              controller: _targetCtrl,
              decoration: InputDecoration(
                hintText: 'URL, IP, or host:port',
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.next,
              autofocus: !isEditing,
            ),
            const SizedBox(height: 24),
            _SectionTitle('Alias'),
            const SizedBox(height: 6),
            TextField(
              controller: _aliasCtrl,
              decoration: InputDecoration(
                hintText: 'Optional display name',
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 24),
            _SectionTitle('Group'),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  ...groups.map((g) => _GroupListTile(
                        label: g,
                        selected: !_isNewGroup && _selectedGroup == g,
                        onTap: () => setState(() {
                          _isNewGroup = false;
                          _selectedGroup = g;
                        }),
                      )),
                  _GroupListTile(
                    label: 'None',
                    selected: !_isNewGroup && _selectedGroup == null,
                    onTap: () => setState(() {
                      _isNewGroup = false;
                      _selectedGroup = null;
                    }),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: Icon(
                      Icons.add_circle_outline,
                      color: _isNewGroup ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                    title: _isNewGroup
                        ? TextField(
                            controller: _newGroupCtrl,
                            decoration: const InputDecoration(
                              hintText: 'New group name',
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            autofocus: true,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                          )
                        : const Text('Create new group'),
                    contentPadding: const EdgeInsets.only(left: 16, right: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    onTap: () => setState(() => _isNewGroup = true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
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

class _GroupListTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GroupListTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        selected ? Icons.check_circle : Icons.circle_outlined,
        color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        size: 22,
      ),
      title: Text(label),
      contentPadding: const EdgeInsets.only(left: 16, right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onTap: onTap,
    );
  }
}
