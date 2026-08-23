import 'dart:convert';
import 'package:web/web.dart' as web;

abstract class BookingNotificationReadStore {
  Future<Set<String>> loadReadIds();
  Future<void> saveReadIds(Set<String> ids);
}

BookingNotificationReadStore createBookingNotificationReadStore(
  String adminId,
) => _BrowserBookingNotificationReadStore(adminId);

class _BrowserBookingNotificationReadStore
    implements BookingNotificationReadStore {
  _BrowserBookingNotificationReadStore(this._adminId);

  static const _prefix = 'hossy_barbers.read_booking_notifications.';
  final String _adminId;

  String get _key => '$_prefix$_adminId';

  @override
  Future<Set<String>> loadReadIds() async {
    try {
      final stored = web.window.localStorage.getItem(_key);
      if (stored == null || stored.isEmpty) return <String>{};
      final decoded = jsonDecode(stored);
      if (decoded is! List) return <String>{};
      return decoded
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .take(500)
          .toSet();
    } catch (_) {
      return <String>{};
    }
  }

  @override
  Future<void> saveReadIds(Set<String> ids) async {
    try {
      final stored = ids.take(500).toList(growable: false);
      web.window.localStorage.setItem(_key, jsonEncode(stored));
    } catch (_) {}
  }
}
