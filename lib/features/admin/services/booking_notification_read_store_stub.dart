abstract class BookingNotificationReadStore {
  Future<Set<String>> loadReadIds();
  Future<void> saveReadIds(Set<String> ids);
}

BookingNotificationReadStore createBookingNotificationReadStore(
  String adminId,
) => _MemoryBookingNotificationReadStore();

class _MemoryBookingNotificationReadStore
    implements BookingNotificationReadStore {
  Set<String> _readIds = <String>{};

  @override
  Future<Set<String>> loadReadIds() async => Set<String>.from(_readIds);

  @override
  Future<void> saveReadIds(Set<String> ids) async {
    _readIds = Set<String>.from(ids);
  }
}
