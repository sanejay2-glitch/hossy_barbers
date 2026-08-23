import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/core/responsive/breakpoints.dart';
import 'package:hossy_barbers/features/booking/presentation/booking_screen.dart';
import 'package:hossy_barbers/shared/widgets/page_container.dart';

class SiteHeader extends StatelessWidget {
  const SiteHeader({
    super.key,
    required this.onNavigate,
    this.logoUrl,
    this.businessName,
  });

  final ValueChanged<String> onNavigate;
  final String? logoUrl;
  final String? businessName;

  @override
  Widget build(BuildContext context) {
    final desktop = Breakpoints.isDesktop(context);
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: .96),
      child: SafeArea(
        bottom: false,
        child: PageContainer(
          child: SizedBox(
            height: 82,
            child: Row(
              children: [
                Semantics(
                  button: true,
                  label: 'Hossy Barbers home',
                  child: TextButton(
                    onPressed: () => onNavigate('home'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: colors.onSurface,
                    ),
                    child: logoUrl?.isNotEmpty == true
                        ? Image.network(
                            logoUrl!,
                            height: 44,
                            width: 128,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) =>
                                _BrandName(name: businessName),
                          )
                        : _BrandName(name: businessName),
                  ),
                ),
                const Spacer(),
                if (desktop) ...[
                  for (final label in const [
                    'Services',
                    'Gallery',
                    'About',
                    'Contact',
                  ])
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: colors.onSurface.withValues(
                          alpha: .74,
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onPressed: () => onNavigate(label.toLowerCase()),
                      child: Text(label),
                    ),
                  const SizedBox(width: AppSpacing.small),
                  FilledButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamed(BookingScreen.routeName),
                    child: const Text('Book appointment'),
                  ),
                ] else
                  IconButton(
                    tooltip: 'Open navigation menu',
                    onPressed: () => _showMenu(context),
                    icon: const Icon(Icons.menu_rounded),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            0,
            AppSpacing.medium,
            AppSpacing.large,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.small,
                  vertical: AppSpacing.small,
                ),
                child: _BrandName(name: null),
              ),
              for (final label in const [
                'Home',
                'Services',
                'Gallery',
                'About',
                'Contact',
              ])
                ListTile(
                  title: Text(label),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onNavigate(label.toLowerCase());
                  },
                ),
              ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: const Text('Book appointment'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.of(context).pushNamed(BookingScreen.routeName);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandName extends StatelessWidget {
  const _BrandName({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) => Text(
    (name?.isNotEmpty == true ? name! : 'HOSSY BARBERS').toUpperCase(),
    style: const TextStyle(
      fontWeight: FontWeight.w900,
      letterSpacing: 1.7,
      fontSize: 15,
    ),
  );
}
