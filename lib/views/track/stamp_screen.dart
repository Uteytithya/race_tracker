import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracker/model/stamp.dart';
import 'package:race_tracker/provider/stamp_provider.dart';
import 'package:race_tracker/widget/navbar.dart';
import 'dart:async';

class StampScreen extends StatefulWidget {
  const StampScreen({super.key});

  @override
  State<StampScreen> createState() => _StampScreenState();
}

class _StampScreenState extends State<StampScreen> {
  int _activeTab = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Fetch un-bibbed stamps when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StampProvider>().getStamps();
    });
  }

  // Show modal to add Bib information to a specific stamp
  void _showAddBibModal(Stamp stamp) {
    TextEditingController bibController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bibController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Enter Bib",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  String bibText = bibController.text.trim();
                  if (bibText.isNotEmpty) {
                    Navigator.of(context).pop();
                    final int bib = int.tryParse(bibText) ?? 0;

                    // Update the stamp with the bib and move it to the participant's stamps
                    Provider.of<StampProvider>(context, listen: false)
                        .addStampToParticipant(stamp, bib);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Bib added: $bib to stamp from ${stamp.segment}"),
                        duration: const Duration(seconds: 1),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: const Text("Save Bib"),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Header_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay
          Container(color: Colors.black.withOpacity(0.2)),

          // Header
          Column(
            children: [
              const SizedBox(height: 80),
              Row(
                children: [
                  Container(
                    width: 300,
                    margin: const EdgeInsets.only(left: 20),
                    child: const Text(
                      'Un-Bibbed Stamps',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Main Content
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF4758E0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  // Tab Selector
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _activeTab = 0;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _activeTab == 0
                                    ? const Color(0xFF4758E0)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  'Un-Bibbed',
                                  style: TextStyle(
                                    color: _activeTab == 0
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Navigate to Race Screen
                              Navigator.pushNamed(context, '/track');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _activeTab == 1
                                    ? const Color(0xFF4758E0)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Center(
                                child: Text(
                                  'Tracker',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // List of un-bibbed stamps
                  Expanded(
                    child: _buildUnbibbedStampsList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildUnbibbedStampsList() {
    return Consumer<StampProvider>(
      builder: (context, stampProvider, child) {
        // Filter stamps to only show those without bibs
        final unBibbedStamps = stampProvider.stamps
            .where((stamp) => stamp.bib == null || stamp.bib == 0)
            .toList();

        if (unBibbedStamps.isEmpty) {
          return const Center(
            child: Text(
              'No un-bibbed stamps available',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          itemCount: unBibbedStamps.length,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, index) {
            final stamp = unBibbedStamps[index];
            
            // Format the time nicely
            final stampTime = _formatTimeFromDateTime(stamp.time);
            
            return Dismissible(
              key: Key(stamp.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                // Remove the stamp from Firebase
                stampProvider.removeStamp(stamp);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Stamp removed'),
                    duration: Duration(seconds: 1),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF4758E0),
                    child: Icon(
                      _getIconForSegment(stamp.segment),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    "Segment: ${stamp.segment}",
                    style: const TextStyle(
                      color: Color(0xFF4758E0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Time: $stampTime",
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.add,
                      color: Color(0xFF4758E0),
                    ),
                    onPressed: () {
                      _showAddBibModal(stamp);
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper method to format DateTime to a readable time
  String _formatTimeFromDateTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
  }

  // Helper method to get an icon based on segment type
  IconData _getIconForSegment(String segment) {
    switch (segment.toLowerCase()) {
      case 'run':
        return Icons.directions_run;
      case 'cycle':
        return Icons.directions_bike;
      case 'swim':
        return Icons.pool;
      default:
        return Icons.timer;
    }
  }
}