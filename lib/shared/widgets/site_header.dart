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
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close navigation menu',
      barrierColor: Colors.black.withValues(alpha: .58),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (dialogContext, _, _) => Align(
        alignment: Alignment.centerRight,
        child: _PublicNavigationPanel(
          businessName: businessName,
          onClose: () => Navigator.of(dialogContext).pop(),
          onNavigate: (section) {
            Navigator.of(dialogContext).pop();
            onNavigate(section);
          },
          onBook: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).pushNamed(BookingScreen.routeName);
          },
        ),
      ),
      transitionBuilder: (_, animation, _, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );
  }
}

class _PublicNavigationPanel extends StatelessWidget {
  const _PublicNavigationPanel({
    required this.businessName,
    required this.onClose,
    required this.onNavigate,
    required this.onBook,
  });

  final String? businessName;
  final VoidCallback onClose;
  final ValueChanged<String> onNavigate;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 24,
      child: SafeArea(
        child: SizedBox(
          width: screenWidth < 440 ? screenWidth * .9 : 400,
          height: double.infinity,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.medium,
                  AppSpacing.medium,
                  AppSpacing.small,
                  AppSpacing.medium,
                ),
                child: Row(
                  children: [
                    Expanded(child: _BrandName(name: businessName)),
                    IconButton(
                      tooltip: 'Close navigation menu',
                      onPressed: onClose,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.outline.withValues(
                  alpha: .55,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.medium,
                    AppSpacing.medium,
                    AppSpacing.medium,
                    AppSpacing.large,
                  ),
                  children: [
                    for (final label in const [
                      'Home',
                      'Services',
                      'Gallery',
                      'About',
                      'Contact',
                    ])
                      _PublicNavigationItem(
                        label: label,
                        onTap: () => onNavigate(label.toLowerCase()),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.medium,
                  AppSpacing.small,
                  AppSpacing.medium,
                  AppSpacing.medium,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onBook,
                    child: const Text('Book appointment'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PublicNavigationItem extends StatelessWidget {
  const _PublicNavigationItem({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xSmall),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.small),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      trailing: const Icon(Icons.arrow_forward_rounded, size: 18),
      onTap: onTap,
    ),
  );
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
