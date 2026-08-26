import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/core/responsive/breakpoints.dart';
import 'package:hossy_barbers/features/admin/data/business_settings_repository.dart';
import 'package:hossy_barbers/features/admin/presentation/business_profile_editor.dart';
import 'package:hossy_barbers/features/admin/presentation/gallery_manager.dart';
import 'package:hossy_barbers/features/admin/presentation/services_manager.dart';
import 'package:hossy_barbers/features/admin/presentation/reviews_manager.dart';
import 'package:hossy_barbers/features/admin/presentation/booking_requests_manager.dart';
import 'package:hossy_barbers/features/admin/presentation/admin_booking_notifications.dart';
import 'package:hossy_barbers/features/admin/presentation/admin_analytics_panel.dart';
import 'package:hossy_barbers/features/admin/services/admin_auth_service.dart';
import 'package:hossy_barbers/features/admin/services/admin_analytics_service.dart';
import 'package:hossy_barbers/features/admin/services/booking_notification_read_store.dart';
import 'package:hossy_barbers/features/admin/services/booking_notification_service.dart';
import 'package:hossy_barbers/features/gallery/data/gallery_repository.dart';
import 'package:hossy_barbers/features/gallery/services/cloudinary_upload_service.dart';
import 'package:hossy_barbers/features/services/data/services_repository.dart';
import 'package:hossy_barbers/features/reviews/data/reviews_repository.dart';
import 'package:hossy_barbers/features/booking/data/booking_requests_repository.dart';
import 'package:hossy_barbers/features/booking/domain/booking_request_record.dart';
import 'package:hossy_barbers/features/gallery/domain/gallery_item.dart';
import 'package:hossy_barbers/features/reviews/domain/customer_review.dart';
import 'package:hossy_barbers/features/services/domain/service.dart';

enum _AdminSection {
  dashboard,
  businessProfile,
  services,
  gallery,
  reviews,
  bookings,
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({
    super.key,
    required this.user,
    required this.authService,
    required this.businessSettingsRepository,
    required this.servicesRepository,
    required this.galleryRepository,
    required this.reviewsRepository,
    required this.bookingRequestsRepository,
  });

  final User user;
  final AdminAuthService authService;
  final BusinessSettingsRepository businessSettingsRepository;
  final ServicesRepository servicesRepository;
  final GalleryRepository galleryRepository;
  final ReviewsRepository reviewsRepository;
  final BookingRequestsRepository bookingRequestsRepository;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  var _section = _AdminSection.dashboard;
  late final BookingNotificationService _bookingNotificationService;

  @override
  void initState() {
    super.initState();
    _bookingNotificationService = BookingNotificationService(
      bookingRequestsRepository: widget.bookingRequestsRepository,
      readStore: createBookingNotificationReadStore(widget.user.uid),
    );
    unawaited(_bookingNotificationService.start());
  }

  @override
  void dispose() {
    unawaited(_bookingNotificationService.dispose());
    super.dispose();
  }

  void _openBookings() => setState(() => _section = _AdminSection.bookings);

  @override
  Widget build(BuildContext context) {
    final desktop = Breakpoints.isDesktop(context);
    final navigation = _AdminNavigation(
      selected: _section,
      onSelected: (section) {
        setState(() => _section = section);
        if (!desktop) {
          Navigator.of(context).pop();
        }
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOSSY BARBERS · CONTENT STUDIO'),
        actions: [
          AdminBookingNotifications(
            service: _bookingNotificationService,
            onOpenBookings: _openBookings,
          ),
          if (desktop)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(child: Text(widget.user.email ?? 'Administrator')),
            ),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: widget.authService.signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
      drawer: desktop ? null : Drawer(child: SafeArea(child: navigation)),
      body: Row(
        children: [
          if (desktop)
            SizedBox(
              width: 272,
              child: Material(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: navigation,
              ),
            ),
          Expanded(
            child: _AdminContent(
              section: _section,
              user: widget.user,
              businessSettingsRepository: widget.businessSettingsRepository,
              servicesRepository: widget.servicesRepository,
              galleryRepository: widget.galleryRepository,
              reviewsRepository: widget.reviewsRepository,
              bookingRequestsRepository: widget.bookingRequestsRepository,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminNavigation extends StatelessWidget {
  const _AdminNavigation({required this.selected, required this.onSelected});
  final _AdminSection selected;
  final ValueChanged<_AdminSection> onSelected;

  @override
  Widget build(BuildContext context) {
    const labels = <_AdminSection, String>{
      _AdminSection.dashboard: 'Overview',
      _AdminSection.businessProfile: 'Brand & website',
      _AdminSection.services: 'Services',
      _AdminSection.gallery: 'Gallery',
      _AdminSection.reviews: 'Reviews',
      _AdminSection.bookings: 'Bookings',
    };
    const icons = <_AdminSection, IconData>{
      _AdminSection.dashboard: Icons.grid_view_rounded,
      _AdminSection.businessProfile: Icons.auto_awesome_outlined,
      _AdminSection.services: Icons.content_cut_rounded,
      _AdminSection.gallery: Icons.photo_library_outlined,
      _AdminSection.reviews: Icons.star_outline_rounded,
      _AdminSection.bookings: Icons.calendar_month_outlined,
    };
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.medium),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HOSSY',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              SizedBox(height: 4),
              Text('Content studio', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        for (final entry in labels.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              selected: selected == entry.key,
              selectedTileColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: .15),
              leading: Icon(icons[entry.key]),
              title: Text(
                entry.value,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              onTap: () => onSelected(entry.key),
            ),
          ),
      ],
    );
  }
}

class _AdminContent extends StatelessWidget {
  const _AdminContent({
    required this.section,
    required this.user,
    required this.businessSettingsRepository,
    required this.servicesRepository,
    required this.galleryRepository,
    required this.reviewsRepository,
    required this.bookingRequestsRepository,
  });

  final _AdminSection section;
  final User user;
  final BusinessSettingsRepository businessSettingsRepository;
  final ServicesRepository servicesRepository;
  final GalleryRepository galleryRepository;
  final ReviewsRepository reviewsRepository;
  final BookingRequestsRepository bookingRequestsRepository;

  @override
  Widget build(BuildContext context) {
    switch (section) {
      case _AdminSection.dashboard:
        return _DashboardView(
          user: user,
          businessSettingsRepository: businessSettingsRepository,
          servicesRepository: servicesRepository,
          galleryRepository: galleryRepository,
          reviewsRepository: reviewsRepository,
          bookingRequestsRepository: bookingRequestsRepository,
        );
      case _AdminSection.businessProfile:
        return BusinessProfileEditor(
          repository: businessSettingsRepository,
          uploadService: const CloudinaryUploadService(),
        );
      case _AdminSection.services:
        return ServicesManager(repository: servicesRepository);
      case _AdminSection.gallery:
        return GalleryManager(
          repository: galleryRepository,
          uploadService: const CloudinaryUploadService(),
        );
      case _AdminSection.reviews:
        return ReviewsManager(repository: reviewsRepository);
      case _AdminSection.bookings:
        return BookingRequestsManager(repository: bookingRequestsRepository);
    }
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({
    required this.user,
    required this.businessSettingsRepository,
    required this.servicesRepository,
    required this.galleryRepository,
    required this.reviewsRepository,
    required this.bookingRequestsRepository,
  });
  final User user;
  final BusinessSettingsRepository businessSettingsRepository;
  final ServicesRepository servicesRepository;
  final GalleryRepository galleryRepository;
  final ReviewsRepository reviewsRepository;
  final BookingRequestsRepository bookingRequestsRepository;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good to see you.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.xSmall),
            Text('Signed in as ${user.email ?? 'administrator'}'),
            const SizedBox(height: AppSpacing.large),
            Wrap(
              spacing: AppSpacing.medium,
              runSpacing: AppSpacing.medium,
              children: [
                _CountCard<Service>(
                  title: 'Published services',
                  icon: Icons.content_cut_rounded,
                  stream: servicesRepository.watchAll(),
                  count: (items) => items.where((item) => item.isActive).length,
                ),
                _CountCard<GalleryItem>(
                  title: 'Gallery images',
                  icon: Icons.photo_library_outlined,
                  stream: galleryRepository.watchAll(),
                  count: (items) => items.length,
                ),
                _CountCard<CustomerReview>(
                  title: 'Reviews to moderate',
                  icon: Icons.star_outline_rounded,
                  stream: reviewsRepository.watchAll(),
                  count: (items) =>
                      items.where((item) => !item.published).length,
                ),
                _CountCard<BookingRequestRecord>(
                  title: 'Prepared requests',
                  icon: Icons.calendar_month_outlined,
                  stream: bookingRequestsRepository.watchAll(),
                  count: (items) =>
                      items.where((item) => item.status == 'prepared').length,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.large),
            _BusinessReadiness(repository: businessSettingsRepository),
            const SizedBox(height: AppSpacing.large),
            AdminAnalyticsPanel(
              service: AdminAnalyticsService(
                bookingRequestsRepository: bookingRequestsRepository,
                reviewsRepository: reviewsRepository,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CountCard<T> extends StatelessWidget {
  const _CountCard({
    required this.title,
    required this.icon,
    required this.stream,
    required this.count,
  });

  final String title;
  final IconData icon;
  final Stream<List<T>> stream;
  final int Function(List<T>) count;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 250,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: StreamBuilder<List<T>>(
          stream: stream,
          builder: (context, snapshot) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: AppSpacing.large),
              Text(
                snapshot.hasData ? '${count(snapshot.data!)}' : '—',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(title),
            ],
          ),
        ),
      ),
    ),
  );
}

class _BusinessReadiness extends StatelessWidget {
  const _BusinessReadiness({required this.repository});
  final BusinessSettingsRepository repository;

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: repository.watchMain(),
    builder: (context, snapshot) {
      final settings = snapshot.data;
      final complete =
          settings != null &&
          settings.businessName.isNotEmpty &&
          settings.whatsAppNumber.isNotEmpty &&
          settings.description.isNotEmpty;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.large),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
        child: Row(
          children: [
            Icon(
              complete ? Icons.verified_outlined : Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Text(
                complete
                    ? 'Your essential public business details are in place.'
                    : 'Complete your brand, WhatsApp number, and about content in Brand & website.',
              ),
            ),
          ],
        ),
      );
    },
  );
}
