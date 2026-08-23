import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_colors.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/app/theme/app_text_styles.dart';
import 'package:hossy_barbers/core/constants/development_content.dart';
import 'package:hossy_barbers/core/responsive/breakpoints.dart';
import 'package:hossy_barbers/features/admin/data/business_settings_repository.dart';
import 'package:hossy_barbers/features/admin/domain/business_settings.dart';
import 'package:hossy_barbers/features/admin/presentation/admin_gate.dart';
import 'package:hossy_barbers/features/booking/presentation/booking_screen.dart';
import 'package:hossy_barbers/features/gallery/data/gallery_repository.dart';
import 'package:hossy_barbers/features/gallery/domain/gallery_item.dart';
import 'package:hossy_barbers/features/services/data/development_services.dart';
import 'package:hossy_barbers/features/services/data/services_repository.dart';
import 'package:hossy_barbers/features/services/domain/service.dart';
import 'package:hossy_barbers/features/reviews/data/reviews_repository.dart';
import 'package:hossy_barbers/features/reviews/presentation/reviews_section.dart';
import 'package:hossy_barbers/shared/widgets/page_container.dart';
import 'package:hossy_barbers/shared/widgets/section_heading.dart';
import 'package:hossy_barbers/shared/widgets/site_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.servicesRepository,
    this.businessSettingsRepository,
    this.galleryRepository,
    this.reviewsRepository,
  });

  final ServicesRepository? servicesRepository;
  final BusinessSettingsRepository? businessSettingsRepository;
  final GalleryRepository? galleryRepository;
  final ReviewsRepository? reviewsRepository;

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
          Expanded(
            child: StreamBuilder<BusinessSettings?>(
              stream: widget.businessSettingsRepository?.watchMain(),
              builder: (context, snapshot) => Title(
                title: snapshot.data?.seoTitle.isNotEmpty == true
                    ? snapshot.data!.seoTitle
                    : 'Hossy Barbers',
                color: Theme.of(context).colorScheme.primary,
                child: Column(
                  children: [
                    SiteHeader(
                      onNavigate: _navigateTo,
                      logoUrl: snapshot.data?.logoUrl,
                      businessName: snapshot.data?.businessName,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _Hero(
                              key: _sections['home'],
                              desktop: desktop,
                              onBook: _openBooking,
                              settings: snapshot.data,
                            ),
                            _Services(
                              key: _sections['services'],
                              servicesRepository: widget.servicesRepository,
                            ),
                            _Gallery(
                              key: _sections['gallery'],
                              galleryRepository: widget.galleryRepository,
                            ),
                            _About(
                              key: _sections['about'],
                              settings: snapshot.data,
                            ),
                            ReviewsSection(
                              repository: widget.reviewsRepository,
                            ),
                            _BookingBanner(
                              onBook: _openBooking,
                              ctaText: snapshot.data?.heroCtaText,
                            ),
                            _Contact(
                              key: _sections['contact'],
                              settings: snapshot.data,
                            ),
                            _Footer(settings: snapshot.data),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    super.key,
    required this.desktop,
    required this.onBook,
    required this.settings,
  });
  final bool desktop;
  final VoidCallback onBook;
  final BusinessSettings? settings;

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.ink,
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
                Text(
                  (settings?.heroEyebrow.isNotEmpty == true
                          ? settings!.heroEyebrow
                          : settings?.businessName.isNotEmpty == true
                          ? settings!.businessName
                          : 'HOSSY BARBERS')
                      .toUpperCase(),
                  style: AppTextStyles.eyebrow.copyWith(
                    color: AppColors.accentSoft,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  settings?.heroHeadline.isNotEmpty == true
                      ? settings!.heroHeadline
                      : 'Your beauty,\nour concern.',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.canvas,
                    fontSize: desktop ? 68 : 48,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  settings?.heroDescription.isNotEmpty == true
                      ? settings!.heroDescription
                      : settings?.shortTagline.isNotEmpty == true
                      ? settings!.shortTagline
                      : DevelopmentContent.heroDescription,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.canvas.withValues(alpha: .72),
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                FilledButton.icon(
                  onPressed: onBook,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(
                    settings?.heroCtaText.isNotEmpty == true
                        ? settings!.heroCtaText
                        : 'Book now',
                  ),
                ),
              ],
            ),
          ),
          _HeroVisual(
            width: desktop ? 485 : double.infinity,
            height: desktop ? 500 : 360,
            imageUrl: settings?.heroImageUrl,
            logoUrl: settings?.logoUrl,
          ),
        ],
      ),
    ),
  );
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual({
    required this.width,
    required this.height,
    required this.imageUrl,
    required this.logoUrl,
  });
  final double width;
  final double height;
  final String? imageUrl;
  final String? logoUrl;
  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
    ),
    child: imageUrl?.isNotEmpty == true
        ? ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
            child: Image.network(
              imageUrl!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _HeroFallback(logoUrl: logoUrl),
            ),
          )
        : _HeroFallback(logoUrl: logoUrl),
  );
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback({required this.logoUrl});
  final String? logoUrl;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (logoUrl?.isNotEmpty == true)
          Image.network(
            logoUrl!,
            height: 96,
            width: 180,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const _DefaultBrandMark(),
          )
        else
          const _DefaultBrandMark(),
        const SizedBox(height: AppSpacing.medium),
        Text(
          'Hossy Barbers',
          style: TextStyle(
            color: AppColors.canvas,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _DefaultBrandMark extends StatelessWidget {
  const _DefaultBrandMark();

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/brand/hossy_mark.png',
    height: 176,
    width: 176,
    fit: BoxFit.contain,
    errorBuilder: (_, _, _) => Container(
      height: 104,
      width: 104,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.accent, width: 2),
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: const Text(
        'HB',
        style: TextStyle(
          color: AppColors.canvas,
          fontSize: 30,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    ),
  );
}

class _Services extends StatelessWidget {
  const _Services({super.key, required this.servicesRepository});

  final ServicesRepository? servicesRepository;
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
              'Choose the service that suits your routine. Availability is confirmed directly by Hossy Barbers.',
        ),
        const SizedBox(height: AppSpacing.large),
        StreamBuilder<List<Service>>(
          stream: servicesRepository?.watchPublished(),
          builder: (context, snapshot) {
            final services =
                snapshot.hasError || snapshot.data?.isEmpty != false
                ? developmentServices
                : snapshot.data!;
            return LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900
                    ? 3
                    : constraints.maxWidth >= 560
                    ? 2
                    : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: columns == 1 ? 1.2 : 1.35,
                  ),
                  itemBuilder: (context, index) {
                    final service = services[index];
                    final colors = Theme.of(context).colorScheme;
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.medium),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: .65),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SIGNATURE SERVICE',
                            style: AppTextStyles.eyebrow.copyWith(
                              color: colors.primary,
                              fontSize: 10,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            service.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSpacing.xSmall),
                          Text(service.description),
                          const SizedBox(height: AppSpacing.medium),
                          Row(
                            children: [
                              if (service.price?.isNotEmpty == true)
                                Text(
                                  service.price!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: colors.primary,
                                  ),
                                ),
                              const Spacer(),
                              if (service.duration?.isNotEmpty == true)
                                Text(
                                  service.duration!,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
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
  const _Gallery({super.key, required this.galleryRepository});

  final GalleryRepository? galleryRepository;
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
          Text(
            'GALLERY',
            style: AppTextStyles.eyebrow.copyWith(color: AppColors.accentSoft),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'The work speaks for itself.',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.canvas),
          ),
          const SizedBox(height: AppSpacing.large),
          StreamBuilder<List<GalleryItem>>(
            stream: galleryRepository?.watchPublished(),
            builder: (context, snapshot) {
              final items = snapshot.data ?? const <GalleryItem>[];
              if (items.isEmpty) return const _GalleryEmptyState();
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 760;
                  final tileWidth = isWide
                      ? (constraints.maxWidth - 32) / 3
                      : (constraints.maxWidth - 12) / 2;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      for (var index = 0; index < items.length; index++)
                        SizedBox(
                          width: isWide && index == 0
                              ? tileWidth * 2 + 16
                              : tileWidth,
                          height: isWide && index == 0 ? 400 : 245,
                          child: _GalleryImage(item: items[index]),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _GalleryEmptyState extends StatelessWidget {
  const _GalleryEmptyState();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.xLarge),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.accentSoft.withValues(alpha: .35)),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
    ),
    child: const Column(
      children: [
        Icon(
          Icons.photo_library_outlined,
          color: AppColors.accentSoft,
          size: 34,
        ),
        SizedBox(height: AppSpacing.small),
        Text(
          'The gallery is being curated.',
          style: TextStyle(
            color: AppColors.canvas,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _GalleryImage extends StatefulWidget {
  const _GalleryImage({required this.item});
  final GalleryItem item;

  @override
  State<_GalleryImage> createState() => _GalleryImageState();
}

class _GalleryImageState extends State<_GalleryImage> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hovered = true),
    onExit: (_) => setState(() => _hovered = false),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 220),
            scale: _hovered ? 1.045 : 1,
            child: Image.network(
              widget.item.imageUrl,
              fit: BoxFit.cover,
              semanticLabel: widget.item.caption.isEmpty
                  ? 'Hossy Barbers gallery image'
                  : widget.item.caption,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: AppColors.accentDark,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.canvas,
                  ),
                ),
              ),
            ),
          ),
          if (widget.item.caption.isNotEmpty)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _hovered ? 1 : 0,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.medium),
                  color: Colors.black.withValues(alpha: .56),
                  child: Text(
                    widget.item.caption,
                    style: const TextStyle(
                      color: AppColors.canvas,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _About extends StatelessWidget {
  const _About({super.key, required this.settings});

  final BusinessSettings? settings;
  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: PageContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: AppSpacing.section,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Wrap(
          spacing: AppSpacing.xLarge,
          runSpacing: AppSpacing.large,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: constraints.maxWidth >= 820 ? 320 : double.infinity,
              child: Text(
                'BUILT FOR\nTHE DETAIL.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 34,
                  letterSpacing: -1.4,
                ),
              ),
            ),
            SizedBox(
              width: constraints.maxWidth >= 820 ? 600 : double.infinity,
              child: SectionHeading(
                eyebrow: 'About Hossy Barbers',
                title: settings?.aboutHeading.isNotEmpty == true
                    ? settings!.aboutHeading
                    : 'A space built around the detail.',
                description: settings?.description.isNotEmpty == true
                    ? settings!.description
                    : DevelopmentContent.aboutDescription,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BookingBanner extends StatelessWidget {
  const _BookingBanner({required this.onBook, required this.ctaText});
  final VoidCallback onBook;
  final String? ctaText;
  @override
  Widget build(BuildContext context) => PageContainer(
    padding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: AppSpacing.section,
    ),
    child: Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.accent.withValues(alpha: .7)),
      ),
      child: Wrap(
        spacing: AppSpacing.large,
        runSpacing: AppSpacing.medium,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 610,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your next appointment\nstarts here.',
                  style: TextStyle(
                    fontSize: 32,
                    height: 1.04,
                    letterSpacing: -1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.canvas,
                  ),
                ),
                SizedBox(height: AppSpacing.xSmall),
                Text(
                  'Choose your preferred service, date, and time. Hossy Barbers will contact you to confirm availability.',
                  style: TextStyle(
                    color: AppColors.canvas.withValues(alpha: .72),
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onBook,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentSoft,
              side: const BorderSide(color: AppColors.accentSoft),
            ),
            child: Text(
              ctaText?.isNotEmpty == true ? ctaText! : 'Start booking',
            ),
          ),
        ],
      ),
    ),
  );
}

class _Contact extends StatelessWidget {
  const _Contact({super.key, required this.settings});

  final BusinessSettings? settings;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: Theme.of(context).colorScheme.surface,
    child: PageContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: AppSpacing.xLarge,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) => Wrap(
          spacing: AppSpacing.xLarge,
          runSpacing: AppSpacing.large,
          children: [
            const SizedBox(
              width: 330,
              child: SectionHeading(
                eyebrow: 'Contact',
                title: 'Visit, call, or message.',
                description:
                    'We are ready to help you find the right time for your next appointment.',
              ),
            ),
            SizedBox(
              width: constraints.maxWidth >= 780 ? 620 : double.infinity,
              child: _ContactDetails(settings: settings, lines: _contactLines),
            ),
          ],
        ),
      ),
    ),
  );

  List<String> get _contactLines => [
    if (settings?.phoneNumber.isNotEmpty == true) settings!.phoneNumber,
    if (settings?.whatsAppNumber.isNotEmpty == true) settings!.whatsAppNumber,
    if (settings?.address.isNotEmpty == true) settings!.address,
    if (settings?.openingHours.isNotEmpty == true)
      settings!.openingHours.entries
          .map((entry) => '${entry.key}: ${entry.value}')
          .join('\n'),
  ];
}

class _ContactDetails extends StatelessWidget {
  const _ContactDetails({required this.settings, required this.lines});
  final BusinessSettings? settings;
  final List<String> lines;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (lines.isEmpty)
        const Text(DevelopmentContent.contactDescription)
      else
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.small),
            child: Text(line, style: Theme.of(context).textTheme.bodyLarge),
          ),
      if (settings?.socialLinks.isNotEmpty == true) ...[
        const SizedBox(height: AppSpacing.medium),
        Wrap(
          spacing: AppSpacing.small,
          runSpacing: AppSpacing.small,
          children: settings!.socialLinks.entries
              .map(
                (entry) => Chip(
                  label: Text(entry.key),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    ],
  );
}

class _Footer extends StatefulWidget {
  const _Footer({required this.settings});
  final BusinessSettings? settings;

  @override
  State<_Footer> createState() => _FooterState();
}

class _FooterState extends State<_Footer> {
  static const _adminTapCount = 7;
  var _tapCount = 0;

  void _openAdminAfterDeveloperTap() {
    _tapCount++;
    if (_tapCount < _adminTapCount) return;
    _tapCount = 0;
    Navigator.of(context).pushNamed(AdminGate.routeName);
  }

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: AppColors.ink,
    child: PageContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: AppSpacing.large,
      ),
      child: Wrap(
        runSpacing: AppSpacing.small,
        alignment: WrapAlignment.spaceBetween,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _openAdminAfterDeveloperTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xSmall),
              child: Text(
                (widget.settings?.businessName.isNotEmpty == true
                        ? widget.settings!.businessName
                        : 'Hossy Barbers')
                    .toUpperCase(),
                style: const TextStyle(
                  color: AppColors.canvas,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          Text(
            '© ${DateTime.now().year} · All rights reserved',
            style: TextStyle(color: AppColors.canvas.withValues(alpha: .62)),
          ),
        ],
      ),
    ),
  );
}
