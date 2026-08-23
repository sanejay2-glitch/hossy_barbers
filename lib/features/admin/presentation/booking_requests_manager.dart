import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/features/booking/data/booking_requests_repository.dart';
import 'package:hossy_barbers/features/booking/domain/booking_payment.dart';
import 'package:hossy_barbers/features/booking/domain/booking_request_record.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingRequestsManager extends StatefulWidget {
  const BookingRequestsManager({super.key, required this.repository});

  final BookingRequestsRepository repository;

  @override
  State<BookingRequestsManager> createState() => _BookingRequestsManagerState();
}

class _BookingRequestsManagerState extends State<BookingRequestsManager> {
  final _processingBookings = <String>{};

  @override
  Widget build(
    BuildContext context,
  ) => StreamBuilder<List<BookingRequestRecord>>(
    stream: widget.repository.watchAll(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return const Center(
          child: Text('Booking requests could not be loaded.'),
        );
      }
      final requests = snapshot.data ?? const [];
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking requests',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.small),
                const Text(
                  'Review requests and contact the customer directly to confirm appointment and payment details.',
                ),
                const SizedBox(height: AppSpacing.large),
                if (requests.isEmpty)
                  const Text('No booking requests have been submitted yet.')
                else
                  ...requests.map(
                    (request) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.small),
                      child: _BookingRequestCard(
                        request: request,
                        processing: _processingBookings.contains(request.id),
                        onAccept: () => _runAction(
                          request,
                          () => widget.repository.markAccepted(request.id),
                          successMessage:
                              'Booking marked accepted. Contact the customer to confirm the remaining details.',
                        ),
                        onDecline: () => _runAction(
                          request,
                          () => widget.repository.decline(request.id),
                          successMessage: 'Booking request declined.',
                        ),
                        onCancel: () => _runAction(
                          request,
                          () => widget.repository.cancel(request.id),
                          successMessage: 'Booking request cancelled.',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );

  Future<void> _runAction(
    BookingRequestRecord request,
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    setState(() => _processingBookings.add(request.id));
    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMessage)));
      }
    } catch (_) {
      _showError('The booking request could not be updated.');
    } finally {
      if (mounted) setState(() => _processingBookings.remove(request.id));
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _BookingRequestCard extends StatelessWidget {
  const _BookingRequestCard({
    required this.request,
    required this.processing,
    required this.onAccept,
    required this.onDecline,
    required this.onCancel,
  });

  final BookingRequestRecord request;
  final bool processing;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.serviceName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              _BookingStatus(status: request.bookingState),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Text(request.customerName),
          Text(request.customerPhone),
          if (request.customerEmail.isNotEmpty) Text(request.customerEmail),
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            'Requested: ${request.preferredDate} • ${request.preferredTime}',
          ),
          if (request.createdAt != null)
            Text(
              'Submitted ${request.createdAt!.day}/${request.createdAt!.month}/${request.createdAt!.year}',
            ),
          if (request.referenceImageUrl.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.medium),
            Text(
              'CUSTOMER’S SELECTED REFERENCE STYLE',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: AppSpacing.xSmall),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              child: Image.network(
                request.referenceImageUrl,
                width: 260,
                height: 180,
                fit: BoxFit.cover,
                semanticLabel: request.referenceCaption.isEmpty
                    ? 'Customer selected reference style'
                    : request.referenceCaption,
                errorBuilder: (_, _, _) => Container(
                  width: 260,
                  height: 120,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: const Text('Reference image unavailable'),
                ),
              ),
            ),
            if (request.referenceCaption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xSmall),
                child: Text(request.referenceCaption),
              ),
          ],
          const SizedBox(height: AppSpacing.medium),
          Wrap(
            spacing: AppSpacing.small,
            runSpacing: AppSpacing.small,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => _call(context, request),
                icon: const Icon(Icons.call_outlined),
                label: const Text('Call'),
              ),
              OutlinedButton.icon(
                onPressed: () => _openWhatsApp(context, request),
                icon: const Icon(Icons.chat_outlined),
                label: const Text('WhatsApp'),
              ),
              if (request.bookingState == BookingStatus.prepared)
                FilledButton.icon(
                  onPressed: processing ? null : onAccept,
                  icon: processing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Mark accepted'),
                ),
              if (request.bookingState == BookingStatus.prepared)
                OutlinedButton(
                  onPressed: processing ? null : onDecline,
                  child: const Text('Decline'),
                ),
              if (request.bookingState == BookingStatus.accepted)
                OutlinedButton(
                  onPressed: processing ? null : onCancel,
                  child: const Text('Cancel booking'),
                ),
            ],
          ),
        ],
      ),
    ),
  );

  Future<void> _call(BuildContext context, BookingRequestRecord request) =>
      _launchContact(
        context,
        Uri(scheme: 'tel', path: request.customerPhone.trim()),
      );

  Future<void> _openWhatsApp(
    BuildContext context,
    BookingRequestRecord request,
  ) {
    final phoneNumber = request.customerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This request has no usable phone number.'),
        ),
      );
      return Future.value();
    }
    return _launchContact(context, Uri.https('wa.me', phoneNumber));
  }

  Future<void> _launchContact(BuildContext context, Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_blank',
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The contact action could not be opened.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The contact action could not be opened.'),
          ),
        );
      }
    }
  }
}

class _BookingStatus extends StatelessWidget {
  const _BookingStatus({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) => Chip(
    visualDensity: VisualDensity.compact,
    label: Text(_label(status).toUpperCase()),
    labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
    side: BorderSide(color: Theme.of(context).colorScheme.outline),
  );

  String _label(BookingStatus status) => switch (status) {
    BookingStatus.prepared => 'Pending review',
    BookingStatus.accepted => 'Accepted',
    BookingStatus.confirmed => 'Confirmed',
    BookingStatus.declined => 'Declined',
    BookingStatus.cancelled => 'Cancelled',
  };
}
