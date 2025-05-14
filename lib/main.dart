import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:race_tracker/data/repository/firebase_participant_repository.dart';
import 'package:race_tracker/data/repository/firebase_stamp_repository.dart';
import 'package:race_tracker/firebase_options.dart';
import 'package:race_tracker/model/participant.dart';
import 'package:race_tracker/model/stamp.dart';
import 'package:race_tracker/utils/enum.dart';
import 'package:race_tracker/provider/participant_provider.dart';
import 'package:race_tracker/views/create_participant_screen.dart';
import 'package:race_tracker/views/dashboard.dart';
import 'package:race_tracker/views/edit_participant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // FirebaseParticipantRepository participantRepo = FirebaseParticipantRepository();
  Logger logger = Logger();
  // logger.d("Firebase initialized");
  // logger.d("Adding participants to the repository");

  // participantRepo.addParticipant(Participant(name: "Tithya", age: 24, gender: Gender.male));

  FirebaseStampRepository stampRepo = FirebaseStampRepository();
  logger.d("Adding stamps to the repository");

  Stamp stamp1 = Stamp(
    
    segment: 'Running',
    time: DateTime.now(),
  );
  await stampRepo.addStamp(stamp1);

  logger.d("Stamps added to the repository");

  stamp1.bib = 1001;

  logger.d("Updating Stamps in the repository");
  await stampRepo.updateStamp(stamp1);
  logger.d("Stamps updated in the repository");

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
