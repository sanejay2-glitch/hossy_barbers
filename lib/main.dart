import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hossy_barbers/app/app.dart';
import 'package:hossy_barbers/core/firebase/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final firebaseState = await FirebaseBootstrap.initialize();
  runApp(HossyBarbersApp(firebaseState: firebaseState));
}
