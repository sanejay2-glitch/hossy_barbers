import 'package:flutter_test/flutter_test.dart';
import 'package:hossy_barbers/features/booking/domain/booking_request.dart';
import 'package:hossy_barbers/features/booking/domain/booking_request_record.dart';
import 'package:hossy_barbers/features/services/domain/service.dart';

void main() {
  test('stores the selected CMS service and gallery reference details', () {
    const service = Service(
      id: 'service-cut',
      name: 'Haircut',
      description: 'A precise cut.',
    );
    final request = BookingRequest(
      customerName: 'Ada',
      customerPhone: '+234 800 000 0000',
      service: service,
      preferredDate: DateTime(2026, 8, 22),
      preferredTime: 'Morning (time to confirm)',
      referenceGalleryItemId: 'gallery-fade',
      referenceImageUrl: 'https://example.com/fade.jpg',
      referenceCaption: 'Low fade',
    );

    final data = BookingRequestRecord.toCreateMap(request);

    expect(data['serviceId'], 'service-cut');
    expect(data['serviceName'], 'Haircut');
    expect(data['referenceGalleryItemId'], 'gallery-fade');
    expect(data['referenceImageUrl'], 'https://example.com/fade.jpg');
    expect(data['referenceCaption'], 'Low fade');
    expect(data['status'], 'prepared');
  });
}
