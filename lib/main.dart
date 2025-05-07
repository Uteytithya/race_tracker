import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracker/provider/participant_provider.dart';
import 'package:race_tracker/views/create_participant_screen.dart';
import 'package:race_tracker/views/dashboard.dart';
import 'package:race_tracker/views/edit_participant.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ParticipantProvider()),
        // Add other providers here if needed in the future
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Race Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const DashboardScreen(),
          '/create': (context) => const CreateParticipantScreen(),
          '/edit': (context) => const EditParticipantScreen(),
        },
      ),
    );
  }
}