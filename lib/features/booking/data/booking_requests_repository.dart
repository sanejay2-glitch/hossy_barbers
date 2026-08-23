import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hossy_barbers/features/booking/domain/booking_request.dart';
import 'package:hossy_barbers/features/booking/domain/booking_payment.dart';
import 'package:hossy_barbers/features/booking/domain/booking_request_record.dart';

class BookingRequestsRepository {
  BookingRequestsRepository(this._firestore);
  final FirebaseFirestore _firestore;

  Stream<List<BookingRequestRecord>> watchAll() =>
      _firestore.collection('bookings').snapshots().map((snapshot) {
        final requests =
            snapshot.docs
                .map(
                  (document) => BookingRequestRecord.fromMap(
                    document.id,
                    document.data(),
                  ),
                )
                .toList()
              ..sort(
                (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
                  a.createdAt ?? DateTime(0),
                ),
              );
        return requests;
      });

  Future<void> submit(BookingRequest request) async {
    await _firestore
        .collection('bookings')
        .add(BookingRequestRecord.toCreateMap(request))
        .timeout(const Duration(seconds: 20));
  }

  Future<void> markAccepted(String bookingId) =>
      _updateAdminStatus(bookingId, BookingStatus.accepted);

  Future<void> decline(String bookingId) =>
      _updateAdminStatus(bookingId, BookingStatus.declined);

  Future<void> cancel(String bookingId) =>
      _updateAdminStatus(bookingId, BookingStatus.cancelled);

  Future<void> _updateAdminStatus(
    String bookingId,
    BookingStatus nextStatus,
  ) async {
    final reference = _firestore.collection('bookings').doc(bookingId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(reference);
      if (!snapshot.exists) {
        throw StateError('This booking request is no longer available.');
      }
      final currentStatus = snapshot.get('status') as String? ?? 'prepared';
      final paymentStatus = snapshot.get('paymentStatus') as String? ?? '';
      final allowed = switch ((currentStatus, paymentStatus, nextStatus)) {
        ('prepared', 'not_required', BookingStatus.accepted) => true,
        ('prepared', 'not_required', BookingStatus.declined) => true,
        ('prepared', 'not_required', BookingStatus.cancelled) => true,
        ('accepted', 'not_required', BookingStatus.cancelled) => true,
        _ => false,
      };
      if (!allowed) {
        throw StateError('This booking request cannot be updated.');
      }
      transaction.update(reference, {
        'status': nextStatus.value,
        'adminUpdatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
