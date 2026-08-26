import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/features/admin/data/business_settings_repository.dart';
import 'package:hossy_barbers/features/admin/domain/business_settings.dart';
import 'package:hossy_barbers/features/booking/data/booking_requests_repository.dart';
import 'package:hossy_barbers/features/booking/domain/booking_request.dart';
import 'package:hossy_barbers/features/booking/services/booking_time_slots.dart';
import 'package:hossy_barbers/features/gallery/data/gallery_repository.dart';
import 'package:hossy_barbers/features/gallery/domain/gallery_item.dart';
import 'package:hossy_barbers/features/services/data/development_services.dart';
import 'package:hossy_barbers/features/services/data/services_repository.dart';
import 'package:hossy_barbers/features/services/domain/service.dart';
import 'package:hossy_barbers/shared/widgets/page_container.dart';
import 'package:hossy_barbers/shared/widgets/section_heading.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({
    super.key,
    this.servicesRepository,
    this.galleryRepository,
    this.bookingRequestsRepository,
    this.businessSettingsRepository,
  });

  static const routeName = '/booking';

  final ServicesRepository? servicesRepository;
  final GalleryRepository? galleryRepository;
  final BookingRequestsRepository? bookingRequestsRepository;
  final BusinessSettingsRepository? businessSettingsRepository;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  Service? _service;
  GalleryItem? _referenceStyle;
  DateTime? _date;
  String? _time;
  var _reviewing = false;
  var _submitting = false;
  var _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    Map<String, String> bookingHours,
    Service? service,
  ) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final lastDate = today.add(const Duration(days: 365));
    final firstAvailableDate = _firstOpenDate(
      firstDate: today,
      lastDate: lastDate,
      bookingHours: bookingHours,
      service: service,
    );
    if (firstAvailableDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No appointment dates are available right now.'),
        ),
      );
      return;
    }
    final picked = await showDatePicker(
      context: context,
      firstDate: today,
      lastDate: lastDate,
      initialDate:
          _date != null &&
              BookingTimeSlots.forAppointment(
                date: _date!,
                openingHours: bookingHours,
                service: service,
              ).isNotEmpty
          ? _date
          : firstAvailableDate,
      selectableDayPredicate: (date) => BookingTimeSlots.forAppointment(
        date: date,
        openingHours: bookingHours,
        service: service,
      ).isNotEmpty,
    );
    if (picked != null && mounted) {
      setState(() {
        _date = picked;
        _time = null;
      });
    }
  }

  DateTime? _firstOpenDate({
    required DateTime firstDate,
    required DateTime lastDate,
    required Map<String, String> bookingHours,
    required Service? service,
  }) {
    for (
      var date = firstDate;
      !date.isAfter(lastDate);
      date = date.add(const Duration(days: 1))
    ) {
      if (BookingTimeSlots.forAppointment(
        date: date,
        openingHours: bookingHours,
        service: service,
      ).isNotEmpty) {
        return date;
      }
    }
    return null;
  }

  void _review() {
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
    setState(() => _reviewing = true);
  }

  BookingRequest get _request => BookingRequest(
    customerName: _nameController.text.trim(),
    customerPhone: _phoneController.text.trim(),
    customerEmail: _emailController.text.trim(),
    service: _service!,
    preferredDate: _date!,
    preferredTime: _time!,
    referenceGalleryItemId: _referenceStyle?.id,
    referenceImageUrl: _referenceStyle?.imageUrl,
    referenceCaption: _referenceStyle?.caption,
  );

  Future<void> _submit() async {
    final repository = widget.bookingRequestsRepository;
    if (repository == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking requests are unavailable right now.'),
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await repository.submit(_request);
      if (mounted) {
        setState(() {
          _submitted = true;
          _reviewing = false;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your request could not be sent. Please check your connection and try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _startAnotherRequest() {
    setState(() {
      _submitted = false;
      _reviewing = false;
      _service = null;
      _referenceStyle = null;
      _date = null;
      _time = null;
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
    });
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
          constraints: const BoxConstraints(maxWidth: 760),
          child: _submitted
              ? _BookingConfirmation(onStartAnother: _startAnotherRequest)
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeading(
                        eyebrow: 'Booking request',
                        title: 'Choose what works for you.',
                        description:
                            'Send a booking request directly to Hossy Barbers. Your appointment is only confirmed when the barber contacts you.',
                      ),
                      const SizedBox(height: AppSpacing.large),
                      if (_reviewing)
                        _BookingReview(request: _request)
                      else
                        _BookingForm(
                          nameController: _nameController,
                          phoneController: _phoneController,
                          emailController: _emailController,
                          servicesRepository: widget.servicesRepository,
                          galleryRepository: widget.galleryRepository,
                          businessSettingsRepository:
                              widget.businessSettingsRepository,
                          selectedServiceId: _service?.id,
                          selectedReferenceId: _referenceStyle?.id,
                          date: _date,
                          time: _time,
                          onServiceChanged: (service) => setState(() {
                            _service = service;
                            _time = null;
                          }),
                          onReferenceChanged: (item) =>
                              setState(() => _referenceStyle = item),
                          onDatePressed: _pickDate,
                          onTimeChanged: (value) =>
                              setState(() => _time = value),
                        ),
                      const SizedBox(height: AppSpacing.large),
                      if (_reviewing)
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: _submitting
                                  ? null
                                  : () => setState(() => _reviewing = false),
                              child: const Text('Edit request'),
                            ),
                            const SizedBox(width: AppSpacing.small),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _submitting ? null : _submit,
                                icon: _submitting
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.send_outlined),
                                label: Text(
                                  _submitting
                                      ? 'Sending request…'
                                      : 'Send booking request',
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        FilledButton(
                          onPressed: _review,
                          child: const Text('Review booking request'),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    ),
  );
}

class _BookingForm extends StatelessWidget {
  const _BookingForm({
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.servicesRepository,
    required this.galleryRepository,
    required this.businessSettingsRepository,
    required this.selectedServiceId,
    required this.selectedReferenceId,
    required this.date,
    required this.time,
    required this.onServiceChanged,
    required this.onReferenceChanged,
    required this.onDatePressed,
    required this.onTimeChanged,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final ServicesRepository? servicesRepository;
  final GalleryRepository? galleryRepository;
  final BusinessSettingsRepository? businessSettingsRepository;
  final String? selectedServiceId;
  final String? selectedReferenceId;
  final DateTime? date;
  final String? time;
  final ValueChanged<Service?> onServiceChanged;
  final ValueChanged<GalleryItem?> onReferenceChanged;
  final Future<void> Function(
    Map<String, String> bookingHours,
    Service? service,
  )
  onDatePressed;
  final ValueChanged<String?> onTimeChanged;

  @override
  Widget build(BuildContext context) => StreamBuilder<BusinessSettings?>(
    stream: businessSettingsRepository?.watchMain(),
    builder: (context, settingsSnapshot) {
      final bookingHours =
          settingsSnapshot.data?.bookingHours.isNotEmpty == true
          ? settingsSnapshot.data!.bookingHours
          : BusinessSettings.initial.bookingHours;
      return StreamBuilder<List<Service>>(
        stream: servicesRepository?.watchPublished(),
        builder: (context, servicesSnapshot) {
          final services = servicesRepository == null
              ? developmentServices
              : servicesSnapshot.data ?? const <Service>[];
          Service? selectedService;
          for (final service in services) {
            if (service.id == selectedServiceId) {
              selectedService = service;
              break;
            }
          }
          final slots = date == null
              ? const <String>[]
              : BookingTimeSlots.forAppointment(
                  date: date!,
                  openingHours: bookingHours,
                  service: selectedService,
                );
          return StreamBuilder<List<GalleryItem>>(
            stream: galleryRepository?.watchPublished(),
            builder: (context, gallerySnapshot) => Column(
              children: [
                TextFormField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Your name'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter your name'
                      : null,
                ),
                const SizedBox(height: AppSpacing.medium),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Phone or WhatsApp number',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a phone number'
                      : null,
                ),
                const SizedBox(height: AppSpacing.medium),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    helperText: 'Used only for booking updates.',
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    return email.contains('@') && email.contains('.')
                        ? null
                        : 'Enter a valid email address';
                  },
                ),
                const SizedBox(height: AppSpacing.medium),
                DropdownButtonFormField<String>(
                  initialValue:
                      services.any((item) => item.id == selectedServiceId)
                      ? selectedServiceId
                      : null,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Preferred service',
                  ),
                  items: services
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  onChanged: (serviceId) => onServiceChanged(
                    serviceId == null
                        ? null
                        : services.firstWhere((item) => item.id == serviceId),
                  ),
                  validator: (value) =>
                      value == null ? 'Select a service' : null,
                ),
                if (servicesRepository != null && services.isEmpty) ...[
                  const SizedBox(height: AppSpacing.xSmall),
                  Text(
                    servicesSnapshot.hasError
                        ? 'Services are unavailable right now. Please try again later.'
                        : 'There are no bookable services available right now.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.medium),
                OutlinedButton.icon(
                  onPressed: () => onDatePressed(bookingHours, selectedService),
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(
                    date == null
                        ? 'Choose preferred date'
                        : '${date!.day}/${date!.month}/${date!.year}',
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                DropdownButtonFormField<String>(
                  initialValue: slots.contains(time) ? time : null,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Preferred time',
                    helperText: date == null
                        ? 'Choose a date to see available appointment times.'
                        : 'Times follow the selected service and booking hours.',
                  ),
                  items: slots
                      .map(
                        (slot) =>
                            DropdownMenuItem(value: slot, child: Text(slot)),
                      )
                      .toList(),
                  onChanged: slots.isEmpty ? null : onTimeChanged,
                  validator: (value) {
                    if (date == null) return 'Choose a preferred date';
                    if (slots.isEmpty) {
                      return 'No appointment times are available';
                    }
                    return value == null ? 'Select a preferred time' : null;
                  },
                ),
                const SizedBox(height: AppSpacing.large),
                _ReferenceStylePicker(
                  items: gallerySnapshot.data ?? const [],
                  selectedReferenceId: selectedReferenceId,
                  onChanged: onReferenceChanged,
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _ReferenceStylePicker extends StatelessWidget {
  const _ReferenceStylePicker({
    required this.items,
    required this.selectedReferenceId,
    required this.onChanged,
  });

  final List<GalleryItem> items;
  final String? selectedReferenceId;
  final ValueChanged<GalleryItem?> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Reference style', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: AppSpacing.xSmall),
      const Text(
        'Optional — choose a style from our gallery to show the barber what you have in mind.',
      ),
      const SizedBox(height: AppSpacing.medium),
      if (items.isEmpty)
        const _ReferenceGalleryEmpty()
      else
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 640 ? 4 : 2;
            final tileWidth =
                (constraints.maxWidth - (columns - 1) * AppSpacing.small) /
                columns;
            return Wrap(
              spacing: AppSpacing.small,
              runSpacing: AppSpacing.small,
              children: items
                  .map(
                    (item) => _ReferenceStyleTile(
                      item: item,
                      width: tileWidth,
                      selected: item.id == selectedReferenceId,
                      onTap: () => onChanged(item),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      if (selectedReferenceId != null) ...[
        const SizedBox(height: AppSpacing.small),
        TextButton.icon(
          onPressed: () => onChanged(null),
          icon: const Icon(Icons.close_rounded),
          label: const Text('Clear selected reference'),
        ),
      ],
    ],
  );
}

class _ReferenceGalleryEmpty extends StatelessWidget {
  const _ReferenceGalleryEmpty();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.medium),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
    ),
    child: const Text('No reference styles are available right now.'),
  );
}

class _ReferenceStyleTile extends StatelessWidget {
  const _ReferenceStyleTile({
    required this.item,
    required this.width,
    required this.selected,
    required this.onTap,
  });

  final GalleryItem item;
  final double width;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: item.caption.isEmpty
        ? 'Select reference style'
        : 'Select reference style: ${item.caption}',
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: .7),
            width: selected ? 3 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall - 2),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                semanticLabel: item.caption.isEmpty
                    ? 'Hossy Barbers gallery style'
                    : item.caption,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Center(child: Icon(Icons.broken_image_outlined)),
                ),
              ),
              if (selected)
                ColoredBox(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: .34),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (item.caption.isNotEmpty)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    width: double.infinity,
                    color: Colors.black.withValues(alpha: .6),
                    padding: const EdgeInsets.all(AppSpacing.xSmall),
                    child: Text(
                      item.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _BookingReview extends StatelessWidget {
  const _BookingReview({required this.request});
  final BookingRequest request;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review your request',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.medium),
          Text(
            'Name: ${request.customerName}\nPhone: ${request.customerPhone}\nEmail: ${request.customerEmail}\nService: ${request.service.name}\nDate: ${request.preferredDate.day}/${request.preferredDate.month}/${request.preferredDate.year}\nTime: ${request.preferredTime}',
          ),
          if (request.referenceImageUrl?.isNotEmpty == true) ...[
            const SizedBox(height: AppSpacing.medium),
            const Text(
              'Selected reference style',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.xSmall),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              child: Image.network(
                request.referenceImageUrl!,
                height: 180,
                width: 220,
                fit: BoxFit.cover,
              ),
            ),
            if (request.referenceCaption?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xSmall),
                child: Text(request.referenceCaption!),
              ),
          ],
          const SizedBox(height: AppSpacing.medium),
          const Text(
            'Submitting this request does not confirm an appointment. Hossy Barbers will contact you to confirm availability.',
          ),
        ],
      ),
    ),
  );
}

class _BookingConfirmation extends StatelessWidget {
  const _BookingConfirmation({required this.onStartAnother});
  final VoidCallback onStartAnother;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.xLarge),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      border: Border.all(color: Theme.of(context).colorScheme.primary),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 44,
        ),
        const SizedBox(height: AppSpacing.medium),
        Text(
          'Request received',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.small),
        const Text(
          'Request received — Hossy Barbers will contact you to confirm your appointment and payment.',
        ),
        const SizedBox(height: AppSpacing.large),
        OutlinedButton(
          onPressed: onStartAnother,
          child: const Text('Send another request'),
        ),
      ],
    ),
  );
}
