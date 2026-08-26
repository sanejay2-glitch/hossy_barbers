import 'package:flutter_test/flutter_test.dart';
import 'package:hossy_barbers/features/booking/services/booking_time_slots.dart';
import 'package:hossy_barbers/features/services/domain/service.dart';

void main() {
  const bookingHours = <String, String>{'Monday–Sunday': '8:00 AM – 6:00 PM'};

  test('generates exact 30-minute slots from configured booking hours', () {
    final slots = BookingTimeSlots.forAppointment(
      date: DateTime(2026, 8, 24),
      openingHours: bookingHours,
      now: DateTime(2026, 8, 23),
    );

    expect(slots.first, '8:00 AM');
    expect(slots.last, '5:30 PM');
    expect(slots, hasLength(20));
  });

  test('uses the selected service duration to space slots', () {
    const service = Service(
      id: 'locs',
      name: 'Loc treatment',
      description: '',
      duration: '1 hour',
    );

    final slots = BookingTimeSlots.forAppointment(
      date: DateTime(2026, 8, 24),
      openingHours: bookingHours,
      service: service,
      now: DateTime(2026, 8, 23),
    );

    expect(slots.take(3), ['8:00 AM', '9:00 AM', '10:00 AM']);
    expect(slots.last, '5:00 PM');
  });

  test('does not offer elapsed same-day appointment slots', () {
    final slots = BookingTimeSlots.forAppointment(
      date: DateTime(2026, 8, 24),
      openingHours: bookingHours,
      now: DateTime(2026, 8, 24, 10, 10),
    );

    expect(slots.first, '10:30 AM');
    expect(slots, isNot(contains('10:00 AM')));
  });

  test('honors configured closed days', () {
    const weekdayHours = <String, String>{
      'Monday–Saturday': '9:00 AM – 5:00 PM',
      'Sunday': 'Closed',
    };

    expect(
      BookingTimeSlots.isOpenOnDate(DateTime(2026, 8, 30), weekdayHours),
      isFalse,
    );
    expect(
      BookingTimeSlots.forAppointment(
        date: DateTime(2026, 8, 30),
        openingHours: weekdayHours,
        now: DateTime(2026, 8, 23),
      ),
      isEmpty,
    );
  });
}
