import 'package:hossy_barbers/features/reviews/domain/customer_review.dart';

class ReviewSummary {
  const ReviewSummary({
    required this.totalPublished,
    required this.ratingTotal,
    required this.ratingCounts,
  });

  static const empty = ReviewSummary(
    totalPublished: 0,
    ratingTotal: 0,
    ratingCounts: {},
  );

  final int totalPublished;
  final int ratingTotal;
  final Map<int, int> ratingCounts;

  double? get averageRating =>
      totalPublished == 0 ? null : ratingTotal / totalPublished;

  int countFor(int rating) => ratingCounts[rating] ?? 0;

  double get positivePercentage => totalPublished == 0
      ? 0
      : (countFor(5) + countFor(4)) / totalPublished * 100;

  factory ReviewSummary.fromMap(Map<String, dynamic> data) => ReviewSummary(
    totalPublished: data['totalPublished'] as int? ?? 0,
    ratingTotal: data['ratingTotal'] as int? ?? 0,
    ratingCounts: _ratingCounts(data['ratingCounts']),
  );

  factory ReviewSummary.fromReviews(Iterable<CustomerReview> reviews) {
    var total = 0;
    var totalRating = 0;
    final counts = <int, int>{};
    for (final review in reviews) {
      if (!review.published || review.rating < 1 || review.rating > 5) {
        continue;
      }
      total++;
      totalRating += review.rating;
      counts.update(review.rating, (count) => count + 1, ifAbsent: () => 1);
    }
    return ReviewSummary(
      totalPublished: total,
      ratingTotal: totalRating,
      ratingCounts: counts,
    );
  }

  ReviewSummary withPublishedReview(int rating, {required bool added}) {
    if (rating < 1 || rating > 5) return this;
    final nextCounts = Map<int, int>.from(ratingCounts);
    final difference = added ? 1 : -1;
    final nextCount = (nextCounts[rating] ?? 0) + difference;
    if (nextCount <= 0) {
      nextCounts.remove(rating);
    } else {
      nextCounts[rating] = nextCount;
    }
    final nextTotal = totalPublished + difference;
    final nextRatingTotal = ratingTotal + rating * difference;
    return ReviewSummary(
      totalPublished: nextTotal < 0 ? 0 : nextTotal,
      ratingTotal: nextRatingTotal < 0 ? 0 : nextRatingTotal,
      ratingCounts: nextCounts,
    );
  }

  Map<String, Object> toMap() => {
    'totalPublished': totalPublished,
    'ratingTotal': ratingTotal,
    'ratingCounts': {
      for (var rating = 1; rating <= 5; rating++) '$rating': countFor(rating),
    },
  };

  static Map<int, int> _ratingCounts(Object? value) {
    if (value is! Map) return const {};
    final counts = <int, int>{};
    for (final entry in value.entries) {
      final rating = int.tryParse(entry.key.toString());
      final count = entry.value as int?;
      if (rating != null &&
          rating >= 1 &&
          rating <= 5 &&
          count != null &&
          count > 0) {
        counts[rating] = count;
      }
    }
    return counts;
  }
}
