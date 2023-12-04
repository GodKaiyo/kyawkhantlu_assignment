import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import './firebase_options.dart';
import './app.dart';
import 'package:provider/provider.dart';
import 'models/UserEmailProvider.dart';
import 'package:dcdg/dcdg.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Create an instance of UserEmailProvider
  UserEmailProvider userEmailProvider = UserEmailProvider();

  // Load data from shared preferences
  await userEmailProvider.loadFromSharedPreferences();

  runApp(
    ChangeNotifierProvider.value(
      value: userEmailProvider,
      child: FirebaseCrud(),
    ),
  );
}
