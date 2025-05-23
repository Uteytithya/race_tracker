import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:race_tracker/firebase_options.dart';
import 'package:race_tracker/provider/race_provider.dart';
import 'package:race_tracker/provider/stamp_provider.dart';
import 'package:race_tracker/provider/participant_provider.dart';
import 'package:race_tracker/views/participant/dashboard.dart';
import 'package:race_tracker/views/race/race_screen.dart';
import 'package:race_tracker/views/result/result_screen.dart';
import 'package:race_tracker/views/track/track_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ParticipantProvider()),
        ChangeNotifierProvider(create: (_) => StampProvider()),
        ChangeNotifierProxyProvider2<
          ParticipantProvider,
          StampProvider,
          RaceProvider
        >(
          create: (_) => RaceProvider(),
          update:
              (_, participantProvider, stampProvider, raceProvider) =>
                  raceProvider!
                    ..updateProviders(participantProvider, stampProvider),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Race Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const DashboardScreen(),
        routes: {
          '/dashboard': (context) => const DashboardScreen(),
          '/track': (context) => const TrackScreen(),
          '/race': (context) => const RaceScreen(),
          '/result': (context) => const ResultScreen(),
        },
        onUnknownRoute:
            (_) => MaterialPageRoute(builder: (_) => const DashboardScreen()),
      ),
    ),
  );
}
