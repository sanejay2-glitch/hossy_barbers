import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hossy_barbers/features/admin/domain/admin_analytics.dart';
import 'package:hossy_barbers/features/booking/data/booking_requests_repository.dart';
import 'package:hossy_barbers/features/booking/domain/booking_request_record.dart';
import 'package:hossy_barbers/features/reviews/data/reviews_repository.dart';
import 'package:hossy_barbers/features/reviews/domain/customer_review.dart';

class AdminAnalyticsService {
  AdminAnalyticsService({
    required BookingRequestsRepository bookingRequestsRepository,
    required ReviewsRepository reviewsRepository,
    DateTime Function()? now,
  }) : _bookingRequestsRepository = bookingRequestsRepository,
       _reviewsRepository = reviewsRepository,
       _now = now ?? DateTime.now;

  final BookingRequestsRepository _bookingRequestsRepository;
  final ReviewsRepository _reviewsRepository;
  final DateTime Function() _now;

  Stream<AdminAnalyticsSnapshot> watchSummary() {
    late final StreamController<AdminAnalyticsSnapshot> controller;
    StreamSubscription<List<BookingRequestRecord>>? bookingsSubscription;
    StreamSubscription<List<CustomerReview>>? reviewsSubscription;
    List<BookingRequestRecord>? bookings;
    List<CustomerReview>? reviews;

    void emitSummary() {
      if (bookings == null || reviews == null) return;
      controller.add(
        summarize(bookings: bookings!, reviews: reviews!, now: _now()),
      );
    }

    controller = StreamController<AdminAnalyticsSnapshot>(
      onListen: () {
        bookingsSubscription = _bookingRequestsRepository.watchAll().listen((
          items,
        ) {
          bookings = items;
          emitSummary();
        }, onError: controller.addError);
        reviewsSubscription = _reviewsRepository.watchAll().listen((items) {
          reviews = items;
          emitSummary();
        }, onError: controller.addError);
      },
      onCancel: () async {
        await bookingsSubscription?.cancel();
        await reviewsSubscription?.cancel();
      },
    );
    return controller.stream;
  }

  static AdminAnalyticsSnapshot summarize({
    required List<BookingRequestRecord> bookings,
    required List<CustomerReview> reviews,
    required DateTime now,
  }) {
    final today = DateUtils.dateOnly(now);
    final firstTrendDay = today.subtract(const Duration(days: 6));
    final bookingCountsByDay = <DateTime, int>{};
    final serviceCounts = <String, int>{};
    final galleryReferenceCounts = <String, int>{};

    for (final booking in bookings) {
      final createdAt = booking.createdAt;
      if (createdAt != null) {
        final day = DateUtils.dateOnly(createdAt);
        if (!day.isBefore(firstTrendDay) && !day.isAfter(today)) {
          bookingCountsByDay.update(
            day,
            (count) => count + 1,
            ifAbsent: () => 1,
          );
        }
      }
      if (booking.serviceName.isNotEmpty) {
        serviceCounts.update(
          booking.serviceName,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
      if (booking.referenceGalleryItemId.isNotEmpty) {
        final label = booking.referenceCaption.isEmpty
            ? 'Gallery inspiration'
            : booking.referenceCaption;
        galleryReferenceCounts.update(
          label,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }

    final ratings = reviews.where((review) => review.rating > 0).toList();
    final averageRating = ratings.isEmpty
        ? null
        : ratings.fold<int>(0, (sum, review) => sum + review.rating) /
              ratings.length;
    final reviewCutoff = today.subtract(const Duration(days: 29));

    return AdminAnalyticsSnapshot(
      totalBookings: bookings.length,
      acceptedBookings: bookings
          .where((booking) => booking.status == 'accepted')
          .length,
      declinedBookings: bookings
          .where((booking) => booking.status == 'declined')
          .length,
      cancelledBookings: bookings
          .where((booking) => booking.status == 'cancelled')
          .length,
      bookingTrend: List.generate(7, (index) {
        final day = firstTrendDay.add(Duration(days: index));
        return AnalyticsTrendPoint(
          date: day,
          count: bookingCountsByDay[day] ?? 0,
        );
      }),
      topServices: _rank(serviceCounts),
      topGalleryReferences: _rank(galleryReferenceCounts),
      totalReviews: reviews.length,
      publishedReviews: reviews.where((review) => review.published).length,
      averageRating: averageRating,
      reviewsLast30Days: reviews
          .where(
            (review) =>
                review.createdAt != null &&
                !DateUtils.dateOnly(review.createdAt!).isBefore(reviewCutoff) &&
                !DateUtils.dateOnly(review.createdAt!).isAfter(today),
          )
          .length,
    );
  }

  static List<AnalyticsRanking> _rank(Map<String, int> counts) {
    final rankings =
        counts.entries
            .map(
              (entry) => AnalyticsRanking(label: entry.key, count: entry.value),
            )
            .toList()
          ..sort((a, b) {
            final byCount = b.count.compareTo(a.count);
            return byCount != 0 ? byCount : a.label.compareTo(b.label);
          });
    return rankings.take(3).toList();
  }
}
