import 'package:hossy_barbers/features/booking/domain/booking_request_record.dart';

class BookingNotification {
  const BookingNotification({required this.booking, required this.isRead});

  final BookingRequestRecord booking;
  final bool isRead;
}

class BookingNotificationsState {
  const BookingNotificationsState({
    this.notifications = const [],
    this.browserNotificationsSupported = false,
    this.browserPermission = BrowserNotificationPermission.unavailable,
  });

  final List<BookingNotification> notifications;
  final bool browserNotificationsSupported;
  final BrowserNotificationPermission browserPermission;

  int get unreadCount => notifications.where((item) => !item.isRead).length;
}

enum BrowserNotificationPermission {
  unavailable,
  defaultPermission,
  denied,
  granted,
}
