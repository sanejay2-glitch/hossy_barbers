import 'package:flutter/widgets.dart';
import 'package:hossy_barbers/app/app.dart';
import 'package:hossy_barbers/core/firebase/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseState = await FirebaseBootstrap.initialize();
  runApp(HossyBarbersApp(firebaseState: firebaseState));
}
