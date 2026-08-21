import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_colors.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/app/theme/app_text_styles.dart';
import 'package:hossy_barbers/core/constants/development_content.dart';
import 'package:hossy_barbers/core/responsive/breakpoints.dart';
import 'package:hossy_barbers/features/booking/presentation/booking_screen.dart';
import 'package:hossy_barbers/features/services/data/development_services.dart';
import 'package:hossy_barbers/shared/widgets/page_container.dart';
import 'package:hossy_barbers/shared/widgets/section_heading.dart';
import 'package:hossy_barbers/shared/widgets/site_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _sections = <String, GlobalKey>{
    'home': GlobalKey(),
    'services': GlobalKey(),
    'gallery': GlobalKey(),
    'about': GlobalKey(),
    'contact': GlobalKey(),
  };

  void _navigateTo(String section) {
    final target = _sections[section]?.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _openBooking() =>
      Navigator.of(context).pushNamed(BookingScreen.routeName);

  @override
  Widget build(BuildContext context) {
    final desktop = Breakpoints.isDesktop(context);
    return Scaffold(
      body: Column(
        children: [
          SiteHeader(onNavigate: _navigateTo),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _Hero(
                    key: _sections['home'],
                    desktop: desktop,
                    onBook: _openBooking,
                  ),
                  _Services(key: _sections['services']),
                  _Gallery(key: _sections['gallery']),
                  _About(key: _sections['about']),
                  _BookingBanner(onBook: _openBooking),
                  _Contact(key: _sections['contact']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({super.key, required this.desktop, required this.onBook});
  final bool desktop;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.mutedSurface,
    child: PageContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: AppSpacing.xLarge,
      ),
      child: Wrap(
        spacing: AppSpacing.xLarge,
        runSpacing: AppSpacing.large,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: desktop ? 530 : double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'THE HOSSY BARBERS EXPERIENCE',
                  style: AppTextStyles.eyebrow,
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  'Look sharp.\nFeel ready.',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: AppSpacing.medium),
                const Text(DevelopmentContent.heroDescription),
                const SizedBox(height: AppSpacing.large),
                FilledButton.icon(
                  onPressed: onBook,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Book now'),
                ),
              ],
            ),
          ),
          _HeroVisual(width: desktop ? 450 : double.infinity),
        ],
      ),
    ),
  );
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual({required this.width});
  final double width;
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: 330,
    decoration: BoxDecoration(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(AppSpacing.radius),
    ),
    child: const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.content_cut_rounded, size: 72, color: AppColors.canvas),
          SizedBox(height: AppSpacing.small),
          Text(
            'Studio photography coming soon',
            style: TextStyle(
              color: AppColors.canvas,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

class _Services extends StatelessWidget {
  const _Services({super.key});
  @override
  Widget build(BuildContext context) => PageContainer(
    padding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: AppSpacing.section,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          eyebrow: 'Services',
          title: 'Grooming, on your terms.',
          description:
              'Service names, pricing, and duration details will be confirmed and managed here.',
        ),
        const SizedBox(height: AppSpacing.large),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 560
                ? 2
                : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: developmentServices.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: columns == 1 ? 1.5 : 1.35,
              ),
              itemBuilder: (context, index) {
                final service = developmentServices[index];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.cut_rounded,
                        color: AppColors.accentDark,
                      ),
                      const Spacer(),
                      Text(
                        service.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xSmall),
                      Text(service.description),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    ),
  );
}

class _Gallery extends StatelessWidget {
  const _Gallery({super.key});
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.ink,
    child: PageContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: AppSpacing.section,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GALLERY',
            style: TextStyle(
              color: Color(0xFFD9B889),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'The work speaks for itself.',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.canvas),
          ),
          const SizedBox(height: AppSpacing.large),
          LayoutBuilder(
            builder: (context, constraints) {
              final count = constraints.maxWidth >= 700 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 6,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: count,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: count == 3 ? 1.1 : .95,
                ),
                itemBuilder: (context, index) => Container(
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      AppColors.accentDark,
                      AppColors.ink,
                      index / 7,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Photo ${index + 1}',
                      style: const TextStyle(
                        color: AppColors.canvas,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _About extends StatelessWidget {
  const _About({super.key});
  @override
  Widget build(BuildContext context) => PageContainer(
    padding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: AppSpacing.section,
    ),
    child: const SectionHeading(
      eyebrow: 'About',
      title: 'A space built around the detail.',
      description: DevelopmentContent.aboutDescription,
    ),
  );
}

class _BookingBanner extends StatelessWidget {
  const _BookingBanner({required this.onBook});
  final VoidCallback onBook;
  @override
  Widget build(BuildContext context) => PageContainer(
    padding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: AppSpacing.large,
    ),
    child: Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Wrap(
        spacing: AppSpacing.large,
        runSpacing: AppSpacing.medium,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const SizedBox(
            width: 610,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready when you are.',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: AppSpacing.xSmall),
                Text(
                  'Choose your preferred service, date, and time. We’ll prepare your WhatsApp request.',
                  style: TextStyle(color: Colors.white, height: 1.5),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onBook,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
            ),
            child: const Text('Start booking'),
          ),
        ],
      ),
    ),
  );
}

class _Contact extends StatelessWidget {
  const _Contact({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: AppColors.surface,
    child: PageContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: AppSpacing.xLarge,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CONTACT', style: AppTextStyles.eyebrow),
          SizedBox(height: AppSpacing.small),
          Text('Visit, call, or message.', style: AppTextStyles.headline),
          SizedBox(height: AppSpacing.small),
          Text(DevelopmentContent.contactDescription),
          SizedBox(height: AppSpacing.large),
          Text(
            'HOSSY BARBERS',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2),
          ),
        ],
      ),
    ),
  );
}
