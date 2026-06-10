import 'package:flutter/material.dart';

class QuickInput extends StatelessWidget {
  final TextEditingController controller;
  final bool loading;
  final VoidCallback onRun;
  const QuickInput({
    super.key,
    required this.controller,
    required this.loading,
    required this.onRun,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Quick check URL, host, or host:port…',
            filled: true,
            fillColor: const Color.fromARGB(255, 10, 10, 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : (value.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear',
                          onPressed: () => controller.clear(),
                        )
                      : null),
          ),
          onSubmitted: (_) => onRun(),
          textInputAction: TextInputAction.search,
        );
      },
    );
  }
}
