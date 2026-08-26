import 'package:flutter_test/flutter_test.dart';
import 'package:hossy_barbers/features/booking/domain/booking_request.dart';
import 'package:hossy_barbers/features/booking/services/whatsapp_booking_service.dart';
import 'package:hossy_barbers/features/services/domain/service.dart';

void main() {
  const service = Service(id: 'cut', name: 'Haircut', description: '');
  final request = BookingRequest(
    customerName: 'Ada',
    customerPhone: '+234 800 000 0000',
    service: service,
    preferredDate: DateTime(2026, 8, 22),
    preferredTime: 'Morning',
  );

  test(
    'normalizes the business WhatsApp number and encodes booking details',
    () {
      final uri = const WhatsAppBookingService().createBookingUri(
        request,
        '+234 910 928 0666',
      );

      expect(uri, isNotNull);
      expect(uri.toString(), contains('wa.me/2349109280666'));

      final queryParameters = uri!.queryParameters;
      expect(queryParameters['text'], contains('Name: Ada'));
      expect(queryParameters['text'], contains('Phone: +234 800 000 0000'));
      expect(queryParameters['text'], contains('Date: 2026-08-22'));
    },
  );

  test(
    'uses the configured safe fallback when business settings are empty',
    () {
      final uri = const WhatsAppBookingService().createBookingUri(request, '');

      expect(uri.toString(), contains('wa.me/2349109280666'));
    },
  );
}
