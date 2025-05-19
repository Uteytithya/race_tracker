import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:race_tracker/data/repository/firebase_participant_repository.dart';
import 'package:race_tracker/data/repository/firebase_stamp_repository.dart';
import 'package:race_tracker/firebase_options.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/model/stamp.dart';
import 'package:race_tracker/provider/race_provider.dart';
import 'package:race_tracker/provider/stamp_provider.dart';
import 'package:race_tracker/utils/enum.dart';
import 'package:race_tracker/provider/participant_provider.dart';
import 'package:race_tracker/views/participant/create_participant_screen.dart';
import 'package:race_tracker/views/dashboard.dart';
import 'package:race_tracker/views/participant/edit_participant.dart';

import 'package:race_tracker/views/result/race_screen.dart';
import 'package:race_tracker/views/result/result_screen.dart';
import 'package:race_tracker/views/track/track_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ParticipantProvider()),
        ChangeNotifierProvider(create: (_) => StampProvider()),
        ChangeNotifierProvider(create: (_) => RaceProvider()),
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
          '/createParticipant': (context) => const CreateParticipantScreen(),
          '/editParticipant': (context) => const EditParticipantScreen(),
          '/track': (context) => const TrackScreen(),
          '/race': (context) => const RaceScreen(),
          '/result': (context) => const ResultScreen(),
        },
        onUnknownRoute:
            (settings) =>
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
      ),
    );
  }
}
