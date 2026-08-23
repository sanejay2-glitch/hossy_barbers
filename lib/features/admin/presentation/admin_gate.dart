import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hossy_barbers/core/firebase/firebase_bootstrap.dart';
import 'package:hossy_barbers/features/admin/data/admin_authorization_repository.dart';
import 'package:hossy_barbers/features/admin/presentation/admin_dashboard.dart';
import 'package:hossy_barbers/features/admin/presentation/admin_login_screen.dart';
import 'package:hossy_barbers/features/admin/services/admin_auth_service.dart';
import 'package:hossy_barbers/features/admin/data/business_settings_repository.dart';
import 'package:hossy_barbers/features/gallery/data/gallery_repository.dart';
import 'package:hossy_barbers/features/services/data/services_repository.dart';
import 'package:hossy_barbers/features/reviews/data/reviews_repository.dart';
import 'package:hossy_barbers/features/booking/data/booking_requests_repository.dart';

class AdminGate extends StatelessWidget {
  const AdminGate({super.key, required this.firebaseState});

  static const routeName = '/admin';
  final FirebaseAppState firebaseState;

  @override
  Widget build(BuildContext context) {
    if (firebaseState != FirebaseAppState.ready) {
      return AdminLoginScreen(firebaseState: firebaseState);
    }
    final authService = AdminAuthService(FirebaseAuth.instance);
    return StreamBuilder<User?>(
      stream: authService.authChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AdminLoading();
        }
        final user = snapshot.data;
        if (user == null) {
          return AdminLoginScreen(firebaseState: firebaseState);
        }
        return _AuthorizationCheck(user: user, authService: authService);
      },
    );
  }
}

class _AuthorizationCheck extends StatelessWidget {
  const _AuthorizationCheck({required this.user, required this.authService});
  final User user;
  final AdminAuthService authService;

  @override
  Widget build(BuildContext context) {
    final repository = AdminAuthorizationRepository(FirebaseFirestore.instance);
    return FutureBuilder<bool>(
      future: repository.isAuthorized(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _AdminLoading();
        }
        if (snapshot.hasError || snapshot.data != true) {
          return _Unauthorized(authService: authService);
        }
        final firestore = FirebaseFirestore.instance;
        return AdminDashboard(
          user: user,
          authService: authService,
          businessSettingsRepository: BusinessSettingsRepository(firestore),
          servicesRepository: ServicesRepository(firestore),
          galleryRepository: GalleryRepository(firestore),
          reviewsRepository: ReviewsRepository(firestore),
          bookingRequestsRepository: BookingRequestsRepository(firestore),
        );
      },
    );
  }
}

class _AdminLoading extends StatelessWidget {
  const _AdminLoading();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _Unauthorized extends StatelessWidget {
  const _Unauthorized({required this.authService});
  final AdminAuthService authService;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Admin access')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Access not authorized',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              const Text(
                'This account is not authorized to access Hossy Barbers administration.',
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: authService.signOut,
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
