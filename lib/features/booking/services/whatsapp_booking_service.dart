import 'package:hossy_barbers/core/constants/development_content.dart';
import 'package:hossy_barbers/features/booking/domain/booking_request.dart';

class WhatsAppBookingService {
  const WhatsAppBookingService();

  Uri? createBookingUri(BookingRequest request) {
    final phoneNumber = DevelopmentContent.whatsappNumber;
    if (phoneNumber.isEmpty) return null;

    final date =
        '${request.preferredDate.year}-${request.preferredDate.month.toString().padLeft(2, '0')}-${request.preferredDate.day.toString().padLeft(2, '0')}';
    final message =
        'Hello Hossy Barbers,\n\nI would like to book an appointment.\nName: ${request.customerName}\nService: ${request.service.name}\nDate: $date\nTime: ${request.preferredTime}\n\nThank you.';
    return Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeQueryComponent(message)}',
    );
  }
}
