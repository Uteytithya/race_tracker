import 'package:flutter/material.dart';

class TrackSegmentTab extends StatelessWidget {
  const TrackSegmentTab({
    super.key,
    required this.selectedSegment,
    required this.onSegmentSelected,
  });

  final String selectedSegment;
  final ValueChanged<String> onSegmentSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          for (final segment in ['Run', 'Cycle', 'Swim'])
            Expanded(
              child: GestureDetector(
                onTap: () {
                  onSegmentSelected(segment);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        selectedSegment == segment
                            ? Colors.white
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      segment,
                      style: TextStyle(
                        color:
                            selectedSegment == segment
                                ? const Color(0xFF4758E0)
                                : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
