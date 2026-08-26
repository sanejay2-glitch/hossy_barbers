import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/features/reviews/data/reviews_repository.dart';
import 'package:hossy_barbers/features/reviews/domain/customer_review.dart';

class ReviewsManager extends StatefulWidget {
  const ReviewsManager({super.key, required this.repository});
  final ReviewsRepository repository;

  @override
  State<ReviewsManager> createState() => _ReviewsManagerState();
}

class _ReviewsManagerState extends State<ReviewsManager> {
  @override
  void initState() {
    super.initState();
    unawaited(_ensureSummary());
  }

  Future<void> _ensureSummary() async {
    try {
      await widget.repository.ensureSummary();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<List<CustomerReview>>(
    stream: widget.repository.watchAll(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return const Center(child: Text('Reviews could not be loaded.'));
      }
      final reviews = snapshot.data ?? const [];
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review moderation',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.small),
                const Text(
                  'Customer reviews can be published, hidden, or removed. Their rating and text cannot be edited.',
                ),
                const SizedBox(height: AppSpacing.large),
                if (reviews.isEmpty)
                  const Text('No customer reviews have been submitted yet.')
                else
                  ...reviews.map(
                    (review) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.small),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.medium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${'★' * review.rating}${'☆' * (5 - review.rating)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const Spacer(),
                                  Chip(
                                    visualDensity: VisualDensity.compact,
                                    label: Text(
                                      review.published
                                          ? 'Published'
                                          : 'Pending',
                                    ),
                                    labelStyle: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xSmall),
                                  Switch(
                                    value: review.published,
                                    onChanged: (value) =>
                                        _publish(context, review, value),
                                  ),
                                ],
                              ),
                              Text(review.review),
                              const SizedBox(height: 8),
                              Text(
                                review.displayName.isEmpty
                                    ? 'Anonymous'
                                    : review.displayName,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              if (review.createdAt != null)
                                Text(
                                  '${review.createdAt!.day}/${review.createdAt!.month}/${review.createdAt!.year}',
                                ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => _delete(context, review),
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Delete'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );

  Future<void> _publish(
    BuildContext context,
    CustomerReview review,
    bool value,
  ) async {
    try {
      await widget.repository.setPublished(review, value);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review status could not be updated.')),
        );
      }
    }
  }

  Future<void> _delete(BuildContext context, CustomerReview review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete review?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    try {
      await widget.repository.delete(review.id);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review could not be deleted.')),
        );
      }
    }
  }
}
