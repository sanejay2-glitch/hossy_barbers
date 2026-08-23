import 'package:hossy_barbers/features/services/domain/service.dart';

class BookingRequest {
  const BookingRequest({
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.service,
    required this.preferredDate,
    required this.preferredTime,
    this.referenceGalleryItemId,
    this.referenceImageUrl,
    this.referenceCaption,
  });

  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final Service service;
  final DateTime preferredDate;
  final String preferredTime;
  final String? referenceGalleryItemId;
  final String? referenceImageUrl;
  final String? referenceCaption;
}
