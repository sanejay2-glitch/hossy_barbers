import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hossy_barbers/features/booking/domain/booking_request.dart';
import 'package:hossy_barbers/features/booking/domain/booking_payment.dart';

class BookingRequestRecord {
  const BookingRequestRecord({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.serviceId,
    required this.serviceName,
    required this.preferredDate,
    required this.preferredTime,
    required this.status,
    required this.referenceGalleryItemId,
    required this.referenceImageUrl,
    required this.referenceCaption,
    required this.paymentStatus,
    required this.paymentReference,
    required this.paymentTransactionId,
    required this.paymentAmount,
    required this.paymentCurrency,
    required this.paymentFailureReason,
    required this.paymentAccessToken,
    this.createdAt,
    this.paymentCreatedAt,
    this.paymentVerifiedAt,
  });

  final String id;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String serviceId;
  final String serviceName;
  final String preferredDate;
  final String preferredTime;
  final String status;
  final String referenceGalleryItemId;
  final String referenceImageUrl;
  final String referenceCaption;
  final String paymentStatus;
  final String paymentReference;
  final String paymentTransactionId;
  final double? paymentAmount;
  final String paymentCurrency;
  final String paymentFailureReason;
  final String paymentAccessToken;
  final DateTime? createdAt;
  final DateTime? paymentCreatedAt;
  final DateTime? paymentVerifiedAt;

  BookingStatus get bookingState => BookingStatusStorage.fromValue(status);
  PaymentStatus get paymentState =>
      PaymentStatusStorage.fromValue(paymentStatus);

  factory BookingRequestRecord.fromMap(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    final paymentCreatedAt = data['paymentCreatedAt'];
    final paymentVerifiedAt = data['paymentVerifiedAt'];
    return BookingRequestRecord(
      id: id,
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      customerEmail: data['customerEmail'] as String? ?? '',
      serviceId: data['serviceId'] as String? ?? '',
      serviceName: data['serviceName'] as String? ?? '',
      preferredDate: data['preferredDate'] as String? ?? '',
      preferredTime: data['preferredTime'] as String? ?? '',
      status: data['status'] as String? ?? 'prepared',
      referenceGalleryItemId: data['referenceGalleryItemId'] as String? ?? '',
      referenceImageUrl: data['referenceImageUrl'] as String? ?? '',
      referenceCaption: data['referenceCaption'] as String? ?? '',
      paymentStatus: data['paymentStatus'] as String? ?? 'not_required',
      paymentReference: data['paymentReference'] as String? ?? '',
      paymentTransactionId: data['paymentTransactionId'] as String? ?? '',
      paymentAmount: (data['paymentAmount'] as num?)?.toDouble(),
      paymentCurrency: data['paymentCurrency'] as String? ?? '',
      paymentFailureReason: data['paymentFailureReason'] as String? ?? '',
      paymentAccessToken: data['paymentAccessToken'] as String? ?? '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      paymentCreatedAt: paymentCreatedAt is Timestamp
          ? paymentCreatedAt.toDate()
          : null,
      paymentVerifiedAt: paymentVerifiedAt is Timestamp
          ? paymentVerifiedAt.toDate()
          : null,
    );
  }

  static Map<String, Object> toCreateMap(BookingRequest request) => {
    'customerName': request.customerName,
    'customerPhone': request.customerPhone,
    'customerEmail': request.customerEmail ?? '',
    'serviceId': request.service.id,
    'serviceName': request.service.name,
    'preferredDate':
        '${request.preferredDate.year}-${request.preferredDate.month.toString().padLeft(2, '0')}-${request.preferredDate.day.toString().padLeft(2, '0')}',
    'preferredTime': request.preferredTime,
    'referenceGalleryItemId': request.referenceGalleryItemId ?? '',
    'referenceImageUrl': request.referenceImageUrl ?? '',
    'referenceCaption': request.referenceCaption ?? '',
    'status': 'prepared',
    'paymentStatus': 'not_required',
    'createdAt': FieldValue.serverTimestamp(),
  };
}
