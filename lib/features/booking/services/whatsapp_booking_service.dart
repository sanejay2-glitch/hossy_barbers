import 'package:hossy_barbers/features/booking/domain/booking_request.dart';

class WhatsAppBookingService {
  const WhatsAppBookingService();

  static const defaultBusinessWhatsAppNumber = '+234 913 928 0666';

  Uri? createBookingUri(
    BookingRequest request,
    String? businessWhatsAppNumber,
  ) {
    final configuredNumber = businessWhatsAppNumber?.trim();
    final numberToUse = configuredNumber?.isNotEmpty == true
        ? configuredNumber!
        : defaultBusinessWhatsAppNumber;
    final phoneNumber = numberToUse.replaceAll(RegExp(r'[^0-9]'), '');
    if (phoneNumber.isEmpty) {
      return null;
    }

    final date =
        '${request.preferredDate.year}-${request.preferredDate.month.toString().padLeft(2, '0')}-${request.preferredDate.day.toString().padLeft(2, '0')}';
    final message =
        "Hello Hossy Barbers 👋\n\nI'd like to book an appointment.\n\nName: ${request.customerName}\nPhone: ${request.customerPhone}\nService: ${request.service.name}\nDate: $date\nTime: ${request.preferredTime}\n\nThank you.";
    return Uri.https('wa.me', phoneNumber, {'text': message});
  }
}
