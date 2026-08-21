import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/features/booking/domain/booking_request.dart';
import 'package:hossy_barbers/features/booking/services/whatsapp_booking_service.dart';
import 'package:hossy_barbers/features/services/data/development_services.dart';
import 'package:hossy_barbers/features/services/domain/service.dart';
import 'package:hossy_barbers/shared/widgets/page_container.dart';
import 'package:hossy_barbers/shared/widgets/section_heading.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  static const routeName = '/booking';

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _whatsApp = const WhatsAppBookingService();
  Service? _service;
  DateTime? _date;
  String? _time;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      initialDate: _date ?? today,
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _continue() {
    if (!_formKey.currentState!.validate() ||
        _service == null ||
        _date == null ||
        _time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your booking preferences.'),
        ),
      );
      return;
    }
    final request = BookingRequest(
      customerName: _nameController.text.trim(),
      service: _service!,
      preferredDate: _date!,
      preferredTime: _time!,
    );
    final link = _whatsApp.createBookingUri(request);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('WhatsApp handoff ready'),
        content: Text(
          link == null
              ? 'The business WhatsApp number has not been configured yet. Your request details are ready for the future WhatsApp handoff.'
              : 'A WhatsApp booking link has been prepared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Book an appointment')),
    body: SingleChildScrollView(
      child: PageContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: AppSpacing.xLarge,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading(
                  eyebrow: 'Booking request',
                  title: 'Choose what works for you.',
                  description:
                      'This request will be prepared for WhatsApp. Availability is confirmed directly by Hossy Barbers.',
                ),
                const SizedBox(height: AppSpacing.large),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Your name'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter your name'
                      : null,
                ),
                const SizedBox(height: AppSpacing.medium),
                DropdownButtonFormField<Service>(
                  initialValue: _service,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Preferred service',
                  ),
                  items: developmentServices
                      .map(
                        (service) => DropdownMenuItem(
                          value: service,
                          child: Text(service.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _service = value),
                  validator: (value) =>
                      value == null ? 'Select a service' : null,
                ),
                const SizedBox(height: AppSpacing.medium),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(
                    _date == null
                        ? 'Choose preferred date'
                        : '${_date!.day}/${_date!.month}/${_date!.year}',
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                DropdownButtonFormField<String>(
                  initialValue: _time,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Preferred time',
                  ),
                  items:
                      const [
                            'Morning (time to confirm)',
                            'Afternoon (time to confirm)',
                            'Evening (time to confirm)',
                          ]
                          .map(
                            (time) => DropdownMenuItem(
                              value: time,
                              child: Text(time),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setState(() => _time = value),
                  validator: (value) =>
                      value == null ? 'Select a preferred time' : null,
                ),
                const SizedBox(height: AppSpacing.large),
                FilledButton.icon(
                  onPressed: _continue,
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('Continue to WhatsApp'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
