import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../controllers/log_controller.dart';
import '../theme/status_colors.dart';

String _monthName(int month) {
  const names = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return names[month - 1];
}

class LogViewer extends StatefulWidget {
  const LogViewer({super.key});

  @override
  State<LogViewer> createState() => _LogViewerState();
}

class _LogViewerState extends State<LogViewer> {
  final Set<int> _expanded = {};

  void _toggleExpanded(int index) {
    setState(() {
      if (_expanded.contains(index)) {
        _expanded.remove(index);
      } else {
        _expanded.add(index);
      }
    });
  }

  void _copyError(String? error) {
    if (error == null || error.isEmpty) return;
    Clipboard.setData(ClipboardData(text: error));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logController = context.watch<LogController>();
    final logs = logController.failures;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                    'Debug Logs',
                    style: GoogleFonts.staatliches().copyWith(
                      fontSize: 20,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  if (logs.isNotEmpty)
                    TextButton(
                      onPressed: () => logController.clear(),
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (logs.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No failures logged yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: logs.length,
                  itemBuilder: (c, i) {
                    final log = logs[i];
                    final isExpanded = _expanded.contains(i);
                    final timeStr =
                        '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}';
                    final dateStr =
                        '${_monthName(log.timestamp.month)} ${log.timestamp.day}';

                    return InkWell(
                      onTap: () => _toggleExpanded(i),
                      onLongPress: () => _copyError(log.errorMessage),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            dense: true,
                            leading: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colorScheme.statusError,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            title: Text(
                              log.target,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${log.method}  •  ${log.statusCode?.toString() ?? '—'}  •  ${log.pingMs}ms',
                                  style: theme.textTheme.bodySmall,
                                ),
                                if (log.errorMessage != null)
                                  Text(
                                    log.errorMessage!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.statusError,
                                    ),
                                    maxLines: isExpanded ? null : 2,
                                    overflow: isExpanded ? null : TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                            trailing: Text(
                              '$dateStr\n$timeStr',
                              textAlign: TextAlign.right,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
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
