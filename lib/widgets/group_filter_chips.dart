import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupFilterChips extends StatelessWidget {
  final List<String> groups;
  final String? selected;
  final void Function(String? group) onSelected;

  const GroupFilterChips({
    super.key,
    required this.groups,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          ChoiceChip(
            label: Text(
              'All',
              style: GoogleFonts.staatliches().copyWith(letterSpacing: 1.1),
            ),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          const SizedBox(width: 8),
          ...groups.map(
            (g) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(
                  g,
                  style: GoogleFonts.staatliches().copyWith(letterSpacing: 1.1),
                ),
                selected: selected == g,
                onSelected: (_) => onSelected(g),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
