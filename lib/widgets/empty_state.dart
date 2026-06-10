import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const EmptyState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_tethering_off, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          const Text('No entries yet', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          const Text(
            'Add a URL or IP to start tracking',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add entry'),
          ),
        ],
      ),
    );
  }
}
