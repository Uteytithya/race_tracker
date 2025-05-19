import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracker/views/participant/participant_form_screen.dart';
import 'package:race_tracker/views/participant/widget/dashboard_content.dart';
import 'package:race_tracker/views/participant/widget/participant_list.dart';
import 'package:race_tracker/views/participant/widget/participant_table_header.dart';
import 'package:race_tracker/views/participant/widget/participant_tile.dart';
import 'package:race_tracker/widget/app_background.dart';
import 'package:race_tracker/widget/app_bottom_navbar.dart';
import 'package:race_tracker/widget/app_content.dart';
import 'package:race_tracker/widget/app_custom_toast.dart';
import 'package:race_tracker/widget/app_header.dart';
import 'package:race_tracker/widget/app_overlay.dart';
import '../../../provider/participant_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Fetch participants when the dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchParticipants();
    });
  }

  Future<void> _fetchParticipants() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch participants from provider
      await context.read<ParticipantProvider>().fetchParticipants();
    } catch (e) {
      // Handle any errors (could show a snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching participants: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void showCustomToast({
    required BuildContext context,
    required String message,
    required VoidCallback onUndo,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: AppCustomToast(
              message: message,
              onUndo: () {
                onUndo();
                entry.remove();
              },
              onClose: () => entry.remove(),
            ),
          ),
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final participantProvider = context.watch<ParticipantProvider>();

    return Scaffold(
      body: Stack(
        children: [
          // Background
          AppBackground(),

          // Overlay
          AppOverlay(),

          // Header
          AppHeader(title: 'Dashboard'),

          // Participant List Section
          AppContent(
            content: DashboardContent(
              isLoading: _isLoading,
              participants: participantProvider.participants,
              fetchParticipants: _fetchParticipants,
              participantProvider: participantProvider,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavbar(),
    );
  }
}
