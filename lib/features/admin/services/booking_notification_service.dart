import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hossy_barbers/features/admin/domain/booking_notification.dart';
import 'package:hossy_barbers/features/admin/services/booking_notification_read_store.dart';
import 'package:hossy_barbers/features/admin/services/browser_notification_service.dart';
import 'package:hossy_barbers/features/booking/data/booking_requests_repository.dart';
import 'package:hossy_barbers/features/booking/domain/booking_request_record.dart';

class BookingNotificationService {
  factory BookingNotificationService({
    BookingRequestsRepository? bookingRequestsRepository,
    Stream<List<BookingRequestRecord>> Function()? watchBookings,
    required BookingNotificationReadStore readStore,
    BrowserNotificationService? browserNotificationService,
  }) {
    assert(bookingRequestsRepository != null || watchBookings != null);
    final browser =
        browserNotificationService ?? createBrowserNotificationService();
    return BookingNotificationService._(
      watchBookings: watchBookings ?? bookingRequestsRepository!.watchAll,
      readStore: readStore,
      browserNotificationService: browser,
    );
  }

  BookingNotificationService._({
    required Stream<List<BookingRequestRecord>> Function() watchBookings,
    required BookingNotificationReadStore readStore,
    required BrowserNotificationService browserNotificationService,
  }) : _watchBookings = watchBookings,
       _readStore = readStore,
       _browserNotificationService = browserNotificationService,
       state = ValueNotifier(
         BookingNotificationsState(
           browserNotificationsSupported:
               browserNotificationService.isSupported,
           browserPermission: browserNotificationService.permission,
         ),
       );

  final Stream<List<BookingRequestRecord>> Function() _watchBookings;
  final BookingNotificationReadStore _readStore;
  final BrowserNotificationService _browserNotificationService;
  final ValueNotifier<BookingNotificationsState> state;
  final StreamController<BookingRequestRecord> _newBookings =
      StreamController<BookingRequestRecord>.broadcast();
  final Set<String> _readIds = <String>{};
  final Map<String, BookingRequestRecord> _bookings =
      <String, BookingRequestRecord>{};

  StreamSubscription<List<BookingRequestRecord>>? _subscription;
  var _hasReceivedInitialSnapshot = false;

  Stream<BookingRequestRecord> get newBookings => _newBookings.stream;

  Future<void> start() async {
    _readIds.addAll(await _readStore.loadReadIds());
    _subscription = _watchBookings().listen(_onBookings, onError: (_) {});
    _publishState();
  }

  Future<void> markRead(String bookingId) async {
    _readIds.add(bookingId);
    await _readStore.saveReadIds(_readIds);
    _publishState();
  }

  Future<void> markAllRead() async {
    _readIds.addAll(_bookings.keys);
    await _readStore.saveReadIds(_readIds);
    _publishState();
  }

  Future<BrowserNotificationPermission> requestBrowserNotifications() async {
    final permission = await _browserNotificationService.requestPermission();
    _publishState();
    return permission;
  }

  void _onBookings(List<BookingRequestRecord> bookings) {
    final newBookings = <BookingRequestRecord>[];
    for (final booking in bookings) {
      final wasKnown = _bookings.containsKey(booking.id);
      _bookings[booking.id] = booking;
      if (_hasReceivedInitialSnapshot &&
          !wasKnown &&
          booking.status == 'prepared') {
        newBookings.add(booking);
      }
    }
    _hasReceivedInitialSnapshot = true;
    _publishState();

    for (final booking in newBookings) {
      _newBookings.add(booking);
      _browserNotificationService.showBookingNotification(
        customerName: booking.customerName,
        serviceName: booking.serviceName,
        date: booking.preferredDate,
        time: booking.preferredTime,
      );
    }
  }

  void _publishState() {
    final notifications =
        _bookings.values
            .map(
              (booking) => BookingNotification(
                booking: booking,
                isRead: _readIds.contains(booking.id),
              ),
            )
            .toList()
          ..sort(
            (first, second) => (second.booking.createdAt ?? DateTime(0))
                .compareTo(first.booking.createdAt ?? DateTime(0)),
          );
    state.value = BookingNotificationsState(
      notifications: notifications,
      browserNotificationsSupported: _browserNotificationService.isSupported,
      browserPermission: _browserNotificationService.permission,
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _newBookings.close();
    state.dispose();
  }
}
