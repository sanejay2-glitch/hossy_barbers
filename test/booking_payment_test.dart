import 'package:flutter_test/flutter_test.dart';
import 'package:hossy_barbers/features/booking/domain/booking_payment.dart';
import 'package:hossy_barbers/features/booking/domain/booking_request_record.dart';

void main() {
  test('maps stored booking and payment states safely', () {
    expect(BookingStatusStorage.fromValue('accepted'), BookingStatus.accepted);
    expect(
      PaymentStatusStorage.fromValue('successful'),
      PaymentStatus.successful,
    );
    expect(
      PaymentStatusStorage.fromValue('untrusted-client-value'),
      PaymentStatus.notRequired,
    );
  });

  test('keeps legacy booking records payment-safe by default', () {
    final record = BookingRequestRecord.fromMap('booking-id', {
      'customerName': 'Ada',
      'customerPhone': '+2348000000000',
      'serviceName': 'Haircut',
      'status': 'prepared',
    });

    expect(record.paymentState, PaymentStatus.notRequired);
    expect(record.bookingState, BookingStatus.prepared);
    expect(record.paymentAmount, isNull);
  });

  test('formats payment amounts with their configured currency', () {
    expect(formatPaymentAmount(4500, 'NGN'), 'NGN 4,500');
    expect(formatPaymentAmount(4500.5, 'NGN'), 'NGN 4,500.50');
  });
}
