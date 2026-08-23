import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hossy_barbers/features/admin/domain/booking_notification.dart';
import 'package:hossy_barbers/features/admin/services/booking_notification_read_store_stub.dart';
import 'package:hossy_barbers/features/admin/services/booking_notification_service.dart';
import 'package:hossy_barbers/features/admin/services/browser_notification_service_stub.dart';
import 'package:hossy_barbers/features/booking/domain/booking_request_record.dart';

void main() {
  test('detects a new booking once and updates the unread count', () async {
    final controller = StreamController<List<BookingRequestRecord>>();
    final browser = _FakeBrowserNotifications();
    final service = _service(controller, browser: browser);
    final alerts = <BookingRequestRecord>[];
    final subscription = service.newBookings.listen(alerts.add);
    await service.start();

    controller.add([_booking('first')]);
    await _settle();
    controller.add([_booking('second'), _booking('first')]);
    await _settle();
    controller.add([_booking('second'), _booking('first')]);
    await _settle();

    expect(alerts.map((booking) => booking.id), ['second']);
    expect(service.state.value.unreadCount, 2);
    expect(browser.shownCustomerNames, ['Second customer']);

    await subscription.cancel();
    await service.dispose();
    await controller.close();
  });

  test('marks individual and all booking notifications as read', () async {
    final controller = StreamController<List<BookingRequestRecord>>();
    final store = _MemoryReadStore();
    final service = BookingNotificationService(
      watchBookings: () => controller.stream,
      readStore: store,
      browserNotificationService: _FakeBrowserNotifications(),
    );
    await service.start();
    controller.add([_booking('first'), _booking('second')]);
    await _settle();

    expect(service.state.value.unreadCount, 2);
    await service.markRead('first');
    expect(service.state.value.unreadCount, 1);
    await service.markAllRead();
    expect(service.state.value.unreadCount, 0);
    expect(store.savedIds, containsAll(['first', 'second']));

    await service.dispose();
    await controller.close();
  });

  test(
    'keeps in-app new booking alerts when browser alerts are unavailable',
    () async {
      final controller = StreamController<List<BookingRequestRecord>>();
      final browser = _FakeBrowserNotifications(supported: false);
      final service = _service(controller, browser: browser);
      final alerts = <BookingRequestRecord>[];
      final subscription = service.newBookings.listen(alerts.add);
      await service.start();

      controller.add([_booking('first')]);
      await _settle();
      controller.add([_booking('second'), _booking('first')]);
      await _settle();

      expect(alerts.single.id, 'second');
      expect(browser.shownCustomerNames, isEmpty);
      expect(service.state.value.browserNotificationsSupported, isFalse);

      await subscription.cancel();
      await service.dispose();
      await controller.close();
    },
  );

  test(
    'keeps in-app alerts when browser notification permission is denied',
    () async {
      final controller = StreamController<List<BookingRequestRecord>>();
      final browser = _FakeBrowserNotifications(
        permission: BrowserNotificationPermission.denied,
      );
      final service = _service(controller, browser: browser);
      final alerts = <BookingRequestRecord>[];
      final subscription = service.newBookings.listen(alerts.add);
      await service.start();

      controller.add([_booking('first')]);
      await _settle();
      controller.add([_booking('second'), _booking('first')]);
      await _settle();

      expect(alerts.single.id, 'second');
      expect(browser.shownCustomerNames, isEmpty);
      expect(
        service.state.value.browserPermission,
        BrowserNotificationPermission.denied,
      );

      await subscription.cancel();
      await service.dispose();
      await controller.close();
    },
  );
}

BookingNotificationService _service(
  StreamController<List<BookingRequestRecord>> controller, {
  required _FakeBrowserNotifications browser,
}) => BookingNotificationService(
  watchBookings: () => controller.stream,
  readStore: _MemoryReadStore(),
  browserNotificationService: browser,
);

BookingRequestRecord _booking(String id) => BookingRequestRecord.fromMap(id, {
  'customerName': '${id[0].toUpperCase()}${id.substring(1)} customer',
  'customerPhone': '+2348000000000',
  'customerEmail': 'customer@example.com',
  'serviceId': 'service-id',
  'serviceName': 'Haircut',
  'preferredDate': '2026-08-22',
  'preferredTime': 'Morning',
  'status': 'prepared',
  'paymentStatus': 'not_required',
});

Future<void> _settle() => Future<void>.delayed(Duration.zero);

class _MemoryReadStore implements BookingNotificationReadStore {
  Set<String> savedIds = <String>{};

  @override
  Future<Set<String>> loadReadIds() async => Set<String>.from(savedIds);

  @override
  Future<void> saveReadIds(Set<String> ids) async {
    savedIds = Set<String>.from(ids);
  }
}

class _FakeBrowserNotifications implements BrowserNotificationService {
  _FakeBrowserNotifications({
    this.supported = true,
    BrowserNotificationPermission? permission,
  }) : _permission = permission;

  final bool supported;
  final BrowserNotificationPermission? _permission;
  final List<String> shownCustomerNames = <String>[];

  @override
  bool get isSupported => supported;

  @override
  BrowserNotificationPermission get permission =>
      _permission ??
      (supported
          ? BrowserNotificationPermission.granted
          : BrowserNotificationPermission.unavailable);

  @override
  Future<BrowserNotificationPermission> requestPermission() async => permission;

  @override
  void showBookingNotification({
    required String customerName,
    required String serviceName,
    required String date,
    required String time,
  }) {
    if (permission == BrowserNotificationPermission.granted) {
      shownCustomerNames.add(customerName);
    }
  }
}
