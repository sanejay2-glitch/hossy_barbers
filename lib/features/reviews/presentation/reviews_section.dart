import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/features/reviews/data/reviews_repository.dart';
import 'package:hossy_barbers/features/reviews/domain/customer_review.dart';
import 'package:hossy_barbers/features/reviews/domain/review_summary.dart';
import 'package:hossy_barbers/features/reviews/presentation/reviews_page.dart';
import 'package:hossy_barbers/features/reviews/presentation/review_widgets.dart';
import 'package:hossy_barbers/shared/widgets/page_container.dart';
import 'package:hossy_barbers/shared/widgets/section_heading.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key, required this.repository});

  final ReviewsRepository? repository;

  void _openReviews(BuildContext context) =>
      Navigator.of(context).pushNamed(ReviewsPage.routeName);

  @override
  Widget build(BuildContext context) => Container(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: PageContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: AppSpacing.section,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            eyebrow: 'Ratings & reviews',
            title: 'Trusted by the people in our chair.',
            description:
                'Every review is moderated before it appears publicly.',
          ),
          const SizedBox(height: AppSpacing.large),
          StreamBuilder<List<CustomerReview>>(
            stream: repository?.watchPublished(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _ReviewUnavailable(
                  onOpenReviews: () => _openReviews(context),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final reviews = snapshot.data ?? const [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReviewSummaryCard(
                    summary: ReviewSummary.fromReviews(reviews),
                  ),
                  const SizedBox(height: AppSpacing.large),
                  _RecentReviewPreview(
                    reviews: reviews.take(2).toList(),
                    onOpenReviews: () => _openReviews(context),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _RecentReviewPreview extends StatelessWidget {
  const _RecentReviewPreview({
    required this.reviews,
    required this.onOpenReviews,
  });

  final List<CustomerReview> reviews;
  final VoidCallback onOpenReviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return OutlinedButton(
        onPressed: onOpenReviews,
        child: const Text('Be the first to share your experience'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What clients are saying',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.medium),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 640 ? 2 : 1;
            final width =
                (constraints.maxWidth - (columns - 1) * AppSpacing.medium) /
                columns;
            return Wrap(
              spacing: AppSpacing.medium,
              runSpacing: AppSpacing.medium,
              children: [
                for (final review in reviews)
                  SizedBox(
                    width: width,
                    child: ReviewCard(review: review, compact: true),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.medium),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onOpenReviews,
            child: const Text('View all reviews  →'),
          ),
        ),
      ],
    );
  }
}

class _ReviewUnavailable extends StatelessWidget {
  const _ReviewUnavailable({required this.onOpenReviews});

  final VoidCallback onOpenReviews;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onOpenReviews,
    child: const Text('Open ratings & reviews'),
  );
}
