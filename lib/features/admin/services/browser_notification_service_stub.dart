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
    _UnsupportedBrowserNotificationService();

class _UnsupportedBrowserNotificationService
    implements BrowserNotificationService {
  @override
  bool get isSupported => false;

  @override
  BrowserNotificationPermission get permission =>
      BrowserNotificationPermission.unavailable;

  @override
  Future<BrowserNotificationPermission> requestPermission() async => permission;

  @override
  void showBookingNotification({
    required String customerName,
    required String serviceName,
    required String date,
    required String time,
  }) {}
}
