import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hossy_barbers/app/theme/app_spacing.dart';
import 'package:hossy_barbers/features/admin/data/business_settings_repository.dart';
import 'package:hossy_barbers/features/admin/domain/business_settings.dart';
import 'package:hossy_barbers/features/admin/services/admin_image_picker.dart';
import 'package:hossy_barbers/features/gallery/services/cloudinary_upload_service.dart';

class BusinessProfileEditor extends StatefulWidget {
  const BusinessProfileEditor({
    super.key,
    required this.repository,
    required this.uploadService,
  });

  final BusinessSettingsRepository repository;
  final CloudinaryUploadService uploadService;

  @override
  State<BusinessProfileEditor> createState() => _BusinessProfileEditorState();
}

class _BusinessProfileEditorState extends State<BusinessProfileEditor> {
  final _formKey = GlobalKey<FormState>();
  final _businessName = TextEditingController();
  final _tagline = TextEditingController();
  final _description = TextEditingController();
  final _phone = TextEditingController();
  final _whatsApp = TextEditingController();
  final _address = TextEditingController();
  final _openingHours = TextEditingController();
  final _bookingHours = TextEditingController();
  final _socialLinks = TextEditingController();
  final _heroEyebrow = TextEditingController();
  final _heroHeadline = TextEditingController();
  final _heroDescription = TextEditingController();
  final _heroCtaText = TextEditingController();
  final _aboutHeading = TextEditingController();
  final _seoTitle = TextEditingController();
  final _seoDescription = TextEditingController();

  var _loaded = false;
  var _saving = false;
  BusinessSettings? _existing;
  _SelectedImage? _logoImage;
  _SelectedImage? _heroImage;
  var _removeLogo = false;
  var _removeHeroImage = false;

  @override
  void dispose() {
    for (final controller in [
      _businessName,
      _tagline,
      _description,
      _phone,
      _whatsApp,
      _address,
      _openingHours,
      _bookingHours,
      _socialLinks,
      _heroEyebrow,
      _heroHeadline,
      _heroDescription,
      _heroCtaText,
      _aboutHeading,
      _seoTitle,
      _seoDescription,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _load(BusinessSettings? settings) {
    if (_loaded) return;
    _loaded = true;
    final initialSettings = settings ?? BusinessSettings.initial;
    _existing = initialSettings;
    _businessName.text = initialSettings.businessName;
    _tagline.text = initialSettings.shortTagline;
    _description.text = initialSettings.description;
    _phone.text = initialSettings.phoneNumber;
    _whatsApp.text = initialSettings.whatsAppNumber;
    _address.text = initialSettings.address;
    _openingHours.text = _formatMap(initialSettings.openingHours);
    _bookingHours.text = _formatMap(initialSettings.bookingHours);
    _socialLinks.text = _formatMap(initialSettings.socialLinks);
    _heroEyebrow.text = initialSettings.heroEyebrow;
    _heroHeadline.text = initialSettings.heroHeadline;
    _heroDescription.text = initialSettings.heroDescription;
    _heroCtaText.text = initialSettings.heroCtaText;
    _aboutHeading.text = initialSettings.aboutHeading;
    _seoTitle.text = initialSettings.seoTitle;
    _seoDescription.text = initialSettings.seoDescription;
  }

  Future<void> _pickImage(bool isLogo) async {
    try {
      final image = await const AdminImagePicker().pick();
      if (image == null || !mounted) return;
      setState(() {
        if (isLogo) {
          _logoImage = _SelectedImage(image.name, image.bytes);
          _removeLogo = false;
        } else {
          _heroImage = _SelectedImage(image.name, image.bytes);
          _removeHeroImage = false;
        }
      });
    } catch (_) {
      if (mounted) {
        _showError('The image could not be selected. Please try again.');
      }
    }
  }

  Map<String, String> _parseMap(String value) => Map.fromEntries(
    value
        .split('\n')
        .map((line) => line.split(':'))
        .where((parts) => parts.length >= 2)
        .map(
          (parts) =>
              MapEntry(parts.first.trim(), parts.sublist(1).join(':').trim()),
        )
        .where((entry) => entry.key.isNotEmpty && entry.value.isNotEmpty),
  );

  String _formatMap(Map<String, String> value) =>
      value.entries.map((entry) => '${entry.key}: ${entry.value}').join('\n');

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final logoUrl = _removeLogo
          ? ''
          : _logoImage == null
          ? _existing?.logoUrl ?? ''
          : await widget.uploadService.uploadImage(
              bytes: _logoImage!.bytes,
              filename: _logoImage!.name,
              folder: 'hossy_barbers/branding',
            );
      final heroImageUrl = _removeHeroImage
          ? ''
          : _heroImage == null
          ? _existing?.heroImageUrl ?? ''
          : await widget.uploadService.uploadImage(
              bytes: _heroImage!.bytes,
              filename: _heroImage!.name,
              folder: 'hossy_barbers/branding',
            );
      await widget.repository.save(
        BusinessSettings(
          businessName: _businessName.text.trim(),
          shortTagline: _tagline.text.trim(),
          description: _description.text.trim(),
          phoneNumber: _phone.text.trim(),
          whatsAppNumber: _whatsApp.text.trim(),
          address: _address.text.trim(),
          openingHours: _parseMap(_openingHours.text),
          bookingHours: _parseMap(_bookingHours.text),
          socialLinks: _parseMap(_socialLinks.text),
          logoUrl: logoUrl,
          heroImageUrl: heroImageUrl,
          heroEyebrow: _heroEyebrow.text.trim(),
          heroHeadline: _heroHeadline.text.trim(),
          heroDescription: _heroDescription.text.trim(),
          heroCtaText: _heroCtaText.text.trim(),
          aboutHeading: _aboutHeading.text.trim(),
          seoTitle: _seoTitle.text.trim(),
          seoDescription: _seoDescription.text.trim(),
        ),
      );
      if (mounted) {
        setState(() {
          _existing = BusinessSettings(
            businessName: _businessName.text.trim(),
            shortTagline: _tagline.text.trim(),
            description: _description.text.trim(),
            phoneNumber: _phone.text.trim(),
            whatsAppNumber: _whatsApp.text.trim(),
            address: _address.text.trim(),
            openingHours: _parseMap(_openingHours.text),
            bookingHours: _parseMap(_bookingHours.text),
            socialLinks: _parseMap(_socialLinks.text),
            logoUrl: logoUrl,
            heroImageUrl: heroImageUrl,
            heroEyebrow: _heroEyebrow.text.trim(),
            heroHeadline: _heroHeadline.text.trim(),
            heroDescription: _heroDescription.text.trim(),
            heroCtaText: _heroCtaText.text.trim(),
            aboutHeading: _aboutHeading.text.trim(),
            seoTitle: _seoTitle.text.trim(),
            seoDescription: _seoDescription.text.trim(),
          );
          _logoImage = null;
          _heroImage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business settings saved.')),
        );
      }
    } on CloudinaryUploadException catch (error) {
      if (mounted) _showError(error.message);
    } catch (_) {
      if (mounted) _showError('Business settings could not be saved.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) => StreamBuilder<BusinessSettings?>(
    stream: widget.repository.watchMain(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return const Center(
          child: Text('Business settings could not be loaded.'),
        );
      }
      _load(snapshot.data);
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business Settings',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  const Text(
                    'Manage the public information, brand assets, and website copy from one place.',
                  ),
                  const SizedBox(height: AppSpacing.large),
                  _group(context, 'Business identity', [
                    _field(_businessName, 'Business name', required: true),
                    _field(_tagline, 'Short tagline'),
                    _field(_description, 'About description', lines: 4),
                    _field(_phone, 'Phone number'),
                    _field(_whatsApp, 'WhatsApp number'),
                    _field(_address, 'Address or location', lines: 2),
                  ]),
                  _group(context, 'Opening hours and social links', [
                    _field(
                      _openingHours,
                      'Opening hours (one “day: hours” entry per line)',
                      lines: 4,
                    ),
                    _field(
                      _bookingHours,
                      'Booking request hours (one “day: hours” entry per line)',
                      lines: 4,
                    ),
                    _field(
                      _socialLinks,
                      'Social links (one “platform: URL” entry per line)',
                      lines: 4,
                    ),
                  ]),
                  _group(context, 'Homepage hero', [
                    _field(_heroEyebrow, 'Hero eyebrow / business label'),
                    _field(_heroHeadline, 'Hero headline', lines: 2),
                    _field(
                      _heroDescription,
                      'Hero supporting description',
                      lines: 3,
                    ),
                    _field(_heroCtaText, 'Primary CTA text'),
                    _imageControl(
                      context: context,
                      label: 'Hero image',
                      selected: _heroImage,
                      savedUrl: _existing?.heroImageUrl ?? '',
                      remove: _removeHeroImage,
                      onPick: () => _pickImage(false),
                      onRemove: () => setState(() {
                        _heroImage = null;
                        _removeHeroImage = true;
                      }),
                    ),
                  ]),
                  _group(context, 'Branding and SEO', [
                    _imageControl(
                      context: context,
                      label: 'Business logo',
                      selected: _logoImage,
                      savedUrl: _existing?.logoUrl ?? '',
                      remove: _removeLogo,
                      onPick: () => _pickImage(true),
                      onRemove: () => setState(() {
                        _logoImage = null;
                        _removeLogo = true;
                      }),
                    ),
                    _field(_aboutHeading, 'About heading'),
                    _field(_seoTitle, 'Page title'),
                    _field(_seoDescription, 'Meta description', lines: 3),
                  ]),
                  const SizedBox(height: AppSpacing.small),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_saving ? 'Saving…' : 'Save changes'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  Widget _group(BuildContext context, String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.large),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.medium),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int lines = 1,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: TextFormField(
        controller: controller,
        minLines: lines,
        maxLines: lines,
        decoration: InputDecoration(labelText: label),
        validator: required
            ? (value) =>
                  value == null || value.trim().isEmpty ? 'Enter a value' : null
            : null,
      ),
    );
  }

  Widget _imageControl({
    required BuildContext context,
    required String label,
    required _SelectedImage? selected,
    required String savedUrl,
    required bool remove,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.small),
          if (!remove && (selected != null || savedUrl.isNotEmpty))
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: selected != null
                  ? Image.memory(
                      selected.bytes,
                      height: 140,
                      width: 220,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      savedUrl,
                      height: 140,
                      width: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox(
                        height: 80,
                        child: Center(child: Icon(Icons.broken_image_outlined)),
                      ),
                    ),
            ),
          const SizedBox(height: AppSpacing.small),
          Text(
            selected == null
                ? 'Choose a PNG, JPG, or WebP image. It uploads when you save changes.'
                : '${selected.name} is ready to upload when you save changes.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.small),
          Wrap(
            spacing: AppSpacing.small,
            children: [
              OutlinedButton.icon(
                onPressed: _saving ? null : onPick,
                icon: const Icon(Icons.upload_outlined),
                label: Text(
                  savedUrl.isEmpty && selected == null
                      ? 'Choose image'
                      : 'Choose replacement',
                ),
              ),
              if (selected != null || savedUrl.isNotEmpty)
                TextButton(
                  onPressed: _saving ? null : onRemove,
                  child: const Text('Remove'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectedImage {
  const _SelectedImage(this.name, this.bytes);

  final String name;
  final Uint8List bytes;
}
