import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/check_visual.dart';
import '../theme/status_colors.dart';
import 'status_dot.dart';

class QuickHistoryList extends StatelessWidget {
  final List<CheckVisual> results;
  final void Function(String target) onRetry;
  final Future<void> Function(String target) onSave;
  const QuickHistoryList({
    super.key,
    required this.results,
    required this.onRetry,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox.shrink();
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 240),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: results.length,
        itemBuilder: (context, index) {
          final r = results[index];
          final isLoading = r.isLoading;
          final colorScheme = Theme.of(context).colorScheme;
          final statusColor = isLoading
              ? colorScheme.loading
              : (r.available ? colorScheme.success : colorScheme.statusError);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StatusDot(
                                color: statusColor,
                                isActive: !isLoading && r.available,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  r.target,
                                  style: GoogleFonts.staatliches().copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (isLoading)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              if (isLoading) const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isLoading
                                      ? 'Checking…'
                                      : 'Ping: ${r.pingMs} ms  •  Status: ${r.status ?? '—'}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Save',
                          onPressed: isLoading ? null : () {
                            HapticFeedback.lightImpact();
                            onSave(r.target);
                          },
                          icon: const Icon(Icons.save_outlined),
                        ),
                        IconButton(
                          tooltip: 'Retry',
                          onPressed: isLoading ? null : () {
                            HapticFeedback.lightImpact();
                            onRetry(r.target);
                          },
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
