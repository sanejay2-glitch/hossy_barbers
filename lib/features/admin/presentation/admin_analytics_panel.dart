import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/features/admin/domain/admin_analytics.dart';
import 'package:hossy_barbers/features/admin/services/admin_analytics_service.dart';

class AdminAnalyticsPanel extends StatelessWidget {
  const AdminAnalyticsPanel({super.key, required this.service});

  final AdminAnalyticsService service;

  @override
  Widget build(BuildContext context) => StreamBuilder<AdminAnalyticsSnapshot>(
    stream: service.watchSummary(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const _AnalyticsMessage(
          message: 'Business insights are temporarily unavailable.',
        );
      }
      if (!snapshot.hasData) {
        return const Padding(
          padding: EdgeInsets.all(AppSpacing.large),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final analytics = snapshot.data!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business insights',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            'Aggregate booking and review activity only. Customer contact details are not shown here.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.medium),
          Wrap(
            spacing: AppSpacing.medium,
            runSpacing: AppSpacing.medium,
            children: [
              _MetricCard(
                label: 'Booking requests',
                value: '${analytics.totalBookings}',
                icon: Icons.calendar_month_outlined,
              ),
              _MetricCard(
                label: 'Accepted bookings',
                value: '${analytics.acceptedBookings}',
                icon: Icons.check_circle_outline_rounded,
              ),
              _MetricCard(
                label: 'Acceptance rate',
                value: '${(analytics.bookingConversionRate * 100).round()}%',
                icon: Icons.trending_up_rounded,
              ),
              _MetricCard(
                label: 'Average review',
                value: analytics.averageRating?.toStringAsFixed(1) ?? '—',
                icon: Icons.star_outline_rounded,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          _InsightSurface(
            title: 'Booking requests · last 7 days',
            child: _BookingTrend(points: analytics.bookingTrend),
          ),
          const SizedBox(height: AppSpacing.medium),
          LayoutBuilder(
            builder: (context, constraints) {
              final panelWidth = constraints.maxWidth >= 760
                  ? 360.0
                  : constraints.maxWidth;
              return Wrap(
                spacing: AppSpacing.medium,
                runSpacing: AppSpacing.medium,
                children: [
                  SizedBox(
                    width: panelWidth,
                    child: _InsightSurface(
                      title: 'Most requested services',
                      child: _RankedList(
                        items: analytics.topServices,
                        emptyMessage: 'No booking requests yet.',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: panelWidth,
                    child: _InsightSurface(
                      title: 'Popular gallery references',
                      child: _RankedList(
                        items: analytics.topGalleryReferences,
                        emptyMessage: 'No gallery references selected yet.',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: panelWidth,
                    child: _InsightSurface(
                      title: 'Review activity',
                      child: Text(
                        '${analytics.totalReviews} received · ${analytics.publishedReviews} published · ${analytics.reviewsLast30Days} in the last 30 days',
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.medium),
          const _AnalyticsMessage(
            message:
                'Website traffic and referral sources are not tracked in this privacy-conscious setup.',
          ),
        ],
      );
    },
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 200,
    child: Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: AppSpacing.medium),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    ),
  );
}

class _InsightSurface extends StatelessWidget {
  const _InsightSurface({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.medium),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppSpacing.radius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.medium),
        child,
      ],
    ),
  );
}

class _BookingTrend extends StatelessWidget {
  const _BookingTrend({required this.points});

  final List<AnalyticsTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final maximum = points.fold<int>(
      1,
      (value, point) => point.count > value ? point.count : value,
    );
    return SizedBox(
      height: 124,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final point in points)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${point.count}'),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: point.count / maximum,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(AppSpacing.radiusSmall),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${point.date.day}/${point.date.month}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RankedList extends StatelessWidget {
  const _RankedList({required this.items, required this.emptyMessage});

  final List<AnalyticsRanking> items;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return Text(emptyMessage);
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.small),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text('${item.count}'),
              ],
            ),
          ),
      ],
    );
  }
}

class _AnalyticsMessage extends StatelessWidget {
  const _AnalyticsMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.medium),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      border: Border.all(color: Theme.of(context).colorScheme.outline),
    ),
    child: Text(message),
  );
}
