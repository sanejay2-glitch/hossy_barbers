import 'package:flutter_test/flutter_test.dart';
import 'package:hossy_barbers/features/admin/services/admin_analytics_service.dart';
import 'package:hossy_barbers/features/booking/domain/booking_request_record.dart';
import 'package:hossy_barbers/features/reviews/domain/customer_review.dart';

void main() {
  test('summarizes aggregate booking and review insights without PII', () {
    final summary = AdminAnalyticsService.summarize(
      now: DateTime(2026, 8, 24, 12),
      bookings: [
        _booking(
          id: 'one',
          serviceName: 'Barbering',
          status: 'accepted',
          createdAt: DateTime(2026, 8, 24, 9),
          referenceId: 'gallery-one',
          referenceCaption: 'Low cut',
        ),
        _booking(
          id: 'two',
          serviceName: 'Barbering',
          status: 'declined',
          createdAt: DateTime(2026, 8, 23, 10),
        ),
        _booking(
          id: 'three',
          serviceName: 'Relocking',
          status: 'cancelled',
          createdAt: DateTime(2026, 8, 10),
        ),
      ],
      reviews: [
        CustomerReview(
          id: 'review-one',
          rating: 5,
          review: 'Great service',
          displayName: 'Client',
          published: true,
          createdAt: DateTime(2026, 8, 24),
        ),
        CustomerReview(
          id: 'review-two',
          rating: 3,
          review: 'Good',
          displayName: '',
          published: false,
          createdAt: DateTime(2026, 7, 10),
        ),
      ],
    );

    expect(summary.totalBookings, 3);
    expect(summary.acceptedBookings, 1);
    expect(summary.declinedBookings, 1);
    expect(summary.cancelledBookings, 1);
    expect(summary.bookingConversionRate, closeTo(1 / 3, 0.001));
    expect(summary.topServices.first.label, 'Barbering');
    expect(summary.topServices.first.count, 2);
    expect(summary.topGalleryReferences.single.label, 'Low cut');
    expect(summary.averageRating, 4);
    expect(summary.publishedReviews, 1);
    expect(summary.reviewsLast30Days, 1);
    expect(summary.bookingTrend.last.count, 1);
    expect(summary.bookingTrend[5].count, 1);
  });
}

BookingRequestRecord _booking({
  required String id,
  required String serviceName,
  required String status,
  required DateTime createdAt,
  String referenceId = '',
  String referenceCaption = '',
}) => BookingRequestRecord(
  id: id,
  customerName: 'Not used in analytics',
  customerPhone: 'Not used in analytics',
  customerEmail: '',
  serviceId: serviceName.toLowerCase(),
  serviceName: serviceName,
  preferredDate: '2026-08-24',
  preferredTime: '9:00 AM',
  status: status,
  referenceGalleryItemId: referenceId,
  referenceImageUrl: '',
  referenceCaption: referenceCaption,
  paymentStatus: 'not_required',
  paymentReference: '',
  paymentTransactionId: '',
  paymentAmount: null,
  paymentCurrency: '',
  paymentFailureReason: '',
  paymentAccessToken: '',
  createdAt: createdAt,
);
