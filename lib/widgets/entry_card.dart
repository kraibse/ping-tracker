import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/track_entry.dart';
import '../theme/status_colors.dart';
import 'status_dot.dart';

class EntryCard extends StatelessWidget {
  final TrackEntry entry;
  final bool isLoading;
  final VoidCallback onCheckNow;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EntryCard({
    super.key,
    required this.entry,
    required this.isLoading,
    required this.onCheckNow,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = isLoading
        ? colorScheme.loading
        : ((entry.isAvailable ?? false) ? colorScheme.success : colorScheme.statusError);
    final isActive = (entry.isAvailable ?? false) && !isLoading;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      StatusDot(color: statusColor, isActive: isActive),
                      const SizedBox(width: 8),
                      Text(
                        entry.alias?.isNotEmpty == true
                            ? entry.alias!
                            : entry.target,
                        style: GoogleFonts.staatliches().copyWith(
                          fontSize: 16,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${entry.target}${entry.group != null && entry.group!.isNotEmpty ? '  •  ${entry.group}' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Row(
                        children: [
                          if (isLoading)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          if (isLoading) const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isLoading
                                  ? 'Checking…'
                                  : 'Ping: ${entry.lastPingMs?.toString() ?? '—'} ms  •  Status: ${entry.lastStatusCode?.toString() ?? '—'}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : PopupMenuButton<String>(
                    onSelected: (v) {
                      HapticFeedback.lightImpact();
                      switch (v) {
                        case 'run':
                          onCheckNow();
                          break;
                        case 'edit':
                          onEdit();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (c) => const [
                      PopupMenuItem(value: 'run', child: Text('Check now')),
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
