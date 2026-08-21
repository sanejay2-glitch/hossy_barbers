import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_colors.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/core/responsive/breakpoints.dart';
import 'package:hossy_barbers/features/booking/presentation/booking_screen.dart';
import 'package:hossy_barbers/shared/widgets/page_container.dart';

class SiteHeader extends StatelessWidget {
  const SiteHeader({super.key, required this.onNavigate});

  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    final desktop = Breakpoints.isDesktop(context);
    return Material(
      color: AppColors.canvas.withValues(alpha: 0.96),
      child: SafeArea(
        bottom: false,
        child: PageContainer(
          child: SizedBox(
            height: 76,
            child: Row(
              children: [
                Semantics(
                  button: true,
                  label: 'Hossy Barbers home',
                  child: TextButton(
                    onPressed: () => onNavigate('home'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: AppColors.ink,
                    ),
                    child: const Text(
                      'HOSSY BARBERS',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      ),
                    ),
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
                      onPressed: () => onNavigate(label.toLowerCase()),
                      child: Text(label),
                    ),
                  const SizedBox(width: AppSpacing.small),
                  FilledButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamed(BookingScreen.routeName),
                    child: const Text('Book now'),
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
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                title: const Text('Book now'),
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
