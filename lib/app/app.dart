import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_theme.dart';
import 'package:hossy_barbers/core/firebase/firebase_bootstrap.dart';
import 'package:hossy_barbers/features/admin/presentation/admin_gate.dart';
import 'package:hossy_barbers/features/admin/presentation/admin_login_screen.dart';
import 'package:hossy_barbers/features/booking/presentation/booking_screen.dart';
import 'package:hossy_barbers/features/home/presentation/home_page.dart';

class HossyBarbersApp extends StatelessWidget {
  const HossyBarbersApp({
    super.key,
    this.firebaseState = FirebaseAppState.unconfigured,
  });

  final FirebaseAppState firebaseState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hossy Barbers',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute<void>(builder: (_) => const HomePage());
          case BookingScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) => const BookingScreen(),
            );
          case AdminLoginScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) => AdminLoginScreen(firebaseState: firebaseState),
            );
          case AdminGate.routeName:
            return MaterialPageRoute<void>(
              builder: (_) => AdminGate(firebaseState: firebaseState),
            );
          default:
            return MaterialPageRoute<void>(builder: (_) => const HomePage());
        }
      },
    );
  }
}
