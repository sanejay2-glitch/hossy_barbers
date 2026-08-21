import 'package:firebase_core/firebase_core.dart';
import 'package:hossy_barbers/firebase_options.dart';

enum FirebaseAppState { ready, unconfigured, unavailable }

abstract final class FirebaseBootstrap {
  static Future<FirebaseAppState> initialize() async {
    final options = DefaultFirebaseOptions.currentPlatform;
    if (options.apiKey.isEmpty ||
        options.appId.isEmpty ||
        options.projectId.isEmpty) {
      return FirebaseAppState.unconfigured;
    }

    try {
      await Firebase.initializeApp(options: options);
      return FirebaseAppState.ready;
    } on FirebaseException {
      return FirebaseAppState.unavailable;
    }
  }
}
