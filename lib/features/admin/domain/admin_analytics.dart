class AdminAnalyticsSnapshot {
  const AdminAnalyticsSnapshot({
    required this.totalBookings,
    required this.acceptedBookings,
    required this.declinedBookings,
    required this.cancelledBookings,
    required this.bookingTrend,
    required this.topServices,
    required this.topGalleryReferences,
    required this.totalReviews,
    required this.publishedReviews,
    required this.averageRating,
    required this.reviewsLast30Days,
  });

  final int totalBookings;
  final int acceptedBookings;
  final int declinedBookings;
  final int cancelledBookings;
  final List<AnalyticsTrendPoint> bookingTrend;
  final List<AnalyticsRanking> topServices;
  final List<AnalyticsRanking> topGalleryReferences;
  final int totalReviews;
  final int publishedReviews;
  final double? averageRating;
  final int reviewsLast30Days;

  double get bookingConversionRate =>
      totalBookings == 0 ? 0 : acceptedBookings / totalBookings;
}

class AnalyticsTrendPoint {
  const AnalyticsTrendPoint({required this.date, required this.count});

  final DateTime date;
  final int count;
}

class AnalyticsRanking {
  const AnalyticsRanking({required this.label, required this.count});

  final String label;
  final int count;
}
