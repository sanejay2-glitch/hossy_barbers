import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/core/responsive/breakpoints.dart';
import 'package:hossy_barbers/features/admin/data/business_settings_repository.dart';
import 'package:hossy_barbers/features/admin/domain/business_settings.dart';
import 'package:hossy_barbers/features/admin/services/admin_auth_service.dart';

enum _AdminSection {
  dashboard,
  businessInformation,
  services,
  gallery,
  homepage,
  bookings,
  settings,
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({
    super.key,
    required this.user,
    required this.authService,
  });
  final User user;
  final AdminAuthService authService;

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  var _section = _AdminSection.dashboard;

  @override
  Widget build(BuildContext context) {
    final desktop = Breakpoints.isDesktop(context);
    final navigation = _AdminNavigation(
      selected: _section,
      onSelected: (section) {
        setState(() => _section = section);
        if (!desktop) Navigator.of(context).pop();
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hossy Barbers Admin'),
        actions: [
          if (desktop)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(child: Text(widget.user.email ?? 'Administrator')),
            ),
          TextButton.icon(
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
              width: 240,
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                child: navigation,
              ),
            ),
          Expanded(
            child: _AdminContent(section: _section, user: widget.user),
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
      _AdminSection.dashboard: 'Dashboard',
      _AdminSection.businessInformation: 'Business information',
      _AdminSection.services: 'Services',
      _AdminSection.gallery: 'Gallery',
      _AdminSection.homepage: 'Homepage',
      _AdminSection.bookings: 'Bookings',
      _AdminSection.settings: 'Settings',
    };
    return ListView(
      padding: const EdgeInsets.all(12),
      children: labels.entries
          .map(
            (entry) => ListTile(
              selected: selected == entry.key,
              title: Text(entry.value),
              onTap: () => onSelected(entry.key),
            ),
          )
          .toList(),
    );
  }
}

class _AdminContent extends StatelessWidget {
  const _AdminContent({required this.section, required this.user});
  final _AdminSection section;
  final User user;

  @override
  Widget build(BuildContext context) {
    if (section != _AdminSection.dashboard) {
      return _FutureArea(section: section);
    }
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.small),
            Text('Signed in as ${user.email ?? 'administrator'}.'),
            const SizedBox(height: AppSpacing.large),
            StreamBuilder<BusinessSettings?>(
              stream: BusinessSettingsRepository(
                FirebaseFirestore.instance,
              ).watchMain(),
              builder: (context, snapshot) {
                final message = snapshot.hasError
                    ? 'Business settings could not be loaded.'
                    : snapshot.connectionState == ConnectionState.waiting
                    ? 'Checking business settings…'
                    : snapshot.data == null
                    ? 'Business settings have not been created yet.'
                    : 'Business settings are connected and ready for future management.';
                return _StatusCard(
                  title: 'Business information',
                  message: message,
                );
              },
            ),
            const SizedBox(height: AppSpacing.medium),
            const _StatusCard(
              title: 'Management areas',
              message:
                  'Services, gallery, homepage, bookings, and settings are prepared for their dedicated management phases.',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message),
        ],
      ),
    ),
  );
}

class _FutureArea extends StatelessWidget {
  const _FutureArea({required this.section});
  final _AdminSection section;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.large),
    child: Text(
      '${_label(section)} management will be added in a future phase.',
      style: Theme.of(context).textTheme.headlineMedium,
    ),
  );

  String _label(_AdminSection section) => switch (section) {
    _AdminSection.businessInformation => 'Business information',
    _AdminSection.services => 'Services',
    _AdminSection.gallery => 'Gallery',
    _AdminSection.homepage => 'Homepage',
    _AdminSection.bookings => 'Bookings',
    _AdminSection.settings => 'Settings',
    _AdminSection.dashboard => 'Dashboard',
  };
}
