import 'package:hossy_barbers/core/constants/development_content.dart';

class BusinessSettings {
  const BusinessSettings({
    required this.businessName,
    required this.shortTagline,
    required this.description,
    required this.phoneNumber,
    required this.whatsAppNumber,
    required this.address,
    required this.openingHours,
    required this.bookingHours,
    required this.socialLinks,
    required this.logoUrl,
    required this.heroImageUrl,
    required this.heroEyebrow,
    required this.heroHeadline,
    required this.heroDescription,
    required this.heroCtaText,
    required this.aboutHeading,
    required this.seoTitle,
    required this.seoDescription,
  });

  final String businessName;
  final String shortTagline;
  final String description;
  final String phoneNumber;
  final String whatsAppNumber;
  final String address;
  final Map<String, String> openingHours;
  final Map<String, String> bookingHours;
  final Map<String, String> socialLinks;
  final String logoUrl;
  final String heroImageUrl;
  final String heroEyebrow;
  final String heroHeadline;
  final String heroDescription;
  final String heroCtaText;
  final String aboutHeading;
  final String seoTitle;
  final String seoDescription;

  static const initial = BusinessSettings(
    businessName: DevelopmentContent.businessName,
    shortTagline: DevelopmentContent.officialTagline,
    description: DevelopmentContent.aboutDescription,
    phoneNumber: DevelopmentContent.publicPhoneNumber,
    whatsAppNumber: DevelopmentContent.whatsappNumber,
    address: DevelopmentContent.businessAddress,
    openingHours: DevelopmentContent.openingHours,
    bookingHours: DevelopmentContent.bookingHours,
    socialLinks: {},
    logoUrl: '',
    heroImageUrl: '',
    heroEyebrow: 'Barber shop · Benin City',
    heroHeadline: 'Your beauty,\nour concern.',
    heroDescription: DevelopmentContent.heroDescription,
    heroCtaText: '',
    aboutHeading: 'Grooming with care and attention to detail.',
    seoTitle: DevelopmentContent.seoTitle,
    seoDescription: DevelopmentContent.seoDescription,
  );

  factory BusinessSettings.fromMap(Map<String, dynamic> data) {
    final openingHours = _stringMap(data['openingHours']);
    final bookingHours = _stringMap(data['bookingHours']);
    return BusinessSettings(
      businessName: _valueOrDefault(data, 'businessName', initial.businessName),
      shortTagline: _valueOrDefault(data, 'shortTagline', initial.shortTagline),
      description: _valueOrDefault(data, 'description', initial.description),
      phoneNumber: _valueOrDefault(data, 'phoneNumber', initial.phoneNumber),
      whatsAppNumber: _valueOrDefault(
        data,
        'whatsAppNumber',
        initial.whatsAppNumber,
      ),
      address: _valueOrDefault(data, 'address', initial.address),
      openingHours: openingHours.isEmpty ? initial.openingHours : openingHours,
      bookingHours: bookingHours.isEmpty ? initial.bookingHours : bookingHours,
      socialLinks: _stringMap(data['socialLinks']),
      logoUrl: data['logoUrl'] as String? ?? '',
      heroImageUrl: data['heroImageUrl'] as String? ?? '',
      heroEyebrow: _valueOrDefault(data, 'heroEyebrow', initial.heroEyebrow),
      heroHeadline: _valueOrDefault(data, 'heroHeadline', initial.heroHeadline),
      heroDescription: _valueOrDefault(
        data,
        'heroDescription',
        initial.heroDescription,
      ),
      heroCtaText: data['heroCtaText'] as String? ?? '',
      aboutHeading: _valueOrDefault(data, 'aboutHeading', initial.aboutHeading),
      seoTitle: _valueOrDefault(data, 'seoTitle', initial.seoTitle),
      seoDescription: _valueOrDefault(
        data,
        'seoDescription',
        initial.seoDescription,
      ),
    );
  }

  Map<String, Object> toMap() => {
    'businessName': businessName,
    'shortTagline': shortTagline,
    'description': description,
    'phoneNumber': phoneNumber,
    'whatsAppNumber': whatsAppNumber,
    'address': address,
    'openingHours': openingHours,
    'bookingHours': bookingHours,
    'socialLinks': socialLinks,
    'logoUrl': logoUrl,
    'heroImageUrl': heroImageUrl,
    'heroEyebrow': heroEyebrow,
    'heroHeadline': heroHeadline,
    'heroDescription': heroDescription,
    'heroCtaText': heroCtaText,
    'aboutHeading': aboutHeading,
    'seoTitle': seoTitle,
    'seoDescription': seoDescription,
  };

  static Map<String, String> _stringMap(Object? value) {
    if (value is! Map) return const {};
    return Map<String, String>.fromEntries(
      value.entries
          .where((entry) => entry.key is String && entry.value is String)
          .map((entry) => MapEntry(entry.key as String, entry.value as String)),
    );
  }

  static String _valueOrDefault(
    Map<String, dynamic> data,
    String key,
    String fallback,
  ) {
    final value = data[key] as String?;
    return value?.trim().isNotEmpty == true ? value! : fallback;
  }
}
