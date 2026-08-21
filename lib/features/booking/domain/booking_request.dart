import 'package:hossy_barbers/features/services/domain/service.dart';

class BookingRequest {
  const BookingRequest({
    required this.customerName,
    required this.service,
    required this.preferredDate,
    required this.preferredTime,
  });

  final String customerName;
  final Service service;
  final DateTime preferredDate;
  final String preferredTime;
}
