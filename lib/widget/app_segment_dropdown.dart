import 'package:flutter/material.dart';

class AppSegmentDropdown extends StatelessWidget {

  final List<String> segments;
  final String selectedSegment;
  final ValueChanged<String> onSegmentChanged;
  const AppSegmentDropdown({super.key, required this.segments, required this.selectedSegment, required this.onSegmentChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButton<String>(
        value: selectedSegment,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        elevation: 16,
        underline: Container(height: 0),
        style: const TextStyle(color: Colors.white),
        dropdownColor: const Color(0xFF354AC2),
        onChanged: (String? value) {
          if (value != null) {
            onSegmentChanged(value);
          }
        },
        items: segments.map((value) => DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        )).toList(),
      ),
    );
  }
}

class AppSegmentHeader extends StatelessWidget {
  const AppSegmentHeader({super.key, required this.selectedSegment, required this.segments, required this.onSegmentChanged});

  final String selectedSegment;
  final List<String> segments;
  final ValueChanged<String> onSegmentChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            selectedSegment == 'Overall'
                ? 'Overall Results'
                : '$selectedSegment Results',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSegmentDropdown(
            segments: segments,
            selectedSegment: selectedSegment,
            onSegmentChanged: (value) {
              onSegmentChanged(value);
            },
          ),
        ],
      ),
    );
  }
}