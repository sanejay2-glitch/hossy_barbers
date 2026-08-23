enum BookingStatus { prepared, accepted, declined, cancelled, confirmed }

enum PaymentStatus { notRequired, pending, successful, failed, cancelled }

extension BookingStatusStorage on BookingStatus {
  String get value => switch (this) {
    BookingStatus.prepared => 'prepared',
    BookingStatus.accepted => 'accepted',
    BookingStatus.declined => 'declined',
    BookingStatus.cancelled => 'cancelled',
    BookingStatus.confirmed => 'confirmed',
  };

  static BookingStatus fromValue(String value) => switch (value) {
    'accepted' => BookingStatus.accepted,
    'declined' => BookingStatus.declined,
    'cancelled' => BookingStatus.cancelled,
    'confirmed' => BookingStatus.confirmed,
    _ => BookingStatus.prepared,
  };
}

extension PaymentStatusStorage on PaymentStatus {
  String get value => switch (this) {
    PaymentStatus.notRequired => 'not_required',
    PaymentStatus.pending => 'pending',
    PaymentStatus.successful => 'successful',
    PaymentStatus.failed => 'failed',
    PaymentStatus.cancelled => 'cancelled',
  };

  static PaymentStatus fromValue(String value) => switch (value) {
    'pending' => PaymentStatus.pending,
    'successful' => PaymentStatus.successful,
    'failed' => PaymentStatus.failed,
    'cancelled' => PaymentStatus.cancelled,
    _ => PaymentStatus.notRequired,
  };
}

String formatPaymentAmount(double? amount, String? currency) {
  if (amount == null || currency == null || currency.isEmpty) return '—';
  final wholeAmount = amount == amount.roundToDouble();
  final formatted = wholeAmount
      ? amount.toStringAsFixed(0)
      : amount.toStringAsFixed(2);
  final parts = formatted.split('.');
  final integer = parts.first;
  final groups = <String>[];
  for (var index = integer.length; index > 0; index -= 3) {
    groups.add(integer.substring(index > 3 ? index - 3 : 0, index));
  }
  final separator = groups.reversed.join(',');
  return '$currency $separator${parts.length == 2 ? '.${parts.last}' : ''}';
}
