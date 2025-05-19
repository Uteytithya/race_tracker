import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracker/views/race/widget/race_content.dart';
import 'package:race_tracker/views/race/widget/race_tab_bar.dart';
import 'package:race_tracker/widget/app_background.dart';
import 'package:race_tracker/widget/app_content.dart';
import 'package:race_tracker/widget/app_header.dart';
import 'package:race_tracker/widget/app_bottom_navbar.dart';
import 'package:race_tracker/provider/race_provider.dart'; // You'll need to create this

class RaceScreen extends StatefulWidget {
  const RaceScreen({super.key});

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch race data in the ResultScreen
    Provider.of<RaceProvider>(context, listen: false).fetchRaceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AppBackground(),
          AppHeader(title: 'Race'),
          // Main Content
          AppContent(content: RaceContent(), tabBar: RaceTabBar(context: context)),
        ],
      ),
      bottomNavigationBar: const AppBottomNavbar(),
    );
  }
}
