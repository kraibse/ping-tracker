import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'controllers/entry_controller.dart';
import 'controllers/settings_controller.dart';
import 'models/app_settings.dart';
import 'models/track_entry.dart';
import 'models/check_log.dart';
import 'models/check_visual.dart';
import 'controllers/log_controller.dart';
import 'widgets/animated_list_item.dart';
import 'widgets/entry_card.dart';
import 'widgets/entry_dialog.dart';
import 'widgets/group_filter_chips.dart';
import 'widgets/quick_history_list.dart';
import 'widgets/quick_input.dart';
import 'screens/settings_page.dart';
import 'widgets/log_viewer.dart';
import 'widgets/empty_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TrackEntryAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(CheckLogAdapter());

  final settingsController = SettingsController();
  await settingsController.init();
  final logController = LogController();
  await logController.init();
  final entryController = EntryController(
    settings: settingsController,
    logs: logController,
  );
  await entryController.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsController),
        ChangeNotifierProvider.value(value: logController),
        ChangeNotifierProvider.value(value: entryController),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>().value;
    final baseTheme = ThemeData(
      colorSchemeSeed: Colors.indigo,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
    );
    return MaterialApp(
      title: 'Ping Tracker',
      debugShowCheckedModeBanner: false,
      theme: baseTheme,
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      themeMode: settings.useDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _quickCtrl = TextEditingController();
  bool _quickLoading = false;
  final List<CheckVisual> _quickResults = <CheckVisual>[];
  final Set<String> _inFlightTargets = <String>{};
  String? _inFlightEntryId;

  @override
  void dispose() {
    _quickCtrl.dispose();
    super.dispose();
  }

  Future<void> _runQuickCheck() async {
    if (_quickCtrl.text.trim().isEmpty) return;
    final target = _quickCtrl.text.trim();
    HapticFeedback.mediumImpact();
    setState(() {
      _quickLoading = true;
      _insertOrUpdateHistory(CheckVisual.loading(target));
      _inFlightTargets.add(target);
    });
    final res = await context.read<EntryController>().quickCheck(target);
    setState(() {
      _quickLoading = false;
      _inFlightTargets.remove(target);
      _insertOrUpdateHistory(CheckVisual.from(res, target));
      if (_quickResults.length > 50) {
        _quickResults.removeRange(50, _quickResults.length);
      }
    });
  }

  Future<void> _retryQuickCheck(String target) async {
    setState(() {
      _quickLoading = true;
      _insertOrUpdateHistory(CheckVisual.loading(target));
      _inFlightTargets.add(target);
    });
    final res = await context.read<EntryController>().quickCheck(target);
    setState(() {
      _quickLoading = false;
      _inFlightTargets.remove(target);
      _insertOrUpdateHistory(CheckVisual.from(res, target));
      if (_quickResults.length > 50) {
        _quickResults.removeRange(50, _quickResults.length);
      }
    });
  }

  void _insertOrUpdateHistory(CheckVisual visual) {
    final existingIndex = _quickResults.indexWhere(
      (r) => r.target.toLowerCase() == visual.target.toLowerCase(),
    );
    if (existingIndex != -1) {
      _quickResults.removeAt(existingIndex);
    }
    _quickResults.insert(0, visual);
  }

  @override
  Widget build(BuildContext context) {
    final entryController = context.watch<EntryController>();
    final settings = context.watch<SettingsController>();
    final groups = entryController.groups;
    final currentGroup = settings.value.activeGroupFilter;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.wifi_tethering, size: 24),
            const SizedBox(width: 6),
            Text(
              'Ping Tracker',
              style: GoogleFonts.staatliches().copyWith(letterSpacing: 1.2),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Add entry',
            icon: const Icon(Icons.add),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showAddDialog();
            },
          ),
          IconButton(
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              HapticFeedback.lightImpact();
              await entryController.runChecks();
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () async {
              HapticFeedback.lightImpact();
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
              if (!mounted) return;
              entryController.refreshTimer();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Debug logs',
        onPressed: () {
          HapticFeedback.lightImpact();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => const LogViewer(),
          );
        },
        child: const Icon(Icons.bug_report_outlined),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                QuickInput(
                  controller: _quickCtrl,
                  loading: _quickLoading,
                  onRun: _runQuickCheck,
                ),
                const SizedBox(height: 8),
                if (_quickResults.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'History (${_quickResults.length})',
                          style: GoogleFonts.staatliches().copyWith(
                            letterSpacing: 1.1,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              setState(() => _quickResults.clear()),
                          child: const Text('Clear all'),
                        ),
                      ],
                    ),
                  ),
                if (_quickResults.isNotEmpty)
                  QuickHistoryList(
                    results: _quickResults,
                    onRetry: _retryQuickCheck,
                    onSave: (target) async {
                      await _showAddDialog(prefillTarget: target);
                      setState(() {
                        _quickResults.removeWhere(
                          (r) => r.target.toLowerCase() == target.toLowerCase(),
                        );
                      });
                    },
                  ),
              ],
            ),
          ),
          GroupFilterChips(
            groups: groups,
            selected: currentGroup,
            onSelected: (g) => settings.update(activeGroup: g ?? ''),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
            child: const Divider(height: 1),
          ),
          Expanded(
            child: entryController.entries.isEmpty
                ?                 EmptyState(onAdd: () => _showAddDialog())
                : RefreshIndicator(
                    onRefresh: () => entryController.runChecks(),
                    child: ListView.builder(
                      itemCount: entryController.entries.length,
                      itemBuilder: (c, i) {
                        final e = entryController.entries[i];
                        final isEntryLoading = _inFlightEntryId == e.id;
                        return AnimatedListItem(
                          index: i,
                          child: EntryCard(
                            entry: e,
                            isLoading: isEntryLoading,
                            onCheckNow: () async {
                              setState(() => _inFlightEntryId = e.id);
                              await entryController.runCheckFor(e);
                              if (mounted) {
                                setState(() => _inFlightEntryId = null);
                              }
                            },
                            onEdit: () async => _showEditDialog(e),
                            onDelete: () async => entryController.deleteEntry(e),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDialog({String? prefillTarget}) async {
    final entryController = context.read<EntryController>();
    final settingsController = context.read<SettingsController>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EntryDialog(
          prefillTarget: prefillTarget,
          onSave: ({required target, alias, group}) async {
            if (group != null && group.isNotEmpty) {
              await settingsController.addGroup(group);
            }
            final newEntry = await entryController.addEntry(
              target: target,
              alias: alias,
              group: group,
            );
            if (!mounted) return;
            setState(() => _inFlightEntryId = newEntry.id);
            Navigator.of(context).pop();
            await entryController.runCheckFor(newEntry);
            if (!mounted) return;
            setState(() => _inFlightEntryId = null);
          },
        ),
      ),
    );
  }

  Future<void> _showEditDialog(TrackEntry entry) async {
    final entryController = context.read<EntryController>();
    final settingsController = context.read<SettingsController>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EntryDialog(
          entry: entry,
          onSave: ({required target, alias, group}) async {
            if (group != null && group.isNotEmpty && group != entry.group) {
              await settingsController.addGroup(group);
            }
            await entryController.updateEntry(
              entry,
              target: target,
              alias: alias,
              group: group,
            );
            if (!mounted) return;
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

// Inline helper widgets moved into lib/widgets and lib/models for clarity.
