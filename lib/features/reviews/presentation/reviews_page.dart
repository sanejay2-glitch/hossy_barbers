import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/features/reviews/data/reviews_repository.dart';
import 'package:hossy_barbers/features/reviews/domain/customer_review.dart';
import 'package:hossy_barbers/features/reviews/domain/review_summary.dart';
import 'package:hossy_barbers/features/reviews/presentation/review_submission_form.dart';
import 'package:hossy_barbers/features/reviews/presentation/review_widgets.dart';
import 'package:hossy_barbers/shared/widgets/page_container.dart';
import 'package:hossy_barbers/shared/widgets/section_heading.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key, required this.repository});

  static const routeName = '/reviews';

  final ReviewsRepository? repository;

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final _reviews = <CustomerReview>[];
  PublishedReviewsPage? _lastPage;
  var _hasMore = false;
  var _loading = true;
  var _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final repository = widget.repository;
    if (repository == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final page = await repository.fetchPublishedPage();
      if (!mounted) return;
      setState(() {
        _reviews
          ..clear()
          ..addAll(page.reviews);
        _lastPage = page;
        _hasMore = page.hasMore;
        _error = null;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Reviews could not be loaded. Please try again.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    final repository = widget.repository;
    if (repository == null || !_hasMore || _loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final page = await repository.fetchPublishedPage(after: _lastPage);
      if (!mounted) return;
      setState(() {
        _reviews.addAll(page.reviews);
        _lastPage = page;
        _hasMore = page.hasMore;
        _error = null;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'More reviews could not be loaded. Please try again.';
          _loadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Text('←', style: TextStyle(fontSize: 30)),
      ),
      title: const Text('Ratings & reviews'),
    ),
    body: SingleChildScrollView(
      child: PageContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: AppSpacing.xLarge,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading(
                eyebrow: 'Hossy Barbers',
                title: 'Ratings & reviews',
                description:
                    'Read real customer experiences and share your own after your appointment.',
              ),
              const SizedBox(height: AppSpacing.large),
              StreamBuilder<ReviewSummary>(
                stream: widget.repository?.watchPublicSummary(),
                builder: (context, snapshot) => ReviewSummaryCard(
                  summary: snapshot.data ?? ReviewSummary.empty,
                ),
              ),
              const SizedBox(height: AppSpacing.xLarge),
              Text(
                'All published reviews',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.medium),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null && _reviews.isEmpty)
                _RetryMessage(message: _error!, onRetry: _loadInitial)
              else if (_reviews.isEmpty)
                const Text('No published reviews yet.')
              else ...[
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 760 ? 2 : 1;
                    final width =
                        (constraints.maxWidth -
                            (columns - 1) * AppSpacing.medium) /
                        columns;
                    return Wrap(
                      spacing: AppSpacing.medium,
                      runSpacing: AppSpacing.medium,
                      children: [
                        for (final review in _reviews)
                          SizedBox(
                            width: width,
                            child: ReviewCard(review: review),
                          ),
                      ],
                    );
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.medium),
                  _RetryMessage(message: _error!, onRetry: _loadMore),
                ],
                if (_hasMore) ...[
                  const SizedBox(height: AppSpacing.large),
                  Center(
                    child: OutlinedButton(
                      onPressed: _loadingMore ? null : _loadMore,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_loadingMore) ...[
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: AppSpacing.xSmall),
                          ],
                          Text(
                            _loadingMore
                                ? 'Loading…'
                                : 'Load more reviews',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: AppSpacing.xLarge),
              ReviewSubmissionForm(repository: widget.repository),
            ],
          ),
        ),
      ),
    ),
  );
}

class _RetryMessage extends StatelessWidget {
  const _RetryMessage({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(message)),
      TextButton(onPressed: onRetry, child: const Text('Try again')),
    ],
  );
}
