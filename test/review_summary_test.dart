import 'package:flutter_test/flutter_test.dart';
import 'package:hossy_barbers/features/reviews/domain/customer_review.dart';
import 'package:hossy_barbers/features/reviews/domain/review_summary.dart';

void main() {
  test('calculates published ratings only from real published reviews', () {
    final summary = ReviewSummary.fromReviews([
      _review(id: 'one', rating: 5, published: true),
      _review(id: 'two', rating: 4, published: true),
      _review(id: 'three', rating: 2, published: true),
      _review(id: 'four', rating: 5, published: false),
    ]);

    expect(summary.totalPublished, 3);
    expect(summary.ratingTotal, 11);
    expect(summary.averageRating, closeTo(11 / 3, 0.001));
    expect(summary.countFor(5), 1);
    expect(summary.countFor(4), 1);
    expect(summary.countFor(2), 1);
    expect(summary.positivePercentage, closeTo(200 / 3, 0.001));
  });

  test(
    'keeps aggregate counts synchronized when reviews are published or hidden',
    () {
      const summary = ReviewSummary(
        totalPublished: 2,
        ratingTotal: 9,
        ratingCounts: {4: 1, 5: 1},
      );

      final afterPublish = summary.withPublishedReview(3, added: true);
      final afterHide = afterPublish.withPublishedReview(3, added: false);

      expect(afterPublish.totalPublished, 3);
      expect(afterPublish.ratingTotal, 12);
      expect(afterPublish.countFor(3), 1);
      expect(afterHide.totalPublished, summary.totalPublished);
      expect(afterHide.ratingTotal, summary.ratingTotal);
      expect(afterHide.ratingCounts, summary.ratingCounts);
    },
  );
}

CustomerReview _review({
  required String id,
  required int rating,
  required bool published,
}) => CustomerReview(
  id: id,
  rating: rating,
  review: 'Review',
  displayName: 'Client',
  published: published,
);
