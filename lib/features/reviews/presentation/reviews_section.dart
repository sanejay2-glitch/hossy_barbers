import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/features/reviews/data/reviews_repository.dart';
import 'package:hossy_barbers/features/reviews/domain/customer_review.dart';
import 'package:hossy_barbers/shared/widgets/page_container.dart';
import 'package:hossy_barbers/shared/widgets/section_heading.dart';

class ReviewsSection extends StatefulWidget {
  const ReviewsSection({super.key, required this.repository});
  final ReviewsRepository? repository;

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _review = TextEditingController();
  var _rating = 5;
  var _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _review.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.repository == null || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.repository!.submit(
        rating: _rating,
        review: _review.text.trim(),
        displayName: _name.text.trim(),
      );
      if (mounted) {
        _name.clear();
        _review.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you. Your review will appear after approval.'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your review could not be submitted.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

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
            eyebrow: 'Reviews',
            title: 'Trusted by the people in our chair.',
            description:
                'Every review is moderated before it appears publicly.',
          ),
          const SizedBox(height: AppSpacing.large),
          _PublishedReviews(repository: widget.repository),
          const SizedBox(height: AppSpacing.large),
          Container(
            constraints: const BoxConstraints(maxWidth: 680),
            padding: const EdgeInsets.all(AppSpacing.large),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: .7),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leave a review',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    'Your rating',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xSmall),
                  Wrap(
                    spacing: 2,
                    children: List.generate(
                      5,
                      (index) => IconButton(
                        tooltip: '${index + 1} star${index == 0 ? '' : 's'}',
                        onPressed: _submitting
                            ? null
                            : () => setState(() => _rating = index + 1),
                        icon: Icon(
                          index < _rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  TextFormField(
                    controller: _name,
                    enabled: !_submitting && widget.repository != null,
                    decoration: const InputDecoration(
                      labelText: 'Name (optional)',
                    ),
                    maxLength: 80,
                  ),
                  TextFormField(
                    controller: _review,
                    enabled: !_submitting && widget.repository != null,
                    decoration: const InputDecoration(labelText: 'Your review'),
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 1000,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Write a short review'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  FilledButton.icon(
                    onPressed: widget.repository == null || _submitting
                        ? null
                        : _submit,
                    icon: const Icon(Icons.rate_review_outlined),
                    label: Text(_submitting ? 'Submitting…' : 'Submit review'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _PublishedReviews extends StatelessWidget {
  const _PublishedReviews({required this.repository});
  final ReviewsRepository? repository;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<CustomerReview>>(
    stream: repository?.watchPublished(),
    builder: (context, snapshot) {
      final reviews = snapshot.data ?? const [];
      if (reviews.isEmpty) return const _NoReviews();
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: reviews.map((review) => _ReviewCard(review: review)).toList(),
      );
    },
  );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final CustomerReview review;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 360,
    child: Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: .65),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '★' * review.rating,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            '“${review.review}”',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 17,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          Text(
            review.displayName.isEmpty
                ? 'Anonymous client'
                : review.displayName,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    ),
  );
}

class _NoReviews extends StatelessWidget {
  const _NoReviews();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.large),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      border: Border.all(color: Theme.of(context).colorScheme.outline),
    ),
    child: const Text('Be the first to share your Hossy Barbers experience.'),
  );
}
