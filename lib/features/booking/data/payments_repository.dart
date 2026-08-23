import 'package:cloud_functions/cloud_functions.dart';
import 'package:hossy_barbers/features/booking/domain/booking_payment.dart';

class PaymentsRepository {
  PaymentsRepository(this._functions);
  final FirebaseFunctions _functions;

  Future<BookingPaymentAcceptance> acceptBooking(String bookingId) async {
    final data = await _call('acceptBooking', {'bookingId': bookingId});
    return BookingPaymentAcceptance(
      paymentUrl: Uri.parse(data['paymentUrl'] as String),
      reference: data['paymentReference'] as String,
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] as String,
    );
  }

  Future<void> declineBooking(String bookingId) =>
      _call('declineBooking', {'bookingId': bookingId});

  Future<void> cancelAcceptedBooking(String bookingId) =>
      _call('cancelAcceptedBooking', {'bookingId': bookingId});

  Future<PublicPaymentDetails> getPaymentDetails(String paymentToken) async =>
      PublicPaymentDetails.fromMap(
        await _call('getPaymentDetails', {'paymentToken': paymentToken}),
      );

  Future<PublicPaymentDetails> verifyPayment(String paymentToken) async =>
      PublicPaymentDetails.fromMap(
        await _call('verifyFlutterwavePayment', {'paymentToken': paymentToken}),
      );

  Future<Map<String, dynamic>> _call(
    String functionName,
    Map<String, Object> arguments,
  ) async {
    try {
      final result = await _functions
          .httpsCallable(functionName)
          .call<Map<Object?, Object?>>(arguments);
      return Map<String, dynamic>.from(result.data);
    } on FirebaseFunctionsException catch (error) {
      throw PaymentException(
        error.message ?? 'The payment request could not be completed.',
      );
    }
  }
}

class BookingPaymentAcceptance {
  const BookingPaymentAcceptance({
    required this.paymentUrl,
    required this.reference,
    required this.amount,
    required this.currency,
  });

  final Uri paymentUrl;
  final String reference;
  final double amount;
  final String currency;
}

class PublicPaymentDetails {
  const PublicPaymentDetails({
    required this.bookingId,
    required this.serviceName,
    required this.preferredDate,
    required this.preferredTime,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.amount,
    required this.currency,
    required this.reference,
    required this.failureReason,
  });

  final String bookingId;
  final String serviceName;
  final String preferredDate;
  final String preferredTime;
  final BookingStatus bookingStatus;
  final PaymentStatus paymentStatus;
  final double? amount;
  final String? currency;
  final String? reference;
  final String? failureReason;

  factory PublicPaymentDetails.fromMap(Map<String, dynamic> data) =>
      PublicPaymentDetails(
        bookingId: data['bookingId'] as String? ?? '',
        serviceName: data['serviceName'] as String? ?? '',
        preferredDate: data['preferredDate'] as String? ?? '',
        preferredTime: data['preferredTime'] as String? ?? '',
        bookingStatus: BookingStatusStorage.fromValue(
          data['bookingStatus'] as String? ?? '',
        ),
        paymentStatus: PaymentStatusStorage.fromValue(
          data['paymentStatus'] as String? ?? '',
        ),
        amount: (data['amount'] as num?)?.toDouble(),
        currency: data['currency'] as String?,
        reference: data['reference'] as String?,
        failureReason: data['failureReason'] as String?,
      );
}

class PaymentException implements Exception {
  const PaymentException(this.message);
  final String message;

  @override
  String toString() => message;
}
