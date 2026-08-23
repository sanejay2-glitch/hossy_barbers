import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_theme.dart';
import 'package:hossy_barbers/core/firebase/firebase_bootstrap.dart';
import 'package:hossy_barbers/features/admin/data/business_settings_repository.dart';
import 'package:hossy_barbers/features/admin/presentation/admin_gate.dart';
import 'package:hossy_barbers/features/admin/presentation/admin_login_screen.dart';
import 'package:hossy_barbers/features/booking/presentation/booking_screen.dart';
import 'package:hossy_barbers/features/booking/data/booking_requests_repository.dart';
import 'package:hossy_barbers/features/booking/presentation/payment_screen.dart';
import 'package:hossy_barbers/features/gallery/data/gallery_repository.dart';
import 'package:hossy_barbers/features/home/presentation/home_page.dart';
import 'package:hossy_barbers/features/reviews/data/reviews_repository.dart';
import 'package:hossy_barbers/features/services/data/services_repository.dart';

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
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      onGenerateRoute: (settings) {
        final route = Uri.tryParse(settings.name ?? '/') ?? Uri(path: '/');
        switch (route.path) {
          case '/':
            return MaterialPageRoute<void>(
              builder: (_) => HomePage(
                servicesRepository: firebaseState == FirebaseAppState.ready
                    ? ServicesRepository(FirebaseFirestore.instance)
                    : null,
                businessSettingsRepository:
                    firebaseState == FirebaseAppState.ready
                    ? BusinessSettingsRepository(FirebaseFirestore.instance)
                    : null,
                galleryRepository: firebaseState == FirebaseAppState.ready
                    ? GalleryRepository(FirebaseFirestore.instance)
                    : null,
                reviewsRepository: firebaseState == FirebaseAppState.ready
                    ? ReviewsRepository(FirebaseFirestore.instance)
                    : null,
              ),
            );
          case BookingScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) => BookingScreen(
                servicesRepository: firebaseState == FirebaseAppState.ready
                    ? ServicesRepository(FirebaseFirestore.instance)
                    : null,
                galleryRepository: firebaseState == FirebaseAppState.ready
                    ? GalleryRepository(FirebaseFirestore.instance)
                    : null,
                bookingRequestsRepository:
                    firebaseState == FirebaseAppState.ready
                    ? BookingRequestsRepository(FirebaseFirestore.instance)
                    : null,
              ),
            );
          case PaymentScreen.routeName:
            return MaterialPageRoute<void>(
              builder: (_) => const PaymentScreen(),
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
