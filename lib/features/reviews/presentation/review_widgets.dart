import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/features/reviews/domain/customer_review.dart';
import 'package:hossy_barbers/features/reviews/domain/review_summary.dart';

class ReviewSummaryCard extends StatelessWidget {
  const ReviewSummaryCard({
    super.key,
    required this.summary,
    this.compact = false,
  });

  final ReviewSummary summary;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (summary.totalPublished == 0) {
      return _ReviewSurface(
        child: Row(
          children: [
            Text(
              '☆',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.medium),
            Expanded(
              child: Text(
                'No customer ratings have been published yet.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      );
    }

    return _ReviewSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = compact || constraints.maxWidth < 520;
          final rating = summary.averageRating!;
          final overview = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    rating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.6,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 4,
                      bottom: AppSpacing.xSmall,
                    ),
                    child: Text(
                      '/ 5',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ReviewStars(rating: rating, size: 22),
              const SizedBox(height: AppSpacing.small),
              Text(
                '${summary.totalPublished} ${summary.totalPublished == 1 ? 'review' : 'reviews'}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (summary.totalPublished > 1) ...[
                const SizedBox(height: 4),
                Text(
                  '${summary.positivePercentage.round()}% gave 4 or 5 stars',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          );
          final distribution = _RatingDistribution(summary: summary);
          return stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    overview,
                    const SizedBox(height: AppSpacing.large),
                    distribution,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 180, child: overview),
                    const SizedBox(width: AppSpacing.large),
                    Expanded(child: distribution),
                  ],
                );
        },
      ),
    );
  }
}

class ReviewStars extends StatelessWidget {
  const ReviewStars({super.key, required this.rating, this.size = 18});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final stars = <Widget>[];
    for (var index = 0; index < 5; index++) {
      final remaining = rating - index;
      stars.add(
        Text(
          remaining >= .75 ? '★' : remaining >= .25 ? '★' : '☆',
          style: TextStyle(
            color: color.withValues(alpha: remaining >= .75 ? 1 : .48),
            fontSize: size,
            height: 1,
          ),
        ),
      );
    }
    return Semantics(
      label: '${rating.toStringAsFixed(1)} out of 5 stars',
      child: ExcludeSemantics(
        child: Row(mainAxisSize: MainAxisSize.min, children: stars),
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review, this.compact = false});

  final CustomerReview review;
  final bool compact;

  @override
  Widget build(BuildContext context) => _ReviewSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _ReviewerAvatar(name: review.displayName),
            const SizedBox(width: AppSpacing.small),
            Expanded(
              child: Text(
                review.displayName.isEmpty
                    ? 'Anonymous client'
                    : review.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            if (review.createdAt != null)
              Text(
                _formatDate(review.createdAt!),
                style: Theme.of(context).textTheme.labelSmall,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.small),
        Row(
          children: [
            ReviewStars(rating: review.rating.toDouble(), size: 17),
            const SizedBox(width: AppSpacing.xSmall),
            Text(
              '${review.rating}.0',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),
        Text(
          '“${review.review}”',
          maxLines: compact ? 3 : null,
          overflow: compact ? TextOverflow.ellipsis : null,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.55),
        ),
      ],
    ),
  );

  String _formatDate(DateTime date) =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}

class _ReviewerAvatar extends StatelessWidget {
  const _ReviewerAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: 16,
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(
        alpha: .18,
      ),
      child: Text(initial, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _RatingDistribution extends StatelessWidget {
  const _RatingDistribution({required this.summary});

  final ReviewSummary summary;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var rating = 5; rating >= 1; rating--)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(width: 32, child: Text('$rating ★')),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  child: LinearProgressIndicator(
                    value: (summary.countFor(rating) / summary.totalPublished)
                        .clamp(0, 1)
                        .toDouble(),
                    minHeight: 7,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: .22),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.small),
              SizedBox(width: 22, child: Text('${summary.countFor(rating)}')),
            ],
          ),
        ),
    ],
  );
}

class _ReviewSurface extends StatelessWidget {
  const _ReviewSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.large),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      border: Border.all(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: .55),
      ),
    ),
    child: child,
  );
}
