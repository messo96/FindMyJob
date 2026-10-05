import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      // Phase 3: override providers here for production:
      // overrides: [
      //   jobsRepositoryProvider.overrideWith((_) => FirebaseJobsRepository()),
      //   authRepositoryProvider.overrideWith((_) => FirebaseAuthRepository()),
      //   profileRepositoryProvider.overrideWith((_) => FirebaseProfileRepository()),
      // ],
      child: FindMyJobApp(),
    ),
  );
}
