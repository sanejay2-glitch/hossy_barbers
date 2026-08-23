import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'package:hossy_barbers/features/admin/domain/booking_notification.dart';

abstract class BrowserNotificationService {
  bool get isSupported;
  BrowserNotificationPermission get permission;
  Future<BrowserNotificationPermission> requestPermission();
  void showBookingNotification({
    required String customerName,
    required String serviceName,
    required String date,
    required String time,
  });
}

BrowserNotificationService createBrowserNotificationService() =>
    _WebBrowserNotificationService();

class _WebBrowserNotificationService implements BrowserNotificationService {
  @override
  bool get isSupported {
    try {
      return web.Notification.permission.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  BrowserNotificationPermission get permission => isSupported
      ? _permissionFromValue(web.Notification.permission)
      : BrowserNotificationPermission.unavailable;

  @override
  Future<BrowserNotificationPermission> requestPermission() async {
    if (!isSupported) return BrowserNotificationPermission.unavailable;
    final value = await web.Notification.requestPermission().toDart;
    return _permissionFromValue(value.toDart);
  }

  @override
  void showBookingNotification({
    required String customerName,
    required String serviceName,
    required String date,
    required String time,
  }) {
    if (permission != BrowserNotificationPermission.granted) return;
    web.Notification(
      'New booking request',
      web.NotificationOptions(
        body: '$customerName • $serviceName\n$date • $time',
        tag: 'hossy-booking-$date-$time-$customerName',
      ),
    );
  }

  BrowserNotificationPermission _permissionFromValue(String value) =>
      switch (value) {
        'granted' => BrowserNotificationPermission.granted,
        'denied' => BrowserNotificationPermission.denied,
        _ => BrowserNotificationPermission.defaultPermission,
      };
}
